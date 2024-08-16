let scan_num str =
        Scanf.sscanf str "%d" (fun i -> i);;

(*
let is_invalid lst target =
        let tbl = Hashtbl.create (List.length lst) in
        let rec aux tbl lst target = match lst with
                | [] -> true
                | t :: ts -> 
                        let complement = target - t in
                        if Hashtbl.mem tbl complement then
                                false
                        else
                                (
                                        Hashtbl.add tbl t ();
                                        aux tbl ts target
                                )
        in
        aux tbl lst target;;

let () =
        let rec aux fp queue idx =
                match idx with
                | i when (i < 25) -> Queue.push (scan_num (input_line fp)) queue;
                        aux fp queue (i+1)
                | i -> let num = (scan_num (input_line fp)) in
                        if is_invalid (queue |> Queue.to_seq |> List.of_seq) num then
                                num
                        else
                                let _ = Queue.pop queue in
                                Queue.push num queue;
                                aux fp queue (i+1)
        in
        Printf.printf "First number is: %d\n" (aux (open_in "input.txt") (Queue.create ()) 0)
*)


let () =
        let rec aux fp idx arr acc l r =
                if r - l < 2 then
                        (
                                match r with
                                | _ when (r == idx) -> arr.(r) <- scan_num (input_line fp);
                                        aux fp (idx+1) arr (acc+(arr.(r))) l (r+1)
                                | right -> 0

                        )
                else
                        0
        in
        Printf.printf "Sum is: %d\n" (aux (open_in "input.txt") 0 (Array.init 1000 (fun _ -> 0)) 0 0 0)
