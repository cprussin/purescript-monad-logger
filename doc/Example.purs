module Example where

import Prelude

import Control.Monad.Logger.Trans
  ( class MonadLogger
  , runLoggerT
  , trace
  , info
  , error
  )
import Data.JSDate (now)
import Data.Log.Formatter.Pretty (prettyFormatter)
import Data.Log.Filter (minimumLevel)
import Data.Log.Level (LogLevel(Info))
import Data.Log.Tag
  ( TagSet
  , tag
  , intTag
  , jsDateTag
  , booleanTag
  , tagSetTag
  , empty
  )
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Console (log)

main :: Effect Unit
main = runLoggerT logMessage $ minimumLevel Info $ prettyFormatter >=> log

logMessage :: forall m. MonadLogger m => m Unit
logMessage = do
  tags <- getTags
  trace empty "Almost Hello World!"
  info tags "Hello World!"
  error empty "Goodbye World!"

getTags :: forall m. MonadEffect m => m TagSet
getTags = do
  now' <- liftEffect now
  pure $
    tag "foo" "bar" <>
    intTag "baz" 0 <>
    booleanTag "isTrue" true <>
    jsDateTag "starting time" now' <>
    tagSetTag "extra tags" (
      tag "sub foo" "bar" <>
      intTag "sub baz" 1 <>
      tagSetTag "sub sub tags" (
        tag "sub sub foo" "bar" <>
        intTag "sub sub baz" 2
      )
    )
