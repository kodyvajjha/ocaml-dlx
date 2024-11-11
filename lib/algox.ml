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

type t = { mutable root: node }

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

let mk_node old name : node =
  let new_node : node =
    {
      id = old.id + 1;
      top = None;
      name = Some name;
      len = None;
      up = None;
      down = None;
      left = Some old;
      right = None;
    }
  in
  old.right <- Some new_node;
  new_node.up <- Some new_node;
  new_node.down <- Some new_node;
  new_node

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
      let _spacer_node : node =
        {
          id = i;
          top = Some 0;
          name = None;
          len = None;
          up = Some head;
          down = None;
          left = None;
          right = None;
        }
      in
      ()
      (* cur := { root = spacer_node } *)
    ) else (
      let new_node : node =
        {
          id = i;
          top = None;
          name = Some itarray.(i - 1);
          len = Some 0;
          up = None;
          down = None;
          left = Some !cur.root;
          right = None;
        }
      in
      !cur.root.right <- Some new_node;
      new_node.up <- Some new_node;
      new_node.down <- Some new_node;
      cur := { root = new_node }
    )
  done;
  !cur
