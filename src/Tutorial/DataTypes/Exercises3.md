# Record Exercises

```idris
module Tutorial.DataTypes.Exercises3

import Tutorial.DataTypes.Exercises1
```

The solutions to these exercises can be found in [`src/Solutions/DataTypes.idr`](../../Solutions/DataTypes.md).

## Exercise 1

Define a record type for time spans by pairing a `UnitOfTime` with an integer representing the duration of the time span in the given unit of time. Also define a function for converting a time span to an `Integer` representing the duration in seconds.

```idris
record Duration where
  constructor MkDuration
  unit  : UnitOfTime
  count : Integer

durationToSeconds : Duration -> Integer
durationToSeconds (MkDuration u c) = toSeconds u c
```

## Exercise 2

Implement an equality check for time spans. Two time spans should be considered equal, if and only if they correspond to the same number of seconds.

```idris
Eq Duration where
  (MkDuration unit1 count1) == (MkDuration unit2 count2) =
    toSeconds unit1 count1 == toSeconds unit2 count2
```

## Exercise 3

Implement a function for pretty printing time spans. The resulting string should display the time span in its given unit, plus show the number of seconds in parentheses, if the unit is not already seconds.

```idris
prettyPrint : Duration -> String
prettyPrint d@(MkDuration Second numSeconds) =
  show numSeconds ++ " seconds"
prettyPrint d@(MkDuration Minute numMinutes) =
  show numMinutes ++ " minutes (" ++ show (durationToSeconds d) ++ ")"
prettyPrint d@(MkDuration Hour   numMinutes) =
  show numMinutes ++ " hours (" ++ show (durationToSeconds d) ++ ")"
prettyPrint d@(MkDuration Day    numMinutes) =
  show numMinutes ++ " days (" ++ show (durationToSeconds d) ++ ")"
prettyPrint d@(MkDuration Week   numMinutes) =
  show numMinutes ++ " weeks (" ++ show (durationToSeconds d) ++ ")"
```

## Exercise 4

Implement a function for adding two time spans. If the two time spans use different units of time, use the smaller unit of time to ensure a lossless conversion.

<!-- vi: filetype=idris2:syntax=markdown
-->
