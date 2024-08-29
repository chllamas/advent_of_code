let create_graph lst =
  let len = List.length lst in
  let calc_index x y = (y * len) + x in
  let arr = Array.init (len * len) (fun _ -> (None, None, -1))
  and up x y = if y > 0 then Some (calc_index x (y - 1)) else None
  and down x y = if y < len - 1 then Some (calc_index x (y + 1)) else None
  and left x y = if x > 0 then Some (calc_index (x - 1) y) else None
  and right x y = if x < len - 1 then Some (calc_index (x + 1) y) else None in
  let rec aux lc y =
    match lc with
    | [] -> arr
    | t :: ts ->
        String.iteri
          (fun x ch ->
            match ch with
            | 'F' -> arr.(calc_index x y) <- (right x y, down x y, -1)
            | 'S' -> arr.(calc_index x y) <- (right x y, down x y, 0)
            | 'L' -> arr.(calc_index x y) <- (up x y, right x y, -1)
            | '|' -> arr.(calc_index x y) <- (up x y, down x y, -1)
            | '-' -> arr.(calc_index x y) <- (left x y, right x y, -1)
            | '7' -> arr.(calc_index x y) <- (left x y, down x y, -1)
            | 'J' -> arr.(calc_index x y) <- (left x y, up x y, -1)
            | _ -> arr.(calc_index x y) <- (None, None, -1))
          t;
        aux ts (y + 1)
  in
  aux lst 0

(* We start at the node that has 0 distance and iterate from there i guess.. *)
let parse_graph arr = 0

let () =
  let rec aux fp lc =
    try aux fp (input_line fp :: lc) with End_of_file -> List.rev lc
  in
  aux (open_in "input.txt") []
  |> create_graph |> parse_graph
  |> Printf.printf "Furthest point is %d\n"
