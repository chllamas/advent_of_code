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
        let calc (row_chars: char list) (col_chars: char list): int =
                let rec aux lc (st: int list) =
                        match lc with
                        | 'F' :: rest | 'L' :: rest -> aux rest (first_half st)
                        | 'B' :: rest | 'R' :: rest -> aux rest (second_half st)
                        | _ -> match st with
                                | [] -> let _ = print_endline "Unexpected fail with st" in exit 1
                                | t :: _ -> t
                in (aux row_chars (List.init 128 (fun i -> i))) * 8 + (aux col_chars (List.init 8 (fun i -> i)))
        in
        let aux fp =
                let rec create_hash fp st =
                        match input_line fp with
                        | exception End_of_file -> st
                        | line -> let _ = Hashtbl.add st (calc (String.sub line 0 7 |> String.to_seq |> List.of_seq) (String.sub line 7 3 |> String.to_seq |> List.of_seq)) true in
                                st
                in let hash = create_hash fp (Hashtbl.create 827) in
                let rec find_seat (lc: int list) f: int  = match lc with
                        | [] -> let _ = print_endline "We failed" in exit 1
                        | t :: ts -> if f (t - 2) && not (f (t - 1)) then
                                t - 1
                        else if f (t + 2) && not (f (t + 1)) then
                                t + 1
                        else
                                find_seat ts f
                in
                find_seat (hash |> Hashtbl.to_seq_keys |> List.of_seq) (Hashtbl.mem hash)
        in
        Printf.printf "My seat is: %d\n" (aux (open_in "input.txt"));;
