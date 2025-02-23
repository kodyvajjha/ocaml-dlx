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
  let opts =
    CCList.map (fun i -> Dlx.Algox.option_of i cur) [ 9; 12; 16; 20; 24; 27 ]
  in
  CCFormat.printf "@.%a" CCFormat.Dump.(list (list string)) opts
