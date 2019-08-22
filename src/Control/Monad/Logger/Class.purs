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
import Data.Log.Tag (TagSet)
import Effect.Class (class MonadEffect, liftEffect)

class Monad m <= MonadLogger m where
  log :: Message -> m Unit

log' :: forall m. MonadEffect m => MonadLogger m => LogLevel -> TagSet -> String -> m Unit
log' level tags message =
  liftEffect now >>= log <<< { level, message, tags, timestamp: _ }

trace :: forall m. MonadEffect m => MonadLogger m => TagSet -> String -> m Unit
trace = log' Trace

debug :: forall m. MonadEffect m => MonadLogger m => TagSet -> String -> m Unit
debug = log' Debug

info :: forall m. MonadEffect m => MonadLogger m => TagSet -> String -> m Unit
info = log' Info

warn :: forall m. MonadEffect m => MonadLogger m => TagSet -> String -> m Unit
warn = log' Warn

error :: forall m. MonadEffect m => MonadLogger m => TagSet -> String -> m Unit
error = log' Error
