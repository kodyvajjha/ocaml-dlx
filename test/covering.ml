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
  let cur = Dlx.Algox.cover 1 cur in
  let cur = Dlx.Algox.uncover 1 cur in
  let cur = Dlx.Algox.cover 2 cur in
  let cur = Dlx.Algox.uncover 2 cur in
  let cur = Dlx.Algox.cover 3 cur in
  let cur = Dlx.Algox.uncover 3 cur in
  let cur = Dlx.Algox.cover 4 cur in
  let cur = Dlx.Algox.uncover 4 cur in
  let cur = Dlx.Algox.cover 5 cur in
  let cur = Dlx.Algox.uncover 5 cur in
  let cur = Dlx.Algox.cover 6 cur in
  let cur = Dlx.Algox.uncover 6 cur in
  let cur = Dlx.Algox.cover 7 cur in
  let cur = Dlx.Algox.uncover 7 cur in
  CCFormat.printf "%a" Dlx.Algox.pp cur
