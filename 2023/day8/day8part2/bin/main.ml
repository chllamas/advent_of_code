let unreachable () =
  print_endline "unreachable code hit";
  exit 1

(*
  //// This proved to be super inefficient, the things looped so we just find exit for each and then calculate LCM
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
*)

let get_starting_tokens tbl =
  Seq.filter (fun k -> Char.equal k.[2] 'A') (Hashtbl.to_seq_keys tbl)
  |> List.of_seq

let tokenize fp =
  let rec aux tbl =
    try
      let sub = String.sub (input_line fp) in
      let key, l, r = (sub 0 3, sub 7 3, sub 12 3) in
      Hashtbl.add tbl key (l, r);
      aux tbl
    with End_of_file -> tbl
  in
  aux (Hashtbl.create 766)

let find_exit tbl str start =
  let rec aux cur i =
    if Char.equal cur.[2] 'Z' then Int64.of_int i
    else
      match (str.[i mod String.length str], Hashtbl.find tbl cur) with
      | 'L', (next, _) -> aux next (i + 1)
      | 'R', (_, next) -> aux next (i + 1)
      | _ -> unreachable ()
  in
  aux start 0

let () =
  let instructions =
    "LRRRLRRLRRLRLRRLRRRLLRRLLRRLRRRLRLRRLLRRLRRLRLRRRLRRRLRLRLRLRRRLRRLRRRLRLRRLLLRLRLLRLRRRLRLRRRLRRRLLLRRLRLRRLRRRLLRRLRRLRRLRRRLRRLRRLRRLRLRRLRLRLRLRLRLRRRLRRLRLLLRRRLRLRRRLRRRLLRRLRRRLRRLRRRLRRRLRLRRRLRRLRLLRRLLRLRRLRLRLLRRLLRRLLRRLRRLRRRLRLRRLRLRRRLRRRLLRLRRLLLLRRRLLRLLLRRLRRRLRRRLRRRLRLRRRLRRRLRRRLRLRRRR"
  in
  let tokens = tokenize (open_in "input.txt") in
  List.map
    (fun tok -> find_exit tokens instructions tok)
    (get_starting_tokens tokens)
  |> List.sort_uniq Int64.compare
  |> List.iter (fun i -> Printf.printf "%s\n" (Int64.to_string i))
(* We print these values and then input theminto an LCM calculator since we don't want to implement ourselves :/ *)
