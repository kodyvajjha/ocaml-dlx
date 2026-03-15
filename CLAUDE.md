# CLAUDE.md — AI Assistant Guide for ocaml-dlx

## Project Overview

This repository is an OCaml implementation of **Knuth's Algorithm X** (Dancing Links / DLX), which solves the [exact cover problem](https://en.wikipedia.org/wiki/Exact_cover). Given a universe of items and a set of options (each covering some subset of items), the algorithm finds all ways to select a disjoint subset of options that covers every item exactly once.

The project includes several combinatorial applications:
- **Sudoku** solver
- **Langford pairs** generator
- **Ménage problem** solver

**Reference**: Knuth's original Dancing Links paper is in `doc/7.2.2.1-dancing_links.pdf`.

---

## Repository Structure

```
ocaml-dlx/
├── lib/                   # Core library (public package: dlx)
│   ├── node.ml            # Node type for the Dancing Links data structure
│   ├── dll.ml             # Doubly linked list implementations (DLList, CDLList)
│   ├── algox.ml           # Algorithm X implementation (main solver)
│   └── algox.mli          # Public interface for the library
├── bin/                   # Executable programs
│   ├── main.ml            # Basic DLX demonstration
│   ├── dll.ml             # CDLList smoke tests
│   ├── sudoku.ml          # Sudoku constraint → exact cover solver
│   ├── langford.ml        # Langford pairs solver
│   ├── menages.ml         # Problème des ménages solver
│   ├── problem.txt        # Example Sudoku puzzle input
│   └── dune
├── test/                  # Test suite (currently disabled — see below)
│   ├── covering.ml        # Cover/uncover operation tests
│   ├── dlx_run.ml         # End-to-end solver tests
│   ├── options.ml         # option_of function tests
│   ├── printing.ml        # Node printing tests
│   ├── traverse.ml        # Traversal tests
│   └── *.expected         # Expected output files for inline tests
├── doc/
│   └── 7.2.2.1-dancing_links.pdf   # Knuth's Dancing Links paper
├── dune-project           # Dune project config + dependency declarations
├── dlx.opam              # Auto-generated OPAM package file (do not edit)
├── Makefile               # Convenience build targets
├── .ocamlformat           # Code formatting configuration
└── .github/workflows/main.yml  # CI pipeline (GitHub Actions)
```

---

## Build System

The project uses **Dune** (>= 3.11). OCaml 5.1.0 is the tested compiler version.

### Common Commands

```bash
make build              # dune build @install
make tests              # dune runtest --force
make clean              # dune clean
make watch              # dune build --watch (auto-rebuild on change)
make format             # Auto-format all OCaml files with ocamlformat
make opam-install-deps  # Install opam dependencies into local switch
```

### Running Executables

After building, executables are available via dune:

```bash
dune exec dlx           # Basic Algorithm X demo
dune exec langford      # Langford pairs
dune exec menages       # Ménage problem
dune exec sudoku        # Sudoku solver (reads bin/problem.txt)
dune exec dll           # CDLList utility tests
```

### Dependencies

Declared in `dune-project` (not in `dlx.opam` — that file is auto-generated):

| Package | Purpose |
|---|---|
| `containers` | Utility library (`CCList`, `CCOption`, etc.) |
| `printbox` + `printbox-text` | Pretty-printing / ASCII box rendering |
| `ppx_deriving` | Deriving `show`, `make`, `eq` for types |
| `odoc` (with-doc) | API documentation generation |

---

## Core Architecture

### Module Dependency Order

```
Node  →  Dll  →  Algox
                  ↓
         bin/{main,sudoku,langford,menages}
```

### `lib/node.ml` — Node

Defines the `Node.t` record for a single cell in the Dancing Links sparse matrix:

```ocaml
type t = {
  name  : string option;   (* item label, only on header nodes *)
  id    : int;             (* unique index into the nodes array *)
  top   : int option;      (* column header id (None = root/spacer) *)
  len   : int ref;         (* count of remaining options (header only) *)
  up    : int ref;
  down  : int ref;
  left  : int ref;
  right : int ref;
}
```

All pointer fields store integer IDs that index into the global `nodes` array in `Algox.t`.

### `lib/dll.ml` — Doubly Linked Lists

Two implementations:

