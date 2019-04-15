module API.Settings (tests) where

import           Imports
import           Bilge               hiding (accept, timeout)
import           Data.Barbie         (buniq)
import           Test.Tasty          hiding (Timeout)
import           Util
import API.Team.Util
import qualified Galley.Types.Teams          as Team

import Data.Id
import qualified Brig.Options as Opt
import           Brig.Types.User (EmailVisibility(..))

import Test.Tasty.HUnit

import Bilge.Assert
import Brig.Types
import Control.Arrow ((&&&))
import Data.Aeson
import Data.Aeson.Lens
import Control.Lens
import Data.ByteString.Conversion

import qualified Data.ByteString.Char8       as C8
import qualified Data.Set                    as Set

tests :: Manager -> Brig -> Galley -> IO TestTree
tests manager brig galley = do
    return
        $ testGroup "settings"
        $ [ testCase "EmailVisibleIfOnTeam"
            . runHttpT manager
            . withEmailVisibility EmailVisibleIfOnTeam brig $
                (testEmailShowsEmailsIfExpected brig galley (expectEmailVisible EmailVisibleIfOnTeam))
          , testCase "EmailVisibleToSelf"
            . runHttpT manager
            . withEmailVisibility EmailVisibleToSelf brig $
                (testEmailShowsEmailsIfExpected brig galley (expectEmailVisible EmailVisibleToSelf))
          ]

data UserRelationship = SameTeam | DifferentTeam | NoTeam

-- Should we show the email for this user type?
type EmailVisibilityAssertion = UserRelationship -> Bool

expectEmailVisible :: EmailVisibility -> UserRelationship -> Bool
expectEmailVisible EmailVisibleIfOnTeam SameTeam = True
expectEmailVisible EmailVisibleIfOnTeam DifferentTeam = True
expectEmailVisible EmailVisibleIfOnTeam NoTeam = False

expectEmailVisible EmailVisibleToSelf SameTeam = False
expectEmailVisible EmailVisibleToSelf DifferentTeam = False
expectEmailVisible EmailVisibleToSelf NoTeam = False

testEmailShowsEmailsIfExpected :: Brig -> Galley -> EmailVisibilityAssertion -> Http ()
testEmailShowsEmailsIfExpected brig galley shouldShowEmail = do
    (creatorId, tid) <- createUserWithTeam brig galley
    (otherTeamCreatorId, otherTid) <- createUserWithTeam brig galley
    userA <- createTeamMember brig galley creatorId tid Team.fullPermissions
    userB <- createTeamMember brig galley otherTeamCreatorId otherTid Team.fullPermissions
    nonTeamUser <- createUser "joe" brig
    let uids = C8.intercalate "," $ toByteString' <$> [userId userA, userId userB, userId nonTeamUser]
        expected :: Set (Maybe UserId, Maybe Email)
        expected = Set.fromList
                   [ ( Just $ userId userA
                     , if shouldShowEmail SameTeam then userEmail userA
                                                   else Nothing)
                   , ( Just $ userId userB
                     , if shouldShowEmail DifferentTeam then userEmail userB
                                                        else Nothing)
                   , ( Just $ userId nonTeamUser
                     , if shouldShowEmail NoTeam then userEmail nonTeamUser
                                                 else Nothing)
                   ]
    get (brig . zUser (userId userB) . path "users" . queryItem "ids" uids) !!! do
        const 200 === statusCode
        const (Just expected) === result
  where
    result r =  Set.fromList
             .  map (field "id" &&& field "email")
            <$> decodeBody r

    field :: FromJSON a => Text -> Value -> Maybe a
    field f u = u ^? key f >>= maybeFromJSON


withEmailVisibility :: EmailVisibility -> Brig -> Http () -> Http ()
withEmailVisibility emailVisibilityOverride brig t =
    withSettingsOverrides brig newSettings t
  where
    newSettings :: Opt.MutableSettings' Maybe
    newSettings =
        (buniq Nothing)
        { Opt.setEmailVisibility = Just emailVisibilityOverride
        }
