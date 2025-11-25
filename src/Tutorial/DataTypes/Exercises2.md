# Sum Type Exercises

```idris
module Tutorial.DataTypes.Exercises2

import Tutorial.DataTypes.SumTypes
```

The solutions to these exercises can be found in [`src/Solutions/DataTypes.idr`](../../Solutions/DataTypes.md).

## Exercise 1

Implement an equality test for `Title` (you can use the equality operator `(==)` for comparing two `String`s):

```idris
total
eqTitle : Title -> Title -> Bool
eqTitle Mr        Mr        = True
eqTitle Mrs       Mrs       = True
eqTitle (Other x) (Other y) = x == y
eqTitle _         _         = False
```

## Exercise 2

Implement a simple test for `Title` to check whether or not a custom title is being used:

```idris
total
isOther : Title -> Bool
isOther (Other _) = True
isOther _         = False
```

## Exercise 3

Given our simple `Credentials` type, there are three ways for authentication to fail:

- An unknown username was used.
- The password given does not match the one associated with the username.
- An invalid key was used.

Encapsulate these three possibilities in a sum type called `LoginError`. Make sure not to disclose any confidential information, an invalid username should be stored in the corresponding error value, but an invalid password or key should not.

```idris
data LoginError
  = InvalidUser String
  | InvalidPassword
  | InvalidKey
```

## Exercise 4

Implement the following function , which can be used to display an error message to the user after they unsuccessfully tried to login into our web application:

```idris
total
showError : LoginError -> String
showError InvalidKey         = "Invalid key was used!"
showError InvalidPassword    = "Invalid password was used!"
showError (InvalidUser user) = "Invalid username was given!"
```

<!-- vi: filetype=idris2:syntax=markdown
-->
