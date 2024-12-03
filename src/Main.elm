module Main exposing (..)

import Aircraft exposing (Aircraft, Response, responseDecoder, aircraftsToGeoJSON)
import Browser
import Html exposing (div, text, Html, h2, p, span, strong)
import Html.Attributes exposing (style)
import Http
import Json.Decode
import Json.Encode exposing (Value)
import LngLat exposing (LngLat)
import Mapbox.Element exposing (..)
import Mapbox.Expression as E exposing (float, str, true)
import Mapbox.Layer as Layer
import Mapbox.Source as Source
import Mapbox.Style exposing (Style(..))
import Styles.Light
import Time
import Utils exposing (roundToOne, hexStringToInt)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { position : LngLat
    , features : List Value
    , aircrafts : List Aircraft
    , selectedAircraft : Maybe Aircraft
    , selectedFeatureId : Maybe Int
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { position = LngLat 0 0
      , features = []
      , aircrafts = []
      , selectedAircraft = Nothing
      , selectedFeatureId = Nothing
      }
    , fetchAircrafts
    )


type Msg
    = Hover EventData
    | Click EventData
    | GotAircrafts (Result Http.Error Response)
    | Tick


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Hover { lngLat, renderedFeatures } ->
            ( { model | position = lngLat, features = renderedFeatures }, Cmd.none )

        Click { lngLat, renderedFeatures } ->
            let
                maybeSelectedFeatureId =
                    case renderedFeatures of
                        feat :: _ ->
                            Json.Decode.decodeValue (Json.Decode.field "id" Json.Decode.int) feat
                                |> Result.toMaybe

                        [] ->
                            Nothing

                maybeSelectedAircraft =
                    maybeSelectedFeatureId
                        |> Maybe.andThen (\id ->
                            List.filter (\a -> hexStringToInt a.icao24 == id) model.aircrafts
                                |> List.head
                        )
            in
            ( { model
                | position = lngLat
                , selectedAircraft = maybeSelectedAircraft
                , selectedFeatureId = maybeSelectedFeatureId
              }
            , Cmd.none
            )

        GotAircrafts result ->
            case result of
                Ok response ->
                    let
                        maybeSelectedAircraft =
                            model.selectedFeatureId
                                |> Maybe.andThen (\id ->
                                    List.filter (\a -> hexStringToInt a.icao24 == id) response.states
                                        |> List.head
                                )
                    in
                    ( { model
                        | aircrafts = response.states
                        , selectedAircraft = maybeSelectedAircraft
                    }
                    , Cmd.none )

                Err error ->
                    let
                        _ = Debug.log "Error fetching aircraft data" error
                    in
                    ( model, Cmd.none )

        Tick ->
            ( model, fetchAircrafts )


-- Fetch aircraft data from OpenSky API
fetchAircrafts : Cmd Msg
fetchAircrafts =
    let
        -- New York City area
        -- url = "https://opensky-network.org/api/states/all?lamin=40&lomin=-75&lamax=41.3&lomax=-73"
        url = "https://opensky-network.org/api/states/all"
    in
    Http.get
        { url = url
        , expect = Http.expectJson GotAircrafts responseDecoder
        }


aircraftFeatures : Model -> MapboxAttr msg
aircraftFeatures model =
    let
        hoverState =
            case model.features of
                firstFeature :: _ ->
                    [ ( firstFeature, [ ( "hover", Json.Encode.bool True ) ] ) ]
                [] ->
                    []

        selectedState =
            case model.selectedFeatureId of
                Just id ->
                    let
                        feature =
                            Json.Encode.object
                                [ ( "source", Json.Encode.string "aircrafts" )
                                , ( "id", Json.Encode.int id )
                                ]
                    in
                    [ ( feature, [ ( "select", Json.Encode.bool True ), ( "hover", Json.Encode.bool False ) ] ) ]

                Nothing ->
                    []
    in
    featureState (hoverState ++ selectedState)


aircraftGeoJSON : Model -> Value
aircraftGeoJSON model =
    aircraftsToGeoJSON model.aircrafts


