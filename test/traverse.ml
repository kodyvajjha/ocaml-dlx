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
  let cur = Dlx.Algox.mk ~items ~options in

  let node_of = Dlx.Algox.find_header_node ~name:"c" ~items cur.root in
  CCFormat.printf "@.Name: %a, id: %d@."
    CCFormat.(some string)
    node_of.name node_of.id
