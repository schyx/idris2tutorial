# Exercises Part 1

```idris
module Tutorial.Interfaces.Exercises1

import Tutorial.Interfaces.Basics
```

1. Implement function `anyLarger`, which should return `True`, if and only if a list of values contains at least one element larger than a given reference value. Use interface `Comp` in your implementation.

```idris
anyLarger : Comp a => a -> List a -> Bool
anyLarger y (x :: xs) = if greaterThan x y then True else anyLarger y xs
anyLarger _        [] = False
```

2. Implement function `allLarger`, which should return `True`, if and only if a list of values contains *only* elements larger than a given reference value. Note, that this is trivially true for the empty list. Use interface `Comp` in your implementation.

```idris
allLarger : Comp a => a -> List a -> Bool
allLarger y (x :: xs) =
  if comp x y /= GT then False else allLarger y xs
allLarger _ []        = True
```

3. Implement function `maxElem`, which tries to extract the largest element from a list of values with a `Comp` implementation. Likewise for `minElem`, which tries to extract the smallest element. Note, that the possibility of the list being empty must be considered when deciding on the output type.

```idris
maxElem : Comp a => List a -> Maybe a
maxElem elements = go elements Nothing
  where
    go : List a -> Maybe a -> Maybe a
    go (x :: xs) buildup =
      case map (comp x) buildup of
           Nothing => go xs $ Just x
           Just GT => go xs $ Just x
           Just _  => go xs buildup
    go []        buildup = buildup

minElem : Comp a => List a -> Maybe a
minElem []        = Nothing
minElem (x :: xs) =
  case minElem xs of
       Nothing => Just x
       Just v  => if comp x v == LT then Just x else Just v
```

4. Define an interface `Concat` for values like lists or strings, which can be concatenated. Provide implementations for lists and strings.

```idris
interface Concat a where
  concatenate : a -> a -> a

implementation Concat String where
  concatenate = (++)

implementation Concat (List b) where
  concatenate = (++)
```

5. Implement function `concatList` for concatenating the values in a list holding values with a `Concat` implementation. Make sure to reflect the possibility of the list being empty in your output type.

```idris
concatList : Concat a => List a -> Maybe a
concatList [] = Nothing
concatList (x :: xs) = case concatList xs of
  Nothing => Just x
  Just v  => Just $ concatenate x v
```

<!-- vi: filetype=idris2:syntax=markdown
-->
