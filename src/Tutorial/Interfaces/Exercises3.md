# Exercises part 3

```idris
module Tutorial.Interfaces.Exercises3
```

These exercises are meant to make you comfortable with implementing interfaces for your own data types, as you will have to do so regularly when writing Idris code.

While it is immediately clear why interfaces like `Eq`, `Ord`, or `Num` are useful, the usability of `Semigroup` and `Monoid` may be harder to appreciate at first. Therefore, there are several exercises where you'll implement different instances for these.

01. Define a record type `Complex` for complex numbers, by pairing two values of type `Double`. Implement interfaces `Eq`, `Num`, `Neg`, and `Fractional` for `Complex`.

```idris
record Complex where
  constructor MkComplex
  real : Double
  imaginary : Double

implementation Eq Complex where
  (MkComplex r1 i1) == (MkComplex r2 i2) = r1 == r2 && i1 == i2

implementation Num Complex where
  fromInteger x = MkComplex (fromInteger x) 0

  (MkComplex r1 i1) * (MkComplex r2 i2) = MkComplex (r1 * r2 - i1 * i2) (r1 * i2 + r2 * i1)

  (MkComplex r1 i1) + (MkComplex r2 i2) = MkComplex (r1 + r2) (i1 + i2)

implementation Neg Complex where
  (MkComplex r1 i1) - (MkComplex r2 i2) = MkComplex (r1 - r2) (i1 - i2)

  negate (MkComplex r i) = MkComplex (negate r) (negate i)

implementation Fractional Complex where
  (MkComplex r1 i1) / (MkComplex r2 i2) =
    let denom = r2 * r2 + i2 * i2
     in MkComplex ((r1 * r2 + i1 * i2) / denom) ((i1 * r2 - r1 * i2) / denom)
```

02. Implement interface `Show` for `Complex`. Have a look at data type `Prec` and function `showPrec` and how these are used in the *Prelude* to implement instances for `Either` and `Maybe`.

    Verify the correct behavior of your implementation by wrapping a value of type `Complex` in a `Just` and `show` the result at the REPL.

```idris
implementation Show Complex where
  showPrec p (MkComplex a b) = showCon p "MkComplex" (" " ++ show a ++ " " ++ show b)
```

03. Consider the following wrapper for optional values:

```idris
record First a where
  constructor MkFirst
  value : Maybe a

pureFirst : a -> First a
pureFirst = MkFirst . Just

mapFirst : (a -> b) -> First a -> First b
mapFirst f first = MkFirst $ map f first.value

mapFirst2 : (a -> b -> c) -> First a -> First b -> First c
mapFirst2 f first second =
  case (first.value, second.value) of
       (Just x, Just y) => MkFirst $ Just $ f x y
       (_     , _     ) => MkFirst Nothing

implementation Eq a => Eq (First a) where
  f1 == f2 = f1.value == f2.value

implementation Ord a => Ord (First a) where
  compare f1 f2 = compare f1.value f2.value

implementation Show a => Show (First a) where
  show = show . value

implementation FromString a => FromString (First a) where
  fromString = pureFirst . fromString

implementation FromChar a => FromChar (First a) where
  fromChar = pureFirst . fromChar

implementation FromDouble a => FromDouble (First a) where
  fromDouble = pureFirst . fromDouble

implementation Num a => Num (First a) where
  fromInteger = pureFirst . fromInteger
  (*) = mapFirst2 (*)
  (+) = mapFirst2 (+)

implementation Neg a => Neg (First a) where
  (-) = mapFirst2 (-)
  negate = mapFirst negate

implementation Integral a => Integral (First a) where
  mod = mapFirst2 mod
  div = mapFirst2 div

implementation Fractional a => Fractional (First a) where
  (/) = mapFirst2 (/)
```

    Implement interfaces `Eq`, `Ord`, `Show`, `FromString`, `FromChar`, `FromDouble`, `Num`, `Neg`, `Integral`, and `Fractional` for `First a`. All of these will require corresponding constraints on type parameter `a`. Consider implementing and using the following utility functions where they make sense:

