module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, field, list, map, oneOf, string)



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
    = Question String (List Answer)


type Answer
    = Right String
    | Wrong String


decoder : Decoder Question
decoder =
    Json.Decode.map2 Question
        (field "statement" string)
        (field "answers" (Json.Decode.list decoderAnswer))


decoderAnswer : Decoder Answer
decoderAnswer =
    oneOf
        [ Json.Decode.map Wrong (field "Wrong" string)
        , Json.Decode.map Right (field "Right" string)
        ]



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
            viewQuestion question
                |> viewPage

        _ ->
            viewButton
                |> viewPage


viewPage : Html Msg -> Html Msg
viewPage content =
    div
        [ class "bg-gray-200"
        , class "h-screen"
        , class "flex"
        , class "flex-col"
        , class "justify-center"
        , class "items-center"
        ]
        [ content
        ]


viewQuestion : Question -> Html Msg
viewQuestion (Question statement answers) =
    div []
        [ div [] [ text statement ]
        , div [] (List.map viewAnswer answers)
        ]


viewAnswer : Answer -> Html Msg
viewAnswer answer =
    case answer of
        Right str ->
            div [] [ text str ]

        Wrong str ->
            div [] [ text str ]


viewButton : Html Msg
viewButton =
    div
        [ class "bg-green-500"
        , class "text-white"
        , class "uppercase"
        , class "cursor-pointer"
        , class "p-4"
        , class "m-4"
        , onClick Clicked
        ]
        [ text "Get question"
        ]
