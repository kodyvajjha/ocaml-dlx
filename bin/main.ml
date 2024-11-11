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
      let* node = cur.root.right in
      node.name);
  CCOption.iter print_endline
    CCOption.(
      let* node = cur.root.left in
      node.name)

let () =
  let items = [ "a"; "b"; "c"; "d"; "e"; "f"; "g"; "i" ] in
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
  let node_of = Dlx.Algox.find ~name:"i" ~items cur.root in
  CCFormat.printf "@.Name: %a, id: %d"
    CCFormat.(some string)
    node_of.name node_of.id
