let rec find_gold hash lst =
        match lst with
        | [] -> false
        | t :: ts -> Printf.printf "Found %s\n" t; (t == "shinygold" || (
                try
                        let other = Hashtbl.find hash t in
                        find_gold hash other || find_gold hash ts
                with
                        Not_found -> find_gold hash ts
        ));;

let () =
        let rec aux fp hash =
                try
                        let (key, vals) = Scanf.sscanf (input_line fp) "%s %s bags contain %s@." (fun a b rest -> (a ^ b, List.map String.trim (String.split_on_char ',' rest))) in
                        List.iter (fun str -> 
                                Scanf.sscanf str "%d %s %s bags" (fun _ a b ->
                                        Hashtbl.replace hash key 
                                                (let v = a ^ b in
                                                        try
                                                                let lst = Hashtbl.find hash key in
                                                                v :: lst
                                                        with
                                                                Not_found -> [v]
                                                )
                                )
                        ) vals;
                        aux fp hash
                with
                        End_of_file -> Hashtbl.fold (fun _ lst acc -> acc + (if find_gold hash lst then 1 else 0)) hash 0
        in
        Printf.printf "Number of bags: %d\n" (aux (open_in "input.txt") (Hashtbl.create 500))
