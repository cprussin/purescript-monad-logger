module Control.Monad.Logger.Trans
  ( LoggerT(..)
  , runLoggerT
  , mapLoggerT
  , module Control.Monad.Trans.Class
  , module Control.Monad.Logger.Class
  ) where

import Prelude

import Effect.Class (class MonadEffect, liftEffect)
import Effect.Aff.Class (class MonadAff, liftAff)
import Control.Monad.Error.Class
  ( class MonadThrow
  , class MonadError
  , throwError
  , catchError
  )
import Control.Monad.Logger.Class
  ( class MonadLogger
  , trace
  , debug
  , info
  , warn
  , error
  )
import Control.Monad.Reader.Trans
  ( class MonadAsk
  , class MonadReader
  , ask
  , local
  )
import Control.Monad.Rec.Class
  ( class MonadRec
  , tailRecM
  )
import Control.Monad.State.Trans
  ( class MonadState
  , state
  )
import Control.Monad.Trans.Class (class MonadTrans, lift)
import Data.Log.Message (Message)
import Data.Newtype (class Newtype, unwrap)

newtype LoggerT m a = LoggerT ((Message -> m Unit) -> m a)

runLoggerT :: forall m a. LoggerT m a -> (Message -> m Unit) -> m a
runLoggerT (LoggerT m) = m

mapLoggerT :: forall m a b. (m a -> m b) -> LoggerT m a -> LoggerT m b
mapLoggerT f (LoggerT m) = LoggerT $ f <<< m

withLoggerT
  :: forall m a
   . ((Message -> m Unit) -> (Message -> m Unit))
  -> LoggerT m a
  -> LoggerT m a
withLoggerT f (LoggerT m) = LoggerT $ f >>> m

derive instance newtypeLoggerT :: Newtype (LoggerT m a) _

instance functorLoggerT :: Functor m => Functor (LoggerT m) where
  map = map >>> mapLoggerT

instance applyLoggerT :: Monad m => Apply (LoggerT m) where
  apply = ap

instance applicativeLoggerT :: Monad m => Applicative (LoggerT m) where
  pure = pure >>> const >>> LoggerT

instance bindLoggerT :: Monad m => Bind (LoggerT m) where
  bind (LoggerT m) f = LoggerT \l -> m l >>= f >>> unwrap >>> (_ $ l)

instance monadLoggerT :: Monad m => Monad (LoggerT m)

instance monadTransLoggerT :: MonadTrans LoggerT where
  lift = LoggerT <<< const

instance monadEffectLoggerT :: MonadEffect m => MonadEffect (LoggerT m) where
  liftEffect = lift <<< liftEffect

instance monadAffLoggerT :: MonadAff m => MonadAff (LoggerT m) where
  liftAff = lift <<< liftAff

instance monadAskLoggerT :: MonadAsk r m => MonadAsk r (LoggerT m) where
  ask = lift ask

instance monadStateLoggerT :: MonadState s m => MonadState s (LoggerT m) where
  state = lift <<< state

instance monadReaderLoggerT :: MonadReader r m => MonadReader r (LoggerT m) where
  local = mapLoggerT <<< local

instance monadRecLoggerT :: MonadRec m => MonadRec (LoggerT m) where
  tailRecM step a =
    LoggerT \l -> tailRecM (\a' -> unwrap (step a') l) a

instance monadLoggerLoggerT :: MonadEffect m => MonadLogger (LoggerT m) where
  log message = LoggerT (_ $ message)

instance monadThrowLoggerT :: MonadThrow e m => MonadThrow e (LoggerT m) where
  throwError = throwError >>> lift

instance monadErrorLoggerT :: MonadError e m => MonadError e (LoggerT m) where
  catchError (LoggerT m) h =
    LoggerT \l -> catchError (m l) $ h >>> unwrap >>> (_ $ l)
