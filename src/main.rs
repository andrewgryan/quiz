#[macro_use]
extern crate rocket;

use rocket::fs::FileServer;
use rocket::serde::json::Json;
use rocket::serde::{Deserialize, Serialize};
use rocket::State;
use std::collections::HashMap;
use std::sync::{Arc, Mutex};

// Game state shared between threads
struct Game {
    responses: Arc<Mutex<HashMap<Answer, usize>>>,
}

#[derive(Serialize)]
struct Tally {
    count: HashMap<String, usize>,
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

impl Answer {
    fn as_string(a: &Answer) -> &String {
        match a {
            Answer::Right(s) => s,
            Answer::Wrong(s) => s,
        }
    }
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
fn answer(data: Json<Answer>, game: &State<Game>) -> Json<Tally> {
    // Update atomic reference counted mutex hash map
    let key = data.into_inner();
    let default_count = 0;
    let s: &Game = game.inner();
    let mut hash_map = s.responses.lock().unwrap();
    let ptr = hash_map.entry(key).or_insert(default_count);
    *ptr += 1;

    // Copy hash map of results to return as JSON
    // TODO: expose as an endpoint
    let mut results: HashMap<String, usize> = HashMap::new();
    for (k, v) in hash_map.iter_mut() {
        results.insert(Answer::as_string(&k).clone(), *v);
    }
    Json(Tally { count: results })
}

#[launch]
fn rocket() -> _ {
    // Game state
    let hash_map: HashMap<Answer, usize> = HashMap::new();
    let responses = Arc::new(Mutex::new(hash_map));
    let game = Game { responses };

    // Rocket server entry point
    rocket::build()
        .mount("/", routes![question, answer])
        .mount("/", FileServer::from("client/dist"))
        .manage(game)
}
