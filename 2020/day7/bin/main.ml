let rec find_gold hash lst =
        match lst with
        | [] -> false
        | t :: ts -> t != "nother" && (t == "shinygold" || (match Hashtbl.find hash t with
                | exception Not_found -> find_gold hash ts
                | other -> find_gold hash other || find_gold hash ts));;

let () =
        let rec aux fp hash =
                match input_line fp with
                | exception End_of_file -> Hashtbl.fold (fun _ lst acc -> acc + (if find_gold hash lst then 1 else 0)) hash 0
                | line -> let (key, vals) = Scanf.sscanf line "%s %s bags contain %s@." (fun a b rest -> let items = String.split_on_char ',' rest in
                        ((a ^ b), List.map String.trim items))
                        in
                        List.iter (fun str -> Scanf.sscanf str "%d %s %s bags" (fun _ word1 word2 -> Hashtbl.replace hash key 
                                (match Hashtbl.find hash str with
                                        | exception Not_found -> [word1 ^ word2]
                                        | ts -> (word1 ^ word2) :: ts)))
                                vals;
                        aux fp hash
        in
        Printf.printf "Number of bags: %d\n" (aux (open_in "input.txt") (Hashtbl.create 500))
