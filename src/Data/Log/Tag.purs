module Data.Log.Tag
  ( TagSet
  , Tag(..)
  , tag
  , intTag
  , numberTag
  , booleanTag
  , jsDateTag
  , tagSetTag
  , fromArray
  , module Data.Map
  ) where

import Prelude

import Data.JSDate (JSDate)
import Data.Map (Map, singleton, unions, empty)

data Tag
  = StringTag String
  | NumberTag Number
  | IntTag Int
  | BooleanTag Boolean
  | JSDateTag JSDate
  | TagSetTag TagSet

type TagSet = Map String Tag

mkTagType :: forall m. (m -> Tag) -> String -> m -> TagSet
mkTagType tagger name = tagger >>> singleton name

tag :: String -> String -> TagSet
tag = mkTagType StringTag

intTag :: String -> Int -> TagSet
intTag = mkTagType IntTag

numberTag :: String -> Number -> TagSet
numberTag = mkTagType NumberTag

booleanTag :: String -> Boolean -> TagSet
booleanTag = mkTagType BooleanTag

jsDateTag :: String -> JSDate -> TagSet
jsDateTag = mkTagType JSDateTag

tagSetTag :: String -> TagSet -> TagSet
tagSetTag = mkTagType TagSetTag

fromArray :: Array TagSet -> TagSet
fromArray = unions
