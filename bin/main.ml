let () = Printexc.record_backtrace true
(* let () =
   let items = [ "a"; "b"; "c"; "d"; "e"; "f"; "g" ] in
   let options =
     [
       [ "c"; "e" ];
       [ "a"; "d"; "g" ];
       [ "b"; "c"; "f" ];
       [ "a"; "d"; "f" ];
       [ "b"; "g" ];
       [ "d"; "e"; "g" ];
     ]
   in
   let cur = Dlx.Algox.mk ~items ~_options:options in
   CCOption.iter print_endline cur.root.name;
   CCOption.iter print_endline
     CCOption.(
       let* node = cur.root.right in
       node.name);
   CCOption.iter print_endline
     CCOption.(
       let* node = cur.root.left in
       node.name) *)

let () =
  let items = [ "a"; "b"; "c"; "d"; "e"; "f"; "g"; "h"; "i" ] in
  let options =
    [
      [ "c"; "e"; "h" ];
      [ "a"; "d"; "g" ];
      [ "b"; "c"; "f" ];
      [ "a"; "d"; "f"; "i" ];
      [ "b"; "g" ];
      [ "d"; "e"; "g" ];
    ]
  in
  let cur = Dlx.Algox.mk ~items ~options in
  (* CCFormat.printf "%a" Dlx.Algox.pp cur; *)
  CCFormat.printf "@.Ans = %a"
    CCFormat.Dump.(list (list string))
    (Dlx.Algox.solve_dlx cur)

(* let row_nodes = Dlx.Algox.rows_of cur1 6 in
   CCFormat.printf "@.Node list: %a"
     CCFormat.Dump.(list Dlx.Node.pp_node)
     row_nodes *)
