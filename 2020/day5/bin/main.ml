let split_list _ =
        ([], []);;

let first_half lst =
        let (f, _) = split_list lst in
        f

let second_half lst =
        let (_, s) = split_list lst in
        s

let () =
        let rec calc chars row_lc col_lc =
                match chars with
                | 'F' :: rest -> calc rest [] []
                | 'B' :: rest -> calc rest row_lc col_lc
                | 'L' :: rest -> calc rest row_lc col_lc
                | 'R' :: rest -> calc rest row_lc col_lc
                | _ -> 0
        in
        let rec aux fp acc =
                match input_line fp with
                | exception End_of_file -> acc
                | line -> aux fp (let x = calc (line |> String.to_seq |> List.of_seq) (List.init 128 (fun i -> i)) (List.init 8 (fun i -> i)) in
                        if x > acc then x else acc
                )
        in
        Printf.printf "Highest seat ID: %d\n" (aux (open_in "input.txt") 0);;
