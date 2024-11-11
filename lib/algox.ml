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

type t = { mutable root: node }

let left node =
  CCOption.get_exn_or "No node to the left of this node!" node.left

let right node =
  CCOption.get_exn_or "No node to the right of this node!" node.right

let find ~name ~(items : string list) node =
  let num_items = CCList.length items in
  let cur = ref node in
  let ans = ref None in
  for _ = 1 to num_items + 1 do
    if name = CCOption.get_exn_or "Failed getting name" !cur.name then
      ans := Some !cur
    else
      cur := CCOption.get_exn_or "No node to the right!" !cur.right
  done;
  CCOption.get_exn_or "Could not find id with that name." !ans

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
  { root = node }

let mk ~(items : string list) ~(_options : string list list) : t =
  let itarray = CCArray.of_list items in
  let num_items = CCArray.length itarray in
  let cur = ref (init ()) in
  (* Immutable bindings FTW!*)
  let head = !cur.root in
  (* Process items *)
  for i = 1 to num_items + 1 do
    if i = num_items + 1 then (
      (* Create a circular linked list on top. *)
      !cur.root.right <- Some head;
      head.left <- Some !cur.root;
      cur := { root = head };
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
      cur := { root = new_node }
    )
  done;

  !cur
