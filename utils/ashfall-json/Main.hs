-- |
-- Copyright:  (c) 2017 Ertugrul Söylemez
-- License:    BSD3
-- Maintainer: Ertugrul Söylemez <esz@posteo.de>

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}

module Main (main) where

import Control.Applicative
import Control.Exception
import Control.Lens
import Control.Monad.State.Strict
import qualified Data.Aeson as J
import Data.Aeson.Lens
import qualified Data.ByteString.Lazy as Bl
import Data.Char
import qualified Data.HashMap.Strict as Mh
import Data.Monoid
import Data.Scientific
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Vector.Generic as V
import Text.ParserCombinators.ReadP


-- | Focus on all JSON strings

strings :: Traversal J.Value J.Value Text J.Value
strings f = go
    where
    go (J.Object xs) = J.Object <$> traverse go xs
    go (J.Array xs)  = J.Array  <$> traverse go xs
    go (J.String x)  = f x
    go x             = pure x


-- | Focus on all hash fields with the given name that are JSON strings

stringsAt :: Text -> Traversal' J.Value Text
stringsAt k f = go
    where
    go (J.Object xs') =
        (\xs dxs -> J.Object (Mh.union dxs xs))
        <$> traverse go (Mh.delete k xs')
        <*> case Mh.lookup k xs' of
              Just (J.String s) -> Mh.singleton k . J.String <$> f s
              Just x            -> Mh.singleton k <$> go x
              Nothing           -> pure mempty
    go (J.Array xs) = J.Array <$> traverse go xs
    go x = pure x


-- | Convert strings to numbers or ranges, combine effects, downcase all
-- refIds

process :: J.Value -> J.Value
process =
    execState $ do
        -- Parse numbers and ranges
        strings %= \s ->
            foldr (const . fst) (J.String s) (readP_to_S numOrRange (T.unpack s))

        -- Downcase refIds
        stringsAt "refId" %= T.map toLower

        -- Combine effects
        zoom (key "items" . _Array . traverse) $ do
            let go i = do
                    let k = "effect" <> T.pack (show i)
                    mx <- preuse (key k)
                    case mx of
                      Just x -> do
                          _Object . at k .= Nothing
                          (x :) <$> go (i + 1)
                      Nothing -> pure []
            Just . J.Array . V.fromList <$> go 0 >>=
                (_Object . at "effects" .=)

    where
    numOrRange =
        J.Number <$> scientificP <* eof
      <|> do
        x <- scientificP <* char '-'
        y <- scientificP <* eof
        pure (J.object ["min" J..= x, "max" J..= y])


main :: IO ()
main =
    J.decode <$> Bl.getContents >>=
    maybe (throwIO (userError "Parse failed")) pure >>=
    Bl.putStr . J.encode . process
