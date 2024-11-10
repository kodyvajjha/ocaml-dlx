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
  CCOption.iter print_endline cur.root.name;
  CCOption.iter print_endline
    CCOption.(
      let* node = cur.root.left in
      node.name);
  CCOption.iter print_endline
    CCOption.(
      let* node1 = cur.root.left in
      let* node2 = node1.left in
      node2.name)
