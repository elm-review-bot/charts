module Chart exposing
    ( chart, Element, scatter, linear, monotone, Metric, bars, histogram
    , Bounds, fromData, startMin, startMax, endMin, endMax, startPad, endPad, zero, middle
    , xAxis, yAxis, xTicks, yTicks, xLabels, yLabels, grid
    , ints, times, format, ticks, amount
    , Event, event, getNearest, getNearestX, getWithin, getWithinX, tooltip, formatTimestamp
    , svgAt, htmlAt, svg, html, none
    , width, height, marginTop, marginBottom, marginLeft, marginRight, responsive, id
    , range, domain, topped, paddingX, paddingY, events, htmlAttrs, binWidth
    , start, end, pinned, color, rounded, roundBottom, margin, spacing
    , dot, dotted, area, noArrow, label, filterX, filterY, only, attrs
    , blue, orange, pink, green, red
    )


{-| Make a chart! Documentation is still unfinished!

# Elements
@docs chart, Element, scatter, linear, monotone, Metric, bars, histogram

## Work with bounds
@docs Bounds, fromData, startMin, startMax, endMin, endMax, startPad, endPad, zero, middle

# Axis
@docs xAxis, yAxis, xTicks, yTicks, xLabels, yLabels, grid
@docs amount, ints, times, ticks, format, noArrow, start, end, pinned, only, filterX, filterY

# Events
@docs Event, event, getNearest, getNearestX, getWithin, getWithinX, tooltip, formatTimestamp

# Attributes
@docs width, height, marginTop, marginBottom, marginLeft, marginRight, paddingX, paddingY
@docs responsive, id, range, domain, events, htmlAttrs, binWidth
@docs color, rounded, roundBottom, margin, dot, dotted, area, attrs

# Interop
@docs svgAt, htmlAt, svg, html, none

# Colors
@docs blue, orange, pink, green, red

-}


import Svg.Chart as C
import Svg.Coordinates as C
import Svg as S
import Svg.Attributes as SA
import Svg.Events as SE
import Html as H
import Html.Attributes as HA
import Intervals as I
import DateFormat as F
import Time
import Dict exposing (Dict)


-- ATTRS


{-| -}
type alias Attribute c =
  c -> c


{-| -}
width : Float -> Attribute { a | width : Float }
width value config =
  { config | width = value }


{-| -}
height : Float -> Attribute { a | height : Float }
height value config =
  { config | height = value }


{-| -}
marginTop : Float -> Attribute { a | marginTop : Float }
marginTop value config =
  { config | marginTop = value }


{-| -}
marginBottom : Float -> Attribute { a | marginBottom : Float }
marginBottom value config =
  { config | marginBottom = value }


{-| -}
marginLeft : Float -> Attribute { a | marginLeft : Float }
marginLeft value config =
  { config | marginLeft = value }


{-| -}
marginRight : Float -> Attribute { a | marginRight : Float }
marginRight value config =
  { config | marginRight = value }


{-| -}
responsive : Attribute { a | responsive : Bool }
responsive config =
  { config | responsive = True }


{-| -}
id : String -> Attribute { a | id : String }
id value config =
  { config | id = value }


{-| -}
range : Bounds -> Attribute { a | range : Bounds }
range value config =
  { config | range = value }


{-| -}
domain : Bounds -> Attribute { a | domain : Bounds }
domain value config =
  { config | domain = value }


{-| -}
paddingX : Float -> Float -> Attribute { a | paddingX : Bounds }
paddingX a b config =
  { config | paddingX = Bounds a b }


{-| -}
paddingY : Float -> Float -> Attribute { a | paddingY : Bounds }
paddingY a b config =
  { config | paddingY = Bounds a b }


{-| -}
events : List (Event msg) -> Attribute { a | events : List (Event msg) }
events value config =
  { config | events = value }


{-| -}
attrs : List (S.Attribute msg) -> Attribute { a | attrs : List (S.Attribute msg) }
attrs value config =
  { config | attrs = value }


{-| -}
htmlAttrs : List (H.Attribute msg) -> Attribute { a | htmlAttrs : List (H.Attribute msg) }
htmlAttrs value config =
  { config | htmlAttrs = value }


{-| -}
start : (Bounds -> Float) -> Attribute { a | start : Bounds -> Float }
start value config =
  { config | start = value }


{-| -}
end : (Bounds -> Float) -> Attribute { a | end : Bounds -> Float }
end value config =
  { config | end = value }


{-| -}
pinned : (Bounds -> Float) -> Attribute { a | pinned : Bounds -> Float }
pinned value config =
  { config | pinned = value }


