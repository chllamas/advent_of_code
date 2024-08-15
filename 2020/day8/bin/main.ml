let () =
        let rec aux fp acc i =
                try
                        let line = input_line fp in
                        acc
                with
                        End_of_file -> acc
        in
        Printf.printf "Acc value: %d\n" (aux (open_in "input.txt") 0)