- **`DLList`**: Standard optional DLL (no circular links). Supports `remove_put_back` for reversible deletion — the conceptual core of Dancing Links.
- **`CDLList`**: Circular DLL used in the actual Algorithm X implementation.

### `lib/algox.ml` — Algorithm X (CORE)

The main `t` record:

```ocaml
type t = {
  root    : Node.t;
  nodes   : Node.t array;
  items   : string list;
  options : string list list;
}
```

**Key functions:**

| Function | Description |
|---|---|
| `mk ~items ~options` | Construct the full Dancing Links structure |
| `solve_dlx t` | Run Algorithm X; returns `string list list list` (all solutions, each solution is a list of options) |
| `cover id t` | Cover item with header-node `id` (remove from active list, hide rows) |
| `uncover id t` | Reverse of `cover` — must be called in LIFO order |
| `hide id t` / `unhide id t` | Row-level hide/unhide (called by cover/uncover) |
| `option_of id t` | Return all item names in the option containing node `id` |
| `find_header_node name t` | Look up a header node by item name |
| `traverse_row id t` | Collect all nodes in the same row |
| `traverse_col id t` | Collect all nodes in the same column |

**Solve algorithm (recursive backtracking):**
1. If no uncovered items remain, record solution.
2. Pick the uncovered item with the minimum remaining options (MRV — currently uses first uncovered item; MRV is a TODO).
3. For each option covering that item: cover all items in the option, recurse, then uncover.

### `lib/algox.mli` — Public Interface

Only `mk`, `solve_dlx`, and a handful of accessors are exported. Internal helpers (`cover`, `uncover`, `hide`, `unhide`, etc.) are **not** part of the public API even though they appear in the `.ml` file.

---

## Tests

The test suite lives in `test/` but is **currently disabled** — the `test/dune` stanza is commented out.

To re-enable tests, uncomment the stanza in `test/dune` and run:

```bash
make tests
# or
dune runtest --force
```

Tests use inline expect-style output: each test file prints to stdout and is compared against a `.expected` file. To regenerate expected files:

```bash
dune runtest --auto-promote
```

---

## Code Style

Formatting is enforced by **ocamlformat** using the config in `.ocamlformat`:

- Profile: `conventional`
- Line margin: 80 characters
- Conditionals: K&R style (`if ... then\n  ...`)
- Sparse breaks enabled; `let ... in` on same line where possible

Always run `make format` before committing.

---

## CI / CD

GitHub Actions (`.github/workflows/main.yml`) runs on every push and pull request:
- OS: Ubuntu
- OCaml: 5.1.0
- Steps: opam setup → install deps → `dune build` → `dune runtest`

---

## Adding a New Problem

To add a new combinatorial problem (e.g., n-Queens):

1. Create `bin/queens.ml`.
2. Express the problem as `items` (a `string list`) and `options` (a `string list list`).
3. Call `Dlx.Algox.mk ~items ~options` to build the structure.
4. Call `Dlx.Algox.solve_dlx t` to get all solutions.
5. Add an entry in `bin/dune`:
   ```lisp
   (executable
    (name queens)
    (libraries dlx))
   ```

Refer to `bin/langford.ml` or `bin/menages.ml` for minimal, self-contained examples.

---

## Known Limitations / TODO

From `README.md`:

1. **MRV heuristic**: `solve_dlx` currently picks the first uncovered item rather than the one with minimum remaining values. Implementing MRV would significantly speed up dense problems like Sudoku.
2. **Slack options**: Support secondary items (covered at most once) for problems like n-Queens.
3. **Progress reporting**: Expose a callback or counter during search.
4. **More problems**: Pentominos, polyomino tilings, Word rectangles, etc.

---

## Important Conventions for AI Assistants

- **Do not edit `dlx.opam`** — it is auto-generated from `dune-project`.
- **All library declarations** (new modules, dependencies) go in `dune-project` and the relevant `lib/dune` or `bin/dune`.
- **Public API changes** must be reflected in `lib/algox.mli`.
- **Run `make format`** after any OCaml edits before committing.
- **Test coverage**: Re-enable the test suite when making changes to `lib/algox.ml` or `lib/dll.ml` to avoid regressions.
- The `nodes` array in `Algox.t` is **1-indexed** (index 0 is the root); be careful with off-by-one errors when navigating.
- `cover`/`uncover` operations must always be paired and called in **LIFO (stack) order** — violating this corrupts the data structure.