{-| -}
color : String -> Attribute { a | color : String }
color value config =
  { config | color = value }


{-| -}
rounded : Float -> Attribute { a | rounded : Float }
rounded value config =
  { config | rounded = value }


{-| -}
roundBottom : Attribute { a | roundBottom : Bool }
roundBottom config =
  { config | roundBottom = True }


{-| -}
margin : Float -> Attribute { a | margin : Float }
margin value config =
  { config | margin = value }


{-| -}
spacing : Float -> Attribute { a | spacing : Float }
spacing value config =
  { config | spacing = value }


{-| -}
dot : (data -> C.Dot msg) -> Attribute { a | dot : Tracked (data -> C.Dot msg) }
dot value config =
  { config | dot = Changed value }


{-| -}
dotted : Attribute { a | dotted : Bool }
dotted config =
  { config | dotted = True }


{-| -}
area : String -> Attribute { a | area : Maybe String }
area value config =
  { config | area = Just value }


{-| -}
noArrow : Attribute { a | arrow : Bool }
noArrow config =
  { config | arrow = False }


{-| -}
filterX : (Bounds -> List Float) -> Attribute { a | filterX : Bounds -> List Float }
filterX value config =
  { config | filterX = value }


{-| -}
filterY : (Bounds -> List Float) -> Attribute { a | filterY : Bounds -> List Float }
filterY value config =
  { config | filterY = value }


{-| -}
only : (b -> Bool) -> Attribute { a | only : b -> Bool }
only value config =
  { config | only = value }


{-| -}
times : Time.Zone -> Attribute { a | produce : Tracked (Int -> Bounds -> List I.Time), value : I.Time -> Float, format : I.Time -> String }
times zone config =
  { config | produce = Changed <| I.times zone, value = .timestamp >> Time.posixToMillis >> toFloat, format = formatTime zone }


{-| -}
ints : Attribute { a | produce : Tracked (Int -> Bounds -> List Int), value : Int -> Float, format : Int -> String }
ints config =
  { config | produce = Changed <| \i -> I.ints (I.around i), value = toFloat, format = String.fromInt }


{-| -}
ticks : (Int -> Bounds -> List tick) -> (tick -> Float) -> (tick -> String) -> Attribute { a | produce : Tracked (Int -> Bounds -> List tick), value : tick -> Float, format : tick -> String }
ticks produce value format_ config =
  { config | produce = Changed produce, value = value, format = format_ }


{-| -}
format : (tick -> String) -> Attribute { a | format : tick -> String }
format value config =
  { config | format = value }


{-| -}
amount : Int -> Attribute { a | amount : Int }
amount value config =
  { config | amount = value }


{-| -}
topped : Int -> Attribute { a | topped : Maybe Int }
topped value config =
  { config | topped = Just value }


{-| -}
label : (data -> String) -> Attribute { a | label : Maybe (data -> String) }
label value config =
  { config | label = Just value }


{-| -}
binWidth : (data -> Float) -> Attribute { a | binWidth : Maybe (data -> Float) }
binWidth value config =
  { config | binWidth = Just value }



-- ELEMENTS


{-| -}
type alias Container msg =
    { width : Float
    , height : Float
    , marginTop : Float
    , marginBottom : Float
    , marginLeft : Float
    , marginRight : Float
    , responsive : Bool
    , id : String
    , range : Bounds
    , domain : Bounds
    , events : List (Event msg)
    , htmlAttrs : List (H.Attribute msg)
    , paddingX : Bounds
    , paddingY : Bounds
    , topped : Maybe Int
    , attrs : List (S.Attribute msg)
    }


