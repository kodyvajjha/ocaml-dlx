type node = {
  id: int;
  mutable name: string option; (* Spacer nodes and root nodes have no name.*)
  mutable len: int option; (* Only header nodes have length. *)
  mutable top: node;
  mutable bottom: node;
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
      top = node;
      bottom = node;
      left = Some node;
      right = Some node;
    }
  in
  { root = node }

let mk ~(items : string list) ~(options : string list list) : t =
  let _init = init () in
  _init
