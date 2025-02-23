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
  (* CCFormat.printf "%a" Dlx.Algox.pp cur1;
     CCFormat.printf "@.%a" Dlx.Algox.pp (Dlx.Algox.solve_dlx cur1);
     let opt = Dlx.Algox.option_of 21 cur1 in
     CCFormat.printf "@.Option of 19 = %a" CCFormat.Dump.(list string) opt *)
  let row_nodes = Dlx.Algox.rows_of cur1 6 in
  CCFormat.printf "@.Node list: %a"
    CCFormat.Dump.(list Dlx.Node.pp_node)
    row_nodes
