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
  Dlx.Algox.cover 1 cur;
  Dlx.Algox.uncover 1 cur;
  Dlx.Algox.cover 2 cur;
  Dlx.Algox.uncover 2 cur;
  Dlx.Algox.cover 3 cur;
  Dlx.Algox.uncover 3 cur;
  Dlx.Algox.cover 4 cur;
  Dlx.Algox.uncover 4 cur;
  Dlx.Algox.cover 5 cur;
  Dlx.Algox.uncover 5 cur;
  Dlx.Algox.cover 6 cur;
  Dlx.Algox.uncover 6 cur;
  Dlx.Algox.cover 7 cur;
  Dlx.Algox.uncover 7 cur;
  CCFormat.printf "%a" Dlx.Algox.pp cur
