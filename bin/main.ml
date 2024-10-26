open Dlx
(* let () =
   let open DLList in
   let l = [ 1; 2; 3; 4 ] in
   let dll = mk l in
   CCFormat.printf "@[DLL: %a@.2nd el: %a@]"
     CCFormat.(pp_node int)
     dll
     CCFormat.(pp_node int)
     (nth 4 dll) *)

(* let () =
   let open DLList in
   let l = [ 1; 2; 3; 4 ] in
   let dll = mk l in
   CCFormat.printf "@[1: %a@.@]" CCFormat.(pp_node int) dll;
   let dll2 = remove_nth 0 dll in
   CCFormat.printf "@[@.REMOVED: %a@.@]" CCFormat.(pp_node int) dll2 *)
(* let dll3 = right dll in *)
(* CCFormat.printf "@[3: %a@.@]" CCFormat.(pp_node int) dll3 *)

let () =
  let open Dll.CDLList in
  let l = of_list [ 1; 2; 3; 4; 5 ] in
  (* show_int_node l.head.left; *)
  show_int_node l.head;
  show_int_node l.head.left;
  show_int_node l.head.left.left;
  show_int_node l.head.left.left.left;
  show_int_node l.head.left.left.left.left;
  show_int_node l.head;
  show_int_node l.head.right;
  show_int_node l.head.right.right;
  show_int_node l.head.right.right.right;
  show_int_node l.head.right.right.right.right

let () =
  let open Dll.CDLList in
  let orig = CCList.(0 -- 10000) in
  let l = of_list orig in
  orig = to_list l |> string_of_bool |> print_endline

(* CCFormat.printf "%a" CCFormat.(pp int) l *)
