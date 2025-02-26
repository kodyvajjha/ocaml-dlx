let () =
  let items = [ "1"; "2"; "3"; "s1"; "s2"; "s3"; "s4"; "s5"; "s6" ] in
  let options =
    [
      [ "1"; "s1"; "s3" ];
      [ "1"; "s2"; "s4" ];
      [ "1"; "s3"; "s5" ];
      [ "1"; "s4"; "s6" ];
      [ "2"; "s1"; "s4" ];
      [ "2"; "s2"; "s5" ];
      [ "2"; "s3"; "s6" ];
      [ "3"; "s1"; "s5" ];
      [ "3"; "s2"; "s6" ];
    ]
  in
  let cur = Dlx.Algox.mk ~items ~options in
  CCFormat.printf "Items = %a@.Options = %a@.Solution(s) = %a"
    CCFormat.Dump.(list string)
    cur.items
    CCFormat.Dump.(list (list string))
    cur.options
    CCFormat.Dump.(list (list (list string)))
    (Dlx.Algox.solve_dlx cur)
