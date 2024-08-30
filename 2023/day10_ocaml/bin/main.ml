let create_graph lst =
  let len = List.length lst in
  let calc_index x y = (y * len) + x in
  let arr = Array.init (len * len) (fun _ -> (None, None, -1))
  and up x y = if y > 0 then Some (calc_index x (y - 1)) else None
  and down x y = if y < len - 1 then Some (calc_index x (y + 1)) else None
  and left x y = if x > 0 then Some (calc_index (x - 1) y) else None
  and right x y = if x < len - 1 then Some (calc_index (x + 1) y) else None in
  let rec aux lc y =
    try
      lc |> List.hd
      |> String.iteri (fun x ch ->
             match ch with
             | 'F' -> arr.(calc_index x y) <- (right x y, down x y, -1)
             | 'S' -> arr.(calc_index x y) <- (right x y, down x y, 0)
             | 'L' -> arr.(calc_index x y) <- (up x y, right x y, -1)
             | '|' -> arr.(calc_index x y) <- (up x y, down x y, -1)
             | '-' -> arr.(calc_index x y) <- (left x y, right x y, -1)
             | '7' -> arr.(calc_index x y) <- (left x y, down x y, -1)
             | 'J' -> arr.(calc_index x y) <- (left x y, up x y, -1)
             | _ -> arr.(calc_index x y) <- (None, None, -1));
      aux (List.tl lc) (y + 1)
    with Failure _ -> arr
  in
  aux lst 0

let parse_graph (graph : (int option * int option * int) array) =
  let queue = Queue.create () in
  let rec aux max_dist =
    let validate_neighbor node dist =
      if Option.is_none node then ()
      else
        match graph.(Option.get node) with
        | a, b, -1 ->
            graph.(Option.get node) <- (a, b, dist + 1);
            Queue.push (Option.get node) queue
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

let () =
  let rec aux fp lc =
    try aux fp (input_line fp :: lc) with End_of_file -> List.rev lc
  in
  aux (open_in "test.txt") []
  |> create_graph |> parse_graph
  |> Printf.printf "Furthest point is %d\n"
