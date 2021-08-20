#[macro_use] extern crate rocket;


use serde::Serialize;
use rocket::serde::json::Json;
use rocket::fs::FileServer;


#[derive(Serialize)]
struct Question {
    statement: String,
    answers: Vec<String>
}


#[get("/api")]
fn question() -> Json<Question> {
    let statement = String::from("How tall is the Eiffel Tower?");
    let answers = vec![
        String::from("100m"),
        String::from("300m"),
        String::from("900m")
    ];
    let question = Question { statement, answers };
    Json(question)
}

#[launch]
fn rocket() -> _ {
    rocket::build().mount("/", routes![question])
        .mount("/", FileServer::from("client/dist"))
}
