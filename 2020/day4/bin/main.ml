let () =
        let verify tbl = (
                let btwn x a b = (int_of_string x) >= a && (int_of_string x) <= b in
                if Hashtbl.mem tbl "byr" && btwn (Hashtbl.find tbl "byr") 1920 2002 &&
                        Hashtbl.mem tbl "iyr" && btwn (Hashtbl.find tbl "iyr") 2010 2020 &&
                        Hashtbl.mem tbl "eyr" && btwn (Hashtbl.find tbl "eyr") 2020 2030 &&
                        Hashtbl.mem tbl "hgt" && (
                                let get_unit fmt = Scanf.sscanf (Hashtbl.find tbl "hgt") fmt (fun a -> Int.to_string a) in
                                try
                                        btwn (get_unit "%dcm") 150 193
                                with
                                        | Scanf.Scan_failure _ | End_of_file | Failure _ -> try 
                                                btwn (get_unit "%din") 59 76
                                        with
                                                | Scanf.Scan_failure _ | End_of_file | Failure _ -> let _ = Printf.printf "Failed scan with string %s\n" (Hashtbl.find tbl "hgt") in false
                        ) &&
                        Hashtbl.mem tbl "hcl" && (
                                let rec is_valid_hair_str str i =
                                        let validate ch = (ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'f') in
                                        i >= String.length str || (validate str.[i] && is_valid_hair_str str (i+1))
                                in
                                String.length (Hashtbl.find tbl "hcl") == 7 && (Hashtbl.find tbl "hcl").[0] == '#' && is_valid_hair_str (Hashtbl.find tbl "hcl") 1
                        ) &&
                        Hashtbl.mem tbl "ecl" && (
                                match Hashtbl.find tbl "ecl" with
                                | "amb" | "blu" | "brn" | "gry" | "grn" | "hzl" | "oth" -> true
                                | _ -> false
                        ) &&
                        Hashtbl.mem tbl "pid" && (
                                let rec verify_pid str i = 
                                        String.length str >= i || (str.[i] >= '0' && str.[i] <= '9' && verify_pid str (i+1)) in
                                String.length (Hashtbl.find tbl "pid") == 9 && verify_pid (Hashtbl.find tbl "pid") 0
                        ) then
                        1 else 0
        ) in
        let rec append tbl words =
                match words with
                | [] -> tbl
                | t :: ts -> let code = String.sub t 0 3 in
                        let input = String.sub t 4 (String.length t - 4) in
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
