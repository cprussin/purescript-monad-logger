module Data.Log.Message
  ( Message
  ) where

import Data.JSDate (JSDate)
import Data.Log.Level (LogLevel)
import Data.Log.Tag (TagSet)

type Message =
  { level :: LogLevel
  , timestamp :: JSDate
  , message :: String
  , tags :: TagSet
  }
