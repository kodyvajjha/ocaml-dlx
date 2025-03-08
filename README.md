# DLX in OCaml

This is an OCaml implementation of Knuth's Algorithm X which solves the exact 
cover problem using dancing links. 


For example, given items `["a";"b";"c";"d"]` and options 
`[["a";"d"];["a";"b"];["c";"b"]]`,the DLX algorithm computes all exact covers of
the items (a partition of the set of items using the options set). So in this 
case we return `[[["a";"d"];["b";"c"]]]`. 

This algorithm backtracks over a data structure consisting of vertical doubly 
linked lists where the items are joined to corresponding options. Here is a 
picture of this data structure for the above example:

``` 
┌────────────────┬──────────────┬──────────────┬──────────────┬──────────────┬┐
│┌──────────────┐│┌────────────┐│┌────────────┐│┌────────────┐│┌────────────┐││
││ 0            │││ 1          │││ 2          │││ 3          │││ 4          │││
│├────┬────┬────┤│├────┬─┬─────┤│├────┬─┬─────┤│├────┬─┬─────┤│├────┬─┬─────┤││
││TOP:│HEAD│LEN:│││TOP:│a│LEN:2│││TOP:│b│LEN:2│││TOP:│c│LEN:1│││TOP:│d│LEN:1│││
│├─┬─┬┴┬───┴────┤│├─┬─┬┴┬┴─────┤│├──┬─┴┬┴┬────┤│├──┬─┴┬┴┬────┤│├─┬─┬┴┬┴─────┤││
││U│D│L│R       │││U│D│L│R     │││U │D │L│R   │││U │D │L│R   │││U│D│L│R     │││
│├─┼─┼─┼────────┤│├─┼─┼─┼──────┤│├──┼──┼─┼────┤│├──┼──┼─┼────┤│├─┼─┼─┼──────┤││
││0│0│4│1       │││9│6│0│2     │││13│10│1│3   │││12│12│2│4   │││7│7│3│0     │││
│└─┴─┴─┴────────┘│└─┴─┴─┴──────┘│└──┴──┴─┴────┘│└──┴──┴─┴────┘│└─┴─┴─┴──────┘││
├────────────────┼──────────────┼──────────────┼──────────────┼──────────────┼┤
│                │┌───────────┐ │              │              │┌───────────┐ ││
│                ││ 6         │ │              │              ││ 7         │ ││
│                │├─────┬┬────┤ │              │              │├─────┬┬────┤ ││
│                ││TOP:1││LEN:│ │              │              ││TOP:4││LEN:│ ││
│                │├─┬─┬─┼┴────┤ │              │              │├─┬─┬─┼┴────┤ ││
│                ││U│D│L│R    │ │              │              ││U│D│L│R    │ ││
│                │├─┼─┼─┼─────┤ │              │              │├─┼─┼─┼─────┤ ││
│                ││1│9│ │     │ │              │              ││4│4│ │     │ ││
│                │└─┴─┴─┴─────┘ │              │              │└─┴─┴─┴─────┘ ││
├────────────────┼──────────────┼──────────────┼──────────────┼──────────────┼┤
│                │┌───────────┐ │┌───────────┐ │              │              ││
│                ││ 9         │ ││ 10        │ │              │              ││
│                │├─────┬┬────┤ │├─────┬┬────┤ │              │              ││
│                ││TOP:1││LEN:│ ││TOP:2││LEN:│ │              │              ││
│                │├─┬─┬─┼┴────┤ │├─┬──┬┴┼────┤ │              │              ││
│                ││U│D│L│R    │ ││U│D │L│R   │ │              │              ││
│                │├─┼─┼─┼─────┤ │├─┼──┼─┼────┤ │              │              ││
│                ││6│1│ │     │ ││2│13│ │    │ │              │              ││
│                │└─┴─┴─┴─────┘ │└─┴──┴─┴────┘ │              │              ││
├────────────────┼──────────────┼──────────────┼──────────────┼──────────────┼┤
│                │              │┌───────────┐ │┌───────────┐ │              ││
│                │              ││ 13        │ ││ 12        │ │              ││
│                │              │├─────┬┬────┤ │├─────┬┬────┤ │              ││
│                │              ││TOP:2││LEN:│ ││TOP:3││LEN:│ │              ││
│                │              │├──┬─┬┴┼────┤ │├─┬─┬─┼┴────┤ │              ││
│                │              ││U │D│L│R   │ ││U│D│L│R    │ │              ││
│                │              │├──┼─┼─┼────┤ │├─┼─┼─┼─────┤ │              ││
│                │              ││10│2│ │    │ ││3│3│ │     │ │              ││
│                │              │└──┴─┴─┴────┘ │└─┴─┴─┴─────┘ │              ││
└────────────────┴──────────────┴──────────────┴──────────────┴──────────────┴┘
```

# Usage 

To install this library, you will need to install opam and OCaml. Then do:

```
make opam-install-deps
make build
```

Some white-box tests can be run with
```
make tests
```

Example usage of this program to solve Sudoku, the [https://en.wikipedia.org/wiki/M%C3%A9nage_problem](Ménage problem)
and the Langford pairs problem are shown in the `bin` directory. You can run them
as: 

``` 
opam exec -- dune exec langford
opam exec -- dune exec sudoku
opam exec -- dune exec menages
```

## TODO

1. MRV heuristic: currently we do the naive thing of picking the first uncovered column when branching in the search tree. This is clearly inefficient (but gets the job done in toy examples). Knuth suggests the MRV heuristic to pick that column which has the least number of remaining items under it. 
2. n-Queens: Should be trivial, but to do it *correctly* needs implementation of "slack options".
3. Progress reports.
4. More problems! (Pentominos, Tilings, ...)