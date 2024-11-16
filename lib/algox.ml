type node = {
  id: int;
  top: int option; (* Spacer nodes have non-positive top values *)
  mutable name: string option; (* Spacer nodes and root nodes have no name.*)
  mutable len: int option; (* Only header nodes have length. *)
  mutable up: node option;
  mutable down: node option;
  mutable left: node option; (* Non-header nodes are not linked left/right*)
  mutable right: node option; (* Non-header nodes are not linked left/right*)
}
[@@deriving make]

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

type t = {
  root: node;
  nodes: node list;
  items: string list;
  options: string list list;
}

let pp fpf t =
  let module C = CCFormat in
  let num_items = CCList.length t.items in
  let _option_string_of pp = C.(to_string (some pp)) in
  let main_box =
    let module B = PrintBox in
    let arr = CCArray.make (num_items + 1) B.empty in
    let root_node = ref t.root in
    for i = 0 to num_items do
      arr.(i) <- box !root_node;
      (* B.sprintf "(%d,%s)" !root_node.id
         (_option_string_of C.string !root_node.name); *)
      root_node := right !root_node
    done;
    CCArray.init (num_items + 1) (fun row ->
        Array.init (num_items + 1) (fun col ->
            if row > 0 then
              B.empty
            else
              arr.(col)))
    |> B.grid |> B.frame
  in
  CCFormat.fprintf fpf "%a" PrintBox_text.pp main_box

let find ~name t =
  let num_items = CCList.length t.items in
  let cur = ref t.root in
  let ans = ref None in
  for _ = 1 to num_items + 1 do
    if name = CCOption.get_exn_or "Failed getting name" !cur.name then
      ans := Some !cur
    else
      cur := right !cur
  done;
  CCOption.get_exn_or "Could not find id with that name." !ans

let init ~items ~options () =
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
  { root = node; nodes = []; items; options }

let mk ~(items : string list) ~(options : string list list) : t =
  let itarray = CCArray.of_list items in
  let optarray = CCArray.map CCArray.of_list (CCArray.of_list options) in
  let num_items = CCArray.length itarray in
  let num_options = CCArray.length optarray in
  let node_list = ref [] in
  let cur = ref (init ~items ~options ()) in
  (* Immutable bindings FTW!*)
  let head = !cur.root in
  (* Process items *)
  for i = 1 to num_items + 1 do
    if i = num_items + 1 then (
      (* Create a circular linked list on top. *)
      !cur.root.right <- Some head;
      head.left <- Some !cur.root;
      cur := { root = head; nodes = []; items; options }
    ) else (
      let new_node : node =
        make_node ~id:i ~name:itarray.(i - 1) ~len:0 ~left:!cur.root ()
      in
      !cur.root.right <- Some new_node;
      new_node.up <- Some new_node;
      new_node.down <- Some new_node;
      cur := { root = new_node; nodes = []; items; options }
    )
  done;
  (* Set up first spacer node *)
  let m = ref 0 in
  let spacer_node = ref (make_node ~id:(num_items + 1) ~top:!m ()) in
  let cur_opt = ref optarray.(0) in
  let new_node = ref (make_node ~id:0 ()) in
  let first_node = ref (make_node ~id:0 ()) in
  for n = 1 to num_options do
    let k = CCArray.length !cur_opt in
    for j = 0 to k - 1 do
      let nodej = find ~name:!cur_opt.(j) !cur in
      nodej.len <- CCOption.map (fun x -> x + 1) nodej.len;
      let q = CCOption.get_exn_or "no up node" nodej.up in
      new_node := make_node ~id:(!spacer_node.id + j + 1) ~top:nodej.id ();
      !new_node.up <- Some q;
      q.down <- Some !new_node;
      !new_node.down <- Some nodej;
      nodej.up <- Some !new_node;
      if j = 0 then
        first_node := !new_node
      else
        ();
      if j = k - 1 then (
        m := !m + 1;
        !spacer_node.down <- Some !new_node;
        node_list := !node_list @ [ !spacer_node ];
        spacer_node := make_node ~id:(!new_node.id + 1) ~top:(-1 * !m) ();
        !spacer_node.up <- Some !first_node
      ) else
        ()
    done;

    if n = num_options then
      node_list := !node_list @ [ !spacer_node ]
    else
      cur_opt := optarray.(n)
  done;
  (* Collect all nodes *)
  let header_node = ref (right !cur.root) in
  for _ = 0 to num_items do
    node_list := !node_list @ [ !header_node ];
    header_node := right !header_node
  done;
  let lrroot = ref (right !cur.root) in
  let udroot = ref (up !lrroot) in
  while !lrroot.id != !cur.root.id do
    while !udroot.id != !lrroot.id do
      node_list := !node_list @ [ !udroot ];
      udroot := up !udroot
    done;
    lrroot := right !lrroot;
    udroot := up !lrroot
  done;
  { !cur with nodes = !node_list }
