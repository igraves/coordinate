{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleInstances #-}

module Data.Geo.Coordinate.Minutes(
  Minutes
, AsMinutes(..)
, modMinutes
) where

import Control.Applicative(Applicative)
import Control.Category(Category(id))
import Control.Lens(Optic', Choice, prism')
import Data.Bool((&&))
import Data.Maybe(Maybe(Just, Nothing))
import Data.Eq(Eq)
import Data.Int(Int)
import Data.Ord(Ord((>=), (<)))
import Prelude(Show, mod)

-- $setup
-- >>> import Control.Lens((#), (^?), (^.))
-- >>> import Data.Foldable(all)
-- >>> import Prelude(Eq(..))

newtype Minutes =
  Minutes Int
  deriving (Eq, Ord, Show)

class AsMinutes p f s where
  _Minutes ::
    Optic' p f s Minutes

instance AsMinutes p f Minutes where
  _Minutes =
    id

-- | A prism on minutes to an integer between 0 and 59 inclusive.
--
-- >>> (7 :: Int) ^? _Minutes
-- Just (Minutes 7)
--
-- >>> (0 :: Int) ^? _Minutes
-- Just (Minutes 0)
--
-- >>> (59 :: Int) ^? _Minutes
-- Just (Minutes 59)
--
-- >>> (60 :: Int) ^? _Minutes
-- Nothing
--
-- prop> all (\m -> _Minutes # m == (n :: Int)) (n ^? _Minutes)
instance (Choice p, Applicative f) => AsMinutes p f Int where
  _Minutes =
    prism'
      (\(Minutes i) -> i)
      (\i -> if i >= 0 && i < 60
               then Just (Minutes i)
               else Nothing)       

-- | Setting a value within the range @0@ and @60@ using modulo arithmetic.
--
-- >>> modMinutes 7
-- Minutes 7
--
-- >>> modMinutes 0
-- Minutes 0
--
-- >>> modMinutes 60
-- Minutes 0
--
-- >>> modMinutes 1
-- Minutes 1
--
-- >>> modMinutes 59
-- Minutes 59 
--
-- >>> modMinutes 61
-- Minutes 1
--
-- >>> modMinutes (-1)
-- Minutes 59
modMinutes ::
  Int
  -> Minutes
modMinutes x =
  Minutes (x `mod` 60)
