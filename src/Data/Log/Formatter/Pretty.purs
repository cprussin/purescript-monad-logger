module Data.Log.Formatter.Pretty
  ( prettyFormatter
  ) where

import Prelude

import Ansi.Codes (Color(BrightBlack, Cyan, Blue, White, Yellow, Red))
import Ansi.Output (foreground, withGraphics, bold)
import Control.Plus (empty)
import Data.Array (concat, cons, singleton)
import Data.Map (toUnfoldable, isEmpty)
import Data.Maybe (Maybe(Nothing, Just), fromMaybe)
import Data.JSDate (JSDate, toISOString)
import Data.Log.Level (LogLevel(Trace, Debug, Info, Warn, Error))
import Data.Log.Message (Message)
import Data.Log.Tag
  ( TagSet
  , Tag(StringTag, NumberTag, IntTag, BooleanTag, JSDateTag, TagSetTag)
  )
import Data.String (joinWith)
import Data.Traversable (sequence)
import Data.Tuple (Tuple(Tuple))
import Effect.Class (class MonadEffect, liftEffect)

prettyFormatter :: forall m. MonadEffect m => Message -> m String
prettyFormatter message =
  append <$> showMainLine message <*> showTags message.tags

showMainLine :: forall m. MonadEffect m => Message -> m String
showMainLine { level, timestamp, message } =
  liftEffect $ toISOString timestamp <#> \ts ->
    joinWith " "
      [ showLevel level
      , color BrightBlack ts
      , color Cyan message
      ]

showLevel :: LogLevel -> String
showLevel Trace = color Cyan "[TRACE]"
showLevel Debug = color Blue "[DEBUG]"
showLevel Info = color White "[INFO]"
showLevel Warn = color Yellow "[WARN]"
showLevel Error = color Red "[ERROR]"

showTags :: forall m. MonadEffect m => TagSet -> m String
showTags = tagLines >>> case _ of
  Nothing -> pure ""
  Just lines -> lines <#> joinWith "\n" >>> append "\n"

tagLines :: forall m. MonadEffect m => TagSet -> Maybe (m (Array String))
tagLines tags
  | isEmpty tags = empty
  | otherwise = pure $ indentEachLine <$> concat <$> lineify tags

lineify :: forall m. MonadEffect m => TagSet -> m (Array (Array String))
lineify tags = sequence $ showField <$> toUnfoldable tags

showField :: forall m. MonadEffect m => Tuple String Tag -> m (Array String)
showField (Tuple name value) = showTag value $ bold' name <> bold' ": "

showTag :: forall m. MonadEffect m => Tag -> String -> m (Array String)
showTag (StringTag value) = showBasic value
showTag (IntTag value) = showSpecial $ show value
showTag (NumberTag value) = showSpecial $ show value
showTag (BooleanTag value) = showSpecial $ show value
showTag (TagSetTag value) = showSubTags value
showTag (JSDateTag value) = showJsDate value

showSubTags :: forall m. MonadEffect m => TagSet -> String -> m (Array String)
showSubTags value label = cons label <$> fromMaybe (pure []) (tagLines value)

showJsDate :: forall m. MonadEffect m => JSDate -> String -> m (Array String)
showJsDate value label =
  liftEffect $ toISOString value >>= flip showSpecial label

showBasic :: forall m. Applicative m => String -> String -> m (Array String)
showBasic value label = pure $ singleton $ label <> value

showSpecial :: forall m. Applicative m => String -> String -> m (Array String)
showSpecial = color Yellow >>> showBasic

indentEachLine :: forall m. Functor m => m String -> m String
indentEachLine = map $ append "   "

color :: Color -> String -> String
color = foreground >>> withGraphics

bold' :: String -> String
bold' = withGraphics bold
