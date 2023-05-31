let process_line line = 
    let c1, c2 = Scanf.sscanf line "%c %c" (fun w1 w2 -> w1, w2) in
    let result = match c2 with
        | 'X' -> 0
        | 'Y' -> 3
        | 'Z' -> 6
        |  _  -> failwith "invalid input"
    in 
    let usr = match (c2, c1) with
        | ('X', 'B') | ('Y', 'A') | ('Z', 'C') -> 1
        | ('X', 'C') | ('Y', 'B') | ('Z', 'A') -> 2
        | ('X', 'A') | ('Y', 'C') | ('Z', 'B') -> 3
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
