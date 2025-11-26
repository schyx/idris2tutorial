# Generic Data Type Exercises

```idris
module Tutorial.DataTypes.Exercises4

import Tutorial.DataTypes.Exercises1
import Tutorial.DataTypes.Exercises2
import Tutorial.DataTypes.SumTypes
```

The solutions to these exercises can be found in [`src/Solutions/DataTypes.idr`](../../Solutions/DataTypes.md).

If this is your first time programming in a pure functional language, these exercises are *very* important. Do not skip any of them! Take your time and work through them all. In most cases, the types should be enough to explain what's going on, even though they might appear cryptic in the beginning. Otherwise, have a look at the comments (if any) of each exercise.

Remember, that lower-case identifiers in a function signature are treated as type parameters.

## Exercise 1

Implement the following generic functions for `Maybe`:

```idris
-- make sure to map a `Just` to a `Just`.
total
mapMaybe : (a -> b) -> Maybe a -> Maybe b
mapMaybe f Nothing  = Nothing
mapMaybe f (Just x) = Just $ f x

-- Example: `appMaybe (Just (+2)) (Just 20) = Just 22`
total
appMaybe : Maybe (a -> b) -> Maybe a -> Maybe b
appMaybe (Just f) (Just x) = Just $ f x
appMaybe _        _        = Nothing

-- Example: `bindMaybe (Just 12) Just = Just 12`
total
bindMaybe : Maybe a -> (a -> Maybe b) -> Maybe b
bindMaybe (Just x) f = f x
bindMaybe _        _ = Nothing

-- keep the value in a `Just` only if the given predicate holds
total
filterMaybe : (a -> Bool) -> Maybe a -> Maybe a
filterMaybe f (Just x) = if f x then Just x else Nothing
filterMaybe f _        = Nothing

-- keep the first value that is not a `Nothing` (if any)
total
first : Maybe a -> Maybe a -> Maybe a
first (Just x) _ = Just x
first _        y = y

-- keep the last value that is not a `Nothing` (if any)
total
last : Maybe a -> Maybe a -> Maybe a
last _ (Just x) = Just x
last y _        = y

-- this is another general way to extract a value from a `Maybe`.
-- Make sure the following holds:
-- `foldMaybe (+) 5 Nothing = 5`
-- `foldMaybe (+) 5 (Just 12) = 17`
total
foldMaybe : (acc -> el -> acc) -> acc -> Maybe el -> acc
foldMaybe _ start Nothing  = start
foldMaybe f start (Just x) = f start x
```

## Exercise 2

Implement the following generic functions for `Either`:

```idris
total
mapEither : (a -> b) -> Either e a -> Either e b
mapEither f (Right x) = Right $ f x
mapEither _ (Left y)  = Left y

-- In case of both `Either`s being `Left`s, keep the
-- value stored in the first `Left`.
total
appEither : Either e (a -> b) -> Either e a -> Either e b
appEither (Right f) (Right x) = Right $ f x
appEither (Left y)  _         = Left y
appEither _         (Left y)  = Left y

total
bindEither : Either e a -> (a -> Either e b) -> Either e b
bindEither (Left y)  _ = Left y
bindEither (Right x) f = f x

-- Keep the first value that is not a `Left`
-- If both `Either`s are `Left`s, use the given accumulator
-- for the error values
total
firstEither : (e -> e -> e) -> Either e a -> Either e a -> Either e a
firstEither f (Left l1) (Left l2) = Left $ f l1 l2
firstEither _ (Right x) _         = Right x
firstEither _ _         (Right x) = Right x

-- Keep the last value that is not a `Left`
-- If both `Either`s are `Left`s, use the given accumulator
-- for the error values
total
lastEither : (e -> e -> e) -> Either e a -> Either e a -> Either e a
lastEither f (Left l1) (Left l2) = Left $ f l1 l2
lastEither _ _         (Right x) = Right x
lastEither _ (Right x) _         = Right x

total
fromEither : (e -> c) -> (a -> c) -> Either e a -> c
fromEither _ f (Right x) = f x
fromEither f _ (Left x)  = f x
```

## Exercise 3

Implement the following generic functions for `List`:

