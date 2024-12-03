module Aircraft exposing (..)

import Json.Decode as Decode exposing (Decoder, andThen, map)
import Json.Encode as Encode exposing (Value)
import Utils exposing (hexStringToInt)

type alias Aircraft =
    { icao24 : String
    , callsign : Maybe String
    , originCountry : String
    , timePosition : Maybe Int
    , lastContact : Int
    , longitude : Maybe Float
    , latitude : Maybe Float
    , baroAltitude : Maybe Float
    , onGround : Bool
    , velocity : Maybe Float
    , trueTrack : Maybe Float
    , verticalRate : Maybe Float
    , sensors : Maybe (List Int)
    , geoAltitude : Maybe Float
    , squawk : Maybe String
    , spi : Bool
    , positionSource : Int
    }


type alias Response =
    { time : Int
    , states : List Aircraft
    }


responseDecoder : Decoder Response
responseDecoder =
    Decode.map2 Response
        (Decode.field "time" Decode.int)
        (Decode.field "states" (Decode.list aircraftDecoder))


aircraftDecoder : Decoder Aircraft
aircraftDecoder =
    Decode.index 0 Decode.string |> andThen (\icao24 ->
    Decode.index 1 (Decode.nullable Decode.string) |> andThen (\callsign ->
    Decode.index 2 Decode.string |> andThen (\originCountry ->
    Decode.index 3 (Decode.nullable Decode.int) |> andThen (\timePosition ->
    Decode.index 4 Decode.int |> andThen (\lastContact ->
    Decode.index 5 (Decode.nullable Decode.float) |> andThen (\longitude ->
    Decode.index 6 (Decode.nullable Decode.float) |> andThen (\latitude ->
    Decode.index 7 (Decode.nullable Decode.float) |> andThen (\baroAltitude ->
    Decode.index 8 Decode.bool |> andThen (\onGround ->
    Decode.index 9 (Decode.nullable Decode.float) |> andThen (\velocity ->
    Decode.index 10 (Decode.nullable Decode.float) |> andThen (\trueTrack ->
    Decode.index 11 (Decode.nullable Decode.float) |> andThen (\verticalRate ->
    Decode.index 12 (Decode.nullable (Decode.list Decode.int)) |> andThen (\sensors ->
    Decode.index 13 (Decode.nullable Decode.float) |> andThen (\geoAltitude ->
    Decode.index 14 (Decode.nullable Decode.string) |> andThen (\squawk ->
    Decode.index 15 Decode.bool |> andThen (\spi ->
    Decode.index 16 Decode.int |> map (\positionSource ->
        Aircraft
            icao24
            callsign
            originCountry
            timePosition
            lastContact
            longitude
            latitude
            baroAltitude
            onGround
            velocity
            trueTrack
            verticalRate
            sensors
            geoAltitude
            squawk
            spi
            positionSource
    )))))))))))))))))


aircraftsToGeoJSON : List Aircraft -> Value
aircraftsToGeoJSON aircrafts =
    let
        features =
            aircrafts
                |> List.filter (\a -> Maybe.withDefault False (Maybe.map2 (\lon lat -> True) a.longitude a.latitude))
                |> List.filter (\a -> String.length a.icao24 > 0) -- Filter invalid IDs
                |> List.map (\a ->
                    let
                        lon = Maybe.withDefault 0 a.longitude
                        lat = Maybe.withDefault 0 a.latitude
                        properties =
                            [ ( "icao24", Encode.string a.icao24 )
                            , ( "callsign", Encode.string (Maybe.withDefault "" a.callsign) )
                            , ( "originCountry", Encode.string a.originCountry )
                            , ( "trueTrack", Encode.float (Maybe.withDefault 0 a.trueTrack) )
                            ]
                        geometry =
                            Encode.object
                                [ ( "type", Encode.string "Point" )
                                , ( "coordinates", Encode.list Encode.float [ lon, lat ] )
                                ]
                        feature =
                            Encode.object
                                [ ( "type", Encode.string "Feature" )
                                , ( "id", Encode.int (hexStringToInt a.icao24) )
                                , ( "geometry", geometry )
                                , ( "properties", Encode.object properties )
                                ]
                    in
                    feature
                )
    in
    Encode.object
        [ ( "type", Encode.string "FeatureCollection" )
        , ( "features", Encode.list identity features )
        ]
