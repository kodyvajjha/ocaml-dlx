# DLX in OCaml

This is a WIP OCaml implementation of Algorithm X which solves the exact cover problem using dancing links. 

Currently we only have finished step X1 of his algorithm, which corresponds to setting up the problem in memory using a weird toroidal data structure. This data structure has a horizonal doubly linked list on the top row and vertical circular doubly linked lists going through each element on the top row. Here is a picture: 


``` 
┌────────────────┬──────────────┬──────────────┬──────────────┬──────────────┬──────────────┬──────────────┬──────────────┬┐
│┌──────────────┐│┌────────────┐│┌────────────┐│┌────────────┐│┌────────────┐│┌────────────┐│┌────────────┐│┌────────────┐││
││ 0            │││ 1          │││ 2          │││ 3          │││ 4          │││ 5          │││ 6          │││ 7          │││
│├────┬────┬────┤│├────┬─┬─────┤│├────┬─┬─────┤│├────┬─┬─────┤│├────┬─┬─────┤│├────┬─┬─────┤│├────┬─┬─────┤│├────┬─┬─────┤││
││TOP:│HEAD│LEN:│││TOP:│a│LEN:2│││TOP:│b│LEN:2│││TOP:│c│LEN:2│││TOP:│d│LEN:3│││TOP:│e│LEN:2│││TOP:│f│LEN:2│││TOP:│g│LEN:3│││
│├─┬─┬┴┬───┴────┤│├──┬─┴┬┴┬────┤│├──┬─┴┬┴┬────┤│├──┬─┼─┼─────┤│├──┬─┴┬┴┬────┤│├──┬─┴┬┴┬────┤│├──┬─┴┬┴┬────┤│├──┬─┴┬┴┬────┤││
││U│D│L│R       │││U │D │L│R   │││U │D │L│R   │││U │D│L│R    │││U │D │L│R   │││U │D │L│R   │││U │D │L│R   │││U │D │L│R   │││
│├─┼─┼─┼────────┤│├──┼──┼─┼────┤│├──┼──┼─┼────┤│├──┼─┼─┼─────┤│├──┼──┼─┼────┤│├──┼──┼─┼────┤│├──┼──┼─┼────┤│├──┼──┼─┼────┤││
││0│0│7│1       │││20│12│0│2   │││24│16│1│3   │││17│9│2│4    │││27│13│3│5   │││28│10│4│6   │││22│18│5│7   │││29│14│6│0   │││
│└─┴─┴─┴────────┘│└──┴──┴─┴────┘│└──┴──┴─┴────┘│└──┴─┴─┴─────┘│└──┴──┴─┴────┘│└──┴──┴─┴────┘│└──┴──┴─┴────┘│└──┴──┴─┴────┘││
├────────────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────┼┤
│                │              │              │┌───────────┐ │              │┌───────────┐ │              │              ││
│                │              │              ││ 9         │ │              ││ 10        │ │              │              ││
│                │              │              │├─────┬┬────┼ │              │├─────┬┬────┼ │              │              ││
│                │              │              ││TOP:3││LEN:│ │              ││TOP:5││LEN:│ │              │              ││
│                │              │              │├─┬──┬┴┼────┼ │              │├─┬──┬┴┼────┼ │              │              ││
│                │              │              ││U│D │L│R   │ │              ││U│D │L│R   │ │              │              ││
│                │              │              │├─┼──┼─┼────┼ │              │├─┼──┼─┼────┼ │              │              ││
│                │              │              ││3│17│ │    │ │              ││5│28│ │    │ │              │              ││
│                │              │              │└─┴──┴─┴────┘ │              │└─┴──┴─┴────┘ │              │              ││
├────────────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────┼┤
│                │┌───────────┐ │              │              │┌───────────┐ │              │              │┌───────────┐ ││
│                ││ 12        │ │              │              ││ 13        │ │              │              ││ 14        │ ││
│                │├─────┬┬────┼ │              │              │├─────┬┬────┼ │              │              │├─────┬┬────┼ ││
│                ││TOP:1││LEN:│ │              │              ││TOP:4││LEN:│ │              │              ││TOP:7││LEN:│ ││
│                │├─┬──┬┴┼────┼ │              │              │├─┬──┬┴┼────┼ │              │              │├─┬──┬┴┼────┼ ││
│                ││U│D │L│R   │ │              │              ││U│D │L│R   │ │              │              ││U│D │L│R   │ ││
│                │├─┼──┼─┼────┼ │              │              │├─┼──┼─┼────┼ │              │              │├─┼──┼─┼────┼ ││
│                ││1│20│ │    │ │              │              ││4│21│ │    │ │              │              ││7│25│ │    │ ││
│                │└─┴──┴─┴────┘ │              │              │└─┴──┴─┴────┘ │              │              │└─┴──┴─┴────┘ ││
├────────────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────┼┤
│                │              │┌───────────┐ │┌───────────┐ │              │              │┌───────────┐ │              ││
│                │              ││ 16        │ ││ 17        │ │              │              ││ 18        │ │              ││
│                │              │├─────┬┬────┼ │├─────┬┬────┼ │              │              │├─────┬┬────┼ │              ││
│                │              ││TOP:2││LEN:│ ││TOP:3││LEN:│ │              │              ││TOP:6││LEN:│ │              ││
│                │              │├─┬──┬┴┼────┼ │├─┬─┬─┼┴────┼ │              │              │├─┬──┬┴┼────┼ │              ││
│                │              ││U│D │L│R   │ ││U│D│L│R    │ │              │              ││U│D │L│R   │ │              ││
│                │              │├─┼──┼─┼────┼ │├─┼─┼─┼─────┼ │              │              │├─┼──┼─┼────┼ │              ││
│                │              ││2│24│ │    │ ││9│3│ │     │ │              │              ││6│22│ │    │ │              ││
│                │              │└─┴──┴─┴────┘ │└─┴─┴─┴─────┘ │              │              │└─┴──┴─┴────┘ │              ││
├────────────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────┼┤
│                │┌───────────┐ │              │              │┌───────────┐ │              │┌───────────┐ │              ││
│                ││ 20        │ │              │              ││ 21        │ │              ││ 22        │ │              ││
│                │├─────┬┬────┼ │              │              │├─────┬┬────┼ │              │├─────┬┬────┼ │              ││
│                ││TOP:1││LEN:│ │              │              ││TOP:4││LEN:│ │              ││TOP:6││LEN:│ │              ││
│                │├──┬─┬┴┼────┼ │              │              │├──┬──┼┴┬───┼ │              │├──┬─┬┴┼────┼ │              ││
│                ││U │D│L│R   │ │              │              ││U │D │L│R  │ │              ││U │D│L│R   │ │              ││
│                │├──┼─┼─┼────┼ │              │              │├──┼──┼─┼───┼ │              │├──┼─┼─┼────┼ │              ││
│                ││12│1│ │    │ │              │              ││13│27│ │   │ │              ││18│6│ │    │ │              ││
│                │└──┴─┴─┴────┘ │              │              │└──┴──┴─┴───┘ │              │└──┴─┴─┴────┘ │              ││
├────────────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────┼┤
│                │              │┌───────────┐ │              │              │              │              │┌───────────┐ ││
│                │              ││ 24        │ │              │              │              │              ││ 25        │ ││
│                │              │├─────┬┬────┼ │              │              │              │              │├─────┬┬────┼ ││
│                │              ││TOP:2││LEN:│ │              │              │              │              ││TOP:7││LEN:│ ││
│                │              │├──┬─┬┴┼────┼ │              │              │              │              │├──┬──┼┴┬───┼ ││
│                │              ││U │D│L│R   │ │              │              │              │              ││U │D │L│R  │ ││
│                │              │├──┼─┼─┼────┼ │              │              │              │              │├──┼──┼─┼───┼ ││
│                │              ││16│2│ │    │ │              │              │              │              ││14│29│ │   │ ││
│                │              │└──┴─┴─┴────┘ │              │              │              │              │└──┴──┴─┴───┘ ││
├────────────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────┼┤
│                │              │              │              │┌───────────┐ │┌───────────┐ │              │┌───────────┐ ││
│                │              │              │              ││ 27        │ ││ 28        │ │              ││ 29        │ ││
│                │              │              │              │├─────┬┬────┼ │├─────┬┬────┼ │              │├─────┬┬────┼ ││
│                │              │              │              ││TOP:4││LEN:│ ││TOP:5││LEN:│ │              ││TOP:7││LEN:│ ││
│                │              │              │              │├──┬─┬┴┼────┼ │├──┬─┬┴┼────┼ │              │├──┬─┬┴┼────┼ ││
│                │              │              │              ││U │D│L│R   │ ││U │D│L│R   │ │              ││U │D│L│R   │ ││
│                │              │              │              │├──┼─┼─┼────┼ │├──┼─┼─┼────┼ │              │├──┼─┼─┼────┼ ││
│                │              │              │              ││21│4│ │    │ ││10│5│ │    │ │              ││25│7│ │    │ ││
│                │              │              │              │└──┴─┴─┴────┘ │└──┴─┴─┴────┘ │              │└──┴─┴─┴────┘ ││
└────────────────┴──────────────┴──────────────┴──────────────┴──────────────┴──────────────┴──────────────┴──────────────┴┘
```

This was produced using Simon Cruanes excellent PrintBox library. 