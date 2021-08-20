#[macro_use] extern crate rocket;


use serde::Serialize;
use rocket::serde::json::Json;
use rocket::fs::FileServer;


#[derive(Serialize)]
struct Question {
    statement: String,
    answers: Vec<Answer>
}


#[derive(Serialize)]
enum Answer {
    Right(String),
    Wrong(String)
}



#[get("/api")]
fn question() -> Json<Question> {
    let statement = String::from("How tall is the Eiffel Tower?");
    let answers = vec![
        Answer::Wrong(String::from("100m")),
        Answer::Right(String::from("300m")),
        Answer::Wrong(String::from("900m"))
    ];
    let question = Question { statement, answers };
    Json(question)
}

#[launch]
fn rocket() -> _ {
    rocket::build().mount("/", routes![question])
        .mount("/", FileServer::from("client/dist"))
}
