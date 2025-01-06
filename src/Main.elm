module Main exposing (Model, Msg(..), init, main, update, view)

import Browser exposing (Document)
import Browser.Events
import Html exposing (div, text)
import Html.Attributes exposing (class)
import Json.Decode exposing (Decoder, andThen, fail, field, string, succeed)


type alias Model =
    { log : List String
    }


type Msg
    = Keypress String


init : ( Model, Cmd Msg )
init =
    ( { log = [] }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Keypress s ->
            ( { model | log = s :: model.log }
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
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Browser.Events.onKeyDown (Json.Decode.map Keypress decodeKey)
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



-- MAIN


main : Program () Model Msg
main =
    Browser.document
        { init = always init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
