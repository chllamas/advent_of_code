(*let rec find_loop arr acc i =
        match arr.(i) with
        | (_, _,_,true) -> acc
        | (s, a, j, _) -> arr.(i) <- (s, a, j, true);
                find_loop arr (acc+a) j;;*)

let rec validate_loop arr acc i =
        if i >= 608 then
                Some(acc)
        else
                match arr.(i) with
                | (_,_,true) -> None
                | (s,x,_) -> arr.(i) <- (s,x,true);
                        match s with
                        | "nop" -> validate_loop arr acc (i+1)
                        | "jmp" -> validate_loop arr acc (i+x)
                        | _ -> validate_loop arr (acc+x) (i+1)


let create_array () =
        let rec aux fp arr i =
                try
                        arr.(i) <- (Scanf.sscanf (input_line fp) "%s %c%d" (fun cmd sign amt ->
                                (cmd, (if sign == '-' then amt * (-1) else amt), false)
                        ));
                        aux fp arr (i+1)
                with
                        End_of_file -> arr
        in
        aux (open_in "input.txt") (Array.init 608 (fun _ -> ("nop", 0, false))) 0;;

(* Array stores (accumulation_add, next_i_index, is_visited_bool) *)
let () =
        let rec aux arr i =
                let matches () = match validate_loop arr 0 0 with
                        | Some(x) -> x
                        | None -> aux (create_array ()) (i+1)
                in
                match arr.(i) with
                | ("nop",a,b) -> arr.(i) <- ("jmp",a,b); matches ()
                | ("jmp",a,b) -> arr.(i) <- ("nop",a,b); matches ()
                | _ -> aux arr (i+1)
        in
        Printf.printf "Acc value: %d\n" (aux (create_array ()) 0)
