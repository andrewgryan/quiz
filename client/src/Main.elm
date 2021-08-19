module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http



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
    | Success String
    | Failed


init : () -> ( Model, Cmd Msg )
init _ =
    ( NotStarted, Cmd.none )



-- UPDATE


type Msg
    = Clicked
    | GotText (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Clicked ->
            ( Loading
            , Http.get
                { url = "/api"
                , expect = Http.expectString GotText
                }
            )

        GotText result ->
            case result of
                Ok text ->
                    ( Success text, Cmd.none )

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
        Success str ->
            div []
                [ viewButton
                , div [] [ text str ]
                ]

        _ ->
            viewButton


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
