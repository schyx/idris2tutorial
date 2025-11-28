# Exercises

```idris
module Tutorial.Functions2.Exercises1

import Data.List
import Tutorial.Functions2.LetBindings
```

The exercises in this section are supposed to increase you experience in writing purely functional code. In some cases it might be useful to use `let` expressions or `where` blocks, but this will not always be required.

Exercise 3 is again of utmost importance. `traverseList` is a specialized version of the more general `traverse`, one of the most powerful and versatile functions available in the *Prelude* (check out its type!).

1. Module `Data.List` in *base* exports functions `find` and `elem`. Inspect their types and use these in the implementation of `handleRequest`. This should allow you to completely get rid of the `where` block.

```idris
handleRequest : DB -> Request -> Response
handleRequest db (MkRequest (MkCredentials email pw) album) =
  case find (\user => user.email == email) db of
       Nothing   => UnknownUser email
       Just user =>
         if      user.password /= pw      then InvalidPassword
         else if album `elem` user.albums then Success album
         else                                  AccessDenied email album
```

2. Refactor `handleRequest` to use `Either`, such that `handleRequest : DB -> Request -> Either Failure Album`, where

```idris
namespace Ex2

  data Failure : Type where
    UnknownUser : Email -> Failure
    InvalidPassword : Failure
    AccessDenied : Email -> Album -> Failure

  handleRequest : DB -> Request -> Either Failure Album
  handleRequest db (MkRequest (MkCredentials e pw) album) =
    case find ((== e) . email) db of
      Nothing   => Left $ UnknownUser e
      Just user =>
        if      user.password /= pw      then Left InvalidPassword
        else if album `elem` user.albums then Right album
        else                                  Left $ AccessDenied e album
```

   Hint: You may find nested `case` statements helpful.

3. Define an enumeration type listing the four [nucleobases](https://en.wikipedia.org/wiki/Nucleobase) occurring in DNA strands. Define also a type alias `DNA` for lists of nucleobases. Declare and implement function `readBase` for converting a single character (type `Char`) to a nucleobase. You can use character literals in your implementation like so: `'A'`, `'a'`. Note, that this function might fail, so adjust the result type accordingly.

```idris
data Base
  = A
  | T
  | C
  | G

DNA : Type
DNA = List Base

readBase : Char -> Maybe Base
readBase 'a' = Just A
readBase 'A' = Just A
readBase 't' = Just T
readBase 'T' = Just T
readBase 'c' = Just C
readBase 'C' = Just C
readBase 'g' = Just G
readBase 'G' = Just G
readBase _   = Nothing
```

4. Implement the following function, which tries to convert all values in a list with a function, which might fail. The result should be a `Just` holding the list of converted values in unmodified order, if and only if every single conversion was successful.

```idris
traverseList : (a -> Maybe b) -> List a -> Maybe (List b)
traverseList _    []        = Just []
traverseList pred (x :: xs) =
  case (pred x, traverseList pred xs) of
    (Just y, Just ys) => Just $ y :: ys
    (_     , _      ) => Nothing
```

   You can verify, that the function behaves correctly with the following test: `traverseList Just [1,2,3] = Just [1,2,3]`.

5. Implement function `readDNA : String -> Maybe DNA` using the functions and types defined in exercises 2 and 3. You will also need function `unpack` from the *Prelude*.

```idris
readDNA : String -> Maybe DNA
readDNA = traverseList readBase . unpack
```

6. Implement function `complement : DNA -> DNA` to calculate the complement of a strand of DNA.

```idris
complement : DNA -> DNA
complement []          = []
complement (A :: rest) = T :: complement rest
complement (T :: rest) = A :: complement rest
complement (C :: rest) = G :: complement rest
complement (G :: rest) = C :: complement rest
```

<!-- vi: filetype=idris2:syntax=markdown
-->
