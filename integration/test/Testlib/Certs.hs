module Testlib.Certs where

import Crypto.Hash.Algorithms (SHA256 (SHA256))
import qualified Crypto.PubKey.RSA as RSA
import qualified Crypto.PubKey.RSA.PKCS15 as PKCS15
import Crypto.Store.PKCS8 (PrivateKeyFormat (PKCS8Format), keyToPEM)
import Crypto.Store.X509 (pubKeyToPEM)
import Data.ASN1.OID (OIDable (getObjectID))
import Data.Hourglass
import Data.PEM (PEM (PEM), pemWriteBS)
import Data.String.Conversions (cs)
import Data.X509
import Testlib.Prelude

type RSAKeyPair = (RSA.PublicKey, RSA.PrivateKey)

type SignedCert = SignedExact Certificate

-- | convert a PEM to a string
toPem :: PEM -> String
toPem = cs . pemWriteBS

-- | convert a signed certificate to a string
signedCertToString :: SignedCert -> String
signedCertToString = toPem . PEM "CERTIFICATE" [] . encodeSignedObject

-- | convert a private key to string
privateKeyToString :: RSA.PrivateKey -> String
privateKeyToString = toPem . keyToPEM PKCS8Format . PrivKeyRSA

-- | convert a public key to string
publicKeyToString :: RSA.PublicKey -> String
publicKeyToString = toPem . pubKeyToPEM . PubKeyRSA

-- | the minimum key size is hard coded to be 256 bytes (= 2048 bits)
mkKeyPair :: (HasCallStack) => (Integer, Integer) -> App RSAKeyPair
mkKeyPair primes =
  assertJust "key generation failed"
    $ RSA.generateWith
      primes
      2048
      65537

primesA :: (Integer, Integer)
primesA =
  ( 1013416710455617992060044810859399709890835129925648843043641673852539448350775594187007527506724875627885909523835606557173980236290013476205929897072239944138314384631600538474898358198731711608598716779857515154388088878657555928549962380829213547435085854695442354636327047821108802590374275481605077802187415357974963365435650338024405558985202998762641404395411587629314013330411500470203761301812113710962088477051775450894192994742118846780105265558368972170180276350636994878636389758206123738715722878057404540464220733023391993383290494652037274532356460190907090422144536951440069212998822960155765054879900781581263606916652700903953626527029121897494538017122565993895036773799860052414697053960902764894046849087727915659738623914130083281919853081537137782445589156217286369690178786653090799221857147470043219175767249163571686740347462294750028790472737772761949491538873890614496706566060247820117584298845501935064037819052405654373374661838572553244593002834443762478259268799467895951456315647324157054992319938064879914915556645111272573189405077515029783954913337757933225821260787418411247627537065834022908147122036442414923430533383989652364612738513379313521406363716216150953874675705623133860932309998632104801092827841702718992714882139811954467163400593020720191718049863114367363094097654194786896842879463158349468509662084081492854544553121389587671952367596127566679408181243898540691657673709282297206699665271972122876732477153246545187514721891966873910637813569799235783300883640120382296336980469139678449923244327325676463743789034561023783533980749100272005938046751700931286800296518645750336292219055157506140422334232031499441618108378207249469768514341014613604798707882336528213109908520952809254346958192134161621644423814067058523341464457188689237566854457651740962437154879472377563420329379777383724869785437079461381042576932777663816932792106785972722313112138774627384189872028788531464434347861094422498231096686231475413078333450041613628998736286930594422166708703115486915826404578851616898264340560519310655180870217752558303339822824214706404615558734661262111177357709447064658518593459191904042065215329175588893364731436963818899069593653897213811368511785916948261704025900054681973429106441628584851712758726618885443787735678619865846520873765930283904988556631550968487727144405349504203063775775239807234977371854786517646240982498594502233136236903225375658288185007963323167751702824125884605983,
    927336758709169856221729309972684377326012758705584701160913392855296574209188805952293975727392736357355525822682625960867980784906333126250176772633612511280160520450355917665344680820117001909657304528897728644985372222487760541890997744380957145384918405839817509991111341989419216342513467094263440712622240826707558561965237909070383875063686755789716081493927682670013715434239129366779748040394792694841549258598842315715859562294976974200564408338450316192760863885386436881465495436476022429943600686139972778561942722494137924396693749231870673494020761865863446686474725091312431012619078931330640808188498974525508440925548025604310429878232463952454557835744654770844144316962049844107999645072674978011865146180434315809137160022154815275730622923394822959089495198091753080586758917401240837851455881168916390487103230014598246305055773428160686563500509562651266122967947533947385066722712316194439650272469880653336775557226431438158529031941085177895035782278423238393385871537920481620086314516883242108371084035236009476902958675684122414056114458154814623140680549398143962297844269217544119579639388880282746926211911340151495180800938356829417651851575812389707158878607136197574826859775996273379970390171328581948608028025142182853278853363612390290636206287758711077096741448655899931751827724488361988091582792716911972718148392453707898042946671553774030598713651389432173834332238513353580335392843797930178943386918304488493730840967156657148290968957715981554273773737487151449135620952308225431024688393136984555900143424679822610046551196808932727745248865362347785479364187372055325574195459037155066312293273886348144861748982170185415622553571530631513603477602826429579398186262265223153306278304799915076700814229178193555765145764377299909576623617487785999435363105546438656832847240507003602597491108906216981192670279162943412764046303699081784813538920115117298548433198843455119043790372888336933692344328141527872374759669746090941218187034798766305747971923638002946091334202545017363599031086846658957509235784541901412672981937055987278520433029602910026209333275313496848631869151490522436140352421940732910006747478399676998276993458833024795683746787074826108339213690383195100285198326586610540809574097037429381790444840835133521220930836457168264627708965665242143474257229651142989737540001394269465834767510321913987796958346807012067096569096845804007816516090656151634293085062792873308124403242170010908041
  )

