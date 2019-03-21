# Purescript Logging Monad Transformer

This library provides a class for monads which can log messages, and an
associated monad transformer.  It also includes associated data types and
utilities, like a `Message` type, log filters, and formatters. It's roughly
inspired by http://hackage.haskell.org/package/monad-logger.

See [doc/Example.purs](doc/Example.purs) for an example of how to use this
library.

## Usage

Say you have a function that returns an effect to calculate a string:

```purescript
doSomething :: forall m. MonadEffect m => m String
doSomething = pure "foobar!"
```

You can add logging to it by doing something like this:

```purescript
doSomethingWithLog :: forall m. MonadLogger m => MonadEffect m => m String
doSomethingWithLog = do
  debug empty "About to do something!"
  result <- doSomething
  debug (tag "Result" result) "Did the thing!"
  pure result
```

To resolve the logger context, pass a log handler to `runLoggerT`:

``` purescript
runLoggedStuff:: forall m. MonadEffect m => m String
runLoggedStuff = runLoggerT doSomethingWithLog $ prettyFormatter >=> Console.log
```

## Levels

Log levels are defined in [Data.Log.Level](src/Data/Log/Level.purs).  For each
level, there is an associated function in
[Control.Monad.Logger.Class](src/Control/Monad/Logger/Class.purs) which will
generate a timestamped `Message` of that level and pass it onto the log handler.

## Tags

You can add various metadata to your log lines by using tags.  You can generate
tags of various types by using the functions exported from
[Data.Log.Tag](src/Data/Log/Tag.purs).

## Log Handlers

A log handler is just a function with the signature:

```purescript
forall m. MonadEffect m => Message -> m Unit
```

The `MonadEffect` constraint is required, even if you don't do anything
effectual with your log handler, because this library generates timestamps for
each message.

Typically you will create a log handler by passing log messages through a
formatter and to something like `Console.log`.  Sometimes you might want to add
a message filter, if you don't want to deliver all logs to a particular target.

## Formatters

Formatters map `Message` payloads to strings.  There are two formatters built
in:

- [Data.Log.Formatter.Pretty](src/Data/Log/Formatter/Pretty.purs): generates
  beautiful, asci-colored strings, appropriate for a developer console log
- [Data.Log.Formatter.JSON](src/Data/Log/Formatter/JSON.purs): generates compact
  JSON strings, appropriate for log files or piping logs through an external
  tool for processing

## Filters

Filters are used, as the name implies, to only pass through certain messages to
handler.  Built-in formatters are available in
[Data.Log.Filter](src/Data/Log/Filter.purs) and can be used to filter messages
out by log level.
