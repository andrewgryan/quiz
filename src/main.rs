#[macro_use]
extern crate rocket;

use rocket::fs::FileServer;
use rocket::serde::json::Json;
use rocket::serde::{Deserialize, Serialize};
use rocket::State;
use std::sync::{Arc, Mutex};

// Game state shared between threads
struct Game {
    responses: Arc<Mutex<Vec<Answer>>>,
}

#[derive(Serialize)]
struct Question {
    statement: String,
    answers: Vec<Answer>,
}

#[derive(Serialize, Deserialize, Hash, PartialEq, Eq, Debug, Clone)]
enum Answer {
    Right(String),
    Wrong(String),
}

#[get("/api")]
fn question() -> Json<Question> {
    let statement = String::from("How tall is the Eiffel Tower?");
    let answers = vec![
        Answer::Wrong(String::from("100m")),
        Answer::Right(String::from("300m")),
        Answer::Wrong(String::from("900m")),
    ];
    let question = Question { statement, answers };
    Json(question)
}

#[post("/answer", format = "application/json", data = "<data>")]
fn answer(data: Json<Answer>, game: &State<Game>) -> Json<Vec<Answer>> {
    // Update atomic reference counted mutex hash map
    let ans = data.into_inner();
    let s: &Game = game.inner();
    let mut answers = s.responses.lock().unwrap();
    answers.push(ans);

    Json(answers.clone())
}

#[launch]
fn rocket() -> _ {
    // Game state
    let answers: Vec<Answer> = vec![];
    let responses = Arc::new(Mutex::new(answers));
    let game = Game { responses };

    // Rocket server entry point
    rocket::build()
        .mount("/", routes![question, answer])
        .mount("/", FileServer::from("client/dist"))
        .manage(game)
}
