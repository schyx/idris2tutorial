# Exercises part 2

```idris
module Tutorial.Interfaces.Exercises2

import Tutorial.Interfaces.More
import Tutorial.Interfaces.Basics
```

1. Implement interfaces `Equals`, `Comp`, `Concat`, and `Empty` for pairs, constraining your implementations as necessary. (Note, that multiple constraints can be given sequentially like other function arguments: `Comp a => Comp b => Comp (a,b)`.)

```idris
implementation Equals a => Equals b => Equals (a, b) where
  eq (l1, r1) (l2, r2) = eq l1 l2 && eq r1 r2

implementation Comp a => Comp b => Comp (a, b) where
  comp (l1, r1) (l2, r2) =
    case comp l1 l2 of
         EQ      => comp r1 r2
         unequal => unequal

implementation Concat a => Concat b => Concat (a, b) where
  concat (l1, r1) (l2, r2) = (concat l1 l2, concat r1 r2)

implementation Empty a => Empty b => Empty (a, b) where
  empty = (empty, empty)
```

2. Below is an implementation of a binary tree. Implement interfaces `Equals` and `Concat` for this type.

```idris
data Tree : Type -> Type where
  Leaf : a -> Tree a
  Node : Tree a -> Tree a -> Tree a

implementation Equals a => Equals (Tree a) where
  eq (Leaf x)     (Leaf y)     = eq x y
  eq (Node l1 r1) (Node l2 r2) = eq l1 l2 && eq r1 r2
  eq _            _            = False

implementation Concat (Tree a) where
  concat = Node
```

<!-- vi: filetype=idris2:syntax=markdown
-->
