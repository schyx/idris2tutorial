# Exercises part 3

```idris
module Tutorial.IO.Exercises3

import Data.String
import System.File
```

1. As we have seen in the examples above, `IO` actions working with file handles often come with the risk of failure. We can therefore simplify things by writing some utility functions and a custom *bind* operator to work with these nested effects. In a new namespace `IOErr`, implement the following utility functions and use these to further cleanup the implementation of `countEmpty'`:

```idris
namespace IOErr
  export
  pure : a -> IO (Either e a)
  pure = pure . Right

  export
  fail : e -> IO (Either e a)
  fail = pure . Left

  export
  lift : IO a -> IO (Either e a)
  lift = map Right

  export
  catch : IO (Either e1 a) -> (e1 -> IO (Either e2 a)) -> IO (Either e2 a)
  catch action f = do
    Left err <- action | Right value => pure value
    f err

  export
  (>>=) : IO (Either e a) -> (a -> IO (Either e b)) -> IO (Either e b)
  val >>= f = Prelude.(>>=) val $ either fail f

  export
  (>>) : IO (Either e ()) -> Lazy (IO (Either e a)) -> IO (Either e a)
  val >> f = Prelude.(>>=) val $ either fail (const f)
```

2. Write a function `countWords` for counting the words in a file. Consider using `Data.String.words` and the utilities from exercise 1 in your implementation.

```idris
covering
countWords : String -> IO (Either FileError Nat)
countWords path = withFile path Read pure (go 0)
  where covering go : Nat -> File -> IO (Either FileError Nat)
        go k file = IOErr.do
          False <- lift $ fEOF file | True => pure k
          line  <- fGetLine file
          go (k + length (words line)) file
```

3. We can generalize the functionality used in `countEmpty` and `countWords`, by implementing a helper function for iterating over the lines in a file and accumulating some state along the way. Implement `withLines` and use it to reimplement `countEmpty` and `countWords`:

```idris
covering
withLines :  (path : String)
          -> (accum : s -> String -> s)
          -> (initialState : s)
          -> IO (Either FileError s)
withLines path accum initialState = withFile path Read pure (go initialState)
  where covering go : s -> File -> IO (Either FileError s)
        go state file = IOErr.do
          False <- lift $ fEOF file | True => pure state
          line  <- fGetLine file
          go (accum state line) file

covering
countWords' : String -> IO (Either FileError Nat)
countWords' path = withLines path (\prevCount, line => prevCount + length (words line)) 0
```

4. We often use a `Monoid` for accumulating values. It is therefore convenient to specialize `withLines` for this case. Use `withLines` to implement `foldLines` according to the type given below:

```idris
covering
foldLines :  Monoid s
          => (path : String)
          -> (f    : String -> s)
          -> IO (Either FileError s)
foldLines path f = withLines path (\prevState => (prevState <+>) . f) neutral
```

5. Implement function `wordCount` for counting the number of lines, words, and characters in a text document. Define a custom record type together with an implementation of `Monoid` for storing and accumulating these values and use `foldLines` in your implementation of `wordCount`.

```idris
record WCStats where
  constructor MkWCStats
  lines      : Nat
  words      : Nat
  characters : Nat

Semigroup WCStats where
  (MkWCStats l1 w1 c1) <+> (MkWCStats l2 w2 c2) = MkWCStats (l1 + l2) (w1 + w2) (c1 + c2)

Monoid WCStats where
  neutral = MkWCStats 0 0 0

covering
wordCount : (path : String) -> IO (Either FileError WCStats)
wordCount path = foldLines path f
  where covering f : String -> WCStats
        f line = MkWCStats 1 (length $ words line) (length line)
```

<!-- vi: filetype=idris2:syntax=markdown
-->
