// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'OX Werknemer';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Wachtwoord';

  @override
  String get errorFieldRequired => 'Verplicht veld';

  @override
  String get errorInvalidEmail => 'Ongeldig e-mailadres';

  @override
  String get errorPasswordShort => 'Minimaal 6 tekens';

  @override
  String get errorPasswordMismatch => 'Wachtwoorden komen niet overeen';

  @override
  String commonErrorWithMessage(String message) {
    return 'Fout: $message';
  }

  @override
  String get commonCancel => 'Annuleren';

  @override
  String get commonConfirm => 'Bevestigen';

  @override
  String get loginSubtitle => 'Inloggen op je werknemersaccount';

  @override
  String get loginButton => 'Inloggen';

  @override
  String get loginForgotPassword => 'Wachtwoord vergeten?';

  @override
  String get loginOrContinueWith => 'of ga verder met';

  @override
  String get loginNoAccount => 'Geen account? ';

  @override
  String get loginRegisterLink => 'Registreer je';

  @override
  String get registerTitle => 'Werknemersaccount aanmaken';

  @override
  String get registerNameLabel => 'Volledige naam';

  @override
  String get registerConfirmPasswordLabel => 'Wachtwoord bevestigen';

  @override
  String get registerButton => 'Account aanmaken';

  @override
  String get registerHasAccount => 'Ik heb al een account';

  @override
  String get registerWorkerBadge => 'Werknemersaccount';

  @override
  String get forgotPasswordTitle => 'Wachtwoord vergeten?';

  @override
  String get forgotPasswordSubtitle =>
      'Voer je e-mailadres in en we sturen je een link om je wachtwoord opnieuw in te stellen.';

  @override
  String get forgotPasswordSendButton => 'Resetlink versturen';

  @override
  String get forgotPasswordSuccessTitle => 'E-mail verzonden!';

  @override
  String forgotPasswordSuccessBody(String email) {
    return 'Controleer je inbox op $email en klik op de link om je wachtwoord opnieuw in te stellen.';
  }

  @override
  String get forgotPasswordBackToLogin => 'Terug naar inloggen';

  @override
  String get resetPasswordTitle => 'Nieuw wachtwoord';

  @override
  String get resetPasswordSubtitle =>
      'Voer je nieuwe wachtwoord in en bevestig het.';

  @override
  String get resetPasswordNewLabel => 'Nieuw wachtwoord';

  @override
  String get resetPasswordConfirmLabel => 'Nieuw wachtwoord bevestigen';

  @override
  String get resetPasswordButton => 'Wachtwoord instellen';

  @override
  String get resetPasswordSuccess => 'Wachtwoord succesvol opnieuw ingesteld!';

  @override
  String get onboardingSkip => 'Overslaan';

  @override
  String get onboardingContinue => 'Doorgaan';

  @override
  String get onboardingStart => 'Aan de slag';

  @override
  String get onboardingPage1Title => 'Kansen voor jou';

  @override
  String get onboardingPage1Subtitle =>
      'Bekijk projecten en uitnodigingen die passen bij jouw vaardigheden en beschikbaarheid.';

  @override
  String get onboardingPage2Title => 'Voer uit met duidelijkheid';

  @override
  String get onboardingPage2Subtitle =>
      'Volg fasen, upload bewijs en houd de klant op de hoogte.';

  @override
  String get onboardingPage3Title => 'Veilig betaald worden';

  @override
  String get onboardingPage3Subtitle =>
      'Betalingen via Stripe Connect na goedkeuring van elke fase door de klant.';

  @override
  String get navJobs => 'Jobs';

  @override
  String get navExecution => 'In uitvoering';

  @override
  String get navNotifications => 'Meldingen';

  @override
  String get navPayments => 'Betalingen';

  @override
  String get navProfile => 'Profiel';

  @override
  String get pushChannelName => 'OX Meldingen';

  @override
  String get pushChannelDescription => 'Meldingen van OX Field Services';

  @override
  String get workerStatusAvailable => 'Beschikbaar';

  @override
  String get workerStatusUnavailable => 'Niet beschikbaar';

  @override
  String workerRating(String rating) {
    return 'Beoordeling: $rating';
  }

  @override
  String get defaultWorkerName => 'Werknemer';

  @override
  String get jobsActiveSection => 'MIJN ACTIEVE JOBS';

  @override
  String get jobsAvailableSection => 'BESCHIKBARE JOBS VOOR JOU';

  @override
  String get jobsNoActive => 'Geen actieve jobs';

  @override
  String get jobsNoActiveSubtitle =>
      'Accepteer een beschikbare job om te beginnen.';

  @override
  String get jobsNoAvailable => 'Je werk verschijnt hier';

  @override
  String get jobsNoAvailableSubtitle =>
      'Nieuwe passende opdrachten voor jouw profiel verschijnen hier zodra ze beschikbaar zijn.';

  @override
  String get jobsLoadError => 'Fout bij laden van jobs';

  @override
  String get jobCompatibility => 'Match: ';

  @override
  String get jobContinueExecution => 'Uitvoering voortzetten';

  @override
  String get jobViewDetails => 'Details bekijken';

  @override
  String phaseOrderLabel(int order) {
    return 'Fase $order';
  }

  @override
  String phaseOrderAndName(int order, String name) {
    return 'Fase $order — $name';
  }

  @override
  String get jobDetailTitle => 'Jobdetails';

  @override
  String get jobInfoSection => 'INFORMATIE';

  @override
  String get jobPhasesPaymentsSection => 'FASEN & BETALINGEN';

  @override
  String get jobInfoDeadline => 'Deadline';

  @override
  String get jobInfoLocation => 'Locatie';

  @override
  String get jobInfoDescription => 'Beschrijving';

  @override
  String get jobTotal => 'Totaal';

  @override
  String get jobAcceptedSuccess => 'Job succesvol geaccepteerd!';

  @override
  String get jobsNoContractError =>
      'Geen contract gevonden voor dit project. Wacht op toewijzing door de beheerder.';

  @override
  String get jobAcceptButton => 'Job accepteren';

  @override
  String get jobDeclineButton => 'Weigeren';

  @override
  String get jobAwaitingPaymentMsg =>
      'Contract getekend. Wachten tot de klant de betaling uitvoert om de uitvoering te starten.';

  @override
  String get jobAwaitingStartMsg =>
      'Betaling bevestigd! Het project wordt binnenkort geactiveerd en fasen verschijnen in het tabblad \"In uitvoering\".';

  @override
  String get jobAcceptDialogTitle => 'Job accepteren';

  @override
  String get jobAcceptDialogContent =>
      'Door te accepteren, verbind je je ertoe alle fasen uit te voeren zoals overeengekomen. Wil je doorgaan?';

  @override
  String get dialogAccept => 'Accepteren';

  @override
  String get statusInExecution => 'In uitvoering';

  @override
  String get statusActiveEscrow => 'Actieve escrow';

  @override
  String get statusContractSigned => 'Contract getekend';

  @override
  String get executionTitle => 'In uitvoering';

  @override
  String get executionNoPhases => 'Geen fasen in uitvoering';

  @override
  String get executionNoPhasesSubtitle =>
      'Wanneer je een job accepteert en de klant betaalt, verschijnen je fasen hier om uit te voeren.';

  @override
  String executionLoadError(String error) {
    return 'Fout bij laden van fasen: $error';
  }

  @override
  String get phaseExecutionTitle => 'Fase-uitvoering';

  @override
  String get phaseChecklist => 'FASE-CHECKLIST';

  @override
  String get phaseChecklistItemMaterials => 'Materialen voorbereid';

  @override
  String get phaseChecklistItemPpe => 'PBM gebruikt';

  @override
  String get phaseChecklistItemWorkStarted => 'Werk gestart';

  @override
  String get phaseChecklistItemSafety => 'Veiligheidscheck';

  @override
  String get phaseChecklistItemPhotoDoc => 'Fotodocumentatie';

  @override
  String get phaseEvidences => 'BEWIJSMATERIAAL';

  @override
  String phaseEvidenceCount(int count) {
    return '$count/3 verplicht';
  }

  @override
  String phaseAmountLabel(String amount) {
    return '€ $amount in deze fase';
  }

  @override
  String get phaseReadyMsg =>
      'Klaar om te beginnen? Start de fase om het uploaden van bewijsmateriaal te ontgrendelen.';

  @override
  String get phaseStartButton => 'Fase starten';

  @override
  String get phaseErrorNotFound => 'Fase niet gevonden.';

  @override
  String get phaseErrorNeedEvidenceBeforeSubmit =>
      'Upload minstens één bewijs voordat je indient voor beoordeling.';

  @override
  String get phaseAddMedia => 'Foto / video toevoegen';

  @override
  String get phaseSubmitButton => 'Indienen voor beoordeling';

  @override
  String get phaseAddMinPhotos =>
      'Voeg minimaal 3 foto\'s/video\'s toe om in te dienen';

  @override
  String get phaseAwaitingReview =>
      'Wachten tot de klant de fase beoordeelt en valideert.';

  @override
  String get phaseSubmittedSuccess => 'Fase ingediend voor klantbeoordeling!';

  @override
  String get phaseStartedSuccess =>
      'Fase gestart! Je kunt nu bewijsmateriaal uploaden.';

  @override
  String get phaseSubmitDialogTitle => 'Indienen voor beoordeling';

  @override
  String get phaseSubmitDialogContent =>
      'De klant wordt op de hoogte gesteld om het ingediende bewijsmateriaal te beoordelen. Na goedkeuring wordt de betaling voor deze fase aan jou vrijgegeven.';

  @override
  String get dialogSend => 'Indienen';

  @override
  String get phaseNoActiveTitle => 'Geen fasen in uitvoering';

  @override
  String get phaseNoActiveSubtitle =>
      'Accepteer een beschikbare job om je fasen uit te voeren.';

  @override
  String get phaseStatusInProgress => 'In uitvoering';

  @override
  String get phaseStatusUnderReview => 'In beoordeling';

  @override
  String get phaseStatusEvidenceUploaded => 'Bewijs geüpload';

  @override
  String get phaseStatusValidated => 'Gevalideerd';

  @override
  String get phaseStatusRejected => 'Afgewezen';

  @override
  String get phaseStatusPending => 'In behandeling';

  @override
  String get phaseStatusAwaitingStart => 'Wachten op start';

  @override
  String uploadTitle(int count) {
    return 'Bewijsmateriaal ($count/3)';
  }

  @override
  String get uploadNoPhoto => 'Geen foto geselecteerd';

  @override
  String get uploadMinPhotos => 'Minimaal 3 foto\'s om de fase in te dienen';

  @override
  String get uploadTakePhoto => 'Foto maken';

  @override
  String get uploadFromGallery => 'Uit galerij';

  @override
  String uploadConfirmButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bevestigen ($count bestanden)',
      one: 'Bevestigen (1 bestand)',
    );
    return '$_temp0';
  }

  @override
  String get uploadUploading => 'Uploaden...';

  @override
  String get uploadSuccess => 'Bewijsmateriaal succesvol geüpload!';

  @override
  String uploadError(String error) {
    return 'Uploadfout: $error';
  }

  @override
  String get notificationsTitle => 'Meldingen';

  @override
  String get notificationsMarkAllRead => 'Alles als gelezen markeren';

  @override
  String get notificationsEmpty => 'Geen meldingen';

  @override
  String get notificationsLoadError => 'Fout bij laden';

  @override
  String notificationsLoadErrorWithDetail(String error) {
    return 'Fout bij laden: $error';
  }

  @override
  String get paymentsTitle => 'Mijn betalingen';

  @override
  String get paymentsTotalReceived => 'TOTAAL ONTVANGEN';

  @override
  String get paymentsReleasedLabel => 'Vrijgegeven betalingen';

  @override
  String get paymentsLoadError => 'Fout bij laden van betalingen';

  @override
  String get paymentsEmpty => 'Nog geen betalingen';

  @override
  String get paymentsEmptySubtitle =>
      'Betalingen verschijnen hier naarmate je fasen worden gevalideerd.';

  @override
  String get paymentsConnectSetupMessage =>
      'Stel je account in om uitbetalingen te ontvangen. Zelfde beveiligde Stripe-flow als in je profiel.';

  @override
  String get paymentStatusReleased => 'Vrijgegeven';

  @override
  String paymentStatusReleasedOn(String date) {
    return 'Vrijgegeven op $date';
  }

  @override
  String get paymentStatusPending => 'Wachten op vrijgave';

  @override
  String get paymentDefaultTitle => 'Betaling';

  @override
  String get profileTitle => 'Mijn profiel';

  @override
  String get profileLogoutTitle => 'Uitloggen';

  @override
  String get profileLogoutConfirm => 'Wil je uitloggen?';

  @override
  String get profileStatusSection => 'STATUS';

  @override
  String get profileSkillsSection => 'VAARDIGHEDEN';

  @override
  String get profileAvailabilityLabel => 'Beschikbaarheid';

  @override
  String get profileShelterLabel => 'Shelter-certificering';

  @override
  String get profileCertifiedValue => 'Gecertificeerd';

  @override
  String get profileNotCertifiedValue => 'Niet gecertificeerd';

  @override
  String get profileSkillsHint => 'Tik op vaardigheden om ze te selecteren';

  @override
  String get profileMarkUnavailable => 'Markeren als niet beschikbaar';

  @override
  String get profileMarkAvailable => 'Markeren als beschikbaar';

  @override
  String profileSignoutError(String error) {
    return 'Uitlogfout: $error';
  }

  @override
  String get profilePhotoTitle => 'Profielfoto';

  @override
  String get profilePhotoChangeHint => 'Tik om te wijzigen';

  @override
  String get profilePhotoGallery => 'Galerij';

  @override
  String get profilePhotoCamera => 'Camera';

  @override
  String get profilePhotoRemove => 'Foto verwijderen';

  @override
  String get profilePhotoPromptTitle => 'Voeg een profielfoto toe';

  @override
  String get profilePhotoPromptBody =>
      'Zo personaliseer je je account. Je kunt dit later in je profiel wijzigen.';

  @override
  String get profilePhotoPromptLater => 'Nu niet';

  @override
  String get profilePhotoUploadError =>
      'Foto uploaden mislukt. Probeer opnieuw.';

  @override
  String get profilePhotoSizeError => 'Afbeelding is te groot (max. 5 MB).';

  @override
  String get profilePhotoTypeError => 'Gebruik JPEG of PNG.';

  @override
  String get profilePhotoRemoveMessage =>
      'De foto wordt van je account verwijderd.';

  @override
  String get bankSection => 'BETAALREKENING';

  @override
  String get bankNotStartedDesc =>
      'Stel je Stripe-account in om betalingen voor voltooide jobs te ontvangen.';

  @override
  String get bankConfigureButton => 'Nu instellen';

  @override
  String get bankPendingDesc =>
      'Je account is aangemaakt, maar er is nog wat informatie nodig om te beginnen met ontvangen:';

  @override
  String get bankContinueButton => 'Registratie voortzetten';

  @override
  String get bankActivePaymentInfo =>
      'Betalingen worden binnen 2 werkdagen gestort nadat elke fase door de klant is gevalideerd.';

  @override
  String get bankUpdateButton => 'Bankgegevens bijwerken';

  @override
  String get bankRestrictedDefault =>
      'Er zijn openstaande problemen die je uitbetalingen blokkeren.';

  @override
  String get bankResolveButton => 'Problemen oplossen';

  @override
  String get bankStatusActive => 'Actief';

  @override
  String get bankStatusPending => 'In behandeling';

  @override
  String get bankStatusRestricted => 'Geblokkeerd';

  @override
  String get bankStatusNotConfigured => 'Niet geconfigureerd';

  @override
  String get bankAccountDefault => 'Bankrekening';

  @override
  String get bankOnboardingError => 'Kon de onboarding-link niet openen';

  @override
  String get bankRetryButton => 'Opnieuw proberen';

  @override
  String bankStatusError(String error) {
    return 'Fout bij controleren status: $error';
  }

  @override
  String get bankReqFullName => 'Volledige naam';

  @override
  String get bankReqBirthDate => 'Geboortedatum';

  @override
  String get bankReqIdDocument => 'Identiteitsbewijs';

  @override
  String get bankReqAddress => 'Thuisadres';

  @override
  String get bankReqBankData => 'Bankgegevens (IBAN of rekening)';

  @override
  String get bankReqStripeTerms => 'Stripe-voorwaarden accepteren';

  @override
  String get bankReqProfile => 'Professioneel profiel';

  @override
  String get bankStripeDisabledPastDue =>
      'Er ontbreekt informatie of data is verlopen. Rond je gegevens in Stripe af om weer uitbetaald te worden.';

  @override
  String get bankStripeDisabledPendingVerification =>
      'Stripe controleert je gegevens. Kom later terug of vul aan wat ze vragen.';

  @override
  String get bankStripeDisabledUnderReview =>
      'Je account wordt beoordeeld. Wacht of vul aan als Stripe dat vraagt.';

  @override
  String get bankStripeDisabledRejected =>
      'Stripe heeft deze betaalrekening niet geaccepteerd. Neem contact op met OX-support.';

  @override
  String get bankReqProductDescription =>
      'Omschrijving van je activiteit of diensten';

  @override
  String get bankReqBusinessType => 'Type bedrijf (zzp of rechtspersoon)';

  @override
  String get bankReqRepresentativeDetails =>
      'Gegevens wettelijk vertegenwoordiger';

  @override
  String get bankReqRepresentativeAddress => 'Adres van de vertegenwoordiger';

  @override
  String get bankReqCompanyInfo => 'Bedrijfsgegevens';

  @override
  String get bankReqContactEmailPhone => 'E-mail of telefoon voor contact';

  @override
  String get bankReqWebsiteOrSocial => 'Website of online aanwezigheid';

  @override
  String get bankReqAdditionalVerification =>
      'Extra document of verificatie door Stripe';

  @override
  String get bankReqFallbackStripeForm =>
      'Ontbrekende gegevens — vul ze in het beveiligde Stripe-formulier in';

  @override
  String get bankConnectBrowserHint =>
      'Opent Stripe in de browser. Kom daarna terug naar deze app om de status te verversen.';

  @override
  String get stripeConnectBannerMessage =>
      'Betaalaccount onvolledig. Voltooi in je profiel om overschrijvingen te ontvangen.';

  @override
  String get stripeConnectBannerCta => 'Naar profiel';

  @override
  String get notifUserWelcomeTitle => 'Welkom bij OX Field Service';

  @override
  String get notifUserWelcomeBody => 'Je account is succesvol aangemaakt.';

  @override
  String get notifWorkerInvitedTitle => 'Projectuitnodiging';

  @override
  String notifWorkerInvitedBody(String projectTitle) {
    return 'Je bent geselecteerd voor het project \"$projectTitle\".';
  }

  @override
  String get notifWorkerAssignedTitle => 'Toewijzing bevestigd';

  @override
  String notifWorkerAssignedBody(String projectTitle) {
    return 'Je bent toegewezen aan het project \"$projectTitle\".';
  }

  @override
  String get notifContractCreatedTitle => 'Nieuw contract';

  @override
  String notifContractCreatedBody(String projectTitle) {
    return 'Je bent toegewezen aan het project \"$projectTitle\". Onderteken het contract om door te gaan.';
  }

  @override
  String get notifContractSignedWorkerTitle => 'Contract getekend';

  @override
  String notifContractSignedWorkerBody(String projectTitle) {
    return 'Je hebt het contract voor project \"$projectTitle\" getekend.';
  }

  @override
  String get notifEscrowHeldTitle => 'Betaling in escrow';

  @override
  String notifEscrowHeldBody(String projectTitle) {
    return 'De waarde van project \"$projectTitle\" is in escrow gehouden.';
  }

  @override
  String get notifProjectActivatedTitle => 'Project actief';

  @override
  String notifProjectActivatedBody(String projectTitle) {
    return 'Het project \"$projectTitle\" is bezig.';
  }

  @override
  String get notifPhaseStartedTitle => 'Fase gestart';

  @override
  String notifPhaseStartedBody(String phaseName, String projectTitle) {
    return 'Fase \"$phaseName\" van project \"$projectTitle\" is gestart.';
  }

  @override
  String get notifPhaseValidatedWorkerTitle => 'Fase goedgekeurd';

  @override
  String notifPhaseValidatedWorkerBody(String phaseName, String projectTitle) {
    return 'Je fase \"$phaseName\" is goedgekeurd in \"$projectTitle\".';
  }

  @override
  String get notifPhaseRejectedWorkerTitle => 'Fase afgewezen';

  @override
  String notifPhaseRejectedWorkerBody(String phaseName, String projectTitle) {
    return 'Fase \"$phaseName\" van \"$projectTitle\" is afgewezen en heeft aanpassingen nodig.';
  }

  @override
  String get notifPaymentTransferredWorkerTitle => 'Overboeking ontvangen';

  @override
  String notifPaymentTransferredWorkerBody(String amount, String projectTitle) {
    return '€ $amount is bijgeschreven voor project \"$projectTitle\".';
  }

  @override
  String get notifEscrowReleasedWorkerTitle => 'Betaling vrijgegeven';

  @override
  String notifEscrowReleasedWorkerBody(String projectTitle) {
    return 'De betaling voor project \"$projectTitle\" is vrijgegeven.';
  }

  @override
  String get notifProjectClosedTitle => 'Project afgesloten';

  @override
  String notifProjectClosedBody(String projectTitle) {
    return 'Het project \"$projectTitle\" is afgesloten.';
  }

  @override
  String get notifWorkerRatedTitle => 'Nieuwe beoordeling';

  @override
  String notifWorkerRatedBody(String score, String projectTitle) {
    return 'Je hebt een beoordeling van $score ontvangen voor project \"$projectTitle\".';
  }

  @override
  String get notifProjectCreatedClientTitle => 'Project aangemaakt';

  @override
  String notifProjectCreatedClientBody(String projectTitle) {
    return 'Het project \"$projectTitle\" is aangemaakt.';
  }

  @override
  String get notifProjectCreatedAdminTitle => 'Nieuw project';

  @override
  String notifProjectCreatedAdminBody(String projectTitle) {
    return 'De klant heeft het project \"$projectTitle\" aangemaakt.';
  }

  @override
  String get notifProjectInValidationTitle => 'Project in validatie';

  @override
  String notifProjectInValidationBody(String projectTitle) {
    return '\"$projectTitle\" is ter validatie verstuurd.';
  }

  @override
  String get notifProjectMatchedTitle => 'Project bijgewerkt';

  @override
  String notifProjectMatchedBody(String projectTitle) {
    return 'Het project \"$projectTitle\" is verder gegaan in het proces.';
  }

  @override
  String get notifProjectClosingTitle => 'Project wordt afgesloten';

  @override
  String notifProjectClosingBody(String projectTitle) {
    return 'Alle fases van \"$projectTitle\" zijn gevalideerd. Afsluiting is bezig.';
  }

  @override
  String get notifProjectRejectedTitle => 'Project afgewezen';

  @override
  String notifProjectRejectedBody(String projectTitle) {
    return 'Het project \"$projectTitle\" is afgewezen.';
  }

  @override
  String get notifProjectUpdatedGenericTitle => 'Project bijgewerkt';

  @override
  String notifProjectUpdatedGenericBody(String projectTitle) {
    return 'De status van project \"$projectTitle\" is gewijzigd.';
  }

  @override
  String get notifPhaseEvidenceUploadedClientTitle => 'Nieuw bewijs';

  @override
  String notifPhaseEvidenceUploadedClientBody(
      String phaseName, String projectTitle) {
    return 'De werknemer heeft bewijs ingediend voor fase \"$phaseName\" bij \"$projectTitle\".';
  }

  @override
  String get notifPhaseEvidenceUploadedAdminTitle => 'Bewijs ontvangen';

  @override
  String notifPhaseEvidenceUploadedAdminBody(
      String projectTitle, String phaseName) {
    return 'Project \"$projectTitle\" — fase \"$phaseName\".';
  }

  @override
  String get notifPhaseUnderReviewClientTitle => 'Fase in beoordeling';

  @override
  String notifPhaseUnderReviewClientBody(
      String phaseName, String projectTitle) {
    return 'Fase \"$phaseName\" van \"$projectTitle\" wacht op jouw validatie.';
  }

  @override
  String get notifPhaseValidatedClientTitle => 'Fase gevalideerd';

  @override
  String notifPhaseValidatedClientBody(String phaseName, String projectTitle) {
    return 'Fase \"$phaseName\" van project \"$projectTitle\" is gevalideerd.';
  }

  @override
  String get notifPhaseRejectedClientTitle => 'Afwijzing geregistreerd';

  @override
  String notifPhaseRejectedClientBody(String phaseName, String projectTitle) {
    return 'Fase \"$phaseName\" is als afgewezen gemarkeerd bij project \"$projectTitle\".';
  }

  @override
  String get notifContractSignedClientTitle => 'Contract getekend';

  @override
  String notifContractSignedClientBody(String projectTitle) {
    return 'Het contract voor project \"$projectTitle\" is door de werknemer getekend.';
  }

  @override
  String get notifContractSignedAdminTitle => 'Contract getekend';

  @override
  String notifContractSignedAdminBody(String projectTitle) {
    return 'Project \"$projectTitle\" — contract getekend.';
  }

  @override
  String get notifEscrowReleasedClientTitle => 'Betaling voltooid';

  @override
  String notifEscrowReleasedClientBody(String projectTitle) {
    return 'De betaling voor project \"$projectTitle\" is succesvol overgemaakt.';
  }

  @override
  String get notifPaymentTransferredAdminTitle => 'Betaling overgemaakt';

  @override
  String notifPaymentTransferredAdminBody(String projectTitle) {
    return 'Project \"$projectTitle\" — overschrijving naar werknemer geregistreerd.';
  }

  @override
  String get notifPaymentFailedTitle => 'Betaling mislukt';

  @override
  String notifPaymentFailedBody(String projectTitle) {
    return 'Betaling voor project \"$projectTitle\" kon niet worden voltooid.';
  }

  @override
  String get notifPaymentFailedAdminTitle => 'Betaling mislukt';

  @override
  String notifPaymentFailedAdminBody(String projectTitle) {
    return 'Project \"$projectTitle\" — betaling mislukt.';
  }
}
