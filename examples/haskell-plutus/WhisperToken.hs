{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE NoImplicitPrelude #-}

module WhisperToken where

import           PlutusTx
import           PlutusTx.Prelude
import           Plutus.V2.Ledger.Api
import           Plutus.V2.Ledger.Contexts
import qualified PlutusTx.AssocMap as Map

-- | Token name
data WhisperToken = WhisperToken
    { tokenName :: TokenName
    , totalSupply :: Integer
    } deriving (Show, Generic, FromJSON, ToJSON)

PlutusTx.makeLift ''WhisperToken

-- | Token state
data TokenState = TokenState
    { balances :: Map.Map PubKeyHash Integer
    , allowances :: Map.Map (PubKeyHash, PubKeyHash) Integer
    } deriving (Show, Generic, FromJSON, ToJSON)

PlutusTx.makeIsDataIndexed ''TokenState [('TokenState, 0)]

-- | Token validator
{-# INLINABLE mkValidator #-}
mkValidator :: WhisperToken -> TokenState -> ScriptContext -> Bool
mkValidator token state ctx = case redeemer of
    Transfer recipient amount ->
        traceIfFalse "Insufficient balance" (senderBalance >= amount) &&
        traceIfFalse "Invalid amount" (amount > 0)
    Approve spender amount ->
        traceIfFalse "Invalid amount" (amount >= 0)
  where
    info :: TxInfo
    info = scriptContextTxInfo ctx

    sender :: PubKeyHash
    sender = case txInfoSignatories info of
        [pkh] -> pkh
        _     -> traceError "Expected exactly one signatory"

    senderBalance :: Integer
    senderBalance = case Map.lookup sender (balances state) of
        Just bal -> bal
        Nothing  -> 0

-- | Validator script
validator :: WhisperToken -> Validator
validator token = mkValidatorScript $
    $$(PlutusTx.compile [|| mkValidator ||])
    `PlutusTx.applyCode`
    PlutusTx.liftCode token

-- | Address of the validator
tokenAddress :: WhisperToken -> Address
tokenAddress = scriptHashAddress . validatorHash . validator
