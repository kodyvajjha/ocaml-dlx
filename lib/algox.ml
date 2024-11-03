type node = {
  id: int;
  mutable name: string;
  mutable top: node;
  mutable bottom: node;
  mutable left: node option;
  mutable right: node option;
}
