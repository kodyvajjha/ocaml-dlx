type t = {
  name: string option; (* Spacer nodes and root nodes have no name.*)
  mutable id: int;
  mutable top: int option; (* Spacer nodes have non-positive top values *)
  mutable len: int option; (* Only header nodes have length. *)
  mutable up: t option;
  mutable down: t option;
  mutable left: t option; (* Non-header nodes are not linked left/right*)
  mutable right: t option; (* Non-header nodes are not linked left/right*)
}
[@@deriving make]

let init () =
  let rec node =
    {
      id = 0;
      top = None;
      name = Some "HEAD";
      len = None;
      up = Some node;
      down = Some node;
      left = Some node;
      right = Some node;
    }
  in
  node

let left node =
  CCOption.get_exn_or "No node to the left of this node!" node.left

let right node =
  CCOption.get_exn_or "No node to the right of this node!" node.right

let up node = CCOption.get_exn_or "No node to the up of this node!" node.up

let down node =
  CCOption.get_exn_or "No node to the down of this node!" node.down

let box node =
  let module B = PrintBox in
  let module C = CCFormat in
  let option_string_of pp = C.(to_string (some pp)) in
  let id = node.id in
  let top = option_string_of C.int node.top in
  let name = option_string_of C.string node.name in
  let len = option_string_of C.int node.len in

  let up_id = option_string_of C.int (CCOption.map (fun x -> x.id) node.up) in
  let down_id =
    option_string_of C.int (CCOption.map (fun x -> x.id) node.down)
  in
  let left_id =
    option_string_of C.int (CCOption.map (fun x -> x.id) node.left)
  in
  let right_id =
    option_string_of C.int (CCOption.map (fun x -> x.id) node.right)
  in
  B.(
    frame
    @@ vlist
         [
           hlist ~bars:false [ text " "; int id; text " " ];
           hlist [ text ("TOP:" ^ top); text name; text ("LEN:" ^ len) ];
           hlist
             [
               vlist [ text "U"; text up_id ];
               vlist [ text "D"; text down_id ];
               vlist [ text "L"; text left_id ];
               vlist [ text "R"; text right_id ];
             ];
         ])

let pp_node fpf node = CCFormat.fprintf fpf "%a" PrintBox_text.pp (box node)

let show_node node = CCFormat.printf "%a" pp_node node
