module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, field, map, string)



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type Model
    = NotStarted
    | Loading
    | Success Question
    | Failed


init : () -> ( Model, Cmd Msg )
init _ =
    ( NotStarted, Cmd.none )


type Question
    = Question String


decoder : Decoder Question
decoder =
    Json.Decode.map Question (field "statement" string)



-- UPDATE


type Msg
    = Clicked
    | GotQuestion (Result Http.Error Question)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Clicked ->
            ( Loading
            , Http.get
                { url = "/api"
                , expect = Http.expectJson GotQuestion decoder
                }
            )

        GotQuestion result ->
            case result of
                Ok question ->
                    ( Success question, Cmd.none )

                Err _ ->
                    ( Failed, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        Success question ->
            div []
                [ viewButton
                , viewQuestion question
                ]

        _ ->
            viewButton


viewQuestion : Question -> Html Msg
viewQuestion (Question str) =
    div [] [ text str ]


viewButton : Html Msg
viewButton =
    div
        [ class "bg-blue-200"
        , class "rounded"
        , class "p-2"
        , onClick Clicked
        ]
        [ text "Hello, Elm!"
        ]
