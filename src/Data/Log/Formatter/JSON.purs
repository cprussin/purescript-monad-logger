module Data.Log.Formatter.JSON
  ( jsonFormatter
  ) where

import Prelude

import Data.Argonaut.Core
  ( Json
  , fromObject
  , fromString
  , fromNumber
  , fromBoolean
  , stringify
  )
import Data.Int (toNumber)
import Data.JSDate (getTime)
import Data.Log.Level (LogLevel(Trace, Debug, Info, Warn, Error))
import Data.Log.Message (Message)
import Data.Log.Tag
  ( TagSet
  , Tag(StringTag, NumberTag, IntTag, BooleanTag, JSDateTag, TagSetTag)
  , fromArray
  , tag
  , intTag
  , jsDateTag
  , tagSetTag
  , empty
  )
import Data.Map (toUnfoldable, isEmpty)
import Data.Tuple (Tuple)
import Foreign.Object (fromFoldable)

jsonFormatter :: Message -> String
jsonFormatter = buildPayload >>> toJson >>> stringify

buildPayload :: Message -> TagSet
buildPayload { level, timestamp, message, tags } = fromArray $
  [ intTag "level" $ levelCode level
  , jsDateTag "ts" timestamp
  , tag "message" message
  , if isEmpty tags then empty else tagSetTag "tags" tags
  ]

toJson :: TagSet -> Json
toJson set = fromObject $ fromFoldable $ jsonify set

jsonify :: TagSet -> Array (Tuple String Json)
jsonify set = toUnfoldable $ fieldToJson <$> set

fieldToJson :: Tag -> Json
fieldToJson (StringTag value) = fromString value
fieldToJson (IntTag value) = fromNumber $ toNumber value
fieldToJson (NumberTag value) = fromNumber value
fieldToJson (BooleanTag value) = fromBoolean value
fieldToJson (JSDateTag value) = fromNumber $ getTime value
fieldToJson (TagSetTag value) = toJson value

levelCode :: LogLevel -> Int
levelCode Trace = 0
levelCode Debug = 1
levelCode Info = 2
levelCode Warn = 3
levelCode Error = 4
