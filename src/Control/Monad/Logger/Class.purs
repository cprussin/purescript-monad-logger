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

import Control.Monad.Cont.Trans (ContT)
import Control.Monad.Except.Trans (ExceptT)
import Control.Monad.List.Trans (ListT)
import Control.Monad.Maybe.Trans (MaybeT)
import Control.Monad.RWS.Trans (RWST)
import Control.Monad.Reader.Trans (ReaderT)
import Control.Monad.State.Trans (StateT)
import Control.Monad.Trans.Class (lift)
import Control.Monad.Writer.Trans (WriterT)
import Data.JSDate (now)
import Data.Log.Level (LogLevel(Trace, Debug, Info, Warn, Error))
import Data.Log.Message (Message)
import Data.Log.Tag (TagSet, empty)
import Effect.Class (class MonadEffect, liftEffect)

class MonadEffect m <= MonadLogger m where
  log :: Message -> m Unit

instance monadLoggerContT :: MonadLogger m => MonadLogger (ContT a m) where
  log = lift <<< log

instance monadLoggerExceptT :: MonadLogger m => MonadLogger (ExceptT a m) where
  log = lift <<< log

instance monadLoggerListT :: MonadLogger m => MonadLogger (ListT m) where
  log = lift <<< log

instance monadLoggerMaybeT :: MonadLogger m => MonadLogger (MaybeT m) where
  log = lift <<< log

instance monadLoggerRWST :: (Monoid w, MonadLogger m) => MonadLogger (RWST r w s m) where
  log = lift <<< log

instance monadLoggerReaderT :: MonadLogger m => MonadLogger (ReaderT a m) where
  log = lift <<< log

instance monadLoggerStateT :: MonadLogger m => MonadLogger (StateT a m) where
  log = lift <<< log

instance monadLoggerWriterT :: (Monoid w, MonadLogger m) => MonadLogger (WriterT w m) where
  log = lift <<< log

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
