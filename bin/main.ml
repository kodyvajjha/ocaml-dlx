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
  let cur = Dlx.Algox.mk ~items ~_options:options in
  CCFormat.printf "%a" Dlx.Algox.pp cur
(*
     let node_of = Dlx.Algox.find ~name:"c" cur in
     CCFormat.printf "@.Name: %a, id: %d@."
       CCFormat.(some string)
       node_of.name node_of.id; *)

(* CCFormat.printf "@.Node: %a" CCFormat.(some Dlx.Algox.pp_node) cur.root.right *)
(* print_nodes ~num:7 cur *)
