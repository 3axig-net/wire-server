# WARNING: GENERATED FILE, DO NOT EDIT.
# This file is generated by running hack/bin/generate-local-nix-packages.sh and
# must be regenerated whenever local packages are added or removed, or
# dependencies are added or removed.
{ mkDerivation
, aeson
, aeson-pretty
, amazonka
, amazonka-core
, amazonka-ses
, amqp
, async
, attoparsec
, base
, base16-bytestring
, base64-bytestring
, bilge
, bloodhound
, bytestring
, bytestring-conversion
, case-insensitive
, cassandra-util
, conduit
, containers
, cql
, crypton
, currency-codes
, data-default
, data-timeout
, email-validate
, errors
, exceptions
, extended
, extra
, gitignoreSource
, HaskellNet
, HaskellNet-SSL
, hex
, HsOpenSSL
, hspec
, hspec-discover
, html-entities
, http-client
, http-types
, http2-manager
, imports
, iso639
, lens
, lib
, memory
, mime
, mime-mail
, network
, network-conduit-tls
, pipes
, polysemy
, polysemy-plugin
, polysemy-time
, polysemy-wire-zoo
, postie
, prometheus-client
, QuickCheck
, quickcheck-instances
, random
, resource-pool
, resourcet
, retry
, saml2-web-sso
, schema-profunctor
, scientific
, servant
, servant-client-core
, stomp-queue
, streaming-commons
, string-conversions
, template
, text
, text-icu-translit
, time
, time-out
, time-units
, tinylog
, transformers
, types-common
, unliftio
, unordered-containers
, uri-bytestring
, uuid
, wai-utilities
, wire-api
, wire-api-federation
, wire-otel
, witherable
}:
mkDerivation {
  pname = "wire-subsystems";
  version = "0.1.0";
  src = gitignoreSource ./.;
  libraryHaskellDepends = [
    aeson
    aeson-pretty
    amazonka
    amazonka-core
    amazonka-ses
    amqp
    async
    attoparsec
    base
    base16-bytestring
    base64-bytestring
    bilge
    bloodhound
    bytestring
    bytestring-conversion
    case-insensitive
    cassandra-util
    conduit
    containers
    cql
    crypton
    currency-codes
    data-default
    data-timeout
    email-validate
    errors
    exceptions
    extended
    extra
    HaskellNet
    HaskellNet-SSL
    hex
    HsOpenSSL
    hspec
    html-entities
    http-client
    http-types
    http2-manager
    imports
    iso639
    lens
    memory
    mime
    mime-mail
    network
    network-conduit-tls
    polysemy
    polysemy-plugin
    polysemy-time
    polysemy-wire-zoo
    prometheus-client
    QuickCheck
    resource-pool
    resourcet
    retry
    saml2-web-sso
    schema-profunctor
    servant
    servant-client-core
    stomp-queue
    template
    text
    text-icu-translit
    time
    time-out
    time-units
    tinylog
    transformers
    types-common
    unliftio
    unordered-containers
    uri-bytestring
    uuid
    wai-utilities
    wire-api
    wire-api-federation
    wire-otel
    witherable
  ];
  testHaskellDepends = [
    aeson
    async
    base
    bilge
    bytestring
    cassandra-util
    containers
    crypton
    data-default
    errors
    extended
    hspec
    imports
    iso639
    lens
    mime-mail
    network
    pipes
    polysemy
    polysemy-plugin
    polysemy-time
    polysemy-wire-zoo
    postie
    QuickCheck
    quickcheck-instances
    random
    scientific
    servant-client-core
    streaming-commons
    string-conversions
    text
    time
    tinylog
    transformers
    types-common
    uri-bytestring
    uuid
    wire-api
    wire-api-federation
  ];
  testToolDepends = [ hspec-discover ];
  license = lib.licenses.agpl3Only;
}
