type t = {
  root : Node.t;
  nodes : Node.t array;
  items : string list;
  options : string list list;
}

val src : Logs.src
(** The [Logs] source for the DLX solver. Use this to control log verbosity
    independently of other libraries, e.g.:
    {[
      Logs.Src.set_level Dlx.Algox.src (Some Logs.Info);
    ]} *)

val pp : Format.formatter -> t -> unit
val mk : items:string list -> options:string list list -> t
val solve_dlx : t -> string list list list