{-| -}
chart : List (Container msg -> Container msg) -> List (Element msg) -> H.Html msg
chart edits elements =
  let config =
        applyAttrs edits
          { width = 500
          , height = 200
          , marginTop = 5
          , marginBottom = 30
          , marginLeft = 30
          , marginRight = 5
          , paddingX = { min = 0, max = 10 }
          , paddingY = { min = 0, max = 10 }
          , responsive = True
          , id = "you-should-really-set-the-id-of-your-chart"
          , range = { min = 1, max = 100 }
          , domain = { min = 1, max = 100 }
          , topped = Nothing
          , events = []
          , attrs = []
          , htmlAttrs = []
          }

      scalePadX =
        C.scaleCartesian
          { marginLower = config.marginLeft
          , marginUpper = config.marginRight
          , length = max 1 (config.width - config.paddingX.min - config.paddingX.max)
          , data = config.range
          , min = config.range.min
          , max = config.range.max
          }

      toppedDomain =
        case config.topped of
          Just num ->
            let domain_ = config.domain
                fs = I.floats (I.around num) config.domain
                interval =
                  case fs of
                    first :: second :: _ -> second - first
                    _ -> 0
            in
            { domain_ | max = domain_.max + interval }

          Nothing ->
            config.domain

      scalePadY =
        C.scaleCartesian
          { marginUpper = config.marginTop
            , marginLower = config.marginBottom
            , length = max 1 (config.height - config.paddingY.min - config.paddingY.max)
            , data = toppedDomain
            , min = toppedDomain.min
            , max = toppedDomain.max
            }

      plane = -- TODO use config / system directly instead
        { x =
            { marginLower = config.marginLeft
            , marginUpper = config.marginRight
            , length = config.width
            , data = config.range
            , min = config.range.min - scalePadX config.paddingX.min
            , max = config.range.max + scalePadX config.paddingX.max
            }
        , y =
            { marginUpper = config.marginTop
            , marginLower = config.marginBottom
            , length = config.height
            , data = toppedDomain
            , min = toppedDomain.min - scalePadY config.paddingY.min
            , max = toppedDomain.max + scalePadY config.paddingY.max
            }
        }

      ( _, allTicks, ( htmlElsBefore, svgEls, htmlElsAfter ) ) =
        List.foldl buildElement ( True, { x = [], y = [] }, ([], [], []) ) elements

      buildElement el ( isBeforeChart, tickAcc, ( htmlB, svgE, htmlA ) ) =
        case el of
          GridElement gConfig ->
            ( False, tickAcc, ( htmlB, svgE ++ [ viewGrid gConfig plane ], htmlA ) )

          SvgElement tickFunc func ->
            ( False, tickFunc plane tickAcc, ( htmlB, svgE ++ [ \_ -> func config.id plane ], htmlA ) )

          HtmlElement func ->
            ( isBeforeChart
            , tickAcc
            , if isBeforeChart
              then ( htmlB ++ [ func plane ], svgE, htmlA )
              else ( htmlB, svgE, htmlA ++ [ func plane ] )
            )

      svgContainer els =
        S.svg (sizingAttrs ++ List.map toEvent config.events ++ config.attrs) <|
          C.frame config.id plane :: els ++ [ C.eventCatcher plane [] ]

      sizingAttrs =
        if config.responsive
        then [ C.responsive plane ]
        else C.static plane

      toEvent e =
        SE.on e.name (C.decodePoint plane e.msg)
  in
  C.container plane config.htmlAttrs <|
    htmlElsBefore ++ [ svgContainer (List.map (\e -> e allTicks) svgEls) ] ++ htmlElsAfter



-- BOUNDS


{-| -}
type alias Bounds =
    { min : Float, max : Float }


{-| -}
fromData : List (data -> Float) -> List data -> Bounds
fromData values data =
  { min = C.minimum values data
  , max = C.maximum values data
  }


{-| -}
startMin : Float -> Bounds -> Bounds
startMin value bounds =
  { bounds | min = min value bounds.min }


{-| -}
startMax : Float -> Bounds -> Bounds
startMax value bounds =
  { bounds | min = max value bounds.min }


{-| -}
endMin : Float -> Bounds -> Bounds
endMin value bounds =
  { bounds | max = max value bounds.max }


{-| -}
endMax : Float -> Bounds -> Bounds
endMax value bounds =
  { bounds | max = min value bounds.max }


{-| -}
endPad : Float -> Bounds -> Bounds
endPad value bounds =
  { bounds | max = bounds.max + value }


{-| -}
startPad : Float -> Bounds -> Bounds
startPad value bounds =
  { bounds | min = bounds.min - value }


{-| -}
zero : Bounds -> Float
zero bounds =
  clamp bounds.min bounds.max 0


{-| -}
middle : Bounds -> Float
middle bounds =
    bounds.min + (bounds.max - bounds.min) / 2




-- EVENTS


{-| -}
type alias Event msg =
  { name : String
  , msg : C.Plane -> C.Point -> msg
  }


{-| -}
event : String -> (C.Plane -> C.Point -> msg) -> Event msg
event =
  Event


{-| -}
getNearest : (Maybe data -> msg) -> (data -> Float) -> List (data -> Float) -> List data -> C.Plane -> C.Point -> msg
getNearest toMsg toX toYs data plane point =
  let points = toDataPoints toX toYs data in
  toMsg (C.getNearest points plane point)


