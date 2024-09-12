# WARNING: GENERATED FILE, DO NOT EDIT.
# This file is generated by running hack/bin/generate-local-nix-packages.sh and
# must be regenerated whenever local packages are added or removed, or
# dependencies are added or removed.
{ mkDerivation
, aeson
, amazonka
, amazonka-core
, amazonka-ses
, async
, base
, base16-bytestring
, bilge
, bytestring
, bytestring-conversion
, cassandra-util
, conduit
, containers
, cql
, crypton
, currency-codes
, data-default
, data-timeout
, errors
, exceptions
, extended
, extra
, gitignoreSource
, gundeck-types
, HaskellNet
, HaskellNet-SSL
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
, QuickCheck
, quickcheck-instances
, random
, resource-pool
, resourcet
, retry
, scientific
, servant
, servant-client-core
, stomp-queue
, streaming-commons
, string-conversions
, template
, text
, time
, time-out
, time-units
, tinylog
, transformers
, transitive-anns
, types-common
, unliftio
, unordered-containers
, uri-bytestring
, uuid
, wai-utilities
, wire-api
, wire-api-federation
, witherable
}:
mkDerivation {
  pname = "wire-subsystems";
  version = "0.1.0";
  src = gitignoreSource ./.;
  libraryHaskellDepends = [
    aeson
    amazonka
    amazonka-core
    amazonka-ses
    async
    base
    base16-bytestring
    bilge
    bytestring
    bytestring-conversion
    cassandra-util
    conduit
    containers
    cql
    crypton
    currency-codes
    data-default
    data-timeout
    errors
    exceptions
    extended
    extra
    gundeck-types
    HaskellNet
    HaskellNet-SSL
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
    QuickCheck
    resource-pool
    resourcet
    retry
    servant
    servant-client-core
    stomp-queue
    template
    text
    time
    time-out
    time-units
    tinylog
    transformers
    transitive-anns
    types-common
    unliftio
    unordered-containers
    uri-bytestring
    uuid
    wai-utilities
    wire-api
    wire-api-federation
    witherable
  ];
  testHaskellDepends = [
    aeson
    async
    base
    bilge
    bytestring
    containers
    crypton
    data-default
    errors
    extended
    gundeck-types
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
    wire-api
    wire-api-federation
  ];
  testToolDepends = [ hspec-discover ];
  license = lib.licenses.agpl3Only;
}
