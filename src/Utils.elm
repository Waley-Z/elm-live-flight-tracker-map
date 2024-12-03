module Utils exposing (..)

roundToOne : Float -> Float
roundToOne number =
    let
        multiplier = 10.0
    in
    toFloat (Basics.round (number * multiplier)) / multiplier


hexDigitToInt : Char -> Int
hexDigitToInt c =
    case c of
        '0' -> 0
        '1' -> 1
        '2' -> 2
        '3' -> 3
        '4' -> 4
        '5' -> 5
        '6' -> 6
        '7' -> 7
        '8' -> 8
        '9' -> 9
        'A' -> 10
        'B' -> 11
        'C' -> 12
        'D' -> 13
        'E' -> 14
        'F' -> 15
        'a' -> 10
        'b' -> 11
        'c' -> 12
        'd' -> 13
        'e' -> 14
        'f' -> 15
        _   -> 0  -- Handle invalid characters as needed


hexStringToInt : String -> Int
hexStringToInt hexStr =
    String.toList hexStr
        |> List.foldl (\c acc -> (acc * 16) + hexDigitToInt c) 0
