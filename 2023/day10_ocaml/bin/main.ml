let file_name = "test3.txt"

let create_graph str x_len y_len =
  let up i = i - x_len
  and down i = i + x_len
  and left i = i - 1
  and right i = i + 1 in
  Array.init (x_len * y_len) (fun i ->
      match str.[i] with
      | 'F' -> (right i, down i, -1)
      | 'L' -> (up i, right i, -1)
      | 'J' -> (up i, left i, -1)
      | '7' -> (down i, left i, -1)
      | 'S' -> (down i, right i, 0)
      | '|' -> (up i, down i, -1)
      | '-' -> (left i, right i, -1)
      | '.' -> (-1, -1, -1)
      | _ -> failwith "Unknown character in input")

let parse_graph graph =
  let queue = Queue.create () in
  let rec aux max_dist =
    let validate_neighbor dist node =
      match graph.(node) with
      | a, b, -1 ->
          graph.(node) <- (a, b, dist + 1);
          Queue.push node queue
      | _ -> ()
    in
    match try Some graph.(Queue.pop queue) with Queue.Empty -> None with
    | Some (a, b, dist) ->
        let v = validate_neighbor dist in
        v a;
        v b;
        aux (max max_dist dist)
    | None -> max_dist
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

let print_graph graph x_len =
  let rec aux i =
    match try Some graph.(i) with Invalid_argument _ -> None with
    | Some (_, _, -1) ->
        if i mod x_len == 0 then print_newline ();
        print_char '.';
        aux (i + 1)
    | Some _ ->
        if i mod x_len == 0 then print_newline ();
        print_char '#';
        aux (i + 1)
    | None -> print_newline ()
  in
  aux 0

let raycast graph x i =
  let rec aux i res dt =
    match graph.(i) with
    | _, _, d when d > -1 && i mod x > 0 ->
        if dt == -1 || abs (dt - d) != 1 then aux (i - 1) (res + 1) d
        else aux (i - 1) res d
    | _, _, d when d > -1 && i mod x == 0 && (dt == -1 || abs (dt - d) != 1) ->
        (res + 1) mod 2
    | _, _, -1 when i mod x > 0 -> aux (i - 1) res (-1)
    | _ -> res mod 2
  in
  aux i 0 (-1)

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
      | _, _, -1 -> (acc + raycast i, i + 1)
      | _, _, _ -> (acc, i + 1))
    (0, 0) graph
  |> fst
  |> Printf.printf "Enclosed tiles is %d\n"
