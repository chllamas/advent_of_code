let () = print_endline "hw";;
(*
let split_list lst =
        let rec aux lst_a lst_b i =
                if i == 0 then
                        (List.rev lst_a, lst_b)
                else
                        match lst_b with
                        | t :: ts -> aux (t :: lst_a) ts (i-1)
                        | [] -> (List.rev lst_a, lst_b)
        in
        aux [] lst (List.length lst / 2);;

let first_half lst =
        let (f, _) = split_list lst in
        f;;

let second_half lst =
        let (_, s) = split_list lst in
        s;;

let () =
        let calc row_chars col_chars =
                let rec aux lc (st: int list) =
                        match lc with
                        | 'F' :: rest | 'L' :: rest -> aux rest (first_half st)
                        | 'B' :: rest | 'R' :: rest -> aux rest (second_half st)
                        | _ -> match st with
                                | [] -> let _ = print_endline "Unexpected fail with st" in exit 1
                                | t :: _ -> t
                in exit 1 (* Request that the functino splits the string then makes them into two lists and we receive them ehre  tod o the math here and return a simple interger *)
        in
        let rec aux fp acc =
                match input_line fp with
                | exception End_of_file -> acc
                | line -> aux fp (let x = calc (line |> String.to_seq |> List.of_seq) (List.init 128 (fun i -> i)) (List.init 8 (fun i -> i)) in
                        if x > acc then x else acc
                )
        in
        Printf.printf "Highest seat ID: %d\n" (aux (open_in "input.txt") 0);;
        *)
