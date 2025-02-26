build:
	@dune build @install

tests:
	dune runtest --force

clean:
	@dune clean

WATCH?= @install
watch:
	@dune build $(WATCH) -w

_opam:
	opam switch create . --empty
	opam switch set-invariant ocaml-base-compiler.5.1.0

opam-install-deps: _opam
	opam install ./dlx.opam -y --deps-only

format:
	@dune build @fmt --auto-promote

.PHONY: all clean watch tests
