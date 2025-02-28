(*
  Supply the following ASCII puzzle to the sudoku binary accompanying this file.
  
   ..3.1....
   415....9.
   2.65..3..
   5...8...9
   .7.9...32
   .38..4.6.
   ...26.4.3
   ...3....8
   32...795.

   That binary file produces the items and options used by DLX. 
*)
module Parse = struct
  open CCParse

  let token =
    take_if (function
      | 'a' .. 'z' | '0' .. '9' -> true
      | _ -> false)
    >|= Slice.to_string

  (* Parser for a space-separated list of tokens *)
  let token_list = sep ~by:(char ' ') token

  (* Parser for the entire input: first line, then multiple lines *)
  let parser =
    let line = token_list <* endline in
    let+ first_line = line and+ rest_lines = many line in
    first_line, rest_lines
end

let () =
  let res =
    let open CCResult in
    let+ items, options = CCParse.parse_file Parse.parser "bin/problem.txt" in
    items, options
  in
  match res with
  | Ok (items, options) ->
    CCFormat.printf "@.(Items,Options) : %a@."
      CCFormat.Dump.(CCResult.pp (pair (list string) (list (list string))))
      res;
    let cur = Dlx.Algox.mk ~items ~options in
    let sols = Dlx.Algox.solve_dlx cur in
    CCFormat.printf "@.Solutions : %a"
      CCFormat.Dump.(list (list (list string)))
      sols
  | Error _ -> failwith "parsing failed"
