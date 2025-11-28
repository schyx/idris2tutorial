module Tutorial.Functions2.HoleExercise

traverseEither : Semigroup e => (a -> Either e b) -> List a -> Either e (List b)
traverseEither fun []        = Right []
traverseEither fun (x :: xs) =
  case (fun x, traverseEither fun xs) of
    (Left y , Left z ) => Left $ y <+> z
    (Left y , Right _) => Left y
    (Right _, Left z ) => Left z
    (Right y, Right z) => Right $ y :: z
