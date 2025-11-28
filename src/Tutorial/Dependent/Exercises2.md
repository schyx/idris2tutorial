# Exercises part 2

```idris
module Tutorial.Dependent.Exercises2

import Tutorial.Dependent.LengthIndexedLists
import Tutorial.Dependent.Fin

%default total
```

1. Implement function `update`, which, given a function of type `a -> a`, updates the value in a`Vect n a` at position `k < n`.

```idris
update : Fin n -> (a -> a) -> Vect n a -> Vect n a
update FZ     f (x :: xs) = f x :: xs
update (FS k) f (x :: xs) = x :: update k f xs
```

2. Implement function `insert`, which inserts a value of type `a` at position `k <= n` in a `Vect n a`. Note, that `k` is the index of the freshly inserted value, so that the following holds:

   ```repl
   index k (insert k v vs) = v
   ```

```idris
insert : (Fin (S n)) -> a -> Vect n a -> Vect (S n) a
insert FZ     y xs        = y :: xs
insert (FS k) y (x :: xs) = x :: insert k y xs
insert (FS k) y Nil impossible
```

3. Implement function `delete`, which deletes a value from a vector at the given index.

   This is trickier than Exercises 1 and 2, as we have to properly encode in the types that the vector is getting one element shorter.

```idris
delete : Fin (S n) -> Vect (S n) a -> Vect n a
delete FZ     (_ :: xs)          = xs
delete (FS k) (x :: xs@(_ :: _)) = x :: delete k xs
delete (FS k) (x :: []) impossible
delete _      []        impossible
```

4. We can use `Fin` to implement safe indexing into `List`s as well. Try to come up with a type and implementation for `safeIndexList`.

   Note: If you don't know how to start, look at the type of `fromList` for some inspiration. You might also need give the arguments in a different order than for `index`.

```idris
safeIndexList : (as : List a) -> Fin (length as) -> a
safeIndexList (x :: xs) FZ     = x
safeIndexList (_ :: xs) (FS k) = safeIndexList xs k
safeIndexList []        _        impossible
```

5. Implement function `finToNat`, which converts a `Fin n` to the corresponding natural number, and use this to declare and implement function `take` for splitting of the first `k` elements of a `Vect n a` with `k <= n`.

```idris
public export
finToNat : Fin n -> Nat
finToNat FZ     = 0
finToNat (FS k) = S $ finToNat k

take : (k : Fin (S n)) -> Vect n a -> Vect (finToNat k) a
take FZ     _         = []
take (FS k) (x :: xs) = x :: take k xs
take (FS k) []          impossible
```

6. Implement function `minus` for subtracting a value `k` from a natural number `n` with `k <= n`.

```idris
public export
minus : (n : Nat) -> (k : Fin (S n)) -> Nat
minus n     FZ     = n
minus (S m) (FS k) = minus m k
minus Z     (FS _)   impossible
```

7. Use `minus` from Exercise 6 to declare and implement function `drop`, for dropping the first `k` values from a `Vect n a`, with `k <= n`.

```idris
drop :  (k : Fin (S n)) -> Vect n a -> Vect (minus n k) a
drop FZ     vect      = vect
drop (FS k) (_ :: xs) = drop k xs
drop (FS _) []          impossible
```

8. Implement function `splitAt` for splitting a `Vect n a` at position `k <= n`, returning the prefix and suffix of the vector wrapped in a pair.

   Hint: Use `take` and `drop` in your implementation.

   Hint: Since `Fin n` consists of the values strictly smaller than `n`, `Fin (S n)` consists of the values smaller than or equal to `n`.

   Note: Functions `take`, `drop`, and `splitAt`, while correct and provably total, are rather cumbersome to type. There is an alternative way to declare their types, as we will see in the next section.

```idris
splitAt : (k : Fin (S n)) -> Vect n a -> (Vect (finToNat k) a, Vect (minus n k) a)
splitAt k vect = (take k vect, drop k vect)
```

<!-- vi: filetype=idris2:syntax=markdown
-->
