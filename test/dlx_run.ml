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
  (* CCFormat.printf "%a" Dlx.Algox.pp cur; *)
  CCFormat.printf "@.Ans = %a"
    CCFormat.Dump.(list (list string))
    (Dlx.Algox.solve_dlx cur)

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
