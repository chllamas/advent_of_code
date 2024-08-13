let () =
        let verify tbl = (
                let btwn x a b = (int_of_string x) >= a && (int_of_string x) <= b in
                if Hashtbl.mem tbl "byr" && btwn (Hashtbl.find tbl "byr") 1920 2002 &&
                        Hashtbl.mem tbl "iyr" && btwn (Hashtbl.find tbl "iyr") 2010 2020 &&
                        Hashtbl.mem tbl "eyr" && btwn (Hashtbl.find tbl "eyr") 2020 2030 &&
                        Hashtbl.mem tbl "hgt" && (* TOOD *)
                        Hashtbl.mem tbl "hcl" && (* TODO *)
                        Hashtbl.mem tbl "ecl" &&  (* TODO *)
                        Hashtbl.mem tbl "pid" then (* TODO *)
                        1 else 0
        ) in
        let rec append tbl words =
                match words with
                | [] -> tbl
                | t :: ts -> let code = String.sub t 0 3 in
                        let input = String.sub t 3 (String.length t - 3) in
                        let _ = Hashtbl.replace tbl code input in
                        append tbl ts
        in
        let rec aux fp st acc =
                match input_line fp with
                | exception End_of_file -> acc + verify st
                | "" -> aux fp (Hashtbl.create 8) (acc + verify st)
                | line -> aux fp (append st (String.split_on_char ' ' line)) acc
        in
        Printf.printf "Valid passports: %d\n" (aux (open_in "input.txt") (Hashtbl.create 8) 0)