primesB :: (Integer, Integer)
primesB =
  ( 871155632739595756799368259914317757869334272154983889623497899446351035891726950864760818802838595063934628826345508916199957107684222515882852684036230531365663403198038587540738738037375348907830388509196441061498831829580551641232283859846190461640815357339853825341277581978021694268863680319244800913484314268404426052051276279669361259959567803085510055380452465751288284768848270342730747029989822198165263072973301996345116628415172285009118708059077706393593020607784780174671547072573221780144687345051988772069027762089091988339582468302138720780718092405021682721751886066645363782225165192495156519578684200413534356562613176683748354996198186163955382610564385310389118252336135259031274255451291680971631891663534692283032504605093383857083862510210862275042255073696123798884409160503619458509744563163914332600437715745600147161022540996340483674184441810042828159783031479546834467530369264396884330140711499699266924456618312375561602660949586678704688686856427513634257055225556101020484663286239650064186437382802373072023507182933268791570788599931961833813734037134668038054950930969107492644097198321408480575010280891590867974839171422952718717441444733710567680383351516170682903290649975877510922338625322722929191152330381838484770793021720831482560176937010381470742911288685130877749162737215149115897767752780906005531169766158172378124848548236188253951341833337787491191664609190850061976677827193348008151669235627322237835010267056500055155911065051791530775399726348686264567265615592790858074242165758723415045115369812705468997801074923865225034659418948148275742092201647617244926597099611670028261172621565835558819135359344483800612705319426768052233109556067407938461005945571595672934139094853414792890276083259923707564466948103729121571083500502589982253333701218140215063120367647585300928378204225025283637784718810313259064139990414485231379692327258476858053769854028351496526751167792340279523340296200242416054659843844911906831964521310830916452145341389783536384312312436425360442183300971035975855454272571297920101093815174274315270008040800474966896945391435392494085295376492758667434573362418630322524804767037530872608312526851376234941674830096729913417387669746155771937829809497813203635102474604063142988339458080423659799467256308889003645375406858192706500220530718350804807804829694351252086594036332829897567632623034066916145636238868932684508748622471625137517969447341759208173885041127987345267,
    1030843359898456423663521323846594342599509001361505950190458094255790543792826808869649005832755187592625111972154015489882697017782849415061917844274039201990123282710414810809677284498651901967728601289390435426055251344683598043635553930587608961202440578033000424009931449958127951542294372025522185552538021557179009278446615246891375299863655746951224012338422185000952023195927317706092311999889180603374149659663869483313116251085191329801800565556652256960650364631610748235925879940728370511827034946814052737660926604082837303885143652256413187183052924192977324527952882600246973965189570970469037044568259408811931440525775822585332497163319841870179534838043708793539688804501356153704884928847627798172061867373042270416202913078776299057112318300845218218100606684092792088779583532324019862407866255929320869554565576301069075336647916168479092314004711778618335406757602974282533765740790546167166172626995630463716394043281720388344899550856555259477489548509996409954619324524195894460510128676025203769176155038527250084664954695197534485529595784255553806751541708069739004260117122700058054443774458724994738753921481706985581116480802534320353367271370286704034867136678539759260831996400891886615914808935283451835347282009482924185619896114631919985205238905153951336432886954324618000593140640843908517786951586431386674557882396487935889471856924185568502767114186884930347618747984770073080480895996031031971187681573023398782756925726725786964170460286504569090697402674905089317540771910375616350312239688178277204391962835159620450731320465816254229575392846112372636483958055913716148919092913102176828552932292829256960875180097808893909460952573027221089128208000054670526724565994184754244760290009957352237133054978847493874379201323517903544742831961755055100216728931496213920467911320372016970509300894067675803619448926461034580033818298648457643287641768005986812455071220244863874301028965665847375769473444088940776224643189987541019987285740411119351744972645543429351630677554481991322726604779330104110295967482897278840078926508970545806499140537364387530291523697762079684955475417383069988065253583073257131193644210418873929829417895241230927769637328283865111435730810586338426336027745629520975220163350734423915441885289661065494424704587153904031874537230782548938379423349488654701140981815973723582107593419642780372301171156324514852331126462907486017679770773972513376077318418003532168673261819818236071249
  )

