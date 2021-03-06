module Ascii exposing (..)

import Array exposing (..)
import Browser
import Browser.Dom exposing (..)
import Browser.Events
import Bytes exposing (Bytes)
import Color exposing (..)
import File exposing (File)
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Image exposing (..)
import Image.Color
import Json.Decode as Decode
import Task



------ CONSTANTS ------


header : List String
header =
    [ " ▄▄·        ▐ ▄  ▌ ▐·▄▄▄ .▄▄▄  ▄▄▄▄▄    ▪  • ▌ ▄ ·.  ▄▄▄·  ▄▄ • ▄▄▄ .    ▄▄▄▄▄           ▄▄▄· .▄▄ ·  ▄▄· ▪  ▪  "
    , "▐█ ▌▪▪     •█▌▐█▪█·█▌▀▄.▀·▀▄ █·•██      ██ ·██ ▐███▪▐█ ▀█ ▐█ ▀ ▪▀▄.▀·    •██  ▪         ▐█ ▀█ ▐█ ▀. ▐█ ▌▪██ ██ "
    , "██ ▄▄ ▄█▀▄ ▐█▐▐▌▐█▐█•▐▀▀▪▄▐▀▀▄  ▐█.▪    ▐█·▐█ ▌▐▌▐█·▄█▀▀█ ▄█ ▀█▄▐▀▀▪▄     ▐█.▪ ▄█▀▄     ▄█▀▀█ ▄▀▀▀█▄██ ▄▄▐█·▐█·"
    , "▐███▌▐█▌.▐▌██▐█▌ ███ ▐█▄▄▌▐█•█▌ ▐█▌·    ▐█▌██ ██▌▐█▌▐█ ▪▐▌▐█▄▪▐█▐█▄▄▌     ▐█▌·▐█▌.▐▌    ▐█ ▪▐▌▐█▄▪▐█▐███▌▐█▌▐█▌"
    , "·▀▀▀  ▀█▄▀▪▀▀ █▪. ▀   ▀▀▀ .▀  ▀ ▀▀▀     ▀▀▀▀▀  █▪▀▀▀ ▀  ▀ ·▀▀▀▀  ▀▀▀      ▀▀▀  ▀█▄▀▪     ▀  ▀  ▀▀▀▀ ·▀▀▀ ▀▀▀▀▀▀"
    ]



-- blocks : Array Char
-- blocks =
--     Array.fromList [ '░', '▒', '▓', '█' ]
-- ascii1 : Array Char
-- ascii1 =
--     Array.fromList
--         (String.toList
--             ".'`,^:\";~-_+<>i!lI?/\\|()1{}[]rcvunxzjftLCJUYXZO0Qoahkbdpqwm*WMB8&%$#@"
--         )
-- ascii2 : Array Char
-- ascii2 =
--     Array.fromList
--         (List.reverse
--             (String.toList
--                 "$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\\|()1{}[]?-_+~<>i!lI;:,\"^`'."
--             )
--         )
-- ascii3 : Array Char
-- ascii3 =
--     Array.fromList
--         (String.toList
--             ".:-=+*#%@"
--         )


blocks : Array Char
blocks =
    Array.fromList [ '█', '▓', '▒', '░' ]



-- ascii1 : Array Char
-- ascii1 =
--     Array.fromList
--         (List.reverse
--             (String.toList
--                 ".'`,^:\";~-_+<>i!lI?/\\|()1{}[]rcvunxzjftLCJUYXZO0Qoahkbdpqwm*WMB8&%$#@"
--             )
--         )
-- ascii2 : Array Char
-- ascii2 =
--     Array.fromList
--         (String.toList
--             "$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\\|()1{}[]?-_+~<>i!lI;:,\"^`'."
--         )
-- ascii3 : Array Char
-- ascii3 =
--     Array.fromList
--         (List.reverse
--             (String.toList
--                 ".:-=+*#%@"
--             )
--         )
------ MAIN ------


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