{-| -}
getWithin : (Maybe data -> msg) -> Float -> (data -> Float) -> List (data -> Float) -> List data -> C.Plane -> C.Point -> msg
getWithin toMsg radius toX toYs data plane point =
  let points = toDataPoints toX toYs data in
  toMsg (C.getWithin radius points plane point)


{-| -}
getNearestX : (List data -> msg) -> (data -> Float) -> List (data -> Float) -> List data -> C.Plane -> C.Point -> msg
getNearestX toMsg toX toYs data plane point =
  let points = toDataPoints toX toYs data in
  toMsg (C.getNearestX points plane point)


{-| -}
getWithinX : (List data -> msg) -> Float -> (data -> Float) -> List (data -> Float) -> List data -> C.Plane -> C.Point -> msg
getWithinX toMsg radius toX toYs data plane point =
  let points = toDataPoints toX toYs data in
  toMsg (C.getWithinX radius points plane point)


{-| -}
tooltip : (Bounds -> Float) -> (Bounds -> Float) -> List (H.Attribute msg) -> List (H.Html msg) -> Element msg
tooltip toX toY att content =
  html <| \p -> C.tooltip p (toX <| toBounds .x p) (toY <| toBounds .y p) att content



-- ELEMENTS


{-| -}
type Element msg
    = GridElement (Grid msg)
    | SvgElement (C.Plane -> AllTicks -> AllTicks) (String -> C.Plane -> S.Svg msg)
    | HtmlElement (C.Plane -> H.Html msg)


type alias AllTicks =
  { x : List Float
  , y : List Float
  }



-- AXIS


{-| -}
type alias Axis msg =
    { start : Bounds -> Float
    , end : Bounds -> Float
    , pinned : Bounds -> Float
    , arrow : Bool
    , color : String -- TODO use Color
    , attrs : List (S.Attribute msg)
    }


{-| -}
xAxis : List (Axis msg -> Axis msg) -> Element msg
xAxis edits =
  let config =
        applyAttrs edits
          { start = .min
          , end = .max
          , pinned = zero
          , color = "rgb(210, 210, 210)"
          , arrow = True
          , attrs = []
          }
  in
  SvgElement (always identity) <| \_ p ->
    S.g [ SA.class "elm-charts__x-axis" ]
      [ C.horizontal p ([ SA.stroke config.color ] ++ config.attrs) (config.pinned <| toBounds .y p) (config.start <| toBounds .x p) (config.end <| toBounds .x p)
      , if config.arrow then
          C.xArrow p config.color (config.end <| toBounds .x p) (config.pinned <| toBounds .y p) 0 0
        else
          S.text ""
      ]


{-| -}
yAxis : List (Axis msg -> Axis msg) -> Element msg
yAxis edits =
  let config =
        applyAttrs edits
          { start = .min
          , end = .max
          , pinned = zero
          , color = "rgb(210, 210, 210)"
          , arrow = True
          , attrs = []
          }
  in
  SvgElement (always identity) <| \_ p ->
    S.g [ SA.class "elm-charts__y-axis" ]
      [ C.vertical p ([ SA.stroke config.color ] ++ config.attrs) (config.pinned <| toBounds .x p) (config.start <| toBounds .y p) (config.end <| toBounds .y p)
      , if config.arrow then
          C.yArrow p config.color (config.pinned <| toBounds .x p) (config.end <| toBounds .y p) 0 0
        else
          S.text ""
      ]


type alias Tick tick msg =
    { color : String -- TODO use Color -- TODO allow custom color by tick value
    , height : Float
    , width : Float
    , pinned : Bounds -> Float
    , start : Bounds -> Float
    , end : Bounds -> Float
    , only : Float -> Bool
    , attrs : List (S.Attribute msg)
    , amount : Int
    , produce : Tracked (Int -> Bounds -> List tick)
    , value : tick -> Float
    , format : tick -> String
    }


{-| -}
xTicks : List (Tick tick msg -> Tick tick msg) -> Element msg
xTicks edits =
  let config =
        applyAttrs edits
          { color = "rgb(210, 210, 210)"
          , start = .min
          , end = .max
          , pinned = .min
          , amount = 5
          , only = \_ -> True
          , produce = Unchanged (\_ _ -> [])
          , value = \_ -> 0
          , format = \_ -> ""
          , height = 5
          , width = 1
          , attrs = []
          }

      xBounds p =
        let b = toBounds .x p in
        { min = config.start b
        , max = config.end b
        }

      allTicks p =
        List.filter config.only <|
          case config.produce of
            Changed produce -> List.map config.value (produce config.amount <| xBounds p)
            Unchanged v -> I.floats (I.around config.amount) <| xBounds p

      allTickNums p ts =
        { ts | x = ts.x ++ allTicks p }

      tickAttrs =
        [ SA.stroke config.color
        , SA.strokeWidth (String.fromFloat config.width)
        ] ++ config.attrs
  in
  SvgElement allTickNums <| \_ p ->
    C.xTicks p (round config.height) tickAttrs (config.pinned <| toBounds .y p) (allTicks p)


