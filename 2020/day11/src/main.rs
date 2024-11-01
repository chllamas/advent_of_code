use std::fs::File;
use std::io::Read;

fn main() {
    let mut text = vec![];
    let mut file = File::open("test.txt").unwrap();
    let _ = file.read_to_end(&mut text);
}
