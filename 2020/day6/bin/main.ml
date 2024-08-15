module CharSet = Set.Make(Char);;

let () = 
        let rec aux fp acc set is_first =
                match input_line fp with
                | exception End_of_file -> acc + (set |> CharSet.to_list |> List.length)
                | "" -> let x = (set |> CharSet.to_list |> List.length) in
                        aux fp (acc + x) CharSet.empty true
                | line ->
                        if is_first then
                                aux fp acc (line |> String.to_seq |> CharSet.of_seq) false
                        else
                                aux fp acc (CharSet.inter set (line |> String.to_seq |> CharSet.of_seq)) false
        in
        Printf.printf "Sum is: %d\n" (aux (open_in "input.txt") 0 CharSet.empty true)