{-| -}
yTicks : List (Tick tick msg -> Tick tick msg) -> Element msg
yTicks edits =
  let config =
        applyAttrs edits
          { color = "rgb(210, 210, 210)"
          , start = .min
          , end = .max
          , pinned = .min
          , only = \_ -> True
          , amount = 5
          , produce = Unchanged (\_ _ -> [])
          , value = \_ -> 0
          , format = \_ -> ""
          , height = 5
          , width = 1
          , attrs = []
          --, offset = 0
          }

      yBounds p =
        let b = toBounds .y p in
        { min = config.start b
        , max = config.end b
        }

      allTicks p =
        List.filter config.only <|
          case config.produce of
            Changed produce -> List.map config.value (produce config.amount <| yBounds p)
            Unchanged v -> (I.floats (I.around config.amount) <| yBounds p)

      allTickNums p ts =
        { ts | y = ts.y ++ allTicks p }

      tickAttrs =
        [ SA.stroke config.color
        , SA.strokeWidth (String.fromFloat config.width)
        ] ++ config.attrs
  in
  SvgElement allTickNums <| \_ p ->
    C.yTicks p (round config.height) tickAttrs (config.pinned <| toBounds .x p) (allTicks p)


type alias Label tick msg =
    { color : String -- TODO use Color
    , pinned : Bounds -> Float
    , attrs : List (S.Attribute msg)
    , start : Bounds -> Float
    , end : Bounds -> Float
    , only : Float -> Bool
    , xOffset : Float
    , yOffset : Float
    , amount : Int
    , produce : Tracked (Int -> Bounds -> List tick)
    , value : tick -> Float
    , format : tick -> String
    }


{-| -}
xLabels : List (Label tick msg -> Label tick msg) -> Element msg
xLabels edits =
  let config =
        applyAttrs edits
          { color = "#808BAB"
          , start = .min
          , end = .max
          , only = \_ -> True
          , pinned = .min
          , attrs = []
          , amount = 5
          , produce = Unchanged (\_ _ -> [])
          , value = \_ -> 0
          , format = \_ -> ""
          , xOffset = 0
          , yOffset = 0
          }

      xBounds p =
        let b = toBounds .x p in
        { min = config.start b
        , max = config.end b
        }

      allTicks p =
        List.filter (config.only << .value) <|
          case config.produce of
            Changed produce -> List.map (\i -> { value = config.value i, label = config.format i }) (produce config.amount <| xBounds p)
            Unchanged v -> List.map (\i -> { value = i, label = String.fromFloat i }) (I.floats (I.around config.amount) <| xBounds p)

      allTickNums p ts =
        { ts | x = ts.x ++ List.map .value (allTicks p) }

      labelAttrs =
        [ SA.fill config.color
        , SA.transform ("translate(" ++ String.fromFloat config.xOffset ++ " " ++ String.fromFloat config.yOffset ++ ")")
        ] ++ config.attrs
  in
  SvgElement allTickNums <| \_ p ->
    C.xLabels p (C.xLabel labelAttrs .value .label) (config.pinned <| toBounds .y p) (allTicks p)


{-| -}
yLabels : List (Label tick msg -> Label tick msg) -> Element msg
yLabels edits =
  let config =
        applyAttrs edits
          { color = "#808BAB"
          , start = .min
          , end = .max
          , pinned = .min
          , only = \_ -> True
          , amount = 5 -- TODO
          , produce = Unchanged (\_ _ -> [])
          , value = \_ -> 0
          , format = \_ -> ""
          , xOffset = 0
          , yOffset = 0
          , attrs = []
          }

      yBounds p =
        let b = toBounds .y p in
        { min = config.start b
        , max = config.end b
        }

      allTicks p =
        List.filter (config.only << .value) <|
          case config.produce of
            Changed produce -> List.map (\i -> { value = config.value i, label = config.format i }) (produce config.amount <| yBounds p)
            Unchanged v -> List.map (\i -> { value = i, label = String.fromFloat i }) (I.floats (I.around config.amount) <| yBounds p)

      allTickNums p ts =
        { ts | y = ts.y ++ List.map .value (allTicks p) }

      labelAttrs =
        [ SA.fill config.color
        , SA.transform ("translate(" ++ String.fromFloat config.xOffset ++ " " ++ String.fromFloat config.yOffset ++ ")")
        ] ++ config.attrs
  in
  SvgElement allTickNums <| \_ p ->
    C.yLabels p (C.yLabel labelAttrs .value .label) (config.pinned <| toBounds .x p) (allTicks p)


