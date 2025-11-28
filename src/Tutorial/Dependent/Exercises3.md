# Exercises part 3

```idris
module Tutorial.Dependent.Exercises3

import Tutorial.Dependent.Exercises2
import Tutorial.Dependent.LengthIndexedLists
import Tutorial.Dependent.Fin
import Tutorial.Dependent.Comptime

%default total
```

1. Here is a function declaration for flattening a `List` of `List`s:

   Implement `flattenList` and declare and implement a similar function `flattenVect` for flattening vectors of vectors.

```idris
flattenList : List (List a) -> List a
flattenList []        = []
flattenList (x :: xs) = x ++ flattenList xs

flattenVect : Vect n (Vect m a) -> Vect (n * m) a
flattenVect (x :: xs) = x ++ flattenVect xs
flattenVect []        = []
```

2. Implement functions `take'` and `splitAt'` like in the exercises of the previous section but using the technique shown for `drop'`.

```idris
take' : (m : Nat) -> Vect (m + n) a -> Vect m a
take' Z     vect      = []
take' (S k) (x :: xs) = x :: take' k xs
take' (S _) []          impossible

drop' : (m : Nat) -> Vect (m + n) a -> Vect n a
drop' Z     vect      = vect
drop' (S k) (x :: xs) = drop' k xs
drop' (S _) []          impossible
```

3. Implement function `transpose` for converting an `m x n`-matrix (represented as a `Vect m (Vect n a)`) to an `n x m`-matrix.

   Note: This might be a challenging exercise, but make sure to give it a try. As usual, make use of holes if you get stuck!

   Here is an example how this should work in action:

   ```repl
   Solutions.Dependent> transpose [[1,2,3],[4,5,6]]
   [[1, 4], [2, 5], [3, 6]]
   ```

```idris
mapVect : (a -> b) -> Vect n a -> Vect n b
mapVect _ []        = []
mapVect f (x :: xs) = f x :: mapVect f xs

tail : Vect (S k) a -> Vect k a
tail (x :: xs) = xs

transpose : Vect (S m) (Vect (S n) a) -> Vect (S n) (Vect (S m) a)
transpose matrix@(row :: [])               = mapVect (:: []) row
transpose matrix@([_] :: _)                = [mapVect (index FZ) matrix]
transpose matrix@((_ :: _ :: _) :: _ :: _) = mapVect (index FZ) matrix :: transpose (mapVect tail matrix)
```

<!-- vi: filetype=idris2:syntax=markdown
-->
