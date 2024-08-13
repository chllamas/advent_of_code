let () = 
        (*let rec occ lst ch acc =
                match lst with
                | t :: ts -> if Char.equal t ch then
                                occ ts ch (acc+1)
                        else 
                                occ ts ch acc
                | [] -> acc
        in*)
        let rec aux fp acc =
                match input_line fp with
                | exception End_of_file -> acc
                | str -> (match Scanf.sscanf str "%d-%d %c: %s" (fun l h c s -> (l-1, h-1, c, s)) with
                        | x, y, ch, str -> if str.[x] != str.[y] && (str.[x] == ch || str.[y] == ch) then
                                        aux fp (acc+1)
                                else 
                                        aux fp acc
                )
        in
        print_endline (Printf.sprintf "Valid passwords: %d" (aux (open_in "input.txt") 0));;
