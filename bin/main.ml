let () = Printexc.record_backtrace true

let () =
  let items = [ "a"; "b"; "c"; "d"; "e"; "f"; "g" ] in
  let options =
    [ [ "c"; "e" ]; [ "b"; "f" ]; [ "a"; "d"; "g" ]; [ "d" ]; [ "a"; "g" ] ]
  in
  let cur = Dlx.Algox.mk ~items ~options in
  CCFormat.printf "Items = %a@.Options = %a@.Solution = %a"
    CCFormat.Dump.(list string)
    cur.items
    CCFormat.Dump.(list (list string))
    cur.options
    CCFormat.Dump.(list (list (list string)))
    (Dlx.Algox.solve_dlx cur)
