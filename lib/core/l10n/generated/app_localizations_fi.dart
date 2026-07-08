// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get appName => 'Fresh Farm';

  @override
  String get splashLoading => 'Valmistellaan tuoreita tuotteita...';

  @override
  String get loginTitle => 'Tervetuloa takaisin';

  @override
  String get loginSubtitle => 'Kirjaudu sisään ostaaksesi tuoretta lähiruokaa.';

  @override
  String get emailLabel => 'Sähköposti';

  @override
  String get passwordLabel => 'Salasana';

  @override
  String get nameLabel => 'Nimi';

  @override
  String get loginButton => 'Kirjaudu sisään';

  @override
  String get registerButton => 'Luo tili';

  @override
  String get createAccountPrompt => 'Uusi Fresh Farmissa?';

  @override
  String get alreadyHaveAccountPrompt => 'Onko sinulla jo tili?';

  @override
  String get registerTitle => 'Luo tilisi';

  @override
  String get registerSubtitle =>
      'Aloita ostaminen läheisiltä maatiloilta ja tuottajilta.';

  @override
  String get customerHomeTitle => 'Markkinapaikka';

  @override
  String get customerHomeGreeting => 'Tuoreita löytöjä lähelläsi';

  @override
  String get customerHomeEmptyTitle => 'Ei tuotteita vielä';

  @override
  String get customerHomeEmptyMessage =>
      'Lähituotteet tulevat näkyviin, kun markkinapaikka yhdistetään.';

  @override
  String get nearbyListingsTitle => 'Tuoretta lähistöltä';

  @override
  String get homeLocationLine => 'Vaasa, Pohjanmaa';

  @override
  String get currentLocationLabel => 'Nykyinen sijaintisi';

  @override
  String get confirmLocationTitle => 'Vahvista sijaintisi';

  @override
  String confirmLocationMessage(Object location) {
    return 'Puhelimesi sijainnin perusteella olet lähellä paikkaa $location.';
  }

  @override
  String get useThisLocationButton => 'Käytä tätä sijaintia';

  @override
  String get enterAnotherLocationButton => 'Syötä toinen sijainti';

  @override
  String get locationSearchTitle => 'Valitse sijainti';

  @override
  String get locationSearchHint => 'Hae kaupunkia tai aluetta';

  @override
  String get noLocationResultsTitle => 'Sijainteja ei löytynyt';

  @override
  String get homeSearchPlaceholder => 'Hae perunaa, hunajaa, tomaatteja...';

  @override
  String get homeHeroTitle => 'Tuoretta lähitiloilta';

  @override
  String get homeHeroSubtitle =>
      'Sesongin tuotteita, munia ja hunajaa lähelläsi.';

  @override
  String get browseTodayPicks => 'Selaa päivän valintoja';

  @override
  String get seeAllButton => 'Näytä kaikki';

  @override
  String get homeJustHarvestedTitle => 'Juuri korjattu';

  @override
  String get homeDealsTodayTitle => 'Hyviä tarjouksia tänään';

  @override
  String get categoryVegetables => 'Vihannekset';

  @override
  String get categoryFruits => 'Hedelmät';

  @override
  String get categoryMeat => 'Liha';

  @override
  String get categoryFish => 'Kala';

  @override
  String get categoryBakery => 'Leipomo';

  @override
  String get categoryDairy => 'Maitotuotteet';

  @override
  String get categoryEggs => 'Kananmunat';

  @override
  String get categoryHoney => 'Hunaja';

  @override
  String get categoryCheese => 'Juusto';

  @override
  String get categoryMilk => 'Maito';

  @override
  String get categoryHerbs => 'Yrtit';

  @override
  String get categoryMushrooms => 'Sienet';

  @override
  String get categoryBerries => 'Marjat';

  @override
  String get categoryFlowers => 'Kukat';

  @override
  String get categoryJuice => 'Mehu';

  @override
  String get categoryPreserves => 'Säilykkeet';

  @override
  String get categoryGrains => 'Viljat';

  @override
  String get categoryReadyMeals => 'Valmisruoat';

  @override
  String get categoryOrganic => 'Luomu';

  @override
  String get notificationsLabel => 'Ilmoitukset';

  @override
  String get cartLabel => 'Ostoskori';

  @override
  String get customerHomeTab => 'Etusivu';

  @override
  String get customerSearchTab => 'Haku';

  @override
  String get messagesTab => 'Viestit';

  @override
  String get dealsTab => 'Tarjoukset';

  @override
  String get profileTab => 'Profiili';

  @override
  String get farmerDashboardTab => 'Hallinta';

  @override
  String get farmerListingsTab => 'Tuotteet';

  @override
  String get farmerReviewsTab => 'Arviot';

  @override
  String get customerSearchTitle => 'Haku';

  @override
  String get customerSearchEmptyMessage => 'Tuotehaku tulee näkyviin tänne.';

  @override
  String get searchListingsHint =>
      'Hae tuotteita, kategorioita tai variantteja';

  @override
  String get noListingsFoundTitle => 'Ilmoituksia ei löytynyt';

  @override
  String get noListingsFoundMessage =>
      'Kokeile toista tuotetta, kategoriaa tai varianttia.';

  @override
  String get listingDetailTitle => 'Ilmoituksen tiedot';

  @override
  String get farmerPublicProfileTitle => 'Tuottajaprofiili';

  @override
  String get kilometersAwayLabel => 'km päässä';

  @override
  String get distanceLabel => 'Etäisyys';

  @override
  String get ratingLabel => 'arvio';

  @override
  String get farmerRatingLabel => 'Tuottajan arvio';

  @override
  String get farmRatingLabel => 'Tilan arvio';

  @override
  String get farmReviewsLabel => 'tila-arviota';

  @override
  String get newFarmLabel => 'Uusi tila';

  @override
  String get viewFarmProfileButton => 'Näytä tilaprofiili';

  @override
  String get verifiedBadgeLabel => 'Vahvistettu tuottaja';

  @override
  String get approximateLocationLabel => 'Suuntaa-antava sijainti';

  @override
  String get chatButton => 'Keskustele';

  @override
  String get exactLocationAfterDealMessage =>
      'Tarkka noutosijainti jaetaan vasta, kun kauppa on vahvistettu.';

  @override
  String get farmerNotFoundMessage =>
      'Tämä tuottajaprofiili ei ole saatavilla.';

  @override
  String get messagesTitle => 'Viestit';

  @override
  String get messagesEmptyMessage => 'Keskustelut tulevat näkyviin tänne.';

  @override
  String get dealsTitle => 'Tarjoukset';

  @override
  String get dealsEmptyMessage => 'Tuoreet tarjoukset tulevat näkyviin tänne.';

  @override
  String get dealsEmptyTitle => 'Ei kauppoja vielä';

  @override
  String get dealStatusNegotiating => 'Neuvottelu';

  @override
  String get dealStatusConfirmed => 'Vahvistettu';

  @override
  String get dealStatusReadyForPickup => 'Valmis noudettavaksi';

  @override
  String get dealStatusCompleted => 'Valmis';

  @override
  String get dealStatusCancelled => 'Peruttu';

  @override
  String get confirmDealButton => 'Vahvista kauppa';

  @override
  String get markCompletedButton => 'Merkitse valmiiksi';

  @override
  String get buyAgainButton => 'Osta uudelleen';

  @override
  String get rateDealButton => 'Arvioi kauppa';

  @override
  String get ratingSoftPromptMessage =>
      'Miten kokemuksesi sujui? Nopea arvio auttaa muita asiakkaita.';

  @override
  String get chatTitle => 'Keskustelu';

  @override
  String get messageLabel => 'Viesti';

  @override
  String get sendButton => 'Lähetä';

  @override
  String get rateDealTitle => 'Arvioi kauppa';

  @override
  String get ratingTagFresh => 'Tuore';

  @override
  String get ratingTagFriendly => 'Ystävällinen';

  @override
  String get ratingTagOnTime => 'Ajoissa';

  @override
  String get ratingTextLabel => 'Vapaa palaute';

  @override
  String get submitRatingButton => 'Lähetä arvio';

  @override
  String get profileTitle => 'Profiili';

  @override
  String get profileGuestName => 'Vieraskäyttäjä';

  @override
  String get profileGuestEmail => 'Sähköpostia ei ole saatavilla';

  @override
  String get switchToFarmerButton => 'Vaihda tuottajaksi';

  @override
  String get switchToCustomerButton => 'Vaihda asiakkaaksi';

  @override
  String get applyAsFarmerButton => 'Hae tuottajaksi';

  @override
  String get applyAsFarmerTitle => 'Hae tuottajaksi';

  @override
  String get applyAsFarmerIntro =>
      'Kerro tuottajaprofiilistasi ennen kuin lähetät sen tarkistettavaksi.';

  @override
  String get profileTypeLabel => 'Profiilityyppi';

  @override
  String get profileTypeIndividual => 'Yksityishenkilö';

  @override
  String get profileTypeFarm => 'Maatila';

  @override
  String get profileTypeCooperative => 'Osuuskunta';

  @override
  String get displayNameLabel => 'Näyttönimi';

  @override
  String get farmNameLabel => 'Tilan nimi';

  @override
  String get phoneLabel => 'Puhelin';

  @override
  String get shortDescriptionLabel => 'Lyhyt kuvaus';

  @override
  String get profilePhotoPlaceholderLabel => 'Profiilikuvan paikka';

  @override
  String get continueButton => 'Jatka';

  @override
  String get farmerLocationTitle => 'Tilan sijainti';

  @override
  String get locationPermissionMessage =>
      'Salli sijainnin käyttö koordinaattien täyttämiseksi tai syötä ne käsin.';

  @override
  String get useCurrentLocationButton => 'Käytä nykyistä sijaintia';

  @override
  String get locationPermissionDeniedMessage =>
      'Sijaintilupa evättiin. Voit syöttää sijainnin käsin.';

  @override
  String get mapPlaceholderTitle => 'Karttaesikatselu';

  @override
  String get mapPlaceholderMessage =>
      'Oikea kartta tulee tähän myöhemmin. Vahvista nyt alla olevat koordinaatit.';

  @override
  String get latitudeLabel => 'Leveysaste';

  @override
  String get longitudeLabel => 'Pituusaste';

  @override
  String get cityLabel => 'Kaupunki';

  @override
  String get countryLabel => 'Maa';

  @override
  String get confirmLocationButton => 'Vahvista sijainti';

  @override
  String get farmerApplicationReviewTitle => 'Tarkista hakemus';

  @override
  String get farmerApplicationReviewIntro =>
      'Tarkista tiedot ennen lähettämistä. Tuottajatila avautuu vasta adminin hyväksynnän jälkeen.';

  @override
  String get submitApplicationButton => 'Lähetä hakemus';

  @override
  String get editLocationButton => 'Muokkaa sijaintia';

  @override
  String get backToCustomerModeButton => 'Takaisin asiakastilaan';

  @override
  String get farmerPendingTitle => 'Tuottajahakemus odottaa';

  @override
  String get farmerPendingMessage => 'Tuottajahakemuksesi on tarkistettavana.';

  @override
  String get farmerRejectedTitle => 'Tuottajahakemus hylätty';

  @override
  String get farmerRejectedMessage =>
      'Tuottajatila ei ole saatavilla tälle tilille.';

  @override
  String get farmerSuspendedTitle => 'Tuottajan käyttö estetty';

  @override
  String get farmerSuspendedMessage =>
      'Tuottajatila ei ole saatavilla tälle tilille.';

  @override
  String get farmerDashboardTitle => 'Tuottajan hallinta';

  @override
  String get farmerDashboardEmptyMessage =>
      'Myynti, tilaukset ja tilan tapahtumat tulevat näkyviin tänne.';

  @override
  String get farmerListingsTitle => 'Tuotteet';

  @override
  String get farmerListingsEmptyTitle => 'Ei ilmoituksia vielä';

  @override
  String get farmerListingsEmptyMessage =>
      'Tilasi tuotteet tulevat näkyviin tänne.';

  @override
  String get createListingTitle => 'Luo ilmoitus';

  @override
  String get editListingTitle => 'Muokkaa ilmoitusta';

  @override
  String get listingPreviewTitle => 'Ilmoituksen esikatselu';

  @override
  String get whatAreYouSelling => 'Mitä myyt?';

  @override
  String get quantityLabel => 'Määrä';

  @override
  String get unitLabel => 'Yksikkö';

  @override
  String get priceLabel => 'Hinta';

  @override
  String get listingDescriptionLabel => 'Kuvaus';

  @override
  String get harvestDateLabel => 'Sadonkorjuupäivä';

  @override
  String get farmingMethodLabel => 'Viljelytapa';

  @override
  String get pickupNotesLabel => 'Nouto-ohjeet';

  @override
  String get deliveryEnabledLabel => 'Toimitus käytössä';

  @override
  String get listingPhotoPlaceholderLabel => 'Kuvan paikka';

  @override
  String get previewListingButton => 'Esikatsele ilmoitus';

  @override
  String get editListingButton => 'Muokkaa ilmoitusta';

  @override
  String get saveChangesButton => 'Tallenna muutokset';

  @override
  String get archiveListingButton => 'Poista/arkistoi ilmoitus';

  @override
  String get listingNotFoundMessage => 'Ilmoitusta ei löytynyt.';

  @override
  String get yesLabel => 'Kyllä';

  @override
  String get noLabel => 'Ei';

  @override
  String get farmerReviewsTitle => 'Arviot';

  @override
  String get farmerReviewsEmptyMessage =>
      'Asiakasarviot tulevat näkyviin tänne.';

  @override
  String get settingsTitle => 'Asetukset';

  @override
  String get languageLabel => 'Kieli';

  @override
  String get englishLanguage => 'Englanti';

  @override
  String get finnishLanguage => 'Suomi';

  @override
  String get swedishLanguage => 'Ruotsi';

  @override
  String get signOutButton => 'Kirjaudu ulos';

  @override
  String get genericErrorTitle => 'Jokin meni pieleen';

  @override
  String get genericErrorMessage => 'Yritä hetken kuluttua uudelleen.';

  @override
  String get retryButton => 'Yritä uudelleen';

  @override
  String get loadingMessage => 'Ladataan...';

  @override
  String get validationRequired => 'Tämä kenttä on pakollinen.';

  @override
  String get validationEmail => 'Syötä kelvollinen sähköpostiosoite.';

  @override
  String get validationPositiveNumber => 'Syötä nollaa suurempi numero.';

  @override
  String get validationNumber => 'Syötä kelvollinen numero.';

  @override
  String get confirmButton => 'Vahvista';

  @override
  String get cancelButton => 'Peruuta';

  @override
  String get confirmArchiveListingTitle => 'Arkistoidaanko ilmoitus?';

  @override
  String get confirmArchiveListingMessage =>
      'Tämä ilmoitus poistetaan aktiivisista ilmoituksistasi.';

  @override
  String get confirmDealTitle => 'Vahvistetaanko kauppa?';

  @override
  String get confirmDealMessage => 'Tämä merkitsee neuvottelun vahvistetuksi.';

  @override
  String get confirmCompletedTitle => 'Merkitäänkö kauppa valmiiksi?';

  @override
  String get confirmCompletedMessage =>
      'Valmiit kaupat siirtyvät ostohistoriaan ja ne voi arvioida.';

  @override
  String get unauthorizedTitle => 'Ei saatavilla';

  @override
  String get verifiedFarmerRequiredMessage =>
      'Vain vahvistetut tuottajat voivat avata tämän näkymän.';

  @override
  String get productSectionTitle => 'Tuote';

  @override
  String get productSectionDescription =>
      'Valitse, mitä asiakkaat näkevät tilasi sivulla.';

  @override
  String get stockAndPriceTitle => 'Varasto ja hinta';

  @override
  String get stockAndPriceDescription =>
      'Kerro saatavilla oleva määrä ja myyntiyksikkö.';

  @override
  String get availableNowLabel => 'Saatavilla nyt';

  @override
  String get productDetailsTitle => 'Tuotetiedot';

  @override
  String get productDetailsDescription =>
      'Valinnaisia tietoja, jotka auttavat asiakasta valinnassa.';

  @override
  String get producedDateOptionalLabel => 'Tuotantopäivä (valinnainen)';

  @override
  String get productionDetailsLabel => 'Tuotantotiedot (valinnainen)';

  @override
  String get bestBeforeOptionalLabel => 'Parasta ennen (valinnainen)';

  @override
  String get storageInstructionsOptionalLabel => 'Säilytysohjeet (valinnainen)';

  @override
  String get addProductButton => 'Lisää tuote';

  @override
  String get productAddedMessage => 'Tuote lisätty.';

  @override
  String get productUpdatedMessage => 'Tuote päivitetty.';

  @override
  String get updateChangedFieldsHint => 'Päivitä vain muuttuneet tiedot.';

  @override
  String get addProductPhotoLabel => 'Lisää tuotekuva';

  @override
  String get sellingUnitLabel => 'Miten myyt tuotteen?';

  @override
  String get kilogramUnit => 'Kilogramma (kg)';

  @override
  String get pieceUnit => 'Kappale';

  @override
  String get bunchUnit => 'Nippu';

  @override
  String get bagUnit => 'Pussi';

  @override
  String get boxUnit => 'Laatikko';

  @override
  String get jarUnit => 'Purkki';

  @override
  String get customerPriceLabel => 'Asiakashinta';

  @override
  String pricePerUnitHelp(Object unit) {
    return 'Asiakas näkee tämän hintana per $unit.';
  }

  @override
  String perUnitLabel(Object unit) {
    return 'per $unit';
  }

  @override
  String get selectDateHint => 'Valitse päivämäärä';

  @override
  String get clearDateTooltip => 'Tyhjennä päivämäärä';

  @override
  String get ordersTitle => 'Tilaukset';

  @override
  String get myOrdersLabel => 'Omat tilaukset';

  @override
  String get totalLabel => 'Yhteensä';

  @override
  String get productsLabel => 'Tuotteet';

  @override
  String get billTitle => 'Laskelma';

  @override
  String get farmPickupLabel => 'Nouto tilalta';

  @override
  String get courierLabel => 'Kuriiri';

  @override
  String get freeLabel => 'Maksuton';

  @override
  String get payAndRequestLabel => 'Maksa ja lähetä pyyntö';

  @override
  String get cartEmptyTitle => 'Ostoskori on tyhjä';

  @override
  String get cartEmptyMessage => 'Lisää tuotteita tilan sivulta.';

  @override
  String get ordersEmptyTitle => 'Ei vielä tilauksia';

  @override
  String get ordersEmptyMessage =>
      'Pyyntösi ja toimituksen eteneminen näkyvät täällä.';

  @override
  String get followLabel => 'Seuraa';

  @override
  String get followingLabel => 'Seurataan';

  @override
  String get addToCartLabel => 'Lisää ostoskoriin';

  @override
  String availableCountLabel(Object count) {
    return '$count saatavilla';
  }

  @override
  String get dashboardGreeting => 'Hyvää huomenta';

  @override
  String get dashboardIntro =>
      'Hallitse tuotteita ja tilauksia sekä jaa tilasi sivu.';

  @override
  String get activeOrdersLabel => 'Aktiiviset tilaukset';

  @override
  String get salesThisMonthLabel => 'Tämän kuun myynti';

  @override
  String allTimeSalesLabel(Object amount) {
    return 'Kaikki yhteensä €$amount';
  }

  @override
  String get noProductsMessage => 'Ei vielä tuotelistauksia.';

  @override
  String get yourFarmPageLabel => 'Tilasi sivu';

  @override
  String get previewLabel => 'Esikatselu';

  @override
  String get copyLinkTooltip => 'Kopioi linkki';

  @override
  String get shareLinkTooltip => 'Jaa linkki';

  @override
  String get farmLinkCopiedMessage => 'Tilan linkki kopioitu';

  @override
  String get manageLabel => 'Hallitse';

  @override
  String get nearbyMapTooltip => 'Lähialueen kartta';

  @override
  String get homeTabLabel => 'Koti';

  @override
  String get insightsTabLabel => 'Tilastot';

  @override
  String get prototypeViewLabel => 'Prototyyppinäkymä';

  @override
  String get farmerModeLabel => 'Tuottaja';

  @override
  String get consumerModeLabel => 'Asiakas';

  @override
  String get orderBookTitle => 'Tilauskirja';

  @override
  String get orderBookSubtitle => 'Pyynnöt, toimitukset ja historia';

  @override
  String get ordersLoadError => 'Tilauksia ei voitu ladata.';

  @override
  String get activeLabel => 'Aktiiviset';

  @override
  String get requestsLabel => 'Pyynnöt';

  @override
  String get historyLabel => 'Historia';

  @override
  String orderNumberLabel(Object number) {
    return 'Tilaus #$number';
  }

  @override
  String productCountLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tuotetta',
      one: '1 tuote',
    );
    return '$_temp0';
  }

  @override
  String get courierCollectionLabel => 'Kuriirin nouto';

  @override
  String get viewOrderLabel => 'Näytä tilaus';

  @override
  String get newRequestStatus => 'Uusi pyyntö';

  @override
  String get requestedStatus => 'Pyydetty';

  @override
  String get acceptedStatus => 'Hyväksytty';

  @override
  String get preparingStatus => 'Valmistellaan';

  @override
  String get readyStatus => 'Valmis';

  @override
  String get deliveredStatus => 'Toimitettu';

  @override
  String get declinedStatus => 'Hylätty';

  @override
  String get noOrdersSectionMessage => 'Tässä osiossa ei ole tilauksia.';

  @override
  String get completedOrdersLabel => 'Valmiit tilaukset';

  @override
  String get averageOrderLabel => 'Keskimääräinen tilaus';

  @override
  String get quantitySoldLabel => 'Myyty määrä';

  @override
  String get salesTrendTitle => 'Myynnin kehitys';

  @override
  String get topProductsTitle => 'Suosituimmat tuotteet';

  @override
  String get fulfilmentTitle => 'Toimitustapa';

  @override
  String get viewSalesStatementLabel => 'Näytä myyntiraportti';

  @override
  String get salesStatementLabel => 'Myyntiraportti';

  @override
  String get previousMonthTooltip => 'Edellinen kuukausi';

  @override
  String get nextMonthTooltip => 'Seuraava kuukausi';

  @override
  String get customRangeHint => 'Valitse mukautettu aikaväli';

  @override
  String get salesPeriodLabel => 'Myyntijakso';

  @override
  String get showReportLabel => 'Näytä raportti';

  @override
  String get totalSalesLabel => 'KOKONAISMYYNTI';

  @override
  String completedOrderCountLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valmista tilausta',
      one: '1 valmis tilaus',
    );
    return '$_temp0';
  }

  @override
  String get noCompletedSalesMessage =>
      'Tällä jaksolla ei ole valmista myyntiä';

  @override
  String get noProductSalesMessage => 'Tällä jaksolla ei ole tuotemyyntiä.';

  @override
  String soldQuantityLabel(Object quantity, Object unit) {
    return 'Myyty $quantity $unit';
  }

  @override
  String get noCompletedOrdersMessage =>
      'Tällä jaksolla ei ole valmiita tilauksia.';

  @override
  String get insightEmptyMessage =>
      'Suorita tilaus nähdäksesi hyödyllisiä myyntitietoja.';

  @override
  String topEarningProductMessage(Object product) {
    return '$product tuotti eniten tällä jaksolla.';
  }

  @override
  String get shareReportTooltip => 'Jaa raportti';

  @override
  String paymentAuthorizedLabel(Object method) {
    return '$method valtuutettu · ei vielä veloitettu';
  }

  @override
  String paymentChargedLabel(Object method) {
    return '$method veloitettu hyväksynnän jälkeen';
  }

  @override
  String get declinedByFarmerLabel => 'Tuottaja hylkäsi pyynnön';

  @override
  String get declinedPaymentReleasedLabel =>
      'Hylätty · maksuvaltuutus vapautettu';

  @override
  String get courierDeliveryLabel => 'Kuriiritoimitus';

  @override
  String get removeTooltip => 'Poista';

  @override
  String onlyQuantityAvailableMessage(Object quantity, Object unit) {
    return 'Saatavilla vain $quantity $unit.';
  }

  @override
  String get fulfilmentQuestion => 'Miten haluat tilauksen?';

  @override
  String get pickupAtFarmLabel => 'Nouda tilalta';

  @override
  String get pickupLocationAfterAcceptance =>
      'Maksuton · tarkka sijainti hyväksynnän jälkeen';

  @override
  String get farmsYouFollowTitle => 'Seuraamasi tilat';

  @override
  String get orderNotFoundMessage => 'Tilausta ei löytynyt.';

  @override
  String get orderDetailsTitle => 'Tilauksen tiedot';

  @override
  String get callLabel => 'Soita';

  @override
  String get textLabel => 'Viesti';

  @override
  String get orderLabel => 'Tilaus';

  @override
  String get statusLabel => 'Tila';

  @override
  String get customerHistoryLabel => 'Asiakashistoria';

  @override
  String get declineLabel => 'Hylkää';

  @override
  String get acceptOrderLabel => 'Hyväksy tilaus';

  @override
  String get acceptLabel => 'Hyväksy';

  @override
  String get acceptRequestLabel => 'Hyväksy pyyntö';

  @override
  String get addOptionalNoteLabel => 'Lisää huomautus (valinnainen)';

  @override
  String get customerPickupLabel => 'Asiakas noutaa';

  @override
  String get customerWillCollectLabel => 'Asiakas noutaa tämän tilauksen';

  @override
  String get courierWillCollectLabel => 'Kuriiri noutaa tämän tilauksen';

  @override
  String get preparePickupMessage =>
      'Valmistele tilaus valittuun noutopisteeseen.';

  @override
  String get prepareCourierMessage =>
      'Valmistele tilaus kuriirin noutoa varten. FreshFarm hoitaa toimituksen.';

  @override
  String customerOrderCountLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tilausta',
      one: '1 tilaus',
    );
    return '$_temp0';
  }

  @override
  String get paymentAuthorizationInfo =>
      'Maksu valtuutetaan nyt ja veloitetaan vasta tuottajan hyväksyttyä tilauksen.';

  @override
  String authorizeWithLabel(Object method) {
    return 'Valtuuta palvelulla $method';
  }

  @override
  String get cardLabel => 'Kortti';

  @override
  String get authorizeCardLabel => 'Valtuuta kortti';

  @override
  String get requestSentLabel => 'Pyyntö lähetetty';

  @override
  String requestSentPaymentMessage(Object method) {
    return '$method valtuutettu. Sinua veloitetaan vasta tuottajan hyväksyttyä tilauksen.';
  }

  @override
  String get doneLabel => 'Valmis';

  @override
  String get loadingFarmMessage => 'Tilaa ladataan...';

  @override
  String get farmOpenErrorTitle => 'Tilaa ei voitu avata';

  @override
  String get farmNotFoundTitle => 'Tilaa ei löytynyt';

  @override
  String get shareFarmTooltip => 'Jaa tila';

  @override
  String addedToCartMessage(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tuotetta lisätty ostoskoriin.',
      one: '1 tuote lisätty ostoskoriin.',
    );
    return '$_temp0';
  }

  @override
  String get viewCartLabel => 'Näytä ostoskori';

  @override
  String get nextHarvestMessage => 'Tila valmistelee seuraavaa satoa.';

  @override
  String get openFarmLabel => 'Avaa tila';

  @override
  String freshPicksLabel(Object count) {
    return '$count tuoretta tuotetta';
  }

  @override
  String get bestBeforeLabel => 'Parasta ennen';

  @override
  String get storageLabel => 'Säilytys';

  @override
  String get farmPickupLocationLabel => 'Tilan noutopaikka';

  @override
  String get allLabel => 'Kaikki';

  @override
  String get editLabel => 'Muokkaa';

  @override
  String availableRatioLabel(Object active, Object total) {
    return '$active/$total saatavilla';
  }

  @override
  String get undoLabel => 'Kumoa';

  @override
  String get quantityToAddLabel => 'Lisättävä määrä';

  @override
  String get addToStockLabel => 'Lisää varastoon';

  @override
  String get farmProfileNotFoundMessage => 'Tilaprofiilia ei löytynyt.';

  @override
  String get editFarmProfileTitle => 'Muokkaa tilaprofiilia';

  @override
  String get changeProfilePhotoLabel => 'Vaihda profiilikuva';

  @override
  String get changeCoverPhotoLabel => 'Vaihda kansikuva';

  @override
  String get shortIntroductionLabel => 'Lyhyt esittely';

  @override
  String get farmIntroductionHint =>
      'Mikä tekee tilastasi ja tuotteistasi erityisiä?';

  @override
  String get customerContactNumberLabel => 'Asiakkaiden puhelinnumero';

  @override
  String get farmPickupDescription =>
      'Asiakkaat voivat noutaa hyväksytyt tilaukset tilaltasi.';

  @override
  String get pickupAtFarmLocationLabel => 'Nouto tilan sijainnista';

  @override
  String get pickupAtFarmLocationDescription =>
      'Käytä vahvistettua tilasi sijaintia noutopisteenä.';

  @override
  String get exactLocationAfterAcceptance =>
      'Tarkka tilan sijainti hyväksynnän jälkeen';

  @override
  String get pickupAddressRequired => 'Syötä noutopisteen osoite.';

  @override
  String get setPickupLocationLabel => 'Aseta noutopaikka';

  @override
  String get pickupLocationHint =>
      'Katuosoite, kaupunki tai tunnistettava paikka';

  @override
  String get pickupNoteLabel => 'Nouto-ohje';

  @override
  String get pickupNoteHint => 'Esimerkiksi: Nouda tilan portilta';

  @override
  String get farmLocationLabel => 'Tilan sijainti';

  @override
  String get confirmedGpsLocationLabel =>
      'Perustuu vahvistettuun GPS-sijaintiisi';

  @override
  String get savePublicProfileLabel => 'Tallenna julkinen profiili';

  @override
  String get customerReviewLabel => 'Asiakasarvio';

  @override
  String get writeReviewLabel => 'Arvioi ja kirjoita arvostelu';

  @override
  String get noReviewYetLabel => 'Ei vielä arviota';

  @override
  String get reviewOptionalHint =>
      'Tähtiarvio ja kirjallinen palaute ovat valinnaisia.';

  @override
  String get notNowLabel => 'Ei nyt';

  @override
  String get reviewSubmittedLabel => 'Arvio lähetetty';

  @override
  String get verifiedCustomerLabel => 'Vahvistettu asiakas';

  @override
  String get landingNavAbout => 'Meistä';

  @override
  String get landingNavInterested => 'Kiinnostuitko?';

  @override
  String get landingNavPrototype => 'Avaa prototyyppi';

  @override
  String get landingHeroKicker => 'Lähiruokaa lautasellesi';

  @override
  String get landingHeroTitle => 'Teemme lähiruuan kuluttamisesta helpompaa';

  @override
  String get landingHeroSubtitle =>
      'FRSH nearby:n avulla tilaat suoraa lähituottajalta tuoretta ja maukasta ruokaa ilman lukuisia välikäsiä.';

  @override
  String get landingHeroPrimaryCta => 'Liity odotuslistaan';

  @override
  String get landingHeroSecondaryCta => 'Kokeile prototyyppiä';

  @override
  String get landingMapBadge => 'Aloitamme Vaasasta, Suomesta';

  @override
  String get landingMapCaption =>
      'Rakennettu lähiruoalle kaikkialla Euroopassa';

  @override
  String get landingAboutTitle => 'Meistä';

  @override
  String get landingAboutBody =>
      'Ajatus FRSH nearby:sta syntyi yksinkertaisesta pohjanmaalaisesta ajatuksesta: paras ruoka tulee läheltä, mutta todellisuudessa ruoka matkustaa aivan liian pitkän matkan. Tämän takia rakennamme sovellusta, joka auttaa  kuluttajia löytämään paikalliset ruuan tuottajat, ja tilaamaan suoraa heiltä. \n\nSovellusta kehittää kolme vastavalmistunutta vaasalaista yliopisto-opiskelijaa  yhdessä paikallisten tuottajien kanssa.';

  @override
  String get landingValue1Title => 'Paikallista ruokaa';

  @override
  String get landingValue1Body =>
      'Löydä tuoretta, lähellä tuotettua ruokaa helposti.';

  @override
  String get landingValue2Title => 'Tuottajalta suoraan kuluttajalle';

  @override
  String get landingValue2Body =>
      'Tuottajat myyvät suoraa kuluttajalle ilman lukuisia välikäsiä, mikä takaa paremman toimeentulon tuottajalle.';

  @override
  String get landingValue3Title => 'Kestävämpi ruuantuotanto';

  @override
  String get landingValue3Body =>
      'Jokainen tilauksesi tukee oman alueesi elinvoimaa ja vahvistaa paikallista ruuantuotantoa.';

  @override
  String get landingInterestedTitle => 'Kiinnostuitko?';

  @override
  String get landingInterestedSubtitle =>
      'Liity odotuslistalle saadaksesi lisäinfoa, kun FRSH nearby -sovellus julkaistaan!';

  @override
  String get landingFormRoleLabel => 'Olen';

  @override
  String get landingFormMessageLabel =>
      'Mitä lähellä tuotettua haluaisit ostaa/myydä?';

  @override
  String get landingRoleConsumer => 'Kuluttaja';

  @override
  String get landingRoleFarmer => 'Tuottaja';

  @override
  String get landingRoleRestaurant => 'Ravintola/Kauppa';

  @override
  String get landingRoleSupporter => 'Lähiruoan ystävä';

  @override
  String get landingFormSubmit => 'Liity odotuslistalle!';

  @override
  String get landingFormConsentLabel =>
      'Hyväksyn, että FRSH nearby Oy:llä on oikeus kerätä, tallentaa, säilyttää ja muutoin käsitellä tällä lomakkeella antamiani henkilötietoja odotuslistan ylläpitämiseksi, yhteydenottoa varten FRSH nearby -sovelluksen julkaisun yhteydessä sekä siihen liittyvien tiedotteiden ja päivitysten toimittamiseksi tietosuojaselosteen mukaisesti.';

  @override
  String get landingFormThanks => 'Kiitos! Olet nyt ennakkokäyttäjälistalla.';

  @override
  String get landingFooterTagline => 'Löydä lähituottajasi';

  @override
  String get landingFooterCopyright => '© 2026 FRSH nearby';

  @override
  String get prototypeChooserTitle => 'Avaa FRSH Nearby -prototyyppi';

  @override
  String get prototypeChooserSubtitle =>
      'Valitse puoli, jota haluat kokeilla ensin.';

  @override
  String get prototypeFarmerHint =>
      'Kojelauta, tilaukset, ilmoitukset, tilastot';

  @override
  String get prototypeConsumerHint => 'Lähiruoka, tilaprofiilit, diilit, chat';

  @override
  String get landingFormPhoneLabel => 'Puhelinnumero';
}
