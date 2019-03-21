module Data.Log.Level
  ( LogLevel(..)
  ) where

import Prelude

data LogLevel = Trace | Debug | Info | Warn | Error
derive instance eqLogLevel :: Eq LogLevel
derive instance ordLogLevel :: Ord LogLevel
