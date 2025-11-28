## Exercises part 1

```idris
module Tutorial.Dependent.Exercises1

import Tutorial.Dependent.LengthIndexedLists

%default total
```

01. Implement a function `len : List a -> Nat` for calculating the length of a `List`. For example, `len [1, 1, 1]` produces `3`.

```idris
len : List a -> Nat
len (_ :: xs) = 1 + len xs
len []        = 0
```

02. Implement function `head` for non-empty vectors:

    Note, how we can describe non-emptiness by using a *pattern* in the length of `Vect`. This rules out the `Nil` case, and we can return a value of type `a`, without having to wrap it in a `Maybe`! Make sure to add an `impossible` clause for the `Nil` case (although this is not strictly necessary here).

```idris
head : Vect (S n) a -> a
head (x :: _) = x
head [] impossible
```

03. Using `head` as a reference, declare and implement function `tail` for non-empty vectors. The types should reflect that the output is exactly one element shorter than the input.

```idris
tail : Vect (S n) a -> Vect n a
tail (_ :: xs) = xs
tail [] impossible
```

04. Implement `zipWith3`. If possible, try to doing so without looking at the implementation of `zipWith`:

```idris
zipWith3 : (a -> b -> c -> d) -> Vect n a -> Vect n b -> Vect n c -> Vect n d
zipWith3 f (x :: xs) (y :: ys) (z :: zs) = f x y z :: zipWith3 f xs ys zs
zipWith3 _ []        []        []        = []
```

05. Declare and implement a function `foldSemi` for accumulating the values stored in a `List` through `Semigroup`s append operator (`(<+>)`). (Make sure to only use a `Semigroup` constraint, as opposed to a `Monoid` constraint.)

```idris
foldSemi : Semigroup a => List a -> Maybe a
foldSemi (x :: xs) = Just $ maybe x (x <+>) (foldSemi xs)
foldSemi []        = Nothing
```

06. Do the same as in Exercise 4, but for non-empty vectors. How does a vector's non-emptiness affect the output type?

```idris
foldSemi' : Semigroup a => Vect (S _) a -> a
foldSemi' (x :: []           ) = x
foldSemi' (x :: rest@(_ :: _)) = x <+> foldSemi' rest
```

07. Given an initial value of type `a` and a function `a -> a`, we'd like to generate `Vect`s of `a`s, the first value of which is `a`, the second value being `f a`, the third being `f (f a)` and so on.

    For instance, if `a` is 1 and `f` is `(* 2)`, we'd like to get results similar to the following: `[1,2,4,8,16,...]`.

    Declare and implement function `iterate`, which should encapsulate this behavior. Get some inspiration from `replicate` if you don't know where to start.

```idris
iterate : (n : Nat) -> (a -> a) -> a -> Vect n a
iterate Z     _ _    = []
iterate (S m) f init = init :: iterate m f (f init)
```

08. Given an initial value of a state type `s` and a function `fun : s -> (s,a)`, we'd like to generate `Vect`s of `a`s. Declare and implement function `generate`, which should encapsulate this behavior. Make sure to use the updated state in every new invocation of `fun`.

    Here's an example how this can be used to generate the first `n` Fibonacci numbers:

    ```repl
    generate 10 (\(x,y) => let z = x + y in ((y,z),z)) (0,1)
    [1, 2, 3, 5, 8, 13, 21, 34, 55, 89]
    ```
```idris
generate : (n : Nat) -> (s -> (s, a)) -> s -> Vect n a
generate 0     _ _    = []
generate (S m) f init =
  let (post, val) := f init
   in val :: generate m f post
```

09. Implement function `fromList`, which converts a list of values to a `Vect` of the same length. Use holes if you get stuck:

```idris
fromList : (as : List a) -> Vect (length as) a
fromList []        = []
fromList (x :: xs) = x :: fromList xs
```

    Note how, in the type of `fromList`, we can *calculate* the length of the resulting vector by passing the list argument to function *length*.

10. Consider the following declarations:

```idris
maybeSize : Maybe a -> Nat
maybeSize Nothing  = 0
maybeSize (Just _) = 1

fromMaybe : (m : Maybe a) -> Vect (maybeSize m) a
fromMaybe Nothing  = []
fromMaybe (Just x) = x :: []
```

Choose a reasonable implementation for `maybeSize` and implement `fromMaybe` afterwards.

<!-- vi: filetype=idris2:syntax=markdown
-->
