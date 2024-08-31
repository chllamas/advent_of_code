let create_graph (str, len) =
  let up i = if i >= len then Some (i - len) else None
  and down i = if i < len * (len - 1) then Some (i + len) else None
  and left i = if i mod len > 0 then Some (i - 1) else None
  and right i = if i mod len < len - 1 then Some (i + 1) else None in
  Array.init (len * len) (fun i ->
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

let () =
  let rec aux fp str len =
    match try Some (input_line fp) with End_of_file -> None with
    | Some line -> aux fp (str ^ line) (String.length line)
    | None -> (str, len)
  in
  let graph = aux (open_in "input.txt") "" 0 |> create_graph in
  let _ = parse_graph graph in
  (* Right here we do the raycasting *)
  Array.fold_left (fun acc (a, b, dist) -> 0) 0 graph
  |> Printf.printf "Enclosed tiles is %d\n"