type alias Grid msg =
    { color : String -- TODO use Color
    , width : Float
    , dotted : Bool
    , filterX : Bounds -> List Float
    , filterY : Bounds -> List Float
    , attrs : List (S.Attribute msg)
    }


{-| -}
grid : List (Grid msg -> Grid msg) -> Element msg
grid edits =
  let config =
        applyAttrs edits
          { color = "#EFF2FA"
          , filterX = zero >> List.singleton
          , filterY = zero >> List.singleton
          , width = 1
          , attrs = []
          , dotted = False
          }
  in
  GridElement config



-- SERIES


type alias Bars data msg =
  { rounded : Float
  , roundBottom : Bool
  , attrs : List (S.Attribute msg)
  , margin : Float
  , spacing : Float
  , label : Maybe (data -> String)
  }


{-| -}
type alias Metric data =
  { color : String
  , value : data -> Float
  }


{-| -}
bars : List (Metric data) -> List (Bars data msg -> Bars data msg) -> List data -> Element msg
bars metrics edits data =
  -- TODO spacing?
  let config =
        applyAttrs edits
          { rounded = 0
          , roundBottom = False
          , label = Nothing
          , spacing = 0
          , margin = 0.05
          , attrs = []
          }

      toLabel i d =
        case config.label of
          Just func -> func d
          Nothing -> String.fromInt i

      numOfBars =
        toFloat (List.length metrics)

      binMargin =
        config.margin * 2

      barSpacing =
        (numOfBars - 1) * config.spacing

      toBar name d metric =
        { attributes = [ SA.stroke "transparent", SA.fill metric.color, clipPath name ] ++ config.attrs
        , width = (1 - barSpacing - binMargin) / numOfBars
        , rounded = config.rounded
        , roundBottom = config.roundBottom
        , value = metric.value d
        }

      toBin name i d =
        { label = toLabel i d
        , spacing = config.spacing
        , bars = List.map (toBar name d) metrics
        }
  in
  SvgElement (always identity) <| \name p ->
    C.bars p (List.indexedMap (toBin name) data)


type alias Histogram data msg =
  { binWidth : Maybe (data -> Float)
  , rounded : Float
  , roundBottom : Bool
  , margin : Float
  , spacing : Float
  , attrs : List (S.Attribute msg)
  }


{-| -}
histogram : (data -> Float) -> (data -> String) -> List (Metric data) -> List (Histogram data msg -> Histogram data msg) -> List data -> Element msg
histogram toX toLabel metrics edits data =
  -- TODO spacing?
  let config =
        applyAttrs edits
          { binWidth = Nothing
          , rounded = 0
          , roundBottom = False
          , spacing = 0.01
          , margin = 0.05
          , attrs = []
          }

      numOfBars =
        toFloat (List.length metrics)

      barMargin =
        config.margin * 2

      barSpacing =
        (numOfBars - 1) * config.spacing

      toBinWidth p d mn =
        case config.binWidth of
          Just toWidth -> toWidth d
          Nothing ->
            case mn of
              Just n -> toX n - toX d
              Nothing -> p.x.max - toX d

      toBar name d i metric =
        { attributes = [ SA.stroke "transparent", SA.fill metric.color, clipPath name ] ++ config.attrs
        , width = (1 - barSpacing - barMargin) / numOfBars
        , rounded = config.rounded
        , roundBottom = config.roundBottom
        , value = metric.value d
        }

      toBin name p d n =
        { label = toLabel d
        , start = toX d
        , end = toX d + toBinWidth p d n
        , spacing = config.spacing
        , tickLength = 4
        , tickWidth = 1
        , bars = List.indexedMap (toBar name d) metrics
        }

      mapWithNext func acc ds =
        case ds of
          a :: b :: rs -> mapWithNext func (func a (Just b) :: acc) rs
          a :: [] -> func a Nothing :: acc
          [] -> acc
  in
  SvgElement (always identity) <| \name p ->
    C.histogram p (mapWithNext (toBin name p) [] data)



-- DOTTED SERIES


type alias Scatter data msg =
    { color : String -- TODO use Color
    , dot : Tracked (data -> C.Dot msg)
    }


