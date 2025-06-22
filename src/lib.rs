mod utils;

use gloo::{console::log, dialogs::alert, events::EventListener};
use wasm_bindgen::prelude::*;

#[wasm_bindgen]
pub fn run() {
    utils::set_panic_hook(); // Error handling

    log!("Hello from rust wasm!");

    let document = gloo::utils::document();
    let greeting_button = document.get_element_by_id("greeting-button").unwrap();

    EventListener::new(&greeting_button, "click", move |_| {
        alert("Greetings from rust wasm!");
    })
    .forget();
}
