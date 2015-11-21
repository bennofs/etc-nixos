{-# LANGUAGE OverloadedStrings #-}
import DBus
import DBus.Client
import Control.Concurrent
import Control.Monad
import Network.MPD
import System.Process

-- | A match rule that matches logind's PrepareForSleep message.
prepareForSleepEvent :: MatchRule
prepareForSleepEvent = matchAny
  { matchMember = Just "PrepareForSleep"
  , matchInterface = Just "org.freedesktop.login1.Manager"
  , matchPath = Just "/org/freedesktop/login1"
  }

-- | This function blocks until a sleep is requested.
waitForSleep :: IO ()
waitForSleep = do
  client <- connectSystem
  sleepEvent <- newEmptyMVar
  handler <- addMatch client prepareForSleepEvent $ \s -> case signalBody s of
    [arg] | Just before <- fromVariant arg -> when before $ putMVar sleepEvent ()
    _ -> return ()
  takeMVar sleepEvent
  removeMatch client handler

-- | This function is executed whenever before system goes to sleep.
sleepAction :: IO ()
sleepAction = do
  void $ withMPD stop
  void $ callProcess "@lock@/bin/lock" ["@out@/bin/lock-on-suspend"]

main :: IO ()
main = waitForSleep >> sleepAction