{-| -}
scatter : (data -> Float) -> (data -> Float) -> List (Scatter data msg -> Scatter data msg) -> List data -> Element msg
scatter toX toY edits data =
  let config =
        applyAttrs edits
          { color = "rgb(5,142,218)" -- TODO
          , dot = Unchanged (\_ -> C.disconnected 6 1 C.cross "rgb(5,142,218)")
          }

      finalDot =
        case config.dot of -- TODO use inheritance instead?
          Unchanged _ -> \_ -> C.disconnected 6 1 C.cross config.color
          Changed d -> d
  in
  SvgElement (always identity) <| \name p ->
    S.g
      [ SA.class "elm-charts__scatter" ]
      [ C.scatter p toX toY finalDot data ]



type alias Interpolation data msg =
    { color : String -- TODO use Color
    , area : Maybe String -- TODO use Color
    , width : Float
    , dot : Tracked (data -> C.Dot msg)
    , attrs : List (S.Attribute msg)
    }


type Tracked a
  = Changed a
  | Unchanged a


{-| -}
monotone : (data -> Float) -> (data -> Float) -> List (Interpolation data msg -> Interpolation data msg) -> List data -> Element msg
monotone toX toY edits data =
  let config =
        applyAttrs edits
          { color = "rgb(5,142,218)" -- TODO
          , area = Nothing
          , width = 1
          , dot = Unchanged (\_ -> C.disconnected 6 1 C.cross "rgb(5,142,218)")
          , attrs = []
          }

      interAttrs =
        [ SA.stroke config.color
        , SA.strokeWidth (String.fromFloat config.width)
        ] ++ config.attrs

      finalDot =
        case config.dot of -- TODO use inheritance instead?
          Unchanged _ -> \_ -> C.disconnected 6 1 C.cross config.color
          Changed d -> d
  in
  SvgElement (always identity) <| \name p ->
    case config.area of
      Just fill ->
        S.g [ SA.class "elm-charts__monotone-area" ]
          [ C.monotoneArea p toX toY (interAttrs ++ [ SA.stroke "transparent", SA.fill fill, clipPath name ]) finalDot data
          , C.monotone p toX toY interAttrs finalDot data
          ]

      Nothing ->
        S.g
          [ SA.class "elm-charts__monotone" ]
          [ C.monotone p toX toY interAttrs finalDot data ]


{-| -}
linear : (data -> Float) -> (data -> Float) -> List (Interpolation data msg -> Interpolation data msg) -> List data -> Element msg
linear toX toY edits data =
  let config =
        applyAttrs edits
          { color = "rgb(5,142,218)" -- TODO
          , area = Nothing
          , width = 1
          , dot = Unchanged (\_ -> C.disconnected 6 1 C.cross "rgb(5,142,218)")
          , attrs = []
          }

      interAttrs =
        [ SA.stroke config.color
        , SA.strokeWidth (String.fromFloat config.width)
        ] ++ config.attrs

      finalDot =
        case config.dot of
          Unchanged _ -> \_ -> C.disconnected 6 1 C.cross config.color
          Changed d -> d
  in
  SvgElement (always identity) <| \name p ->
    case config.area of
      Just fill ->
        S.g [ SA.class "elm-charts__linear-area" ]
          [ C.linearArea p toX toY (interAttrs ++ [ SA.stroke "transparent", SA.fill fill, clipPath name ]) finalDot data
          , C.linear p toX toY interAttrs finalDot data
          ]

      Nothing ->
        S.g
          [ SA.class "elm-charts__linear" ]
          [ C.linear p toX toY interAttrs finalDot data ]


{-| -}
svg : (C.Plane -> S.Svg msg) -> Element msg
svg func =
  SvgElement (always identity) (always func)


{-| -}
html : (C.Plane -> H.Html msg) -> Element msg
html =
  HtmlElement


{-| -}
svgAt : (Bounds -> Float) -> (Bounds -> Float) -> Float -> Float -> List (S.Svg msg) -> Element msg
svgAt toX toY xOff yOff view =
  SvgElement (always identity) <| \_ p ->
    S.g [ C.position p (toX <| toBounds .x p) (toY <| toBounds .y p) xOff yOff ] view


{-| -}
htmlAt : (Bounds -> Float) -> (Bounds -> Float) -> Float -> Float -> List (H.Attribute msg) -> List (H.Html msg) -> Element msg
htmlAt toX toY xOff yOff att view =
  HtmlElement <| \p ->
    C.positionHtml p (toX <| toBounds .x p) (toY <| toBounds .y p) xOff yOff att view


{-| -}
none : Element msg
none =
  HtmlElement (\_ -> H.text "")



-- HELPERS


