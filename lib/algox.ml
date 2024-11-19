type node = {
  name: string option; (* Spacer nodes and root nodes have no name.*)
  mutable id: int;
  mutable top: int option; (* Spacer nodes have non-positive top values *)
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

(** Get the node with specified id. *)
let get ~id t = CCList.nth t.nodes id

(** Get the row and column of sparse matrix representing the node in question. Used mainly for printing. *)
let rowcol t node =
  let node_array = CCArray.of_list t.nodes in
  let col =
    match node.top with
    | Some i ->
      if i <= 0 then
        0
      else
        i
    | None -> 0
  in
  let rec find_right idx =
    match node_array.(idx).top with
    | None -> 0
    | Some i ->
      if i <= 0 then
        -1 * i
      else
        find_right (idx + 1)
  in
  (* Find the index of the target node *)
  let row = find_right node.id in
  row, col

let pp fpf t =
  let module C = CCFormat in
  let num_items = CCList.length t.items in
  let num_options = CCList.length t.options in
  let node_array = CCArray.of_list t.nodes in
  let rc_array = CCArray.map (rowcol t) node_array in
  let num_nodes = CCArray.length node_array in
  let main_box =
    let module B = PrintBox in
    let arr = CCArray.make_matrix (num_options + 1) (num_items + 2) B.empty in
    let root_node = ref t.root in
    (* Print the header node boxes. *)
    for i = 0 to num_items do
      arr.(0).(i) <- box !root_node;
      root_node := right !root_node
    done;
    (* Print all other non-spacer nodes.*)
    for i = 0 to num_nodes - 1 do
      let row, col = rc_array.(i) in
      match node_array.(i).top with
      | Some m -> if m > 0 then arr.(row).(col) <- box node_array.(i)
      | None -> ()
    done;
    arr |> B.grid |> B.frame
  in
  CCFormat.fprintf fpf "%a" PrintBox_text.pp main_box

let find_header_node ~name ~items root =
  let num_items = CCList.length items in
  let cur = ref root in
  let ans = ref None in
  for _ = 1 to num_items + 1 do
    if name = CCOption.get_exn_or "Failed getting name" !cur.name then
      ans := Some !cur
    else
      cur := right !cur
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
  node

let mk ~(items : string list) ~(options : string list list) : t =
  let itarray = CCArray.of_list items in
  let optarray = CCArray.map CCArray.of_list (CCArray.of_list options) in
  let num_items = CCArray.length itarray in
  let num_options = CCArray.length optarray in
  let node_list = ref [] in
  let cur = ref (init ()) in
  (* Immutable bindings FTW!*)
  let head = !cur in
  (* Process items *)
  for i = 1 to num_items + 1 do
    if i = num_items + 1 then (
      (* Create a circular linked list on top. *)
      !cur.right <- Some head;
      head.left <- Some !cur;
      cur := head
    ) else (
      let new_node : node =
        make_node ~id:i ~name:itarray.(i - 1) ~len:0 ~left:!cur ()
      in
      !cur.right <- Some new_node;
      new_node.up <- Some new_node;
      new_node.down <- Some new_node;
      cur := new_node
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
      let nodej = find_header_node ~name:!cur_opt.(j) ~items !cur in
      nodej.len <- CCOption.map (fun x -> x + 1) nodej.len;
      let q = CCOption.get_exn_or "no up node" nodej.up in
      new_node := make_node ~id:(!spacer_node.id + j + 1) ~top:nodej.id ();
      !new_node.up <- Some q;
      q.down <- Some !new_node;
      !new_node.down <- Some nodej;
      nodej.up <- Some !new_node;
      if j = 0 then first_node := !new_node;
      if j = k - 1 then (
        m := !m + 1;
        !spacer_node.down <- Some !new_node;
        node_list := !node_list @ [ !spacer_node ];
        spacer_node := make_node ~id:(!new_node.id + 1) ~top:(-1 * !m) ();
        !spacer_node.up <- Some !first_node
      )
    done;

    if n = num_options then
      node_list := !node_list @ [ !spacer_node ]
    else
      cur_opt := optarray.(n)
  done;
  (* Collect all nodes *)
  let header_node = ref (right !cur) in
  for _ = 0 to num_items do
    node_list := !node_list @ [ !header_node ];
    header_node := right !header_node
  done;
  let lrroot = ref (right !cur) in
  let udroot = ref (up !lrroot) in
  while !lrroot.id != !cur.id do
    while !udroot.id != !lrroot.id do
      node_list := !node_list @ [ !udroot ];
      udroot := up !udroot
    done;
    lrroot := right !lrroot;
    udroot := up !lrroot
  done;
  node_list := CCList.sort (fun n1 n2 -> compare n1.id n2.id) !node_list;
  { root = !cur; nodes = !node_list; items; options }

let hide (p : int) t =
  let qnode = ref (get ~id:(p + 1) t) in
  CCFormat.printf "%a@." pp_node !qnode;
  while !qnode.id != p do
    let x = !qnode.top in
    let u = up !qnode in
    let d = down !qnode in
    match x with
    | None -> failwith "Trying to hide node with no top!"
    | Some id ->
      if id <= 0 then
        (* qnode was a spacer node *)
        qnode := CCOption.get_exn_or "No upper node!" !qnode.up
      else (
        let topnode = get ~id t in
        u.down <- Some d;
        d.up <- Some u;
        topnode.len <- CCOption.map (fun x -> x - 1) topnode.len;
        qnode := get ~id:(!qnode.id + 1) t
      )
  done;
  t
