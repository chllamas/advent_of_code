let process_line line = 
    let c1, c2 = Scanf.sscanf line "%c %c" (fun w1 w2 -> w1, w2) in
    let usr = match c2 with
        | 'X' -> 1
        | 'Y' -> 2
        | 'Z' -> 3
        |  _  -> failwith "invalid input"
    in 
    let result = match (c1, c2) with
        | ('A', 'Y') | ('B', 'Z') | ('C', 'X') -> 6
        | ('A', 'X') | ('B', 'Y') | ('C', 'Z') -> 3
        | ('A', 'Z') | ('B', 'X') | ('C', 'Y') -> 0
        | _ -> failwith "invalid input"
    in
    result + usr
   
let read_input filename =
    let ic = open_in filename in 
    let rec loop acc =
        try 
            let line = input_line ic in
            let result = process_line line in
            loop (acc + result)
        with End_of_file ->
            close_in ic;
            acc
    in
    let total = loop 0 in
    print_int total;
    print_newline ()

let () =
    read_input "input.txt"
