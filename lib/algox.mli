type t = {
  root : Node.t;
  nodes : Node.t array;
  items : string list;
  options : string list list;
}
val pp : Format.formatter -> t -> unit
val mk : items:string list -> options:string list list -> t
val solve_dlx : t -> string list list list
val cover : int -> t -> unit
val uncover : int -> t -> unit
val find_header_node : name:string -> items:string list -> Node.t -> Node.t
val option_of : int -> t -> string list
