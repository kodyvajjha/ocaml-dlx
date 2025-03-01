(* Menages problem for n=4 *)

let () =
  let items = [ "M0"; "M1"; "M2"; "M3"; "S0"; "S1"; "S2"; "S3" ] in
  let options =
    [
      [ "S0"; "M1" ];
      [ "S0"; "M2" ];
      [ "S1"; "M2" ];
      [ "S1"; "M3" ];
      [ "S2"; "M0" ];
      [ "S2"; "M3" ];
      [ "S3"; "M0" ];
      [ "S3"; "M1" ];
    ]
  in
  let cur = Dlx.Algox.mk ~items ~options in
  let solution = Dlx.Algox.solve_dlx cur in
  CCFormat.printf "@.Solutions = %a @.Number of solutions = %d"
    CCFormat.Dump.(list (list (list string)))
    solution (CCList.length solution)
