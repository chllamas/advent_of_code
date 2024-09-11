let read_graph_from_input fp =
  let rec aux lc =
    match try Some (input_line fp) with End_of_file -> None with
    | Some line -> aux (line :: lc)
    | None -> Array.of_list (List.rev lc)
  in
  aux []

let expand_graph graph =
  let rec aux (rows_empty, cols_empty) = graph in
  let rec find_empties i rows_empty cols_empty =
    match try Some graph.(i) with Invalid_argument _ -> None with
    | Some str ->
        rows_empty.(i) <- String.for_all (fun ch -> ch == '.') str;
        find_empties (i + 1) rows_empty
          (Array.map2
             (fun a b -> a && b == '.')
             cols_empty
             (str |> String.to_seq |> Array.of_seq))
    | None -> (rows_empty, cols_empty)
  in
  find_empties 0
    (Array.init (Array.length graph) (fun _ -> true))
    (Array.init (String.length graph.(0)) (fun _ -> true))
  |> aux

let test_expanse graph =
  try
    if
      Array.for_all2
        (fun str1 str2 -> String.equal str1 str2)
        graph
        (open_in "test_expanse.txt" |> read_graph_from_input)
    then print_endline "The expanse was good"
    else print_endline "The expanse was wrong"
  with Invalid_argument _ ->
    print_endline "Expanse failed due to differing lengths"

let print_graph graph =
  Array.iter
    (fun str ->
      print_string str;
      print_newline ())
    graph

let () = open_in "test.txt" |> read_graph_from_input |> test_expanse
