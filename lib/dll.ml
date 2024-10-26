(*
  DLLs are an imperitive phenomenon. Zippers or Finger Trees are their purely functional equivalents. 

*)

module DLList = struct
  [@@@warning "-34-32"]

  type 'a node = {
    el: 'a;
    mutable left: 'a node option;
    mutable right: 'a node option;
  }

  (** Traverse and print the doubly linked list forward *)
  let rec pp_node ppa fpf node =
    CCOption.iter
      (fun node ->
        CCFormat.fprintf fpf "@[%a <-> %a@]" ppa node.el (pp_node ppa)
          node.right)
      node

  let show_node node = CCFormat.printf "@[%a@.@]" CCFormat.(pp_node int) node

  let left n =
    CCOption.(
      let* n = n in
      n.left)

  let right n =
    CCOption.(
      let* n = n in
      n.right)

  (** Convert a list to a doubly linked list. This returns the head node of the DLL. *)
  let mk l : 'a node option =
    let rec aux ~left ~cur =
      match cur with
      | [] -> None
      | el :: els ->
        (* Right ref is None because we don't know it yet. *)
        let node = { el; left; right = None } in
        (* Build out the node we don't know. *)
        let next_node = aux ~left:(Some node) ~cur:els in
        (* Assign it to the previous one. *)
        node.right <- next_node;
        (* Return the new node. *)
        Some node
    in
    aux ~left:None ~cur:l

  let rec nth n node =
    let open CCOption in
    let* node = node in
    if n = 0 then
      pure node
    else
      nth (n - 1) node.right

  let behead head =
    let open CCOption in
    let* h = head in
    let+ g = h.right in
    g.left <- None;
    g

  let remove node =
    match node with
    | Some node ->
      CCOption.iter (fun x -> x.left <- node.left) node.right;
      CCOption.iter (fun x -> x.right <- node.right) node.left
    | None -> ()

  (** This function is at the basis of Knuth's Dancing Links method. *)
  let remove_put_back node =
    match node with
    | Some node ->
      CCOption.iter (fun x -> x.left <- node.left) node.right;
      CCOption.iter (fun x -> x.right <- node.right) node.left;
      CCOption.iter (fun x -> x.left <- Some node) (right (Some node));
      CCOption.iter (fun x -> x.right <- Some node) (left (Some node))
    | None -> ()

  (** This needs special handling when n=0 since we don't explicitly track the head node. We just return the original head node after reassigning links. *)
  let remove_nth n node =
    if n = 0 then
      behead node
    else (
      remove (nth n node);
      node
    )
end

module CDLList = struct
  exception Empty

  (* No option since in a cdll every node has neighbours.*)
  type 'a node = {
    el: 'a;
    mutable left: 'a node;
    mutable right: 'a node;
  }

  and 'a t = { mutable head: 'a node }

  let pp_node ppa fpf node = CCFormat.fprintf fpf "@[%a@]" ppa node.el

  let show_int_node node =
    CCFormat.printf "@[%a@.@]" CCFormat.(pp_node int) node

  let pp ppa fpf l = CCFormat.fprintf fpf "%a" (pp_node ppa) l.head

  let create x =
    let rec node = { el = x; left = node; right = node } in
    node

  let shift_right (lst : 'a t) = lst.head <- lst.head.right

  let shift_left (lst : 'a t) = lst.head <- lst.head.left

  let of_list l : 'a t =
    match l with
    | [] -> (* If the list is empty, DLL has no head. *) raise Empty
    | h :: t ->
      (* Start by creating a node which points to itself on the left and right*)
      let first = create h in
      let rec loop ~cur ~rest =
        match rest with
        | [] ->
          cur.right <- first;
          first.left <- cur;
          first
        | n :: ns ->
          (* Start with the first nontrivial element, and create a node. Left pointer to this node points to the node where you start out from. Right pointer does not exist just yet and will be assigned in the subsequent recursive call. We just assign it something just now as a placeholder (We could do None, but we don't like the option monad in this module.) *)
          let next_node = { el = n; left = cur; right = cur } in
          (* Right pointer of current node points to the node just created.  *)
          cur.right <- next_node;
          (* Carry out recursion with the next node as current. *)
          loop ~cur:next_node ~rest:ns
      in

      { head = loop ~cur:first ~rest:t }

  let to_list (lst : 'a t) =
    let head_node = lst.head in
    let res = ref [ head_node.el ] in
    let cur_node = ref head_node.right in
    while !cur_node != head_node do
      res := !res @ [ !cur_node.el ];
      cur_node := !cur_node.right
    done;
    !res
end
