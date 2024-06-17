module Test.Bot where

import API.Brig
import API.Common
import API.Galley
import Control.Lens hiding ((.=))
import qualified Data.Aeson as Aeson
import qualified Data.ProtoLens as Proto
import Data.String.Conversions (cs)
import Network.HTTP.Types (status200, status201)
import Network.Wai (responseLBS)
import qualified Network.Wai as Wai
import qualified Network.Wai.Route as Wai
import Numeric.Lens (hex)
import qualified Proto.Otr as Proto
import qualified Proto.Otr_Fields as Proto
import SetupHelpers
import Testlib.Certs
import Testlib.MockIntegrationService
import Testlib.Prelude
import UnliftIO

{- FUTUREWORK(mangoiv):
 -
 - In general the situation is as follows: we only support self-signed certificates, and there's no
 - way of testing we support anything but self-signed certs due to the simple reason of not being able
 - to obtain a valid certificate for testing reasons without modifying brig to accept some root cert
 - generated by us.
 -
 - These tests exist to document this behaviour. If, in the future, some situation would arise that
 - makes us add the certificate validation for PKI, there are already helpers in place in the 'Testlib.Certs'
 - module.
 -
 - In more long form:
 -
 - The issue is as follows:
 -
 - certificate validation should work only for self-signed certs, this is checked by the signature
 - verification function; so this test fails if there's any unknown entity (CA) involved who
 - signed the cert. (a cert can only have one signatory, a CA or self)
 -
 - this test succeeds if the signature verification fails (because it's not self signed), however,
 - even if Brig starts to do signature verification, the test would still succeed, because brig
 - doesn't know (or trust) the CA, anyway, even if it does signature verification.
 -
 - For this test to make sense, we would have to make sure that the brig we're testing against
 - *would* trust the CA, *if* it did verification, because only in that case it would now succeed
 - with verification and not return a "PinInvalidCert" error.
 -
 - -}
testBotUnknownSignatory :: App ()
testBotUnknownSignatory = do
  (_, rootPrivKey) <- mkKeyPair primesA
  (ownerPubKey, privateKeyToString -> ownerPrivKey) <- mkKeyPair primesB
  let rootSignedLeaf = signedCertToString $ intermediateCert "Kabel" ownerPubKey "Example-Root" rootPrivKey
      settings = MkMockServerSettings rootSignedLeaf ownerPrivKey (publicKeyToString ownerPubKey)
  withBotWithSettings settings \resp' -> withResponse resp' \resp -> do
    resp.status `shouldMatchInt` 502
    resp.json %. "label" `shouldMatch` "bad-gateway"
    resp.json %. "message" `shouldMatch` "The upstream service returned an invalid response: PinInvalidCert"

testBotSelfSigned :: App ()
testBotSelfSigned = do
  keys@(publicKeyToString -> pub, privateKeyToString -> priv) <- mkKeyPair primesA
  let cert = signedCertToString $ selfSignedCert "Kabel" keys
  withBotWithSettings MkMockServerSettings {certificate = cert, privateKey = priv, publicKey = pub} \resp' -> do
    resp <- withResponse resp' \resp -> do
      resp.status `shouldMatchInt` 201
      pure resp

    -- If self signed, we should be able to exchange messages
    -- with the bot conversation.
    botClient <- resp.json %. "client"
    botId <- resp.json %. "id"
    aliceQid <- resp.json %. "event.qualified_from"
    conv <- resp.json %. "event.qualified_conversation"

    aliceC <- getJSON 201 =<< addClient aliceQid def
    aliceCid <- objId aliceC

    msg <-
      mkProteusRecipients
        aliceQid
        [(botId, [botClient])]
        "hi bot"
    let aliceBotMessage =
          Proto.defMessage @Proto.QualifiedNewOtrMessage
            & #sender . Proto.client .~ (aliceCid ^?! hex)
            & #recipients .~ [msg]
            & #reportAll .~ Proto.defMessage
    assertStatus 201
      =<< postProteusMessage aliceQid conv aliceBotMessage

withBotWithSettings ::
  MockServerSettings ->
  (Response -> App ()) ->
  App ()
withBotWithSettings settings k = do
  alice <- randomUser OwnDomain def

  withMockServer settings mkBotService \(host, port) _chan -> do
    email <- randomEmail
    provider <- setupProvider alice def {newProviderEmail = email, newProviderPassword = Just defPassword}
    providerId <- provider %. "id" & asString
    service <-
      newService OwnDomain providerId $
        def {newServiceUrl = "https://" <> host <> ":" <> show port, newServiceKey = cs settings.publicKey}
    serviceId <- asString $ service %. "id"
    conv <- getJSON 201 =<< postConversation alice defProteus
    convId <- conv %. "id" & asString
    assertStatus 200 =<< updateServiceConn providerId serviceId do
      object ["enabled" .= True, "password" .= defPassword]
    addBot alice providerId serviceId convId >>= k

data BotEvent
  = BotCreated
  | BotMessage String
  deriving stock (Eq, Ord, Show)

mkBotService :: Chan BotEvent -> LiftedApplication
mkBotService chan =
  Wai.route
    [ (cs "/bots", onBotCreate chan),
      (cs "/bots/:bot/messages", onBotMessage chan),
      (cs "/alive", onBotAlive chan)
    ]

onBotCreate,
  onBotMessage,
  onBotAlive ::
    Chan BotEvent ->
    [(ByteString, ByteString)] ->
    Wai.Request ->
    (Wai.Response -> App Wai.ResponseReceived) ->
    App Wai.ResponseReceived
onBotCreate chan _headers _req k = do
  ((: []) -> pks) <- getPrekey
  writeChan chan BotCreated
  lpk <- getLastPrekey
  k $ responseLBS status201 mempty do
    Aeson.encode $
      object
        [ "prekeys" .= pks,
          "last_prekey" .= lpk
        ]
onBotMessage chan _headers req k = do
  body <- liftIO $ Wai.strictRequestBody req
  writeChan chan (BotMessage (cs body))
  liftIO $ putStrLn $ cs body
  k (responseLBS status200 mempty mempty)
onBotAlive _chan _headers _req k = do
  k (responseLBS status200 mempty (cs "success"))