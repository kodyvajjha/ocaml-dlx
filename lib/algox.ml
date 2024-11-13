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

let box node =
  let module B = PrintBox in
  let module C = CCFormat in
  let option_string_of pp = C.(to_string (some pp)) in
  let id = node.id in
  let top = option_string_of C.int node.top in
  let name = option_string_of C.string node.name in
  let len = option_string_of C.int node.len in

  B.(
    frame
    @@ vlist
         [
           hlist ~bars:false [ text " "; int id; text " " ];
           hlist [ text top; text name; text len ];
         ])

let pp_node fpf node = CCFormat.fprintf fpf "%a" PrintBox_text.pp (box node)

type t = {
  mutable root: node;
  items: string list;
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

let init ~items () =
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
  { root = node; items }

let mk ~(items : string list) ~(_options : string list list) : t =
  let itarray = CCArray.of_list items in
  let optarray = CCArray.map CCArray.of_list (CCArray.of_list _options) in
  let num_items = CCArray.length itarray in
  let num_options = CCArray.length optarray in
  let cur = ref (init ~items ()) in
  (* Immutable bindings FTW!*)
  let head = !cur.root in
  (* Process items *)
  for i = 1 to num_items + 1 do
    if i = num_items + 1 then (
      (* Create a circular linked list on top. *)
      !cur.root.right <- Some head;
      head.left <- Some !cur.root;
      cur := { root = head; items };
      (* Set up spacer node *)
      let _spacer_node : node = make_node ~id:i ~top:0 () in
      ()
    ) else (
      let new_node : node =
        make_node ~id:i ~name:itarray.(i - 1) ~len:0 ~left:!cur.root ()
      in
      !cur.root.right <- Some new_node;
      new_node.up <- Some new_node;
      new_node.down <- Some new_node;
      cur := { root = new_node; items }
    )
  done;
  let cur_opt = ref optarray.(0) in
  for n = 1 to num_options do
    let k = CCArray.length !cur_opt in
    for j = 0 to k - 1 do
      let node = find ~name:!cur_opt.(j) !cur in
      node.len <- CCOption.map (fun x -> x + 1) node.len
    done;
    if n = num_options then
      ()
    else
      cur_opt := optarray.(n)
  done;
  !cur
