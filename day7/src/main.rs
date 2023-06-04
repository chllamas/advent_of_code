use std::fs::File;
use std::io::{BufRead, BufReader};
use std::collections::HashMap;
use scanf::sscanf;

enum FileNode {
    Dir(HashMap<String, FileNode>),
    Doc(i32),
}

fn retrieve_current_node<'a>(path: &[String], root_node: &'a mut FileNode) -> &'a mut FileNode {
    let mut current_node = root_node;
    for dir_name in path {
        if let FileNode::Dir(dir_map) = current_node {
            current_node = dir_map
                .entry(dir_name.clone())
                .or_insert(FileNode::Dir(HashMap::new()))
        } else {
            panic!("Reached unexpected error while retrieving node")
        }
    }

    current_node
}

fn handle_cd() {
    todo!()
}

fn handle_ls() {
    todo!() 
}

fn main() -> std::io::Result<()> {
    let file = File::open("input.txt")?;
    let reader = BufReader::new(file);
    let root_node = FileNode::Dir(HashMap::new());

    let mut current_path: Vec<String> = vec![];
    let mut current_node: &FileNode = &root_node;

    for line in reader.lines() {
        let line: String = line?;
        match &line[..4] {
            "$ cd" => todo!(),
            "$ ls" => todo!(),
            "dir " => todo!(),
              _    => todo!(),
        }
    }

    Ok(())
}

