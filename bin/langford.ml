let generate_items n =
  let nums = List.init n (fun i -> string_of_int (i + 1)) in
  let slots = List.init (2 * n) (fun i -> "s" ^ string_of_int (i + 1)) in
  nums @ slots

let generate_options n =
  let rec generate k acc =
    if k > n then
      acc
    else (
      let rec place i acc =
        if i + k + 1 >= 2 * n then
          acc
        else (
          let option =
            [
              string_of_int k;
              "s" ^ string_of_int (i + 1);
              "s" ^ string_of_int (i + k + 2);
            ]
          in
          place (i + 1) (option :: acc)
        )
      in
      generate (k + 1) (place 0 acc)
    )
  in
  generate 1 []

(* Compare https://oeis.org/A014552 *)
let () =
  let n = 16 in
  let items = generate_items n in
  let options = generate_options n in
  CCFormat.printf "@.Setting up data structure....";
  let cur = Dlx.Algox.mk ~items ~options in
  CCFormat.printf "@.Starting....";
  CCFormat.printf "Items = %a@.Options = %a@.Solution(s) = %d"
    CCFormat.Dump.(list string)
    cur.items
    CCFormat.Dump.(list (list string))
    cur.options
    (* CCFormat.Dump.(list (list (list string))) *)
    (CCList.length (Dlx.Algox.solve_dlx cur))
