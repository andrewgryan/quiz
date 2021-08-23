#[macro_use]
extern crate rocket;

use rocket::fs::FileServer;
use rocket::serde::json::Json;
use rocket::serde::{Deserialize, Serialize};
use rocket::State;
use std::collections::HashMap;
use std::sync::{Arc, Mutex};

struct Score {
    database: Arc<Mutex<HashMap<Answer, usize>>>,
}

#[derive(Serialize)]
struct Board {
    score: HashMap<String, usize>,
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
fn answer(data: Json<Answer>, score: &State<Score>) -> Json<Board> {
    // Update atomic reference counted mutex hash map
    let key = data.into_inner();
    println!("{:?}", key);
    let default = 0;
    let s: &Score = score.inner();
    let mut hash_map = s.database.lock().unwrap();
    let ptr = hash_map.entry(key).or_insert(default);
    *ptr += 1;

    let mut results: HashMap<String, usize> = HashMap::new();
    for (k, v) in hash_map.iter_mut() {
        results.insert(Answer::as_string(&k).clone(), *v);
    }
    Json(Board { score: results })
}

#[launch]
fn rocket() -> _ {
    // Data structures
    let hash_map: HashMap<Answer, usize> = HashMap::new();
    let mutex = Arc::new(Mutex::new(hash_map));

    println!("main thread: {:?}", mutex);

    // Rocket server entry point
    rocket::build()
        .mount("/", routes![question, answer])
        .mount("/", FileServer::from("client/dist"))
        .manage(Score { database: mutex })
}
