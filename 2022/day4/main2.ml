let has_overlap (a, b) (c, d) =
    (b >= c && a <= d) || (d >= a && c <= b)

let process_line line =
    let range1, range2 = Scanf.sscanf line "%d-%d,%d-%d" (fun w1 w2 w3 w4 -> (w1, w2), (w3, w4)) in
    if has_overlap range1 range2 then 1 else 0

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
