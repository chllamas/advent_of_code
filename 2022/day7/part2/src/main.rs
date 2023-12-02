use std::env;
use std::fs::File;
use std::io::{BufRead, BufReader};
use std::collections::HashMap;

use scanf::sscanf;

#[allow(unused)]
enum FileNode {
    Dir(HashMap<String, FileNode>),
    Doc(u32),
}

fn handle_cd(line: &str, current_path: &mut Vec<String>) {
    line
        .split('/')
        .for_each(|p|
            match p {
                ".." => { current_path.pop(); },
                _   => { current_path.push(p.to_string()); },
            }
        )
}

fn handle_ls<'a>(root_node: &'a mut FileNode, current_path: &[String]) -> &'a mut FileNode {
    let mut ret = root_node;
    for dir_name in current_path {
        if let FileNode::Dir(dir_map) = ret {
            ret = dir_map 
                .entry(dir_name.clone())
                .or_insert(FileNode::Dir(HashMap::new()))
        }
    }
    ret
}

fn calculate_smallest_file_to_delete(directory: &FileNode, minimum: u32) -> (u32, u32) {
    let mut smallest: u32 = 700000000;
    let mut full_folder_sum: u32 = 0;

    if let FileNode::Dir(dir_map) = directory {
        for (_, node) in dir_map {
            match node {
                FileNode::Dir(_) => {
                    let (s, f)= calculate_smallest_file_to_delete(node, minimum);
                    full_folder_sum += f;
                    if s < smallest {
                        smallest = s;
                    }
                },
                FileNode::Doc(size) => {
                    full_folder_sum += size;
                }
            }
        }
    }

    if full_folder_sum < smallest && full_folder_sum >= minimum {
        (full_folder_sum, full_folder_sum)
    } else {
        (smallest, full_folder_sum)
    }
}

fn calculate_file_directory_size(directory: &FileNode) -> u32 {
    let mut full_folder_sum = 0;
    if let FileNode::Dir(dir_map) = directory {
        for (_, node) in dir_map {
            match node {
                FileNode::Dir(_) => {
                    let size = calculate_file_directory_size(node);
                    full_folder_sum += size;
                },
                FileNode::Doc(size) => {
                    full_folder_sum += size;
                },
            }
        }
    }

    full_folder_sum
}

#[allow(dead_code)]
fn print_file_node_tree(node: &FileNode, depth: usize) {
    match node {
        FileNode::Dir(dir_map) => {
            for (name, file_node) in dir_map {
                println!("{}Dir: {}", "\t".repeat(depth), name);
                print_file_node_tree(file_node, depth + 1);
            }
        }
        FileNode::Doc(size) => {
            println!("{}File: {}", "\t".repeat(depth), size);
        }
    }
}

fn main() -> std::io::Result<()> {
    let current_dir = env::current_dir()?;
    let file_path = current_dir.join("input.txt");
    let file = File::open(file_path)?;
    let reader = BufReader::new(file);
    let mut root_node = FileNode::Dir(HashMap::new());

    let mut current_path: Vec<String> = vec![];
    let mut current_node = &mut root_node;

    for line in reader.lines() {
        let line: String = line?;
        match &line[..4] {
            "$ cd" => handle_cd(&line[5..], &mut current_path),
            "$ ls" => {
                current_node = handle_ls(&mut root_node, &current_path);
            }
            "dir " => {
                let dir_name: &str = &line[4..];
                if let FileNode::Dir(dir_map) = current_node {
                    if !dir_map.contains_key(dir_name) {
                        dir_map.insert(dir_name.to_string(), FileNode::Dir(HashMap::new()));
                    }
                }
            },
            _      => {
                let mut file_name: String = String::new();
                let mut file_size: u32 = 0;
                sscanf!(&line, "{} {}", file_size, file_name)?;
                if let FileNode::Dir(dir_map) = current_node {
                    dir_map
                        .entry(file_name)
                        .or_insert(FileNode::Doc(file_size));
                }
            },
        }
    }

    let full_size = calculate_file_directory_size(&root_node);
    let free_space = 70000000 - full_size;
    let minimum = 30000000 - free_space;
    let (solution, _) = calculate_smallest_file_to_delete(&root_node, minimum);

    println!("Answer is {solution}");

    Ok(())
}

