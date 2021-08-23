#[macro_use]
extern crate rocket;

use rocket::fs::FileServer;
use rocket::serde::json::Json;
use rocket::serde::{Deserialize, Serialize};
use rocket::State;
use std::collections::HashMap;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::{Arc, Mutex};

struct Score {
    count: AtomicUsize,
    database: Arc<Mutex<HashMap<usize, usize>>>,
}

#[derive(Serialize)]
struct Board {
    score: usize,
}

#[derive(Serialize)]
struct Question {
    statement: String,
    answers: Vec<Answer>,
}

#[derive(Serialize, Deserialize, Debug)]
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
fn answer(data: Json<Answer>, score: &State<Score>) -> Json<Board> {
    println!("{:?}", data.into_inner());

    let update = score.count.fetch_add(1, Ordering::Relaxed);

    // Update atomic reference counted mutex hash map
    let key = 0;
    let default = 0;
    let s: &Score = score.inner();
    let mut hash_map = s.database.lock().unwrap();
    let ptr = hash_map.entry(key).or_insert(default);
    *ptr += 1;
    println!("mutex: {:?}", hash_map);

    Json(Board { score: update })
}

#[launch]
fn rocket() -> _ {
    // Data structures
    let hash_map: HashMap<usize, usize> = HashMap::new();
    let mutex = Arc::new(Mutex::new(hash_map));

    println!("main thread: {:?}", mutex);

    // Rocket server entry point
    rocket::build()
        .mount("/", routes![question, answer])
        .mount("/", FileServer::from("client/dist"))
        .manage(Score {
            count: AtomicUsize::new(0),
            database: mutex,
        })
}
