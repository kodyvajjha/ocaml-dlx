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
  (* CCFormat.printf "%a@." Dlx.Node.pp_node (Dlx.Node.get ~id:15 cur1); *)
  CCFormat.printf "%a" Dlx.Algox.pp cur1;
  let cur2 = Dlx.Algox.hide 28 cur1 in
  CCFormat.printf "@.%a" Dlx.Algox.pp cur2
(* Dlx.Algox.print_row ~from:12 cur1 *)