```idris
total
mapList : (a -> b) -> List a -> List b
mapList f []        = []
mapList f (x :: xs) = f x :: mapList f xs

total
filterList : (a -> Bool) -> List a -> List a
filterList f (x :: xs) = if f x then x :: filterList f xs else filterList f xs
filterList _ []        = []

-- re-implement list concatenation (++) such that e.g. (++) [1, 2] [3, 4] = [1, 2, 3, 4]
-- note that because this function conflicts with the standard
-- Prelude.List.(++), if you use it then you will need to prefix it with
-- the name of your module, like DataTypes.(++) or Ch3.(++). alternatively
-- you could simply call the function something unique like myListConcat or concat'
total
(++) : List a -> List a -> List a
[] ++ ys        = ys
(x :: xs) ++ ys = x :: (Tutorial.DataTypes.Exercises4.(++) xs ys)

-- return the first value of a list, if it is non-empty
total
headMaybe : List a -> Maybe a
headMaybe (x :: xs) = Just x
headMaybe []        = Nothing

-- return everything but the first value of a list, if it is non-empty
total
tailMaybe : List a -> Maybe (List a)
tailMaybe (_ :: xs) = Just xs
tailMaybe []        = Nothing

-- return the last value of a list, if it is non-empty
total
lastMaybe : List a -> Maybe a
lastMaybe (x :: [])      = Just x
lastMaybe (_ :: y :: xs) = lastMaybe $ y :: xs
lastMaybe []             = Nothing

-- return everything but the last value of a list,
-- if it is non-empty
total
initMaybe : List a -> Maybe (List a)
initMaybe []        = Nothing
initMaybe (x :: []) = Just []
initMaybe (x :: xs) = mapMaybe (x ::) $ initMaybe xs

-- accumulate the values in a list using the given
-- accumulator function and initial value
--
-- Examples:
-- `foldList (+) 10 [1,2,7] = 20`
-- `foldList String.(++) "" ["Hello","World"] = "HelloWorld"`
-- `foldList last Nothing (mapList Just [1,2,3]) = Just 3`
total
foldList : (acc -> el -> acc) -> acc -> List el -> acc
foldList f start (x :: xs) = foldList f (f start x) xs
foldList _ start []        = start
```

## Exercise 4

Assume we store user data for our web application in the following record:

```idris
record Client where
  constructor MkClient
  name          : String
  title         : Title
  age           : Bits8
  passwordOrKey : Either Bits64 String
```

Using `LoginError` from an earlier exercise, implement function `login`, which, given a list of `Client`s plus a value of type `Credentials` will return either a `LoginError` in case no valid credentials where provided, or the first `Client` for whom the credentials match.

```idris
total
loginSingleUser : Client -> Credentials -> Either LoginError Client
loginSingleUser client@(MkClient name _ _ passwordOrKey) (Password user password) =
  if user == name
     then case passwordOrKey of
            Left clientPassword =>
              if clientPassword == password
                then Right client
                else Left InvalidPassword
            Right _             => Left InvalidKey
     else Left $ InvalidUser name
loginSingleUser client@(MkClient name _ _ passwordOrKey) (Key user key)           =
  if user == name
     then case passwordOrKey of
            Left _    => Left InvalidPassword
            Right clientKey =>
              if clientKey == key
                then Right client
                else Left InvalidKey
     else Left $ InvalidUser name

total
login : List Client -> Credentials -> Either LoginError Client
login (client :: clients) credentials       =
  case loginSingleUser client credentials of
    Right client         => Right client
    Left InvalidPassword => Left InvalidPassword
    Left InvalidKey      => Left InvalidKey
    Left _               => login clients credentials
login []                  (Password user _) =
  Left $ InvalidUser      user
login []                  (Key user _)      =
  Left $ InvalidUser      user
```


## Exercise 5

Using your data type for chemical elements from an earlier exercise, implement a function for calculating the molar mass of a molecular formula.

Use a list of elements each paired with its count (a natural number) for representing formulae. For instance:

```idris
ethanol : List (Element,Nat)
ethanol = [(C,2),(H,6),(O,1)]

calculateMolarMass : List (Element, Nat) -> Double
calculateMolarMass ((element, count) :: rest) =
  cast count * atomicMass element + calculateMolarMass rest
calculateMolarMass []                         = 0
```

Hint: You can use function `cast` to convert a natural number to a `Double`.

<!-- vi: filetype=idris2:syntax=markdown
-->