toBounds : (C.Plane -> C.Axis) -> C.Plane -> Bounds
toBounds toA plane =
  let { min, max } = toA plane
  in { min = min, max = max }


toDataBounds : (C.Plane -> C.Axis) -> C.Plane -> Bounds
toDataBounds toA plane =
  let axis = toA plane
  in axis.data


applyAttrs : List (a -> a) -> a -> a
applyAttrs funcs default =
  let apply f a = f a in
  List.foldl apply default funcs


clipPath : String -> S.Attribute msg
clipPath name =
  SA.clipPath <| "url(#" ++ name ++ ")"


{-| -}
blue : String
blue =
  "rgb(5,142,218)"


{-| -}
orange : String
orange =
  "rgb(244, 149, 69)"


{-| -}
pink : String
pink =
  "rgb(253, 121, 168)"


{-| -}
green : String
green =
  "rgb(68, 201, 72)"


{-| -}
red : String
red =
  "rgb(215, 31, 10)"


toDataPoints : (data -> Float) -> List (data -> Float) -> List data -> List (C.DataPoint data)
toDataPoints toX toYs data =
  List.concatMap (\toY -> C.toDataPoints toX toY data) toYs


viewGrid : Grid msg -> C.Plane -> AllTicks -> S.Svg msg
viewGrid config p allTicks =
  let gridAttrs =
        [ SA.stroke config.color
        , SA.strokeWidth (String.fromFloat config.width)
        ] ++ config.attrs

      notTheseX =
        config.filterX (toBounds .x p)

      notTheseY =
        config.filterY (toBounds .y p)

      toXGrid v =
        if List.member v notTheseY
        then Nothing else Just <| C.yGrid p gridAttrs v

      toYGrid v =
        if List.member v notTheseX
        then Nothing else Just <| C.xGrid p gridAttrs v

      toDot x y =
        if List.member x notTheseX || List.member y notTheseY
        then Nothing
        else Just <| C.full config.width C.circle config.color p x y
  in
  S.g [ SA.class "elm-charts__grid" ] <|
    if config.dotted then
      List.concatMap (\x -> List.filterMap (toDot x) allTicks.y) allTicks.x
    else
      [ S.g [ SA.class "elm-charts__x-grid" ] (List.filterMap toXGrid allTicks.x)
      , S.g [ SA.class "elm-charts__y-grid" ] (List.filterMap toYGrid allTicks.y)
      ]



-- FORMATTING


{-| -}
formatTimestamp : Time.Zone -> Float -> String
formatTimestamp zone ts =
  formatFullTime zone (Time.millisToPosix (round ts))


formatTime : Time.Zone -> I.Time -> String
formatTime zone time =
    case Maybe.withDefault time.unit time.change of
        I.Millisecond ->
            formatClock zone time.timestamp

        I.Second ->
            formatClock zone time.timestamp

        I.Minute ->
            formatClock zone time.timestamp

        I.Hour ->
            formatClock zone time.timestamp

        I.Day ->
            if time.multiple == 7
            then formatWeekday zone time.timestamp
            else formatDate zone time.timestamp

        I.Month ->
            formatMonth zone time.timestamp

        I.Year ->
            formatYear zone time.timestamp


formatFullTime : Time.Zone -> Time.Posix -> String
formatFullTime =
    F.format
        [ F.monthNumber
        , F.text "/"
        , F.dayOfMonthNumber
        , F.text "/"
        , F.yearNumberLastTwo
        , F.text " "
        , F.hourMilitaryFixed
        , F.text ":"
        , F.minuteFixed
        ]


formatFullDate : Time.Zone -> Time.Posix -> String
formatFullDate =
    F.format
        [ F.monthNumber
        , F.text "/"
        , F.dayOfMonthNumber
        , F.text "/"
        , F.yearNumberLastTwo
        ]


formatDate : Time.Zone -> Time.Posix -> String
formatDate =
    F.format
        [ F.monthNumber
        , F.text "/"
        , F.dayOfMonthNumber
        ]


formatClock : Time.Zone -> Time.Posix -> String
formatClock =
    F.format
        [ F.hourMilitaryFixed
        , F.text ":"
        , F.minuteFixed
        ]


formatMonth : Time.Zone -> Time.Posix -> String
formatMonth =
    F.format
        [ F.monthNameAbbreviated
        ]


formatYear : Time.Zone -> Time.Posix -> String
formatYear =
    F.format
        [ F.yearNumber
        ]


formatWeekday : Time.Zone -> Time.Posix -> String
formatWeekday =
    F.format
        [ F.dayOfWeekNameFull ]
