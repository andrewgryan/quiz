#[macro_use] extern crate rocket;


use serde::Serialize;
use rocket::serde::json::Json;
use rocket::fs::FileServer;


#[derive(Serialize)]
struct Question {
    statement: String
}


#[get("/api")]
fn question() -> Json<Question> {
    let statement = String::from("How tall is the Eiffel Tower?");
    let question = Question { statement };
    Json(question)
}

#[launch]
fn rocket() -> _ {
    rocket::build().mount("/", routes![question])
        .mount("/", FileServer::from("client/dist"))
}
