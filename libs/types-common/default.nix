# WARNING: GENERATED FILE, DO NOT EDIT.
# This file is generated by running hack/bin/generate-local-nix-packages.sh and
# must be regenerated whenever local packages are added or removed, or
# dependencies are added or removed.
{ mkDerivation
, aeson
, attoparsec
, attoparsec-iso8601
, base
, base16-bytestring
, base64-bytestring
, binary
, bytestring
, bytestring-conversion
, cassandra-util
, cereal
, containers
, cryptohash-md5
, cryptohash-sha1
, crypton
, currency-codes
, email-validate
, generic-random
, gitignoreSource
, hashable
, http-api-data
, imports
, iproute
, iso3166-country-codes
, iso639
, lens
, lens-datetime
, lib
, mime
, openapi3
, optparse-applicative
, pem
, protobuf
, QuickCheck
, quickcheck-instances
, random
, schema-profunctor
, scientific
, servant-server
, string-conversions
, tagged
, tasty
, tasty-hunit
, tasty-quickcheck
, template-haskell
, text
, time
, time-locale-compat
, tinylog
, unix
, unordered-containers
, uri-bytestring
, utf8-string
, uuid
, yaml
}:
mkDerivation {
  pname = "types-common";
  version = "0.16.0";
  src = gitignoreSource ./.;
  libraryHaskellDepends = [
    aeson
    attoparsec
    attoparsec-iso8601
    base
    base16-bytestring
    base64-bytestring
    binary
    bytestring
    bytestring-conversion
    cassandra-util
    containers
    cryptohash-md5
    cryptohash-sha1
    crypton
    currency-codes
    email-validate
    generic-random
    hashable
    http-api-data
    imports
    iproute
    iso3166-country-codes
    iso639
    lens
    lens-datetime
    mime
    openapi3
    optparse-applicative
    pem
    protobuf
    QuickCheck
    quickcheck-instances
    random
    schema-profunctor
    scientific
    servant-server
    tagged
    tasty
    tasty-hunit
    template-haskell
    text
    time
    time-locale-compat
    tinylog
    unix
    unordered-containers
    uri-bytestring
    utf8-string
    uuid
    yaml
  ];
  testHaskellDepends = [
    aeson
    base
    bytestring
    bytestring-conversion
    cereal
    email-validate
    imports
    protobuf
    string-conversions
    tasty
    tasty-hunit
    tasty-quickcheck
    text
    time
    unordered-containers
    utf8-string
    uuid
  ];
  description = "Shared type definitions";
  license = lib.licenses.agpl3Only;
}
