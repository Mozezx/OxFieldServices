// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appName => 'OX Services';

  @override
  String get loginTitle => 'Welkom terug';

  @override
  String get loginSubtitle => 'Log in op je OX-account';

  @override
  String get loginEmailLabel => 'E-mail';

  @override
  String get loginPasswordLabel => 'Wachtwoord';

  @override
  String get loginButton => 'Inloggen';

  @override
  String get loginGoogleButton => 'Inloggen met Google';

  @override
  String get loginNoAccount => 'Geen account? Registreer je';

  @override
  String get loginForgotPassword => 'Wachtwoord vergeten?';

  @override
  String get loginOrContinueWith => 'of ga verder met';

  @override
  String get registerTitle => 'Account aanmaken';

  @override
  String get registerNameLabel => 'Volledige naam';

  @override
  String get registerConfirmPasswordLabel => 'Wachtwoord bevestigen';

  @override
  String get registerButton => 'Account aanmaken';

  @override
  String get registerHasAccount => 'Ik heb al een account';

  @override
  String get registerRoleClient => 'Ik ben klant';

  @override
  String get registerRoleWorker => 'Ik ben werknemer';

  @override
  String get registerAccountType => 'Accounttype';

  @override
  String get forgotPasswordSubtitle =>
      'Vul je e-mailadres in en we sturen je een resetlink.';

  @override
  String get forgotPasswordSendButton => 'Resetlink verzenden';

  @override
  String get forgotPasswordSuccessTitle => 'E-mail verzonden!';

  @override
  String forgotPasswordSuccessBody(String email) {
    return 'Controleer je inbox bij $email en klik op de link om je wachtwoord te resetten.';
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
  String get resetPasswordButton => 'Wachtwoord resetten';

  @override
  String get resetPasswordSuccess => 'Wachtwoord succesvol gereset!';

  @override
  String get profileTitle => 'Mijn Profiel';

  @override
  String get profileLogoutTitle => 'Uitloggen';

  @override
  String get profileLogoutConfirm => 'Weet je zeker dat je wilt uitloggen?';

  @override
  String get profileLogoutButton => 'Account verlaten';

  @override
  String get profilePaymentMethods => 'Betaalmethoden';

  @override
  String get profilePaymentMethodsSubtitle =>
      'Opgeslagen kaarten voor snelle betalingen';

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
  String get projectsTitle => 'Mijn Projecten';

  @override
  String projectsActive(int count) {
    return '$count actieve projecten';
  }

  @override
  String get projectsFilterAll => 'Alle';

  @override
  String get projectsFilterActive => 'Actief';

  @override
  String get projectsFilterClosed => 'Gesloten';

  @override
  String get projectsEmpty => 'Je project verschijnt hier';

  @override
  String get projectsEmptySubtitle =>
      'Zodra er een project voor je is aangemaakt of je er een toevoegt via een uitnodigingslink, zie je het in deze lijst.';

  @override
  String get projectsCreateButton => 'Project aanmaken';

  @override
  String get projectsLoadError => 'Fout bij laden van projecten';

  @override
  String get projectDetailTitle => 'Projectdetails';

  @override
  String get projectDetailWorker => 'Werknemer';

  @override
  String get projectDetailBudget => 'Totaalbedrag';

  @override
  String get projectDetailDeadline => 'Deadline';

  @override
  String get projectDetailPhases => 'Fases';

  @override
  String get projectDetailPayment => 'Betaling';

  @override
  String get projectDetailInfoSection => 'INFO';

  @override
  String get projectDetailPhasesSection => 'FASES';

  @override
  String get projectDetailPaymentSection => 'BETALING';

  @override
  String get projectDetailLocation => 'Locatie';

  @override
  String get projectRateWorkerSection => 'BEOORDELING';

  @override
  String get projectRateWorkerSubtitle => 'Hoe was het werk in dit project?';

  @override
  String get projectRateWorkerFeedbackLabel => 'Opmerking (optioneel)';

  @override
  String get projectRateWorkerSubmit => 'Beoordeling verzenden';

  @override
  String get projectRateWorkerThanks => 'Bedankt voor uw beoordeling.';

  @override
  String projectRateWorkerYourScore(int score) {
    return 'Uw score: $score van 5';
  }

  @override
  String projectRateWorkerError(String message) {
    return 'Verzenden mislukt: $message';
  }

  @override
  String get projectDraftSaved => 'Concept opgeslagen';

  @override
  String get projectDraftDescription =>
      'Dit project is opgeslagen als concept. Dien in voor validatie om het matchingproces met werknemers te starten.';

  @override
  String get projectSubmitForValidation => 'Indienen voor Validatie';

  @override
  String get projectSubmitSuccess => 'Project ingediend voor validatie!';

  @override
  String projectSubmitError(String error) {
    return 'Fout bij indienen: $error';
  }

  @override
  String get projectSignContract => 'Contract ondertekenen';

  @override
  String get projectSignContractDescription =>
      'Onderteken het contract om je deelname aan dit project te bevestigen.';

  @override
  String get projectPaymentRequired => 'Betaling vereist';

  @override
  String get projectPaymentRequiredDescription =>
      'De werknemer is aangewezen en wacht op de start. Betaal om de uitvoering van de fases te ontgrendelen.';

  @override
  String get projectPayButton => 'Betalen en Project starten';

  @override
  String get projectViewFinancials => 'Financiële details bekijken →';

  @override
  String projectPhaseLabel(int order, String name) {
    return 'Fase $order — $name';
  }

  @override
  String get projectEscrowLabel => 'Escrow';

  @override
  String get projectReleasedLabel => 'Vrijgegeven';

  @override
  String projectEscrowValue(String amount) {
    return '€ $amount geblokkeerd';
  }

  @override
  String projectCardPhase(int validated, int total) {
    return 'Fase $validated/$total';
  }

  @override
  String get phaseValidateButton => 'Valideren';

  @override
  String get phaseStatusValidated => 'Gevalideerd';

  @override
  String get phaseStatusUnderReview => 'In beoordeling';

  @override
  String get phaseStatusEvidenceUploaded => 'Bewijs geüpload';

  @override
  String get phaseStatusInProgress => 'In uitvoering';

  @override
  String get phaseStatusRejected => 'Afgewezen';

  @override
  String get phaseStatusPending => 'In behandeling';

  @override
  String get createProjectTitle => 'Nieuw Project';

  @override
  String get createProjectStep1 => 'Basisinformatie';

  @override
  String get createProjectStep2 => 'Fases';

  @override
  String get createProjectStep3 => 'Beoordeling';

  @override
  String get createProjectTitleLabel => 'Projecttitel';

  @override
  String get createProjectDescLabel => 'Beschrijving';

  @override
  String get createProjectLocationLabel => 'Locatie';

  @override
  String get createProjectBudgetLabel => 'Totaalbudget (€)';

  @override
  String get createProjectDeadlineLabel => 'Deadline';

  @override
  String get createProjectNextButton => 'Doorgaan';

  @override
  String get createProjectSubmitButton => 'Project aanmaken';

  @override
  String get createProjectAddPhase => '+ Fase toevoegen';

  @override
  String createProjectStepLabel(int step) {
    return 'Nieuw Project — Stap $step/3';
  }

  @override
  String get createProjectPhasesTitle => 'Projectfases';

  @override
  String get createProjectPhaseNameLabel => 'Fasenaam';

  @override
  String get createProjectPhaseAmountLabel => 'Geschatte waarde (€)';

  @override
  String get createProjectSaveDraft => 'Concept opslaan';

  @override
  String get createProjectDraftSaved => 'Concept opgeslagen!';

  @override
  String get createProjectSentForValidation =>
      'Project ingediend voor validatie!';

  @override
  String get createProjectSelectDeadline => 'Deadline selecteren';

  @override
  String get createProjectInvalidAmount => 'Ongeldig bedrag';

  @override
  String get createProjectReviewTitle => 'Beoordeling';

  @override
  String get validatePhaseTitle => 'Fase valideren';

  @override
  String get validatePhaseEvidence => 'Bewijs van werknemer';

  @override
  String get validatePhaseApprove => 'Fase goedkeuren';

  @override
  String get validatePhaseReject => 'Fase afwijzen';

  @override
  String get validatePhaseWarning =>
      'Na goedkeuring wordt het bedrag vrijgegeven aan de werknemer.';

  @override
  String get validatePhaseEvidenceSection => 'BEWIJS VAN WERKNEMER';

  @override
  String get validatePhaseNoEvidence => 'Geen bewijs geüpload';

  @override
  String get validatePhaseSuccess => 'Fase succesvol gevalideerd!';

  @override
  String get validatePhaseApproveConfirmTitle => 'Fase goedkeuren?';

  @override
  String get validatePhaseRejectConfirmTitle => 'Fase afwijzen?';

  @override
  String get validatePhaseApproveConfirmBody =>
      'De fasebetaling wordt vrijgegeven aan de werknemer.';

  @override
  String get validatePhaseRejectConfirmBody =>
      'De werknemer moet het bewijs opnieuw indienen.';

  @override
  String get validatePhaseApproveButton => 'Goedkeuren';

  @override
  String get validatePhaseRejectButton => 'Afwijzen';

  @override
  String get validatePhaseApproveAction => '✓ Fase goedkeuren';

  @override
  String get validatePhaseRejectAction => '✕ Fase afwijzen';

  @override
  String validatePhaseAmountWarning(String amount) {
    return 'Na goedkeuring wordt € $amount vrijgegeven aan de werknemer.';
  }

  @override
  String validatePhaseDetailTitle(int order, String name) {
    return 'Valideren — Fase $order: $name';
  }

  @override
  String get onboardingSkip => 'Overslaan';

  @override
  String get onboardingStart => 'Aan de slag';

  @override
  String get onboardingPage1Title => 'Maak je project aan';

  @override
  String get onboardingPage1Subtitle =>
      'Beschrijf de dienst, definieer fases en budget met gemak.';

  @override
  String get onboardingPage2Title => 'Wij vinden de professional';

  @override
  String get onboardingPage2Subtitle =>
      'Automatisch matching met gecertificeerde en goed beoordeelde werknemers.';

  @override
  String get onboardingPage3Title => 'Betaal veilig';

  @override
  String get onboardingPage3Subtitle =>
      'Escrow geeft het bedrag pas vrij na jouw goedkeuring van elke fase.';

  @override
  String get notificationsTitle => 'Meldingen';

  @override
  String get notificationsMarkAllRead => 'Alles als gelezen markeren';

  @override
  String get notificationsEmpty => 'Geen meldingen';

  @override
  String get notificationsLoadError => 'Fout bij laden';

  @override
  String get statusDraft => 'Concept';

  @override
  String get statusInValidation => 'In Validatie';

  @override
  String get statusMatched => 'Gematcht';

  @override
  String get statusContractSigned => 'Contract getekend';

  @override
  String get statusActiveEscrow => 'Actieve Escrow';

  @override
  String get statusInExecution => 'In Uitvoering';

  @override
  String get statusClosing => 'Afsluiten';

  @override
  String get statusClosed => 'Voltooid';

  @override
  String get statusRejected => 'Afgewezen';

  @override
  String get statusAwaitingMatch => 'Wachten op match';

  @override
  String get errorGeneric => 'Er is een fout opgetreden. Probeer opnieuw.';

  @override
  String get errorFieldRequired => 'Verplicht veld';

  @override
  String get errorInvalidEmail => 'Ongeldig e-mailadres';

  @override
  String get errorPasswordShort => 'Minimaal 6 tekens';

  @override
  String get errorPasswordMismatch => 'Wachtwoorden komen niet overeen';

  @override
  String get commonLoading => 'Laden...';

  @override
  String get commonCancel => 'Annuleren';

  @override
  String get commonConfirm => 'Bevestigen';

  @override
  String get commonSave => 'Opslaan';

  @override
  String get commonBack => 'Terug';

  @override
  String get commonOr => 'of';

  @override
  String get navProjects => 'Projecten';

  @override
  String get navNotifications => 'Meldingen';

  @override
  String get navProfile => 'Profiel';

  @override
  String get pushChannelName => 'OX Meldingen';

  @override
  String get pushChannelDescription => 'OX Field Services meldingen';

  @override
  String get notifUserWelcomeTitle => 'Welkom bij OX Field Service';

  @override
  String get notifUserWelcomeBody => 'Uw account is succesvol aangemaakt.';

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
    return 'Een klant heeft het project \"$projectTitle\" aangemaakt.';
  }

  @override
  String get notifProjectInValidationTitle => 'Project in validatie';

  @override
  String notifProjectInValidationBody(String projectTitle) {
    return '\"$projectTitle\" is ingediend voor validatie.';
  }

  @override
  String get notifProjectMatchedTitle => 'Project bijgewerkt';

  @override
  String notifProjectMatchedBody(String projectTitle) {
    return 'Het project \"$projectTitle\" is verder in de workflow.';
  }

  @override
  String get notifProjectActivatedTitle => 'Project actief';

  @override
  String notifProjectActivatedBody(String projectTitle) {
    return 'Het project \"$projectTitle\" is nu in uitvoering.';
  }

  @override
  String get notifProjectClosingTitle => 'Project wordt afgesloten';

  @override
  String notifProjectClosingBody(String projectTitle) {
    return 'Alle fases van \"$projectTitle\" zijn gevalideerd.';
  }

  @override
  String get notifProjectClosedTitle => 'Project afgesloten';

  @override
  String notifProjectClosedBody(String projectTitle) {
    return 'Het project \"$projectTitle\" is afgesloten.';
  }

  @override
  String get notifProjectRejectedTitle => 'Project afgewezen';

  @override
  String notifProjectRejectedBody(String projectTitle) {
    return 'Het project \"$projectTitle\" is afgewezen.';
  }

  @override
  String get notifPhaseStartedTitle => 'Fase gestart';

  @override
  String notifPhaseStartedBody(String phaseName, String projectTitle) {
    return 'Fase \"$phaseName\" van project \"$projectTitle\" is gestart.';
  }

  @override
  String get notifPhaseEvidenceUploadedClientTitle => 'Nieuw bewijs';

  @override
  String notifPhaseEvidenceUploadedClientBody(
      String phaseName, String projectTitle) {
    return 'De werknemer heeft bewijs ingediend voor fase \"$phaseName\" in \"$projectTitle\".';
  }

  @override
  String get notifPhaseEvidenceUploadedAdminTitle => 'Bewijs ontvangen';

  @override
  String notifPhaseEvidenceUploadedAdminBody(
      String phaseName, String projectTitle) {
    return 'Project \"$projectTitle\" — fase \"$phaseName\".';
  }

  @override
  String get notifPhaseUnderReviewTitle => 'Fase in beoordeling';

  @override
  String notifPhaseUnderReviewBody(String phaseName, String projectTitle) {
    return 'Fase \"$phaseName\" van \"$projectTitle\" wacht op uw validatie.';
  }

  @override
  String get notifPhaseValidatedClientTitle => 'Fase gevalideerd';

  @override
  String notifPhaseValidatedClientBody(String phaseName, String projectTitle) {
    return 'Fase \"$phaseName\" van project \"$projectTitle\" is gevalideerd.';
  }

  @override
  String get notifPhaseValidatedWorkerTitle => 'Fase goedgekeurd';

  @override
  String notifPhaseValidatedWorkerBody(String phaseName, String projectTitle) {
    return 'Uw fase \"$phaseName\" is goedgekeurd in \"$projectTitle\".';
  }

  @override
  String get notifPhaseRejectedWorkerTitle => 'Fase afgewezen';

  @override
  String notifPhaseRejectedWorkerBody(String phaseName, String projectTitle) {
    return 'Fase \"$phaseName\" van \"$projectTitle\" is afgewezen en vereist aanpassingen.';
  }

  @override
  String get notifPhaseRejectedClientTitle => 'Afwijzing geregistreerd';

  @override
  String notifPhaseRejectedClientBody(String phaseName, String projectTitle) {
    return 'Fase \"$phaseName\" van \"$projectTitle\" is gemarkeerd als afgewezen.';
  }

  @override
  String get notifContractCreatedTitle => 'Nieuw contract';

  @override
  String notifContractCreatedBody(String projectTitle) {
    return 'U bent toegewezen aan project \"$projectTitle\". Onderteken het contract om door te gaan.';
  }

  @override
  String get notifWorkerInvitedTitle => 'Projectuitnodiging';

  @override
  String notifWorkerInvitedBody(String projectTitle) {
    return 'U bent geselecteerd voor het project \"$projectTitle\".';
  }

  @override
  String get notifWorkerAssignedTitle => 'Toewijzing bevestigd';

  @override
  String notifWorkerAssignedBody(String projectTitle) {
    return 'U bent toegewezen aan het project \"$projectTitle\".';
  }

  @override
  String get notifContractSignedClientTitle => 'Contract ondertekend';

  @override
  String notifContractSignedClientBody(String projectTitle) {
    return 'Het contract voor project \"$projectTitle\" is ondertekend door de werknemer.';
  }

  @override
  String get notifContractSignedWorkerTitle => 'Contract ondertekend';

  @override
  String notifContractSignedWorkerBody(String projectTitle) {
    return 'U heeft het contract voor project \"$projectTitle\" ondertekend.';
  }

  @override
  String get notifEscrowHeldTitle => 'Betaling in escrow';

  @override
  String notifEscrowHeldBody(String projectTitle) {
    return 'De middelen voor project \"$projectTitle\" zijn vastgehouden in escrow.';
  }

  @override
  String get notifPaymentTransferredWorkerTitle => 'Overboeking ontvangen';

  @override
  String notifPaymentTransferredWorkerBody(String amount, String projectTitle) {
    return '€ $amount is bijgeschreven voor project \"$projectTitle\".';
  }

  @override
  String get notifPaymentTransferredAdminTitle => 'Betaling overgemaakt';

  @override
  String notifPaymentTransferredAdminBody(String projectTitle) {
    return 'Project \"$projectTitle\" — overboeking naar werknemer geregistreerd.';
  }

  @override
  String get notifEscrowReleasedWorkerTitle => 'Betaling vrijgegeven';

  @override
  String notifEscrowReleasedWorkerBody(String projectTitle) {
    return 'De betaling voor project \"$projectTitle\" is vrijgegeven.';
  }

  @override
  String get notifEscrowReleasedClientTitle => 'Betaling voltooid';

  @override
  String notifEscrowReleasedClientBody(String projectTitle) {
    return 'De betaling voor project \"$projectTitle\" is succesvol overgemaakt.';
  }

  @override
  String get notifPaymentFailedTitle => 'Betaling mislukt';

  @override
  String notifPaymentFailedBody(String projectTitle) {
    return 'De betaling voor project \"$projectTitle\" kon niet worden voltooid.';
  }

  @override
  String get notifWorkerRatedTitle => 'Nieuwe beoordeling';

  @override
  String notifWorkerRatedBody(String score, String projectTitle) {
    return 'U ontving een score van $score voor project \"$projectTitle\".';
  }

  @override
  String get notifInviteRedeemedClientTitle =>
      'Project toegevoegd aan je account';

  @override
  String notifInviteRedeemedClientBody(String projectTitle) {
    return 'Je kunt de fases volgen en de betaling voor \"$projectTitle\" afronden.';
  }

  @override
  String get notifInviteRedeemedAdminTitle => 'Uitnodiging ingewisseld';

  @override
  String notifInviteRedeemedAdminBody(String clientName, String projectTitle) {
    return '$clientName heeft de uitnodiging voor project \"$projectTitle\" geaccepteerd.';
  }

  @override
  String get paymentTitle => 'Betaling';

  @override
  String get paymentConfirmTitle => 'Betaling bevestigen';

  @override
  String get paymentConfirmBody =>
      'Het bedrag wordt vastgehouden in een veilige escrow. Het wordt pas aan de werknemer uitgekeerd nadat u elke projectfase heeft gevalideerd.';

  @override
  String get paymentTestModeHint =>
      'Testmodus: gebruik kaart 4242 4242 4242 4242, elke toekomstige vervaldatum, elke CVC.';

  @override
  String get paymentPayNow => 'Nu betalen';

  @override
  String get paymentProcessing => 'Bezig…';

  @override
  String get paymentAlreadyPaidSnack => 'Voor dit contract is al betaald.';

  @override
  String get paymentDoneWaitingSnack =>
      'Betaling verstuurd! Wachten op bevestiging…';

  @override
  String get paymentErrorClientSecret =>
      'Betaalsessie niet ontvangen van de server.';

  @override
  String get paymentMerchantDisplayName => 'OX Field Services';

  @override
  String get paymentStripePrimaryButton => 'Betalen';

  @override
  String get paymentEscrowStatusHeading => 'Escrow-status';

  @override
  String get paymentEscrowBrand => 'Escrow';

  @override
  String get paymentEscrowStatusHeld => 'Geblokkeerd';

  @override
  String get paymentEscrowStatusReleased => 'Vrijgegeven';

  @override
  String get paymentEscrowStatusRefunded => 'Terugbetaald';

  @override
  String get paymentTotalContractValue => 'Totale contractwaarde';

  @override
  String get paymentDistributionHeading => 'VERDELING';

  @override
  String get paymentSplitWorker => 'Werknemer (70%)';

  @override
  String get paymentSplitPlatform => 'OX-platform (30%)';

  @override
  String get paymentEscrowReleaseInfo =>
      'De betaling wordt automatisch vrijgegeven nadat u elke projectfase goedkeurt.';

  @override
  String get paymentCancelledStripe => 'Betaling geannuleerd';

  @override
  String paymentErrorLine(String details) {
    return 'Fout: $details';
  }

  @override
  String get redeemTitle => 'Project toevoegen via link';

  @override
  String get redeemSubtitle =>
      'Plak de link die de beheerder heeft verzonden of voer het uitnodigingstoken in.';

  @override
  String get redeemInputHint => 'https://app.ox.example/i/... of token';

  @override
  String get redeemAddByLink => 'Toevoegen via link';

  @override
  String redeemPreviewClient(String name) {
    return 'Klant: $name';
  }

  @override
  String redeemPreviewExpires(String date) {
    return 'Verloopt op $date';
  }

  @override
  String get redeemButton => 'Toevoegen aan mijn account';

  @override
  String get redeemRetry => 'Opnieuw proberen';

  @override
  String get redeemErrorExpired =>
      'Deze uitnodiging is verlopen. Vraag de beheerder om een nieuwe link.';

  @override
  String get redeemErrorRevoked =>
      'Deze uitnodiging is ingetrokken. Neem contact op met de beheerder.';

  @override
  String get redeemErrorWrongEmail =>
      'Deze link is aangemaakt voor een ander e-mailadres. Log in met het juiste account of vraag een nieuwe link aan.';

  @override
  String get redeemErrorGeneric =>
      'Ongeldige uitnodiging. Controleer de link en probeer opnieuw.';

  @override
  String get redeemErrorNotFound =>
      'Uitnodiging niet gevonden op deze server. De app moet dezelfde API-URL gebruiken als het adminpaneel — zet --dart-define=API_BASE_URL=https://jouw-backend… bij builden.';

  @override
  String get redeemErrorNetwork =>
      'Server niet bereikbaar. Controleer netwerk en API-URL.';

  @override
  String get redeemErrorRoleMustBeClient =>
      'Alleen klantaccounts kunnen uitnodigingen inwisselen. Controleer je rol via POST /auth/sync.';
}
