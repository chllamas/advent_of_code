use std::env;
use std::fs::File;
use std::io::{BufRead, BufReader, Error, ErrorKind};
use std::collections::HashSet;

enum MoveMethod {
    Dynamic(i32, i32),
    Static(i32, i32),
}

struct Rope {
    position: (i32, i32),
    dependency: Option<Box<Rope>>,
}

impl Rope {
    fn new(mut n: i32) -> Self {
        let mut root = Self{ position: (0, 0), dependency: None };
        let mut current = &mut root.dependency;
        n -= 1;
        while n > 0 {
            (*current) = Some(Box::new(Self{ position: (0, 0), dependency: None }));
            if let Some(t) = current {
                current = &mut t.dependency;
            }
            n -= 1;
        }
        root
    }

    fn move_point(&mut self, movement: MoveMethod) -> Option<(i32, i32)> {
        let (x, y) = self.position;
        self.position = match movement {
            MoveMethod::Static(a, b) => (a, b),
            MoveMethod::Dynamic(dx, dy) => (x + dx, y + dy),
        };
        if let Some(next) = &mut self.dependency {
            if !are_adjacent(&self.position, &next.position) {
                next.move_point(MoveMethod::Static(x, y))
            } else {
                None
            }
        } else {
            Some(self.position)
        }
    }
}

fn are_adjacent((a, b): &(i32, i32), (m, n): &(i32, i32)) -> bool {
    (a-m).abs() <= 1 && (b-n).abs() <= 1
}

fn main() -> std::io::Result<()> {
    let mut path = env::current_dir()?;
    path.push("input.txt");
    let file = File::open(path)?;
    let reader = BufReader::new(file);
    let mut visit_set: HashSet<(i32, i32)> = HashSet::from([(0,0)]);
    let mut head = Rope::new(10);

    for line in reader.lines() {
        let line: String = line?;
        let direction: char = line
            .chars()
            .next()
            .unwrap();
        let mut n: i32 = (line[2..])
            .parse()
            .map_err(|e| Error::new(ErrorKind::InvalidInput, e))?;
        while n > 0 {
            let (x, y) = match direction {
                'L' => (-1, 0),
                'R' => (1, 0),
                'U' => (0, -1),
                'D' => (0, 1),
                 _  => unreachable!(),
            };
            if let Some(new_visited) = head.move_point(MoveMethod::Dynamic(x,y)) {
                visit_set.insert(new_visited);
            }
            n -= 1;
        }
    }

    println!("Spots visited {}\n", visit_set.len());
    Ok(())
}
