let () =
        let rec aux fp x dx y dy acc =
                match input_line fp with
                | exception End_of_file -> acc
                | _ when y > 0 -> aux fp x dx (y-1) dy acc
                | line -> let next_num = (x + dx) mod (String.length line) in
                        if line.[x] == '#' then
                                aux fp next_num dx dy dy (acc+1)
                        else
                                aux fp next_num dx dy dy acc
        in
        Printf.printf "Trees traversed: %d\n" (
                (aux (open_in "input.txt") 1 1 1 0 0) *
                (aux (open_in "input.txt") 3 3 1 0 0) *
                (aux (open_in "input.txt") 5 5 1 0 0) *
                (aux (open_in "input.txt") 7 7 1 0 0) *
                (aux (open_in "input.txt") 1 1 2 1 0)
        )
