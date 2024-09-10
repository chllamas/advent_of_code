let bfs = ()

let read_input fp =
  let rec aux res x y =
    match try Some (input_line fp) with End_of_file -> None with
    | Some line -> aux (line :: res) (String.length line) (y + 1)
    | None -> (List.rev res, x, y)
  in
  aux [] 0 0

let create_graph (lst, x, y) = 
        let arr =Array.init y (fun row -> 
                let str = 
        ) in arr

let () = print_endline "Hello, World!"
