type t = {
  root : Node.t;
  nodes : Node.t array;
  items : string list;
  options : string list list;
}
val pp : Format.formatter -> t -> unit
val mk : items:string list -> options:string list list -> t
val solve_dlx : t -> string list list list
