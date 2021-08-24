module Main exposing (main)

import Browser
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, dict, field, int, list, map, oneOf, string)
import Json.Encode



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
      -- TODO support response count
    | ViewTally Tally


init : () -> ( Model, Cmd Msg )
init _ =
    ( NotStarted, Cmd.none )


type Question
    = Question String (List Answer)
    | Answered


type Answer
    = Right String
    | Wrong String


type Tally
    = Tally (List Answer)


decoderTally : Decoder Tally
decoderTally =
    Json.Decode.map Tally (Json.Decode.list decoderAnswer)


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


encode : Answer -> Json.Encode.Value
encode answer =
    case answer of
        Right str ->
            Json.Encode.object
                [ ( "Right", Json.Encode.string str )
                ]

        Wrong str ->
            Json.Encode.object
                [ ( "Wrong", Json.Encode.string str )
                ]



-- UPDATE


type Msg
    = Clicked
    | GotQuestion (Result Http.Error Question)
    | GotAnswer Answer
    | GotTally (Result Http.Error Tally)


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

        GotAnswer answer ->
            ( Success Answered
            , Http.post
                { url = "/answer"
                , body = Http.jsonBody (encode answer)
                , expect = Http.expectJson GotTally decoderTally
                }
            )

        GotTally result ->
            case result of
                Ok tally ->
                    ( ViewTally tally, Cmd.none )

                Err _ ->
                    -- TODO handle error decoding response
                    ( model, Cmd.none )



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

        ViewTally tally ->
            viewTally tally
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
viewQuestion question =
    case question of
        Question statement answers ->
            div
                []
                [ div [] [ text statement ]
                , div
                    [ class "flex"
                    , class "flex-col"
                    , class "space-y-4"
                    , class "mt-4"
                    ]
                    (List.map viewAnswer answers)
                ]

        Answered ->
            div [] [ text "TO DO" ]


viewAnswer : Answer -> Html Msg
viewAnswer answer =
    let
        toMsg =
            GotAnswer answer
    in
    case answer of
        Right str ->
            div
                [ class "p-2"
                , class "bg-gray-100"
                , class "text-gray-900"
                , class "shadow-lg"
                , onClick toMsg
                ]
                [ text str ]

        Wrong str ->
            div
                [ class "p-2"
                , class "bg-gray-100"
                , class "text-gray-900"
                , class "shadow-lg"
                , onClick toMsg
                ]
                [ text str ]


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


viewTally : Tally -> Html Msg
viewTally tally =
    case tally of
        Tally answers ->
            let
                keyValues =
                    aggregate answers
                        |> Dict.toList
            in
            -- TODO aggregate responses
            div [] (List.map viewKeyValue keyValues)


viewKeyValue : ( String, Int ) -> Html Msg
viewKeyValue ( key, count ) =
    div [] [ text (key ++ ": " ++ String.fromInt count) ]


aggregate : List Answer -> Dict String Int
aggregate answers =
    answers
        |> List.map toString
        |> List.foldr countKey Dict.empty


toString : Answer -> String
toString answer =
    case answer of
        Right str ->
            str

        Wrong str ->
            str


countKey : String -> Dict String Int -> Dict String Int
countKey key records =
    case Dict.get key records of
        Nothing ->
            Dict.insert key 0 records

        Just count ->
            Dict.insert key (count + 1) records
