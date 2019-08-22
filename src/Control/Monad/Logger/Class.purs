module Control.Monad.Logger.Class
  ( class MonadLogger
  , log
  , trace
  , debug
  , info
  , warn
  , error
  ) where

import Prelude

import Data.JSDate (now)
import Data.Log.Level (LogLevel(Trace, Debug, Info, Warn, Error))
import Data.Log.Message (Message)
import Data.Log.Tag (TagSet, empty)
import Effect.Class (class MonadEffect, liftEffect)

class MonadEffect m <= MonadLogger m where
  log :: Message -> m Unit

log' :: forall m. MonadLogger m => LogLevel -> TagSet -> String -> m Unit
log' level tags message =
  liftEffect now >>= log <<< { level, message, tags, timestamp: _ }

trace :: forall m. MonadLogger m => TagSet -> String -> m Unit
trace = log' Trace

trace' :: forall m. MonadLogger m => String -> m Unit
trace' = trace empty

debug :: forall m. MonadLogger m => TagSet -> String -> m Unit
debug = log' Debug

debug' :: forall m. MonadLogger m => String -> m Unit
debug' = debug empty

info :: forall m. MonadLogger m => TagSet -> String -> m Unit
info = log' Info

info' :: forall m. MonadLogger m => String -> m Unit
info' = info empty

warn :: forall m. MonadLogger m => TagSet -> String -> m Unit
warn = log' Warn

warn' :: forall m. MonadLogger m => String -> m Unit
warn' = warn empty

error :: forall m. MonadLogger m => TagSet -> String -> m Unit
error = log' Error

error' :: forall m. MonadLogger m => String -> m Unit
error' = error empty
