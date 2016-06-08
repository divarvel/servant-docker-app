{-# LANGUAGE DataKinds       #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeOperators   #-}
{-# LANGUAGE OverloadedStrings #-}
module Lib
    ( startApp
    ) where

import Network.Wai.Middleware.Prometheus (prometheus, PrometheusSettings(..))
import Prometheus (register)
import Prometheus.Metric.GHC (ghcMetrics)

import Data.Aeson
import Data.Aeson.TH
import Network.Wai
import Network.Wai.Handler.Warp
import Servant

data User = User
  { userId        :: Int
  , userFirstName :: String
  , userLastName  :: String
  } deriving (Eq, Show)

$(deriveJSON defaultOptions ''User)

data SortBy = Name | Age deriving (Eq, Show)

$(deriveJSON defaultOptions ''SortBy)

type API = "users" :> Get '[JSON] [User]

startApp :: IO ()
startApp = do
  register ghcMetrics
  let promMiddleware = prometheus $ PrometheusSettings ["metrics"] True True
  run 8080 $ promMiddleware $ app

app :: Application
app = serve api server

api :: Proxy API
api = Proxy

server :: Server API
server = return users

users :: [User]
users = [ User 1 "Isaac" "Newton"
        , User 2 "Albert" "Einstein"
        ]
