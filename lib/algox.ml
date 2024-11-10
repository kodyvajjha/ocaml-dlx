type node = {
  id: int;
  mutable name: string option; (* Spacer nodes and root nodes have no name.*)
  mutable len: int option; (* Only header nodes have length. *)
  mutable top: node option;
  mutable bottom: node option;
  mutable left: node option; (* Non-header nodes are not linked left/right*)
  mutable right: node option; (* Non-header nodes are not linked left/right*)
}

type t = { mutable root: node }

let init () =
  let rec node =
    {
      id = 0;
      name = None;
      len = None;
      top = Some node;
      bottom = Some node;
      left = Some node;
      right = Some node;
    }
  in
  { root = node }

let mk_node old name : node =
  let new_node : node =
    {
      id = old.id + 1;
      name = Some name;
      len = None;
      top = None;
      bottom = None;
      left = Some old;
      right = None;
    }
  in
  old.right <- Some new_node;
  new_node.top <- Some new_node;
  new_node.bottom <- Some new_node;
  new_node

let mk ~(items : string list) ~(_options : string list list) : t =
  let itarray = CCArray.of_list items in
  let num_items = CCArray.length itarray in
  let cur = ref (init ()) in
  for i = 1 to num_items do
    let new_node : node =
      {
        id = i;
        name = Some itarray.(i - 1);
        len = None;
        top = None;
        bottom = None;
        left = Some !cur.root;
        right = None;
      }
    in
    !cur.root.right <- Some new_node;
    new_node.top <- Some new_node;
    new_node.bottom <- Some new_node;
    new_node.left <- Some !cur.root;
    cur := { root = new_node }
  done;
  !cur
