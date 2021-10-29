#[macro_use]
extern crate rocket;

use rocket::fs::FileServer;
use rocket::response::stream::{Event, EventStream};
use rocket::serde::json::Json;
use rocket::serde::{Deserialize, Serialize};
use rocket::tokio::select;
use rocket::tokio::sync::broadcast::{channel, error::RecvError, Sender};
use rocket::{Shutdown, State};
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
fn question() -> Json<Vec<Question>> {
    let statement = String::from("How tall is the Eiffel Tower?");
    let answers = vec![
        Answer::Wrong(String::from("100m")),
        Answer::Right(String::from("300m")),
        Answer::Wrong(String::from("900m")),
    ];
    let question = Question { statement, answers };
    Json(vec![question])
}

#[post("/answer", format = "application/json", data = "<data>")]
fn answer(
    data: Json<Answer>,
    game: &State<Game>,
    queue: &State<Sender<Message>>,
) -> Json<Vec<Answer>> {
    // Update atomic reference counted mutex hash map
    let ans = data.into_inner();
    let s: &Game = game.inner();
    let mut answers = s.responses.lock().unwrap();
    answers.push(ans);

    // Emit server-sent event
    let msg = Message {
        answers: answers.clone(),
    };
    let _ = queue.send(msg);

    Json(answers.clone())
}

// Server-sent event stream

#[derive(Serialize, Clone)]
struct Message {
    answers: Vec<Answer>,
}

#[get("/events")]
fn events(queue: &State<Sender<Message>>, mut end: Shutdown) -> EventStream![] {
    let mut rx = queue.subscribe();
    EventStream! {
        loop {
            let msg = select! {
                msg = rx.recv() => match msg {
                    Ok(msg) => msg,
                    Err(RecvError::Closed) => break,
                    Err(RecvError::Lagged(_)) => continue,
                },
                _ = &mut end => break,
            };
            yield Event::json(&msg);
        }
    }
}

#[launch]
fn rocket() -> _ {
    // Game state
    let answers: Vec<Answer> = vec![];
    let responses = Arc::new(Mutex::new(answers));
    let game = Game { responses };

    // Rocket server entry point
    rocket::build()
        .mount("/", routes![question, answer, events])
        .mount("/", FileServer::from("client/dist"))
        .manage(game)
        .manage(channel::<Message>(1024).0)
}
