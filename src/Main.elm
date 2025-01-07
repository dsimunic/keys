module Main exposing (Model, Msg(..), init, main, update, view)

import Browser exposing (Document)
import Browser.Events
import Html exposing (div, span, text)
import Html.Attributes exposing (class)
import Json.Decode exposing (Decoder, andThen, fail, field, float, map2, string, succeed)


type alias Model =
    { log : List String
    , mouse : ( Float, Float )
    , mouseDuplicates : Int
    }


type Msg
    = Keypress String
    | Mousemove ( Float, Float )


init : ( Model, Cmd Msg )
init =
    ( { log = []
      , mouse = ( 0, 0 )
      , mouseDuplicates = 0
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Keypress s ->
            ( { model | log = s :: model.log }
            , Cmd.none
            )

        Mousemove p ->
            ( if model.mouse == p then
                { model | mouseDuplicates = model.mouseDuplicates + 1 }

              else
                { model | mouse = p, mouseDuplicates = 0 }
            , Cmd.none
            )


view : Model -> Document Msg
view model =
    { title = "Keypress repro"
    , body =
        [ div [ class "keypresses" ]
            (List.reverse <|
                Tuple.first <|
                    List.foldl
                        (\a ( acc, p ) ->
                            if a == p then
                                ( div [ class "rep" ] [ text a ] :: acc, a )

                            else
                                ( div [] [ text a ] :: acc, a )
                        )
                        ( [], "" )
                        (model.log |> List.take 10 |> List.reverse)
            )
        , div []
            [ let
                ( x, y ) =
                    model.mouse
              in
              text (String.fromFloat x ++ "," ++ String.fromFloat y)
            , if model.mouseDuplicates > 0 then
                span [ class "rep" ]
                    [ text (" " ++ String.fromInt model.mouseDuplicates ++ " duplicate(s)") ]

              else
                text ""
            ]
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Browser.Events.onKeyDown (Json.Decode.map Keypress decodeKey)
        , Browser.Events.onMouseMove (Json.Decode.map Mousemove decodeMouse)
        ]


decodeKey : Decoder String
decodeKey =
    field "key" string
        |> andThen
            (\key ->
                if String.isEmpty key then
                    fail "empty key"

                else
                    succeed key
            )


decodeMouse : Decoder ( Float, Float )
decodeMouse =
    map2 Tuple.pair
        (field "screenX" float)
        (field "screenY" float)



-- MAIN


main : Program () Model Msg
main =
    Browser.document
        { init = always init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
