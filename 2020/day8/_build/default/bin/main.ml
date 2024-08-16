let rec find_loop arr acc i =
        match arr.(i) with
        | (_,_,true) -> acc
        | (a, j, _) -> arr.(i) <- (a, j, true);
                find_loop arr (acc+a) j

(* Array stores (accumulation_add, next_i_index, is_visited_bool) *)
let () =
        let rec aux fp arr i =
                try
                        arr.(i) <- (Scanf.sscanf (input_line fp) "%s %c%d" (fun cmd sign amt ->
                                match cmd with
                                | "nop" -> (0, i+1, false)
                                | "acc" -> ((if sign == '-' then amt * (-1) else amt), i+1, false)
                                | "jmp" -> (0, (i + (if sign == '-' then amt * -1 else amt)), false)
                                | _ -> print_endline "unexpected error"; exit 1
                        ));
                        aux fp arr (i+1)
                with
                        End_of_file -> find_loop arr 0 0
        in
        Printf.printf "Acc value: %d\n" (aux (open_in "input.txt") (Array.init 608 (fun _ -> (0, 0, false))) 0)
