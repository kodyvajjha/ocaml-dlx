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

(* let _print_nodes ~num (root : Dlx.Algox.t) =
   let cur = ref root in
   for _ = 0 to num do
     CCFormat.printf "@.%a" Dlx.Algox.pp_node !cur.root;
     CCFormat.printf "<->";
     cur := { root = CCOption.get_exn_or "No node to right!" !cur.root.right }
   done *)

let () =
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
  let cur1 = Dlx.Algox.mk ~items ~options in
  (* CCFormat.printf "%a@." Dlx.Algox.pp_node (Dlx.Algox.get ~id:15 cur1) *)
  CCFormat.printf "%a" Dlx.Algox.pp cur1;
  let cur2 = Dlx.Algox.hide 13 cur1 in
  CCFormat.printf "@.%a" Dlx.Algox.pp cur2
