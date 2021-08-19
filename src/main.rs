#[macro_use] extern crate rocket;


use rocket::fs::FileServer;


#[get("/api")]
fn index() -> &'static str {
    "Hello, world!"
}

#[launch]
fn rocket() -> _ {
    rocket::build().mount("/", routes![index])
        .mount("/", FileServer::from("static"))
}
