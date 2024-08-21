let unreachable () =
  print_endline "unreachable code hit";
  exit 1

let do_step lst ch tbl =
  let rec aux lc st is_end =
    match lc with
    | [] -> (st, is_end)
    | x :: xs -> (
        match (ch, Hashtbl.find tbl x) with
        | 'L', (next, _) ->
            aux xs (next :: st) (is_end && Char.equal next.[2] 'Z')
        | 'R', (_, next) ->
            aux xs (next :: st) (is_end && Char.equal next.[2] 'Z')
        | _ -> unreachable ())
  in
  aux lst [] true

let solve tbl lst str =
  let rec aux lc st i =
    match do_step lc str.[i] tbl with
    | _, true -> st + 1
    | res, false -> aux res (st + 1) ((i + 1) mod String.length str)
  in
  aux lst 0 0

let get_starting_tokens tbl =
  Seq.filter (fun k -> Char.equal k.[2] 'A') (Hashtbl.to_seq_keys tbl)
  |> List.of_seq

let tokenize fp =
  let rec aux tbl =
    try
      let key, l, r =
        Scanf.sscanf (input_line fp) "%s = (%s%, %s)" (fun a b c -> (a, b, c))
      in
      Hashtbl.add tbl key (l, r);
      aux tbl
    with End_of_file -> tbl
  in
  aux (Hashtbl.create 766)

let () =
  let instructions =
    "LRRRLRRLRRLRLRRLRRRLLRRLLRRLRRRLRLRRLLRRLRRLRLRRRLRRRLRLRLRLRRRLRRLRRRLRLRRLLLRLRLLRLRRRLRLRRRLRRRLLLRRLRLRRLRRRLLRRLRRLRRLRRRLRRLRRLRRLRLRRLRLRLRLRLRLRRRLRRLRLLLRRRLRLRRRLRRRLLRRLRRRLRRLRRRLRRRLRLRRRLRRLRLLRRLLRLRRLRLRLLRRLLRRLLRRLRRLRRRLRLRRLRLRRRLRRRLLRLRRLLLLRRRLLRLLLRRLRRRLRRRLRRRLRLRRRLRRRLRRRLRLRRRR"
  in
  let _ = print_endline "tarting tokens" in
  let tokens = tokenize (open_in "input.txt") in
  print_endline "Finished tokens";
  Printf.printf "Steps taken: %d\n"
    (solve tokens (get_starting_tokens tokens) instructions)
