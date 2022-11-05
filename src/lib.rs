mod utils;

use gloo::{console::log, events::EventListener, dialogs::alert};
use wasm_bindgen::prelude::*;

// When the `wee_alloc` feature is enabled, use `wee_alloc` as the global
// allocator.
#[cfg(feature = "wee_alloc")]
#[global_allocator]
static ALLOC: wee_alloc::WeeAlloc = wee_alloc::WeeAlloc::INIT;

#[wasm_bindgen]
pub fn run() {
    utils::set_panic_hook(); // Error handling

    log!("Hello from rust wasm!");

    let document = gloo::utils::document();
    let greeting_button = document.get_element_by_id("greeting-button").unwrap();

    EventListener::new(&greeting_button, "click", move |_| {
        alert("Greetings from rust wasm!");
    }).forget();
}