04. Implement interfaces `Semigroup` and `Monoid` for `First a` in such a way, that `(<+>)` will return the first non-nothing argument and `neutral` is the corresponding neutral element. There must be no constraints on type parameter `a` in these implementations.

```idris
implementation Semigroup (First a) where
  f1 <+> f2 = case f1.value of
                Just _  => f1
                Nothing => f2

implementation Monoid (First a) where
  neutral = MkFirst Nothing
```

05. Repeat exercises 3 and 4 for record `Last`. The `Semigroup` implementation should return the last non-nothing value.

```idris
record Last a where
  constructor MkLast
  value : Maybe a

pureLast : a -> Last a
pureLast = MkLast . Just

mapLast : (a -> b) -> Last a -> Last b
mapLast f last = MkLast $ map f last.value

mapLast2 : (a -> b -> c) -> Last a -> Last b -> Last c
mapLast2 f first second =
  case (first.value, second.value) of
       (Just x, Just y) => MkLast $ Just $ f x y
       (_     , _     ) => MkLast Nothing

implementation Eq a => Eq (Last a) where
  f1 == f2 = f1.value == f2.value

implementation Ord a => Ord (Last a) where
  compare f1 f2 = compare f1.value f2.value

implementation Show a => Show (Last a) where
  show = show . value

implementation FromString a => FromString (Last a) where
  fromString = pureLast . fromString

implementation FromChar a => FromChar (Last a) where
  fromChar = pureLast . fromChar

implementation FromDouble a => FromDouble (Last a) where
  fromDouble = pureLast . fromDouble

implementation Num a => Num (Last a) where
  fromInteger = pureLast . fromInteger
  (*) = mapLast2 (*)
  (+) = mapLast2 (+)

implementation Neg a => Neg (Last a) where
  (-) = mapLast2 (-)
  negate = mapLast negate

implementation Integral a => Integral (Last a) where
  mod = mapLast2 mod
  div = mapLast2 div

implementation Fractional a => Fractional (Last a) where
  (/) = mapLast2 (/)

implementation Semigroup (Last a) where
  l1 <+> l2 = case l2.value of
                Just _  => l2
                Nothing => l1

implementation Monoid (Last a) where
  neutral = MkLast Nothing
```

06. Function `foldMap` allows us to map a function returning a `Monoid` over a list of values and accumulate the result using `(<+>)` at the same time. This is a very powerful way to accumulate the values stored in a list. Use `foldMap` and `Last` to extract the last element (if any) from a list.

    Note, that the type of `foldMap` is more general and not specialized to lists only. It works also for `Maybe`, `Either` and other container types we haven't looked at so far. We will learn about interface `Foldable` in a later section.

```idris
lastElement : List a -> Maybe a
lastElement = value . foldMap pureLast
```

07. Consider record wrappers `Any` and `All` for boolean values:

```idris
record Any where
  constructor MkAny
  any : Bool

implementation Semigroup Any where
  (MkAny True) <+> _ = MkAny True
  _            <+> r = r

implementation Monoid Any where
  neutral = MkAny False

record All where
  constructor MkAll
  all : Bool

implementation Semigroup All where
  (MkAll False) <+> _ = MkAll False
  _             <+> r = r

implementation Monoid All where
  neutral = MkAll True
```

    Implement `Semigroup` and `Monoid` for `Any`, so that the result of `(<+>)` is `True`, if and only if at least one of the arguments is `True`. Make sure that `neutral` is indeed the neutral element for this operation.

    Likewise, implement `Semigroup` and `Monoid` for `All`, so that the result of `(<+>)` is `True`, if and only if both of the arguments are `True`. Make sure that `neutral` is indeed the neutral element for this operation.

08. Implement functions `anyElem` and `allElems` using `foldMap` and `Any` or `All`, respectively:

```idris
-- True, if the predicate holds for at least one element
anyElem : (a -> Bool) -> List a -> Bool
anyElem pred = any . foldMap (MkAny . pred)

-- True, if the predicate holds for all elements
allElems : (a -> Bool) -> List a -> Bool
allElems pred = all . foldMap (MkAll . pred)
```

09. Record wrappers `Sum` and `Product` are mainly used to hold numeric types.

```idris
record Sum a where
  constructor MkSum
  value : a

implementation Num a => Semigroup (Sum a) where
  s1 <+> s2 = MkSum $ s1.value + s2.value

implementation Num a => Monoid (Sum a) where
  neutral = MkSum 0

record Product a where
  constructor MkProduct
  value : a

implementation Num a => Semigroup (Product a) where
  s1 <+> s2 = MkProduct $ s1.value * s2.value

implementation Num a => Monoid (Product a) where
  neutral = MkProduct 1
```

    Given an implementation of `Num a`, implement `Semigroup (Sum a)` and `Monoid (Sum a)`, so that `(<+>)` corresponds to addition.

    Likewise, implement `Semigroup (Product a)` and `Monoid (Product a)`, so that `(<+>)` corresponds to multiplication.

    When implementing `neutral`, remember that you can use integer literals when working with numeric types.

10. Implement `sumList` and `productList` by using `foldMap` together with the wrappers from Exercise 9:

```idris
sumList : Num a => List a -> a
sumList = value . foldMap MkSum

productList : Num a => List a -> a
productList = value . foldMap MkProduct
```

11. To appreciate the power and versatility of `foldMap`, after solving exercises 6 to 10 (or by loading `Solutions.Inderfaces` in a REPL session), run the following at the REPL, which will - in a single list traversal! - calculate the first and last element of the list as well as the sum and product of all values.

    ```repl
    > foldMap (\x => (pureFirst x, pureLast x, MkSum x, MkProduct x)) [3,7,4,12]
    (MkFirst (Just 3), (MkLast (Just 12), (MkSum 26, MkProduct 1008)))
    ```

    Note, that there are also `Semigroup` implementations for types with an `Ord` implementation, which will return the smaller or larger of two values. In case of types with an absolute minimum or maximum (for instance, 0 for natural numbers, or 0 and 255 for `Bits8`), these can even be extended to `Monoid`.

12. In an earlier exercise, you implemented a data type representing chemical elements and wrote a function for calculating their atomic masses. Define a new single field record type for representing atomic masses, and implement interfaces `Eq`, `Ord`, `Show`, `FromDouble`, `Semigroup`, and `Monoid` for this.

```idris
data Element = H | C | N | O | F

record ChemicalMass where
  constructor MkMass
  mass : Double

implementation Eq ChemicalMass where
  (==) = (==) `on` mass

implementation Ord ChemicalMass where
  compare = compare `on` mass

implementation Show ChemicalMass where
  show = show . mass

implementation FromDouble ChemicalMass where
  fromDouble = MkMass . fromDouble

implementation Semigroup ChemicalMass where
  m1 <+> m2 = MkMass $ m1.mass + m2.mass

implementation Monoid ChemicalMass where
  neutral = MkMass 0
```

13. Use the new data type from exercise 12 to calculate the atomic mass of an element and compute the molecular mass of a molecule given by its formula.

    Hint: With a suitable utility function, you can use `foldMap` once again for this.

```idris
atomicMass : Element -> ChemicalMass
atomicMass H = 1.008
atomicMass C = 12.011
atomicMass N = 14.007
atomicMass O = 15.999
atomicMass F = 18.9984

elementMass : (Element, Nat) -> ChemicalMass
elementMass (element, n) = MkMass $ mass (atomicMass element) * cast n

findMass : List (Element, Nat) -> Double
findMass = mass . foldMap elementMass
```

Final notes: If you are new to functional programming, make sure to give your implementations of exercises 6 to 10 a try at the REPL. Note, how we can implement all of these functions with a minimal amount of code and how, as shown in exercise 11, these behaviors can be combined in a single list traversal.

<!-- vi: filetype=idris2:syntax=markdown
-->
