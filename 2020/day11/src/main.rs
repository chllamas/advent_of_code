use std::fs;

trait GraphExtensions {
    fn deep_eq(&self, b: &Vec<Vec<char>>) -> bool;
    fn adj_occupied(&self, x: usize, y: usize) -> u8;
}

impl GraphExtensions for Vec<Vec<char>> {
    fn deep_eq(&self, other: &Vec<Vec<char>>) -> bool {
        for y in 0..self.len() {
            for x in 0..self[0].len() {
                if self[y][x] != other[y][x] {
                    return false;
                }
            }
        }
        return true;
    }

    fn adj_occupied(&self, x: usize, y: usize) -> u8 {
        let mut count: u8 = 0;
        if y > 0 {
            // up
            let mut j = y - 1;
            loop {
                match self[j][x] {
                    '#' => {
                        count += 1;
                        break;
                    }
                    'L' => break,
                    _ if j == 0 => break,
                    _ => j -= 1,
                }
            }

            // up-right
            let mut j = y - 1;
            for i in x + 1..self[0].len() {
                match self[j][i] {
                    '#' => {
                        count += 1;
                        break;
                    }
                    'L' => break,
                    _ if j == 0 => break,
                    _ => j -= 1,
                }
            }
        }

        if x > 0 {
            // left
            let mut i = x - 1;
            loop {
                match self[y][i] {
                    '#' => {
                        count += 1;
                        break;
                    }
                    'L' => break,
                    _ if i == 0 => break,
                    _ => i -= 1,
                }
            }

            // down-left
            let mut i = x - 1;
            for j in y + 1..self.len() {
                match self[j][i] {
                    '#' => {
                        count += 1;
                        break;
                    }
                    'L' => break,
                    _ if i == 0 => break,
                    _ => i -= 1,
                }
            }
        }

        // down
        for j in y + 1..self.len() {
            match self[j][x] {
                '#' => {
                    count += 1;
                    break;
                }
                'L' => break,
                _ => continue,
            }
        }

        // right
        for i in x + 1..self[0].len() {
            match self[y][i] {
                '#' => {
                    count += 1;
                    break;
                }
                'L' => break,
                _ => continue,
            }
        }

        // down-right
        let mut i = x + 1;
        let mut j = y + 1;
        while i < self[0].len() && j < self.len() {
            match self[j][i] {
                '#' => {
                    count += 1;
                    break;
                }
                'L' => break,
                _ => {
                    i += 1;
                    j += 1;
                }
            }
        }

        if x > 0 && y > 0 {
            // up-left
            let mut i = x - 1;
            let mut j = y - 1;
            loop {
                match self[j][i] {
                    '#' => {
                        count += 1;
                        break;
                    }
                    'L' => break,
                    _ if (i == 0 || j == 0) => break,
                    _ => {
                        i -= 1;
                        j -= 1;
                    }
                }
            }
        }

        return count;
    }
}

fn main() {
    let mut graph: Vec<Vec<char>> = fs::read_to_string("input.txt")
        .expect("Error reading file")
        .split('\n')
        .filter_map(|line| {
            if line.len() == 0 {
                return None;
            }
            return Some(line.chars().collect());
        })
        .collect();

    let mut cache: Vec<Vec<char>> = vec![vec!['.'; graph[0].len()]; graph.len()];

    while !graph.deep_eq(&cache) {
        for y in 0..graph.len() {
            for x in 0..graph[0].len() {
                cache[y][x] = graph[y][x];
            }
        }

        for y in 0..graph.len() {
            for x in 0..graph[0].len() {
                graph[y][x] = match cache[y][x] {
                    'L' if cache.adj_occupied(x, y) == 0 => '#',
                    '#' if cache.adj_occupied(x, y) >= 5 => 'L',
                    _ => cache[y][x],
                }
            }
        }
    }

    println!(
        "There are {} occupied seats!",
        graph.iter().fold(0, |acc, row| acc
            + row.iter().filter(|&&c| c == '#').count())
    );
}
