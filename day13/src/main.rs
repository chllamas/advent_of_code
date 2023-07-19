use std::cmp::{min, Ordering};
use std::env;
use std::fs::File;
use std::io::{BufRead, BufReader};
use serde::Deserialize;
use serde_json::Value;

#[derive(Debug, Deserialize, PartialEq)]
enum ListObj {
    Array(Vec<ListObj>),
    Value(i64),
}

fn compare(left: &ListObj, right: &ListObj) -> Ordering {
    match left {
        ListObj::Array(arr_left) => match right {
            ListObj::Value(num_right) => compare(left, &ListObj::Array(vec![ListObj::Value(*num_right)])),
            ListObj::Array(arr_right) => {
                for i in 0..min(arr_left.len(), arr_right.len()) {
                    let result = compare(&arr_left[i], &arr_right[i]);
                    if result != Ordering::Equal {
                        return result;
                    }
                }
                arr_left.len().cmp(&arr_right.len())
            },
        },
        ListObj::Value(num_left) => {
            if let ListObj::Value(num_right) = right {
                num_left.cmp(&num_right)
            } else {
                compare(&ListObj::Array(vec![ListObj::Value(*num_left)]), right)
            }
        },
    }
}

fn parse_list(value: &Value) -> Result<ListObj, serde_json::Error> {
    match value {
        Value::Number(num) => {
            if let Some(parsed_num) = num.as_i64() {
                Ok(ListObj::Value(parsed_num))
            } else {
                panic!("Couldn't parse num")
            }
        },
        Value::Array(arr) => {
            let mut result: Vec<ListObj> = vec![];
            for elem in arr {
                result.push(parse_list(elem)?);
            }
            Ok(ListObj::Array(result))
        },
        _ => panic!("Couldn't work with this!")
    }
}

fn print_list(list: &Vec<ListObj>) {
    print!("[");
    for elem in list {
        match elem {
            ListObj::Value(num) => print!("{}, ", num),
            ListObj::Array(arr) => print_list(arr),
        }
    }
    print!("]");
}

fn main() -> std::io::Result<()> {
    let mut path = env::current_dir()?;
    path.push("input.txt");
    let file: File = File::open(path)?;
    let reader: BufReader<File> = BufReader::new(file);

    let mut result: Vec<ListObj> = vec![ListObj::Value(2), ListObj::Value(6)];
    for line in reader.lines() {
        let line: String = line?;
        if line.is_empty() { continue }
        let val: Value = serde_json::from_str(&line)?;
        result.push(parse_list(&val)?);
    }
    result.sort_by(compare);

    let mut index = 1;
    let mut product: i64 = -12341235;
    for elem in &result {
        if *elem == ListObj::Value(2) {
            product = index;
        } else if *elem == ListObj::Value(6) {
            product *= index;
            break;
        }
        index += 1;
    }

    println!("{}", product);

    Ok(())
}
