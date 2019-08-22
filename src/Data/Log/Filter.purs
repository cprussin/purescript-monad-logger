module Data.Log.Filter
  ( minimumLevel
  , maximumLevel
  , onlyLevel
  ) where

import Prelude

import Data.Log.Level (LogLevel)
import Data.Log.Message (Message)

type LogFilter m = (Message -> m Unit) -> Message -> m Unit

filterLevel
  :: forall m
   . Applicative m
  => (LogLevel -> LogLevel -> Boolean)
  -> LogLevel
  -> LogFilter m
filterLevel op level logger message =
  if message.level `op` level
     then logger message
     else pure unit

minimumLevel :: forall m. Applicative m => LogLevel -> LogFilter m
minimumLevel = filterLevel (>=)

maximumLevel :: forall m. Applicative m => LogLevel -> LogFilter m
maximumLevel = filterLevel (<=)

onlyLevel :: forall m. Applicative m => LogLevel -> LogFilter m
onlyLevel = filterLevel (==)
