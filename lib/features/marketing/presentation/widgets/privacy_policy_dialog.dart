import 'package:flutter/material.dart';

import '../marketing_tokens.dart';

void showPrivacyPolicyDialog(BuildContext context) {
  final policy = _PrivacyPolicyCopy.forLocale(Localizations.localeOf(context));

  showDialog<void>(
    context: context,
    builder: (context) {
      final screenSize = MediaQuery.sizeOf(context);
      final maxHeight = screenSize.height * 0.78;

      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 760, maxHeight: maxHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            policy.title,
                            style: const TextStyle(
                              color: LandingColors.ink,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            policy.updated,
                            style: const TextStyle(
                              color: LandingColors.muted,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: policy.closeLabel,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: LandingColors.line),
              Expanded(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 26),
                    child: SelectableText.rich(
                      TextSpan(children: _policySpans(policy.body)),
                      style: const TextStyle(
                        color: LandingColors.muted,
                        fontSize: 14,
                        height: 1.55,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

String privacyPolicyLinkLabel(BuildContext context) {
  return _PrivacyPolicyCopy.forLocale(
    Localizations.localeOf(context),
  ).linkLabel;
}

List<InlineSpan> _policySpans(String body) {
  final spans = <InlineSpan>[];
  final blocks = body.trim().split('\n\n');

  for (var index = 0; index < blocks.length; index += 1) {
    final block = blocks[index].trim();
    final lines = block.split('\n');
    final heading = lines.first.trim();
    final hasHeading = heading.length < 80 && lines.length > 1;
    final rest = lines.skip(1).join('\n');

    if (hasHeading) {
      spans.add(
        TextSpan(
          text: heading,
          style: const TextStyle(
            color: LandingColors.ink,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            height: 1.45,
          ),
        ),
      );
      spans.add(TextSpan(text: '\n$rest'));
    } else {
      spans.add(
        TextSpan(
          text: block,
          style: block.length < 80
              ? const TextStyle(
                  color: LandingColors.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  height: 1.45,
                )
              : null,
        ),
      );
    }

    if (index != blocks.length - 1) {
      spans.add(const TextSpan(text: '\n\n'));
    }
  }

  return spans;
}

class _PrivacyPolicyCopy {
  const _PrivacyPolicyCopy({
    required this.title,
    required this.updated,
    required this.closeLabel,
    required this.linkLabel,
    required this.body,
  });

  final String title;
  final String updated;
  final String closeLabel;
  final String linkLabel;
  final String body;

  static _PrivacyPolicyCopy forLocale(Locale locale) {
    return switch (locale.languageCode) {
      'fi' => _fi,
      'sv' => _sv,
      _ => _en,
    };
  }
}

const _en = _PrivacyPolicyCopy(
  title: 'Privacy Policy',
  updated: 'Last updated: 8 July 2026',
  closeLabel: 'Close',
  linkLabel: 'Privacy Policy',
  body: '''
Data Controller
This Privacy Policy applies to FRSH nearby, which acts as the data controller. The data controller is responsible for the processing of personal data in accordance with the General Data Protection Regulation (EU) 2016/679 ("GDPR") and all other applicable data protection legislation.

Purpose and Legal Basis for the Processing of Personal Data
FRSH nearby processes personal data for the purpose of providing and developing its digital marketplace and ensuring the secure and efficient operation of the service. Personal data may be processed for purposes including, but not limited to, creating and maintaining user accounts, processing orders, facilitating payments, providing customer support, identifying users, ensuring service security, preventing fraud and misuse, and improving the service.
In addition, personal data may be processed for maintaining a waiting list, informing users about the launch of the service, sending newsletters and other service-related communications, and carrying out marketing activities where the data subject has provided consent.
Depending on the circumstances, the processing of personal data is based on the data subject's consent (Article 6(1)(a)), the performance of a contract (Article 6(1)(b)), compliance with a legal obligation to which the data controller is subject (Article 6(1)(c)), or the legitimate interests pursued by the data controller (Article 6(1)(f)).

Legitimate Interests of the Data Controller
Where the processing of personal data is based on the legitimate interests of the data controller, such processing is carried out to ensure the security of the service, prevent fraud and misuse, develop the functionality of the service, analyse the use of the platform, improve the user experience, and maintain customer relationships.
FRSH nearby has assessed that such processing is proportionate and that its legitimate interests do not override the rights and freedoms of the data subjects.

Categories of Personal Data Processed
FRSH nearby may process personal data including, but not limited to, the data subject's name, email address, telephone number, user account credentials, encrypted password, billing and delivery addresses, declared location, GPS location data where the user has provided consent, order and purchase history, payment-related information, customer support communications, technical log data, IP address, device identifiers, browser information, and information relating to the use of the service, such as search history, viewed products, and analytics data.
For sellers or producers using the platform, FRSH nearby may additionally process the business name, Business ID, contact details, product information, and collection or delivery locations.

Recipients of Personal Data
FRSH nearby may disclose personal data to partners and service providers involved in the operation of the service. Such recipients may include payment service providers, cloud hosting providers, analytics service providers, email service providers, information system suppliers, and other technical subcontractors necessary for providing the service.
Personal data may also be disclosed to public authorities where required by applicable legislation or pursuant to a lawful request by a competent authority.
FRSH nearby does not sell users' personal data to third parties.

Transfers of Personal Data Outside the European Union or European Economic Area
Some service providers engaged by FRSH nearby may process personal data outside the European Union or the European Economic Area.
Where such transfers take place, the data controller ensures that the transfer is carried out in accordance with applicable European data protection legislation. Appropriate safeguards may include the European Commission's Standard Contractual Clauses (SCCs), an adequacy decision issued by the European Commission, or another lawful transfer mechanism permitted under the GDPR.

Retention of Personal Data
Personal data is retained only for as long as necessary to fulfil the purposes described in this Privacy Policy or to comply with applicable legal obligations.
Personal data relating to the waiting list is retained until the user withdraws their consent or the waiting list is discontinued. User account information is retained for the duration of the user account. Accounting records are retained for the period required by applicable accounting legislation. Log files and customer support information are retained only for as long as necessary for their intended purposes.

Rights of the Data Subject
The data subject has the right to obtain confirmation as to whether personal data concerning them is being processed and to access such personal data.
The data subject also has the right to request the rectification of inaccurate personal data, the erasure of personal data, the restriction of processing, and to object to processing where permitted by applicable law.
Furthermore, the data subject has the right to receive personal data concerning them in a structured, commonly used, and machine-readable format and to transmit such data to another controller where the processing is based on consent or a contract.
Where the data subject believes that their personal data has been processed in violation of applicable data protection legislation, they have the right to lodge a complaint with the competent supervisory authority.

Withdrawal of Consent
Where the processing of personal data is based on the data subject's consent, the data subject has the right to withdraw that consent at any time by notifying the data controller.
The withdrawal of consent shall not affect the lawfulness of processing carried out before the consent was withdrawn.

Obligation to Provide Personal Data
The provision of certain personal data is necessary for FRSH nearby to provide its services or fulfil its contractual obligations.
Such information may include, for example, an email address, user account credentials, delivery address, and other information necessary to process and fulfil orders.
If the data subject does not provide the required personal data, FRSH nearby may be unable to provide the requested service or complete an order.
The provision of optional personal data, such as a telephone number or an optional message, is voluntary, and failure to provide such information will not prevent the use of the service where such information is not required.

Sources of Personal Data
FRSH nearby primarily collects personal data directly from the data subject when they register for the service, join the waiting list, place orders, or otherwise use the platform.
Where necessary, personal data may also be obtained from publicly available business registers, public authorities, business partners, and payment service providers, to the extent necessary for providing the service or complying with legal obligations.

Automated Decision-Making and Profiling
FRSH nearby may use profiling to provide users with more personalised product recommendations and to improve the overall user experience.
Profiling may be based on factors such as the user's location, previous purchases, search history, or other information relating to the user's interaction with the service.
FRSH nearby does not make decisions based solely on automated processing that produce legal effects concerning the data subject or similarly significant effects.

Protection of Personal Data
FRSH nearby implements appropriate technical and organisational measures to protect personal data against unauthorised processing, accidental loss, alteration, destruction, or other unlawful processing.
Such measures include, among others, encrypted communications, access control mechanisms, secure password hashing, monitoring of log files, data backups, and the continuous development of information security practices.

Amendments to this Privacy Policy
FRSH nearby reserves the right to amend this Privacy Policy where required by changes in legislation, regulatory guidance, or the development of its services.
Users will be informed of any material changes by appropriate means before such changes become effective.
''',
);

const _fi = _PrivacyPolicyCopy(
  title: 'Tietosuojaseloste',
  updated: 'Viimeksi päivitetty: 8.7.2026',
  closeLabel: 'Sulje',
  linkLabel: 'tietosuojaselosteen',
  body: '''
Rekisterinpitäjä
Tämän tietosuojaselosteen mukaisena rekisterinpitäjänä toimii FRSH nearby. Rekisterinpitäjä vastaa henkilötietojen käsittelystä Euroopan unionin yleisen tietosuoja-asetuksen (EU) 2016/679 ("GDPR") sekä muun soveltuvan tietosuojalainsäädännön mukaisesti.

Henkilötietojen käsittelyn tarkoitus ja oikeusperuste
FRSH nearby käsittelee henkilötietoja tarjotakseen ja kehittääkseen digitaalista markkinapaikkaansa sekä mahdollistaakseen palvelun turvallisen ja tehokkaan käytön. Henkilötietoja voidaan käsitellä muun muassa käyttäjätilien luomista ja ylläpitämistä, tilausten käsittelyä, maksujen välittämistä, asiakaspalvelun tarjoamista, käyttäjien tunnistamista, palvelun turvallisuuden varmistamista, väärinkäytösten estämistä sekä palvelun kehittämistä varten.
Lisäksi henkilötietoja voidaan käsitellä odotuslistan ylläpitämiseksi, käyttäjien informoimiseksi palvelun julkaisemisesta, uutiskirjeiden ja muiden palveluun liittyvien tiedotteiden lähettämiseksi sekä markkinointiviestintään silloin, kun rekisteröity on antanut siihen suostumuksensa.
Henkilötietojen käsittely perustuu tilanteesta riippuen rekisteröidyn antamaan suostumukseen (artikla 6(1)(a)), sopimuksen täytäntöönpanoon (artikla 6(1)(b)), rekisterinpitäjän lakisääteisten velvoitteiden noudattamiseen (artikla 6(1)(c)) tai rekisterinpitäjän oikeutettuun etuun (artikla 6(1)(f)).

Rekisterinpitäjän oikeutettu etu
Niiltä osin kuin henkilötietojen käsittely perustuu rekisterinpitäjän oikeutettuun etuun, käsittelyn tarkoituksena on varmistaa palvelun turvallisuus, ehkäistä petoksia ja väärinkäytöksiä, kehittää palvelun ominaisuuksia, analysoida palvelun käyttöä, parantaa käyttäjäkokemusta sekä ylläpitää asiakassuhteita.
FRSH nearby on arvioinut etukäteen, että käsittely on oikeasuhtaista eikä rekisterinpitäjän oikeutettu etu syrjäytä rekisteröityjen oikeuksia tai vapauksia.

Käsiteltävät henkilötiedot
FRSH nearby voi käsitellä rekisteröidystä muun muassa nimeä, sähköpostiosoitetta, puhelinnumeroa, käyttäjätilin tunnistetietoja, salattua salasanaa, toimitus- ja laskutusosoitteita, käyttäjän ilmoittamaa sijaintia, GPS-sijaintitietoja käyttäjän suostumuksella, tilaus- ja ostohistoriaa, maksuihin liittyviä tietoja, asiakaspalveluviestintää, teknisiä lokitietoja, IP-osoitetta, laitteen tunnistetietoja, selaintietoja sekä tietoja palvelun käytöstä, kuten hakuhistoriasta, katsotuista tuotteista ja analytiikkatiedoista.
Palvelussa toimivilta myyjiltä tai tuottajilta voidaan lisäksi käsitellä yrityksen nimeä, Y-tunnusta, yhteystietoja, tuotteisiin liittyviä tietoja sekä nouto- ja toimituspaikkoja.

Henkilötietojen vastaanottajat
FRSH nearby voi luovuttaa henkilötietoja sellaisille yhteistyökumppaneille ja palveluntarjoajille, jotka osallistuvat palvelun toteuttamiseen. Tällaisia vastaanottajia voivat olla esimerkiksi maksupalveluntarjoajat, pilvipalveluiden tarjoajat, analytiikkapalvelut, sähköpostipalvelut, tietojärjestelmätoimittajat sekä muut palvelun tekniset alihankkijat.
Tietoja voidaan luovuttaa myös viranomaisille silloin, kun luovuttaminen perustuu lainsäädäntöön tai viranomaisen lainmukaiseen pyyntöön.
FRSH nearby ei myy käyttäjien henkilötietoja kolmansille osapuolille.

Henkilötietojen siirtäminen Euroopan unionin tai Euroopan talousalueen ulkopuolelle
Osa FRSH nearbyn käyttämistä palveluntarjoajista voi käsitellä henkilötietoja Euroopan unionin tai Euroopan talousalueen ulkopuolella. Tällaisissa tilanteissa rekisterinpitäjä huolehtii siitä, että henkilötietojen siirto toteutetaan Euroopan unionin tietosuojalainsäädännön edellyttämällä tavalla. Käytettäviä suojatoimia voivat olla esimerkiksi Euroopan komission hyväksymät vakiosopimuslausekkeet (Standard Contractual Clauses), Euroopan komission antama riittävyyspäätös tai muu GDPR:n sallima siirtoperuste.

Henkilötietojen säilyttäminen
Henkilötietoja säilytetään ainoastaan niin kauan kuin se on tarpeellista tässä tietosuojaselosteessa kuvattujen käsittelytarkoitusten toteuttamiseksi tai lainsäädännön velvoitteiden täyttämiseksi.
Odotuslistalle liittyviä tietoja säilytetään siihen asti, kunnes käyttäjä peruuttaa suostumuksensa tai odotuslista poistetaan käytöstä. Käyttäjätiliin liittyviä tietoja säilytetään käyttäjätilin voimassaolon ajan. Kirjanpitoon liittyviä tietoja säilytetään kirjanpitolainsäädännön edellyttämän ajan. Lokitietoja sekä asiakaspalvelutietoja säilytetään vain niin kauan kuin niiden käyttötarkoitus edellyttää.

Rekisteröidyn oikeudet
Rekisteröidyllä on oikeus saada tieto siitä, käsitelläänkö häntä koskevia henkilötietoja, sekä oikeus saada pääsy omiin tietoihinsa. Rekisteröidyllä on lisäksi oikeus pyytää virheellisten tietojen oikaisemista, henkilötietojen poistamista, käsittelyn rajoittamista sekä vastustaa henkilötietojen käsittelyä lain sallimissa tilanteissa.
Rekisteröidyllä on myös oikeus saada itseään koskevat henkilötiedot jäsennellyssä ja koneellisesti luettavassa muodossa sekä siirtää ne toiselle rekisterinpitäjälle silloin, kun tietojen käsittely perustuu suostumukseen tai sopimukseen.
Mikäli rekisteröity katsoo, että hänen henkilötietojaan on käsitelty tietosuojalainsäädännön vastaisesti, hänellä on oikeus tehdä valitus toimivaltaiselle valvontaviranomaiselle.

Suostumuksen peruuttaminen
Siltä osin kuin henkilötietojen käsittely perustuu rekisteröidyn antamaan suostumukseen, rekisteröidyllä on oikeus peruuttaa suostumuksensa milloin tahansa ilmoittamalla siitä rekisterinpitäjälle. Suostumuksen peruuttaminen ei vaikuta ennen peruuttamista suoritetun henkilötietojen käsittelyn lainmukaisuuteen.

Henkilötietojen antamisen pakollisuus
Tiettyjen henkilötietojen antaminen on välttämätöntä, jotta FRSH nearby voi tarjota palvelunsa tai täyttää sopimusvelvoitteensa. Tällaisia tietoja voivat olla esimerkiksi sähköpostiosoite, käyttäjätilin tunnistetiedot, toimitusosoite sekä muut tilausten toteuttamisen kannalta välttämättömät tiedot.
Mikäli rekisteröity ei toimita pakollisia henkilötietoja, FRSH nearby ei välttämättä voi tarjota palvelua tai toteuttaa tilausta.
Vapaaehtoisten henkilötietojen, kuten puhelinnumeron tai vapaaehtoisen viestin, antamatta jättäminen ei estä palvelun käyttöä siltä osin kuin kyseisiä tietoja ei tarvita palvelun toteuttamiseksi.

Henkilötietojen lähteet
FRSH nearby kerää henkilötiedot ensisijaisesti rekisteröidyltä itseltään tämän rekisteröityessä palveluun, liittyessä odotuslistalle, tehdessä tilauksia tai muutoin käyttäessään palvelua.
Tarvittaessa henkilötietoja voidaan saada myös julkisista yritysrekistereistä, viranomaislähteistä, yhteistyökumppaneilta sekä maksupalveluntarjoajilta siltä osin kuin se on tarpeen palvelun toteuttamiseksi tai lakisääteisten velvoitteiden täyttämiseksi.

Automaattinen päätöksenteko ja profilointi
FRSH nearby voi käyttää profilointia tarjotakseen käyttäjälle henkilökohtaisempia tuotesuosituksia ja kehittääkseen palvelun käyttökokemusta. Profilointi voi perustua esimerkiksi käyttäjän sijaintiin, aiempiin ostoksiin, hakuhistoriaan tai muihin palvelun käyttöä kuvaaviin tietoihin.
FRSH nearby ei tee sellaisia yksinomaan automaattiseen päätöksentekoon perustuvia päätöksiä, joilla olisi rekisteröityyn kohdistuvia oikeudellisia vaikutuksia tai muita vastaavia merkittäviä vaikutuksia.

Henkilötietojen suojaaminen
FRSH nearby toteuttaa asianmukaiset tekniset ja organisatoriset toimenpiteet henkilötietojen suojaamiseksi luvattomalta käsittelyltä, häviämiseltä, muuttamiselta ja tuhoutumiselta. Käytössä oleviin suojaustoimenpiteisiin kuuluvat muun muassa salatut tietoliikenneyhteydet, käyttöoikeuksien hallinta, salasanojen turvallinen hajautus, lokitietojen seuranta, varmuuskopiointi sekä tietoturvan jatkuva kehittäminen.

Tietosuojaselosteen muuttaminen
FRSH nearby pidättää oikeuden muuttaa tätä tietosuojaselostetta lainsäädännön, viranomaisohjeiden tai palvelun kehittämisen edellyttämällä tavalla. Merkittävistä muutoksista ilmoitetaan käyttäjille asianmukaisella tavalla ennen muutosten voimaantuloa.
''',
);

const _sv = _PrivacyPolicyCopy(
  title: 'Integritetspolicy',
  updated: 'Senast uppdaterad: 8 juli 2026',
  closeLabel: 'Stäng',
  linkLabel: 'integritetspolicyn',
  body: '''
Personuppgiftsansvarig
Denna integritetspolicy gäller FRSH nearby, som är personuppgiftsansvarig. Den personuppgiftsansvariga ansvarar för behandlingen av personuppgifter i enlighet med Europaparlamentets och rådets allmänna dataskyddsförordning (EU) 2016/679 ("GDPR") samt övrig tillämplig dataskyddslagstiftning.

Ändamål och rättslig grund för behandling av personuppgifter
FRSH nearby behandlar personuppgifter för att tillhandahålla och utveckla sin digitala marknadsplats samt säkerställa en säker och effektiv drift av tjänsten. Personuppgifter kan behandlas för ändamål som bland annat omfattar att skapa och upprätthålla användarkonton, behandla beställningar, förmedla betalningar, erbjuda kundsupport, identifiera användare, säkerställa tjänstens säkerhet, förebygga bedrägerier och missbruk samt förbättra tjänsten.
Dessutom kan personuppgifter behandlas för att administrera en väntelista, informera användare om lanseringen av tjänsten, skicka nyhetsbrev och annan tjänsterelaterad kommunikation samt genomföra marknadsföringsåtgärder när den registrerade har lämnat sitt samtycke.
Beroende på omständigheterna grundar sig behandlingen av personuppgifter på den registrerades samtycke (artikel 6.1 a), fullgörande av avtal (artikel 6.1 b), fullgörande av en rättslig förpliktelse som åligger den personuppgiftsansvariga (artikel 6.1 c) eller den personuppgiftsansvarigas berättigade intressen (artikel 6.1 f).

Den personuppgiftsansvarigas berättigade intressen
När behandlingen av personuppgifter grundar sig på den personuppgiftsansvarigas berättigade intressen sker behandlingen för att säkerställa tjänstens säkerhet, förebygga bedrägerier och missbruk, utveckla tjänstens funktioner, analysera användningen av plattformen, förbättra användarupplevelsen och upprätthålla kundrelationer.
FRSH nearby har bedömt att sådan behandling är proportionerlig och att de berättigade intressena inte väger tyngre än de registrerades rättigheter och friheter.

Kategorier av personuppgifter som behandlas
FRSH nearby kan behandla personuppgifter inklusive, men inte begränsat till, den registrerades namn, e-postadress, telefonnummer, användarkontouppgifter, krypterat lösenord, fakturerings- och leveransadresser, angiven plats, GPS-platsdata när användaren har lämnat samtycke, order- och köphistorik, betalningsrelaterade uppgifter, kundsupportkommunikation, tekniska logguppgifter, IP-adress, enhetsidentifierare, webbläsarinformation och uppgifter om användningen av tjänsten, såsom sökhistorik, visade produkter och analysdata.
För säljare eller producenter som använder plattformen kan FRSH nearby dessutom behandla företagsnamn, FO-nummer, kontaktuppgifter, produktinformation samt hämtnings- eller leveransplatser.

Mottagare av personuppgifter
FRSH nearby kan lämna ut personuppgifter till partner och tjänsteleverantörer som deltar i driften av tjänsten. Sådana mottagare kan omfatta betaltjänstleverantörer, molntjänstleverantörer, analystjänster, e-posttjänster, informationssystemleverantörer och andra tekniska underleverantörer som är nödvändiga för att tillhandahålla tjänsten.
Personuppgifter kan också lämnas ut till myndigheter när det krävs enligt tillämplig lagstiftning eller på grundval av en laglig begäran från en behörig myndighet.
FRSH nearby säljer inte användares personuppgifter till tredje parter.

Överföring av personuppgifter utanför Europeiska unionen eller Europeiska ekonomiska samarbetsområdet
Vissa tjänsteleverantörer som FRSH nearby anlitar kan behandla personuppgifter utanför Europeiska unionen eller Europeiska ekonomiska samarbetsområdet.
När sådana överföringar sker säkerställer den personuppgiftsansvariga att överföringen genomförs i enlighet med tillämplig europeisk dataskyddslagstiftning. Lämpliga skyddsåtgärder kan omfatta Europeiska kommissionens standardavtalsklausuler (SCC), ett beslut om adekvat skyddsnivå från Europeiska kommissionen eller någon annan laglig överföringsmekanism som är tillåten enligt GDPR.

Lagring av personuppgifter
Personuppgifter lagras endast så länge som det är nödvändigt för att uppfylla de ändamål som beskrivs i denna integritetspolicy eller för att följa tillämpliga rättsliga skyldigheter.
Personuppgifter som hänför sig till väntelistan lagras tills användaren återkallar sitt samtycke eller väntelistan upphör. Uppgifter om användarkonton lagras under den tid användarkontot är aktivt. Bokföringsmaterial lagras under den tid som krävs enligt tillämplig bokföringslagstiftning. Loggfiler och kundsupportuppgifter lagras endast så länge som det är nödvändigt för deras avsedda ändamål.

Den registrerades rättigheter
Den registrerade har rätt att få bekräftelse på om personuppgifter som rör honom eller henne behandlas och rätt att få tillgång till sådana personuppgifter.
Den registrerade har också rätt att begära rättelse av felaktiga personuppgifter, radering av personuppgifter, begränsning av behandling och att invända mot behandling när detta är tillåtet enligt tillämplig lag.
Den registrerade har dessutom rätt att få personuppgifter som rör honom eller henne i ett strukturerat, allmänt använt och maskinläsbart format och att överföra dessa uppgifter till en annan personuppgiftsansvarig när behandlingen grundar sig på samtycke eller avtal.
Om den registrerade anser att hans eller hennes personuppgifter har behandlats i strid med tillämplig dataskyddslagstiftning har den registrerade rätt att lämna in klagomål till behörig tillsynsmyndighet.

Återkallelse av samtycke
När behandlingen av personuppgifter grundar sig på den registrerades samtycke har den registrerade rätt att när som helst återkalla sitt samtycke genom att meddela den personuppgiftsansvariga.
Återkallelsen av samtycke påverkar inte lagligheten av behandling som utförts innan samtycket återkallades.

Skyldighet att lämna personuppgifter
Tillhandahållande av vissa personuppgifter är nödvändigt för att FRSH nearby ska kunna tillhandahålla sina tjänster eller fullgöra sina avtalsförpliktelser.
Sådana uppgifter kan till exempel omfatta e-postadress, användarkontouppgifter, leveransadress och annan information som är nödvändig för att behandla och fullgöra beställningar.
Om den registrerade inte lämnar de personuppgifter som krävs kan FRSH nearby vara förhindrat att tillhandahålla den begärda tjänsten eller slutföra en beställning.
Tillhandahållande av frivilliga personuppgifter, såsom telefonnummer eller ett frivilligt meddelande, är frivilligt och underlåtenhet att lämna sådana uppgifter hindrar inte användningen av tjänsten när uppgifterna inte krävs.

Källor till personuppgifter
FRSH nearby samlar i första hand in personuppgifter direkt från den registrerade när han eller hon registrerar sig för tjänsten, ansluter sig till väntelistan, gör beställningar eller på annat sätt använder plattformen.
Vid behov kan personuppgifter också erhållas från offentliga företagsregister, myndigheter, affärspartner och betaltjänstleverantörer i den utsträckning det är nödvändigt för att tillhandahålla tjänsten eller följa rättsliga skyldigheter.

Automatiserat beslutsfattande och profilering
FRSH nearby kan använda profilering för att ge användare mer personliga produktrekommendationer och förbättra den övergripande användarupplevelsen.
Profilering kan baseras på faktorer som användarens plats, tidigare köp, sökhistorik eller annan information som rör användarens interaktion med tjänsten.
FRSH nearby fattar inte beslut som enbart grundar sig på automatiserad behandling och som har rättsliga följder för den registrerade eller på liknande sätt påverkar den registrerade i betydande grad.

Skydd av personuppgifter
FRSH nearby vidtar lämpliga tekniska och organisatoriska åtgärder för att skydda personuppgifter mot obehörig behandling, oavsiktlig förlust, ändring, förstöring eller annan olaglig behandling.
Sådana åtgärder omfattar bland annat krypterad kommunikation, åtkomstkontroller, säker lösenordshashning, övervakning av loggfiler, säkerhetskopiering och kontinuerlig utveckling av informationssäkerhetsrutiner.

Ändringar av denna integritetspolicy
FRSH nearby förbehåller sig rätten att ändra denna integritetspolicy när det krävs på grund av ändringar i lagstiftning, myndighetsvägledning eller utvecklingen av tjänsterna.
Användare kommer att informeras om väsentliga ändringar på lämpligt sätt innan sådana ändringar träder i kraft.
''',
);
