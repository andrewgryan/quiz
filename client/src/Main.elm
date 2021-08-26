port module Main exposing (main)

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



-- PORTS


port recv : (Json.Encode.Value -> msg) -> Sub msg



-- MODEL


type alias Model =
    { answers : List Answer
    , question : Remote Question
    , player : Player
    , error : Bool
    }


type Player
    = Playing
    | Answered
      -- TODO support response count
    | ViewTally Tally


type Remote a
    = NotStarted
    | Loading
    | Success a
    | Failed


init : () -> ( Model, Cmd Msg )
init _ =
    let
        model =
            { player = Playing
            , answers = []
            , question = NotStarted
            , error = False
            }
    in
    ( model, Cmd.none )


type Question
    = Question String (List Answer)


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


decoderAnswers : Decoder (List Answer)
decoderAnswers =
    field "answers" (Json.Decode.list decoderAnswer)


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
    | Recv Json.Encode.Value


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Clicked ->
            ( { model | question = Loading }
            , Http.get
                { url = "/api"
                , expect = Http.expectJson GotQuestion decoder
                }
            )

        GotQuestion result ->
            case result of
                Ok question ->
                    ( { model | question = Success question }, Cmd.none )

                Err _ ->
                    ( { model | question = Failed }, Cmd.none )

        GotAnswer answer ->
            ( { model | player = Answered }
            , Http.post
                { url = "/answer"
                , body = Http.jsonBody (encode answer)
                , expect = Http.expectJson GotTally decoderTally
                }
            )

        GotTally result ->
            case result of
                Ok tally ->
                    ( { model | player = ViewTally tally }, Cmd.none )

                Err _ ->
                    -- TODO handle error decoding response
                    ( model, Cmd.none )

        Recv value ->
            case Json.Decode.decodeValue decoderAnswers value of
                Ok answers ->
                    ( { model | answers = answers }, Cmd.none )

                Err _ ->
                    -- TODO handle error
                    ( { model | error = True }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    recv Recv



-- VIEW


view : Model -> Html Msg
view model =
    case model.player of
        Playing ->
            case model.question of
                Success question ->
                    viewQuestion question
                        |> viewPage

                _ ->
                    viewButton
                        |> viewPage

        ViewTally _ ->
            case model.question of
                Success question ->
                    let
                        s =
                            summary question model.answers
                    in
                    viewSummary s
                        |> viewPage

                _ ->
                    viewButton
                        |> viewPage

        Answered ->
            div [] [ text "TO DO" ]


viewError : Bool -> Html Msg
viewError flag =
    if flag then
        div [] [ text "ERROR" ]

    else
        text ""


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


type Counted a
    = Counted Int a


type Summary
    = Summary String (List (Counted Answer))


viewSummary : Summary -> Html Msg
viewSummary (Summary statement countedAnswers) =
    div []
        [ div [] [ text statement ]
        , div [] (List.map viewCounted countedAnswers)
        ]


viewCounted : Counted Answer -> Html Msg
viewCounted (Counted n answer) =
    div []
        [ div [] [ text (String.fromInt n) ]
        , viewAnswer answer
        ]


summary : Question -> List Answer -> Summary
summary question responses =
    let
        toFreq =
            \a -> Counted (frequency responses a) a
    in
    case question of
        Question statement answers ->
            Summary statement (List.map toFreq answers)


frequency : List Answer -> Answer -> Int
frequency answers answer =
    List.filter (\a -> a == answer) answers
        |> List.length


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
            Dict.insert key 1 records

        Just count ->
            Dict.insert key (count + 1) records