aircraftSource : Model -> Source.Source
aircraftSource model =
    Source.geoJSONFromValue "aircrafts" [] (aircraftGeoJSON model)


aircraftLayer : Layer.Layer
aircraftLayer =
    Layer.symbol "aircrafts" "aircrafts"
        [ Layer.iconImage (str "airport-15")
        , Layer.iconSize (float 1.5)
        , Layer.iconAllowOverlap true
        , Layer.iconIgnorePlacement true
        , Layer.iconOpacity 
            (E.ifElse 
                (E.toBool (E.featureState (str "select")))
                (float 1)
                (E.ifElse 
                    (E.toBool (E.featureState (str "hover")))
                    (float 0.8)
                    (float 0.5)
                )
            )
        , Layer.iconRotate (E.getProperty (str "trueTrack"))
        ]


baseStyle = Styles.Light.style
extendedStyle model =
    case baseStyle of
        Style styleDef ->
            let
                newStyleDef =
                    { styleDef
                        | layers = styleDef.layers ++ [ aircraftLayer ]
                        , sources = styleDef.sources ++ [ aircraftSource model ]
                    }
            in
            Style newStyleDef

        FromUrl _ ->
            baseStyle


view : Model -> Html Msg
view model =
    div []
        [ css
        , mapView model
        , positionDisplay model
        , maybeAircraftInfo model.selectedAircraft
        ]


mapView : Model -> Html Msg
mapView model =
    div [ style "width" "100vw", style "height" "100vh" ]
        [ map
            [ maxZoom 18
            , onMouseMove Hover
            , onClick Click
            , id "my-map"
            , eventFeaturesLayers [ "aircrafts" ]
            , aircraftFeatures model
            ]
            (extendedStyle model)
        ]


positionDisplay : Model -> Html Msg
positionDisplay model =
    div [ style "position" "absolute", style "bottom" "20px", style "left" "20px" ]
        [ text (LngLat.toString model.position) ]


maybeAircraftInfo : Maybe Aircraft -> Html Msg
maybeAircraftInfo maybeAircraft =
    case maybeAircraft of
        Just aircraft ->
            aircraftInfoView aircraft

        Nothing ->
            text ""

    
aircraftInfoView : Aircraft -> Html msg
aircraftInfoView aircraft =
    div
        [ style "position" "absolute"
        , style "top" "20px"
        , style "left" "20px"
        , style "background-color" "#ffffff"
        , style "padding" "20px 25px 12px 25px"
        , style "border-radius" "8px"
        , style "box-shadow" "0 4px 6px rgba(0, 0, 0, 0.1)"
        , style "max-width" "300px"
        , style "min-width" "150px"
        , style "font-family" "Arial, sans-serif"
        , style "color" "#333333"
        ]
        [ div [ style "border-bottom" "1px solid #dddddd", style "padding-bottom" "10px", style "margin-bottom" "10px" ]
            [ h2 [ style "margin" "0", style "font-size" "18px" ] [ text (Maybe.withDefault "Unknown Aircraft" aircraft.callsign) ]
            , p [ style "margin" "5px 0 0 0", style "font-size" "14px", style "color" "#777777" ] [ text ("ICAO24: " ++ aircraft.icao24) ]
            ]
        , div []
            [ infoRow "Origin Country" aircraft.originCountry
            , infoRow "Geometric Altitude" (maybeToString aircraft.geoAltitude ++ " m")
            , infoRow "Velocity" (maybeToString (Maybe.map (\v -> roundToOne (v * 2.23694)) aircraft.velocity) ++ " mph")
            , infoRow "Vertical Rate" (maybeToString aircraft.verticalRate ++ " m/s")
            ]
        ]


infoRow : String -> String -> Html msg
infoRow label value =
    div [ style "margin-bottom" "8px" ]
        [ strong [ style "display" "block", style "font-size" "14px", style "color" "#555555" ] [ text label ]
        , span [ style "font-size" "14px", style "color" "#333333" ] [ text value ]
        ]


maybeToString : Maybe Float -> String
maybeToString maybeValue =
    case maybeValue of
        Just value ->
            String.fromFloat value

        Nothing ->
            "N/A"


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every (10 * 1000) (\_ -> Tick)
