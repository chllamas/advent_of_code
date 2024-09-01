let file_name = "test.txt"

let create_graph str x_len y_len =
  let up i = if i >= x_len then Some (i - x_len) else None
  and down i = if i < x_len * (x_len - 1) then Some (i + x_len) else None
  and left i = if i mod x_len > 0 then Some (i - 1) else None
  and right i = if i mod x_len < x_len - 1 then Some (i + 1) else None in
  Array.init (x_len * y_len) (fun i ->
      match str.[i] with
      | 'F' -> (right i, down i, -1)
      | 'L' -> (up i, right i, -1)
      | 'J' -> (up i, left i, -1)
      | '7' -> (down i, left i, -1)
      | 'S' -> (down i, up i, 0)
      | '|' -> (up i, down i, -1)
      | '-' -> (left i, right i, -1)
      | '.' -> (None, None, -1)
      | _ -> failwith "Unknown character in input")

let parse_graph graph =
  let queue = Queue.create () in
  let rec aux max_dist =
    let validate_neighbor node_opt dist =
      if Option.is_some node_opt then
        let node = Option.get node_opt in
        match graph.(node) with
        | a, b, -1 ->
            graph.(node) <- (a, b, dist + 1);
            Queue.push node queue
        | _ -> ()
    in
    match try Some graph.(Queue.pop queue) with Queue.Empty -> None with
    | Some (a, b, dist) ->
        validate_neighbor a dist;
        validate_neighbor b dist;
        aux (max max_dist dist)
    | _ -> max_dist
  in
  Queue.push
    (Option.get (graph |> Array.find_index (fun (_, _, x) -> x == 0)))
    queue;
  aux 0

(* Run parse graph and drop the value, we just need the graph to be updated with the loop, then we
   iterate the graph and check if it's visited then its an edge, if it's not visited we do the raycasting
     and add it to the count if its inside *)

(*
let () =
  let rec aux fp str len =
    match try Some (input_line fp) with End_of_file -> None with
    | Some line -> aux fp (str ^ line) (String.length line)
    | None -> (str, len)
  in
  aux (open_in "input.txt") "" 0
  |> create_graph |> parse_graph
  |> Printf.printf "Furthest point is %d\n"
  *)

let raycast graph row_len i =
  let rec aux i res dt =
    match graph.(i) with
    | _, _, d when i mod row_len > 0 && d > -1 ->
        if abs (dt - d) == 1 then aux (i - 1) res d else aux (i - 1) (res + 1) d
    | _, _, d when i mod row_len == 0 && d > -1 ->
        if abs (dt - d) == 1 then res mod 2 == 1 else (res + 1) mod 2 == 1
    | _, _, -1 when i mod row_len == 0 -> res mod 2 == 1
    | _, _, -1 when i mod row_len > 0 -> aux (i - 1) res (-2)
    | _ -> failwith "How can it be negative?"
  in
  let res = aux i 0 (-2) in
  if res then
    let _ =
      Printf.printf "Coord (%d) enclosed and has value dist of %d\n" (i + 1)
        (match graph.(i + 1) with _, _, d -> d)
    in
    res
  else res

let parse_file fp =
  let rec aux res x y =
    match try Some (input_line fp) with End_of_file -> None with
    | Some line -> aux (res ^ line) (String.length line) (y + 1)
    | None -> (res, x, y)
  in
  aux "" 0 0

let () =
  let file_text, len_x, len_y = parse_file (open_in file_name) in
  let graph = create_graph file_text len_x len_y in
  let _ = parse_graph graph and raycast = raycast graph len_x in
  Array.fold_left
    (fun (acc, i) -> function
      | _, _, -1 when i mod len_x > 0 ->
          ((acc + if raycast (i - 1) then 1 else 0), i + 1)
      | _, _, _ -> (acc, i + 1))
    (0, 0) graph
  |> fst
  |> Printf.printf "Enclosed tiles is %d\n"
