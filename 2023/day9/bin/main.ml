(*
let rec print_list = function
  | [] -> print_newline ()
  | x :: xs ->
      print_int x;
      print_char ' ';
      print_list xs
  *)

let next_history lst =
  let rec aux lc st =
    if List.for_all (fun x -> x == 0) lc then 0
    else
      match lc with
      | [ x; y ] ->
          let res = List.rev ((x - y) :: st) in
          y - aux res []
      | a :: b :: rest -> aux (b :: rest) ((a - b) :: st)
      | _ ->
          print_endline "ig i should handle this";
          exit 1
  in
  aux lst []

let get_numbers fp =
  let rec aux acc =
    match try Some (input_line fp) with End_of_file -> None with
    | Some line ->
        aux
          (acc
          + (String.split_on_char ' ' line
            |> List.map int_of_string |> List.rev |> next_history))
    | None -> acc
  in
  aux 0

let () = get_numbers (open_in "input.txt") |> Printf.printf "Sum is %d\n"
