let expanse_multiplier = 1_000_000

let read_graph_from_input fp =
  let rec aux lc =
    match try Some (input_line fp) with End_of_file -> None with
    | Some line -> aux (line :: lc)
    | None -> List.rev lc
  in
  aux []

let find_expanses graph =
  let x_arr = ref [] and y_arr = ref [] in
  Array.iteri
    (fun i _ ->
      if Array.for_all (fun row -> row.(i) == '.') graph then
        x_arr := i :: !x_arr)
    graph.(0);
  Array.iteri
    (fun i row ->
      if Array.for_all (fun x -> x == '.') row then y_arr := i :: !y_arr)
    graph;
  (!x_arr, !y_arr)

let solve_graph (graph : char array array)
    ((x_expanses : int list), (y_expanses : int list)) =
  let expansions (a, b) (x, y) =
    List.fold_left
      (fun acc cmp ->
        if (cmp >= a && cmp <= x) || (cmp >= x && cmp <= a) then
          acc + (expanse_multiplier - 1)
        else acc)
      0 x_expanses
    + List.fold_left
        (fun acc cmp ->
          if (cmp >= y && cmp <= b) || (cmp >= b && cmp <= y) then
            acc + (expanse_multiplier - 1)
          else acc)
        0 y_expanses
  in
  let dist_between ((sx, sy) as a) ((dx, dy) as b) =
    abs (sx - dx) + abs (sy - dy) + expansions a b
  in
  let num_galaxies =
    Array.fold_left
      (fun acc row ->
        Array.fold_left
          (fun acc ch -> if ch == '#' then acc + 1 else acc)
          acc row)
      0 graph
  in
  let rec calc_distances res = function
    | [] | [ _ ] -> res
    | galaxy_a :: xs ->
        calc_distances
          (res
          + List.fold_left
              (fun acc galaxy_b -> acc + dist_between galaxy_a galaxy_b)
              0 xs)
          xs
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
  calc_distances 0 (galaxies |> Array.to_list)

let () =
  let graph =
    open_in "input.txt" |> read_graph_from_input
    |> List.map (fun str -> str |> String.to_seq |> Array.of_seq)
    |> Array.of_list
  in
  solve_graph graph (find_expanses graph)
  |> Printf.printf "The summation is %d\n"
