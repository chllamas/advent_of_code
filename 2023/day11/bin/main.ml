let read_graph_from_input fp =
  let rec aux lc =
    match try Some (input_line fp) with End_of_file -> None with
    | Some line -> aux (line :: lc)
    | None -> List.rev lc
  in
  aux []

let expand_graph lst =
  let is_empty_row str = String.for_all (fun ch -> ch == '.') str
  and is_empty_col lst i =
    List.for_all (fun str -> Char.equal '.' str.[i]) lst
  in
  let expand_rows lst =
    let rec aux st = function
      | [] -> List.rev st
      | x :: xs ->
          if is_empty_row x then aux (x :: String.map (fun _ -> '.') x :: st) xs
          else aux (x :: st) xs
    in
    aux [] lst
  and expand_cols lst =
    let n = String.length (List.hd lst) in
    let rec aux i st =
      match i with
      | _ when i == n ->
          List.map (fun lc -> lc |> List.rev |> List.to_seq |> String.of_seq) st
      | _ ->
          let is_empty = is_empty_col lst i in
          aux (i + 1)
            (List.map2
               (fun src_str des_lst ->
                 if is_empty then '.' :: src_str.[i] :: des_lst
                 else src_str.[i] :: des_lst)
               lst st)
    in
    aux 0 (List.map (fun _ -> []) lst)
  in
  lst |> expand_rows |> expand_cols

let solve_graph graph =
  print_endline "Solving...";
  let gy = Array.length graph
  and gx = Array.length graph.(0)
  and create_name x y = Printf.sprintf "%d,%d" x y in
  Printf.printf "Working with a graph of size %d %d\n" gx gy;
  let within_bounds x y = x >= 0 && x < gx && y >= 0 && y < gy in
  let dist_between (sx, sy) (dx, dy) =
    let visited = Hashtbl.create (gx * gy) and q = Queue.create () in
    let exists x y = Hashtbl.mem visited (create_name x y) in
    let mark dist x y =
      if within_bounds x y && not (exists x y) then
        let _ = Queue.push (x, y, dist + 1) q in
        Hashtbl.add visited (create_name x y) true
      else ()
    in
    let rec bfs () =
      (* We not checking for empty queue because this will end by the time we reach the destination node *)
      match Queue.pop q with
      | x, y, dist when x == dx && y == dy -> dist
      | x, y, dist ->
          let m = mark dist in
          m (x - 1) y;
          m (x + 1) y;
          m x (y - 1);
          m x (y + 1);
          bfs ()
    in
    mark (-1) sx sy;
    bfs ()
  in
  let threads = ref []
  and res_lock = Mutex.create ()
  and res = ref 0
  and finished_galaxies = ref 0 in
  let num_galaxies =
    Array.fold_left
      (fun acc row ->
        Array.fold_left
          (fun acc ch -> if ch == '#' then acc + 1 else acc)
          acc row)
      0 graph
  in
  let rec calc_distances galaxies i n =
    let node = galaxies.(i) and
    split = match n - 1 - i with
  | x when x > 200 -> 4
    | x when x > 150 -> 3
    | x when x > 100 -> 2
    | _ -> 1
  in


    | [] | [ _ ] -> List.iter (fun t -> Domain.join t) !threads
    | t when List.length !threads == 4 ->
        List.iter (fun t -> Domain.join t) !threads;
        threads := [];
        calc_distances t
    | galaxy_a :: xs ->
        threads :=
          Domain.spawn (fun () ->
              let sum =
                List.fold_left
                  (fun acc galaxy_b -> acc + dist_between galaxy_a galaxy_b)
                  0 xs
              in
              Mutex.lock res_lock;
              res := !res + sum;
              finished_galaxies := !finished_galaxies + 1;
              Printf.printf "Progress %d of %d galaxies ... %.2f%%\n"
                !finished_galaxies num_galaxies
                (Float.div
                   (Int.to_float !finished_galaxies)
                   (Int.to_float num_galaxies));
              Mutex.unlock res_lock)
          :: !threads;
        calc_distances xs
  in
  let index = ref 0 and galaxies = Array.init num_galaxies (fun _ -> (0, 0)) in
  Array.iteri
    (fun y row ->
      Array.iteri
        (fun x ch ->
          if ch = '#' then (
            galaxies.(!index) <- (x, y);
            index := !index + 1))
        row)
    graph;
  calc_distances galaxies 0 num_galaxies;
  !res

(*
let test_expanse graph =
  try
    if
      List.for_all2
        (fun str1 str2 -> String.equal str1 str2)
        graph
        (open_in "test_expanse.txt" |> read_graph_from_input)
    then print_endline "The expanse was good"
    else print_endline "The expanse was wrong"
  with Invalid_argument _ ->
    print_endline "Expanse failed due to differing lengths"
*)

(*
let print_graph graph =
  Array.iter
    (fun str ->
      print_string str;
      print_newline ())
    graph
*)

let () =
  open_in "input.txt" |> read_graph_from_input |> expand_graph
  |> List.map (fun str -> str |> String.to_seq |> Array.of_seq)
  |> Array.of_list |> solve_graph
  |> Printf.printf "The summation is %d\n"