------ MODEL ------


type alias Model =
    { file : List File -- list or singular?
    , fileBytes : List Bytes
    , convertedASCII : List String -- List String?
    }


type alias Flags =
    ()


init : Flags -> ( Model, Cmd Msg )
init () =
    ( { file = []
      , fileBytes = []
      , convertedASCII = []
      }
    , Cmd.none
    )



------ UPDATE ------


type Msg
    = GotFiles (List File)
    | GotBytes (List Bytes)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotFiles files ->
            ( { model | file = files }
            , Task.perform GotBytes <|
                Task.sequence <|
                    List.map File.toBytes files
            )

        GotBytes bytes ->
            let
                ascii =
                    imageToAscii (List.head bytes)
            in
            ( { model | fileBytes = bytes, convertedASCII = ascii }
            , Cmd.none
            )



------ SUBSCRIPTIONS ------


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



------ VIEW ------


view : Model -> Html Msg
view model =
    div
        [ style "display" "flex"
        , style "flex-direction" "column"
        , style "align-items" "center"
        ]
        (asciiToHtml header 10
            ++ [ input
                    [ Attr.type_ "file"
                    , Attr.multiple True
                    , on "change" (Decode.map GotFiles filesDecoder)
                    ]
                    []
               ]
            ++ asciiToHtml model.convertedASCII 2
        )



------ HELPERS ------


filesDecoder : Decode.Decoder (List File)
filesDecoder =
    Decode.at [ "target", "files" ] (Decode.list File.decoder)


imageToColors : Maybe Bytes -> List (List Color)
imageToColors file =
    -- convert image to 2d array of colors
    let
        empty =
            [ [] ]
    in
    case file of
        Nothing ->
            empty

        Just bytes ->
            let
                img =
                    Image.decode bytes
            in
            case img of
                Nothing ->
                    empty

                Just i ->
                    Image.Color.toList2d i


luminosity : Color -> Float
luminosity col =
    -- convert color to luminosity float using weighted avg formula
    -- https://en.wikipedia.org/wiki/Relative_luminance
    -- may need to transform sRGB  values to linear ones
    -- https://en.wikipedia.org/wiki/Relative_luminance
    let
        { red, green, blue } =
            Color.toRgba col
    in
    -- standardized on interval [0, 1]
    0.2126 * red + 0.7152 * green + 0.0722 * blue


colorsToLuminosity : List (List Color) -> List (List Float)
colorsToLuminosity colors =
    -- convert 2d list of colors to 2d list of luminosity floats
    -- implement scale here to fit ascii in browser window
    List.indexedMap
        (\i xs ->
            if modBy 2 (i * 5) == 0 then
                List.map luminosity xs

            else
                []
        )
        colors


asciify : Float -> Array Char -> Char
asciify lum ascii =
    -- convert luminosity float to char based on brightness
    -- display "no solution" symbol if error in conversion
    let
        ch =
            Array.get
                (Basics.round
                    (lum * Basics.toFloat (Array.length ascii - 1))
                )
                ascii
    in
    case ch of
        Nothing ->
            'ø'

        Just c ->
            c


luminosityToStrings : List (List Float) -> List String
luminosityToStrings lumins =
    -- 2d list of luminosity floats to list of strings
    List.map
        (\xs ->
            String.fromList
                (List.map (\x -> asciify x blocks) xs)
        )
        lumins


imageToAscii : Maybe Bytes -> List String
imageToAscii img =
    -- link all the necessary functions together
    luminosityToStrings
        (colorsToLuminosity
            (imageToColors img)
        )


asciiToHtml : List String -> Int -> List (Html msg)
asciiToHtml strs size =
    -- list of ascii strings to list of formatted divs
    let
        fontSize =
            String.append (String.fromInt size) "px"
    in
    List.map
        (\str ->
            div
                [ style "font-family" "monospace"
                , style "font-size" fontSize
                ]
                [ text (String.replace " " "_" str) ]
        )
        strs
