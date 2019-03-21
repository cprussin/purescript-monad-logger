module Data.Log.Filter
  ( minimumLevel
  , maximumLevel
  , onlyLevel
  ) where

import Prelude

import Data.Log.Level (LogLevel)
import Data.Log.Message (Message)
import Effect.Class (class MonadEffect)

type LogFilter m = (Message -> m Unit) -> Message -> m Unit

filterLevel
  :: forall m
   . MonadEffect m
  => (LogLevel -> LogLevel -> Boolean)
  -> LogLevel
  -> LogFilter m
filterLevel op level logger message =
  if message.level `op` level
     then logger message
     else pure unit

minimumLevel :: forall m. MonadEffect m => LogLevel -> LogFilter m
minimumLevel = filterLevel (>=)

maximumLevel :: forall m. MonadEffect m => LogLevel -> LogFilter m
maximumLevel = filterLevel (<=)

onlyLevel :: forall m. MonadEffect m => LogLevel -> LogFilter m
onlyLevel = filterLevel (==)