-- | sign an intermediate/ leaf certificate by signing with an intermediate/ root CA's key
intermediateCert ::
  (HasCallStack) =>
  -- | name of the owner of the certificate
  String ->
  -- | the public key of the owner
  RSA.PublicKey ->
  -- | name of the signatory (intermediate/ root CA)
  String ->
  -- | the private (signature) key of the signing (intermediate/ root) CA
  RSA.PrivateKey ->
  SignedCert
intermediateCert intermediateCaName pubKey rootCaName rootKey =
  mkSignedCert
    pubKey
    rootKey
    rootCaName
    intermediateCaName

-- | self sign a certificate
selfSignedCert ::
  (HasCallStack) =>
  -- | name of the owner
  String ->
  -- | key material of the owner
  RSAKeyPair ->
  SignedCert
selfSignedCert ownerName (pubKey, privKey) =
  mkSignedCert
    pubKey
    privKey
    ownerName
    ownerName

signMsgWithPrivateKey :: (HasCallStack) => RSA.PrivateKey -> ByteString -> ByteString
signMsgWithPrivateKey privKey = fromRight (error "signing unsuccessful") . PKCS15.sign Nothing (Just SHA256) privKey

-- | create a signed certificate
mkSignedCert ::
  (HasCallStack) =>
  -- | public key of the *owner*
  RSA.PublicKey ->
  -- | private key of *signatory*
  RSA.PrivateKey ->
  -- | name of the issuer
  String ->
  -- | name of the owner
  String ->
  SignedExact Certificate
mkSignedCert pubKey privKey caName ownerName =
  let distinguishedName name =
        DistinguishedName
          [ (getObjectID DnCommonName, fromString $ name),
            (getObjectID DnCountry, fromString "DE")
          ]
   in fst
        $ objectToSignedExact
          (\msg -> (signMsgWithPrivateKey privKey msg, SignatureALG HashSHA256 PubKeyALG_RSA, ()))
          Certificate
            { certVersion = 3,
              certSerial = 1,
              certSignatureAlg = SignatureALG HashSHA256 PubKeyALG_RSA,
              certIssuerDN = distinguishedName caName,
              certValidity = (DateTime {dtDate = Date 2000 January 1, dtTime = midNight}, DateTime {dtDate = Date 2049 January 1, dtTime = midNight}),
              certSubjectDN = distinguishedName ownerName,
              certPubKey = PubKeyRSA pubKey,
              certExtensions = Extensions Nothing
            }
  where
    midNight = TimeOfDay 0 0 0 0
