use std::fs::File;
use std::io::{BufRead, BufReader};
use std::collections::HashMap;
use scanf::sscanf;

enum FileNode {
    Dir(HashMap<String, FileNode>),
    Doc(i32),
}

fn main() -> std::io::Result<()> {
    let file = File::open("input.txt")?;
    let reader = BufReader::new(file);
    let mut root_node = FileNode::Dir(HashMap::new());

    let mut current_path: Vec<String> = vec![];
    let mut current_node: &mut FileNode = &mut root_node;

    for line in reader.lines() {
        let line: String = line?;
        match &line[..4] {
            "$ cd" => line.split('/')
                .for_each(|p|
                    match p {
                        ".." => { current_path.pop(); },
                        _   => { current_path.push(p.to_string()); },
                    }
                ),
            "$ ls" => {
                current_node = &mut root_node;
                for dir_name in &current_path {
                    if let FileNode::Dir(dir_map) = current_node {
                        current_node = dir_map 
                            .entry(dir_name.clone())
                            .or_insert(FileNode::Dir(HashMap::new()))
                    }
                }
            },
            "dir " => todo!(),
              _    => todo!(),
        }
    }

    Ok(())
}

