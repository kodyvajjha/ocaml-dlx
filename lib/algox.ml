type t = {
  root: Node.t;
  nodes: Node.t array;
  items: string list;
  options: string list list;
}

(** Get the row and column of sparse matrix representing the node in question. Used mainly for printing. *)
let rowcol t node =
  let open Node in
  let node_array = t.nodes in
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
  let open Node in
  let module C = CCFormat in
  let num_items = CCList.length t.items in
  let num_options = CCList.length t.options in
  let node_array = t.nodes in
  let rc_array = CCArray.map (rowcol t) node_array in
  let num_nodes = CCArray.length node_array in
  let main_box =
    let module B = PrintBox in
    let arr = CCArray.make_matrix (num_options + 1) (num_items + 2) B.empty in
    (* Print the header node boxes. *)
    for i = 0 to num_items do
      arr.(0).(i) <- box t.nodes.(i)
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
  let open Node in
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

let mk ~(items : string list) ~(options : string list list) : t =
  let itarray = CCArray.of_list items in
  let optarray = CCArray.map CCArray.of_list (CCArray.of_list options) in
  let num_items = CCArray.length itarray in
  let num_options = CCArray.length optarray in
  let node_list = ref [] in
  let cur = ref (Node.init ()) in
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
      let new_node : Node.t =
        Node.make ~id:i ~name:itarray.(i - 1) ~len:0 ~left:!cur ()
      in
      !cur.right <- Some new_node;
      new_node.up <- Some new_node;
      new_node.down <- Some new_node;
      cur := new_node
    )
  done;
  (* Set up first spacer node *)
  let m = ref 0 in
  let spacer_node = ref (Node.make ~id:(num_items + 1) ~top:!m ()) in
  let cur_opt = ref optarray.(0) in
  let new_node = ref (Node.make ~id:0 ()) in
  let first_node = ref (Node.make ~id:0 ()) in
  for n = 1 to num_options do
    let k = CCArray.length !cur_opt in
    for j = 0 to k - 1 do
      let nodej = find_header_node ~name:!cur_opt.(j) ~items !cur in
      nodej.len <- CCOption.map (fun x -> x + 1) nodej.len;
      let q = CCOption.get_exn_or "no up node" nodej.up in
      new_node := Node.make ~id:(!spacer_node.id + j + 1) ~top:nodej.id ();
      !new_node.up <- Some q;
      q.down <- Some !new_node;
      !new_node.down <- Some nodej;
      nodej.up <- Some !new_node;
      if j = 0 then first_node := !new_node;
      if j = k - 1 then (
        m := !m + 1;
        !spacer_node.down <- Some !new_node;
        node_list := !node_list @ [ !spacer_node ];
        spacer_node := Node.make ~id:(!new_node.id + 1) ~top:(-1 * !m) ();
        !spacer_node.up <- Some !first_node
      )
    done;

    if n = num_options then
      node_list := !node_list @ [ !spacer_node ]
    else
      cur_opt := optarray.(n)
  done;
  let open Node in
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
  let nodes = CCArray.of_list !node_list in
  CCArray.sort (fun n1 n2 -> compare n1.id n2.id) nodes;
  { root = !cur; nodes; items; options }

type dirn =
  | Left
  | Right

let step d id =
  match d with
  | Left -> id - 1
  | Right -> id + 1

let traverse_row p (root : t) dir ~by:f =
  let cur = ref root.nodes.(step dir p) in
  (*Repeat until we are back were we started. *)
  while !cur.id != p do
    match !cur.top with
    | None -> failwith "Current node doesn't have a top node!"
    | Some i ->
      if i <= 0 then
        (* We are at a spacer node.*)
        cur :=
          match dir with
          | Right ->
            CCOption.get_exn_or "traverse_row: node doesn't have an up!" !cur.up
          | Left ->
            CCOption.get_exn_or "traverse_row: node doesn't have an down!"
              !cur.down
      else (
        f !cur;
        cur := root.nodes.(step dir !cur.id)
      )
  done;
  root

let hide p (root : t) =
  let unlink (node : Node.t) =
    CCOption.iter
      (fun i ->
        root.nodes.(i).len <- CCOption.map (fun x -> x - 1) root.nodes.(i).len)
      node.top;
    let u = Node.up node in
    let d = Node.down node in
    u.down <- Some d;
    d.up <- Some u
  in
  traverse_row p root Right ~by:unlink

let unhide p (root : t) =
  let link (node : Node.t) =
    CCOption.iter
      (fun i ->
        root.nodes.(i).len <- CCOption.map (fun x -> x + 1) root.nodes.(i).len)
      node.top;
    let u = Node.up node in
    let d = Node.down node in
    u.down <- Some node;
    d.up <- Some node
  in
  traverse_row p root Left ~by:link

let cover i (root : t) =
  let cur = ref (Node.down root.nodes.(i)) in
  let curroot = ref root in
  while !cur.id != i do
    curroot := hide !cur.id root;
    cur := Node.down !cur
  done;
  let l = Node.left root.nodes.(i) in
  let r = Node.right root.nodes.(i) in
  l.right <- Some r;
  r.left <- Some l;
  root

let uncover i (root : t) =
  let l = Node.left root.nodes.(i) in
  let r = Node.right root.nodes.(i) in
  l.right <- Some root.nodes.(i);
  r.left <- Some root.nodes.(i);
  let cur = ref (Node.up root.nodes.(i)) in
  let curroot = ref root in
  while !cur.id != i do
    curroot := unhide !cur.id root;
    cur := Node.up !cur
  done;
  root
