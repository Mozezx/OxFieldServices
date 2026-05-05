// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'OX Services';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to your OX account';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginButton => 'Sign in';

  @override
  String get loginGoogleButton => 'Sign in with Google';

  @override
  String get loginNoAccount => 'Don\'t have an account? Sign up';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginOrContinueWith => 'or continue with';

  @override
  String get registerTitle => 'Create account';

  @override
  String get registerNameLabel => 'Full name';

  @override
  String get registerConfirmPasswordLabel => 'Confirm password';

  @override
  String get registerButton => 'Create account';

  @override
  String get registerHasAccount => 'Already have an account';

  @override
  String get registerRoleClient => 'I\'m a client';

  @override
  String get registerRoleWorker => 'I\'m a worker';

  @override
  String get registerAccountType => 'Account type';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email and we\'ll send you a reset link.';

  @override
  String get forgotPasswordSendButton => 'Send reset link';

  @override
  String get forgotPasswordSuccessTitle => 'Email sent!';

  @override
  String forgotPasswordSuccessBody(String email) {
    return 'Check your inbox at $email and click the link to reset your password.';
  }

  @override
  String get forgotPasswordBackToLogin => 'Back to login';

  @override
  String get resetPasswordTitle => 'New password';

  @override
  String get resetPasswordSubtitle => 'Enter and confirm your new password.';

  @override
  String get resetPasswordNewLabel => 'New password';

  @override
  String get resetPasswordConfirmLabel => 'Confirm new password';

  @override
  String get resetPasswordButton => 'Reset password';

  @override
  String get resetPasswordSuccess => 'Password reset successfully!';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get profileLogoutTitle => 'Sign out';

  @override
  String get profileLogoutConfirm => 'Are you sure you want to sign out?';

  @override
  String get profileLogoutButton => 'Sign out';

  @override
  String get profilePaymentMethods => 'Payment methods';

  @override
  String get profilePaymentMethodsSubtitle => 'Saved cards for quick payments';

  @override
  String get profilePhotoTitle => 'Profile photo';

  @override
  String get profilePhotoChangeHint => 'Tap to change';

  @override
  String get profilePhotoGallery => 'Gallery';

  @override
  String get profilePhotoCamera => 'Camera';

  @override
  String get profilePhotoRemove => 'Remove photo';

  @override
  String get profilePhotoPromptTitle => 'Add a profile photo';

  @override
  String get profilePhotoPromptBody =>
      'It helps personalize your account. You can change it later in profile settings.';

  @override
  String get profilePhotoPromptLater => 'Not now';

  @override
  String get profilePhotoUploadError =>
      'Could not upload the photo. Please try again.';

  @override
  String get profilePhotoSizeError => 'Image is too large (max 5 MB).';

  @override
  String get profilePhotoTypeError => 'Use JPEG or PNG.';

  @override
  String get profilePhotoRemoveMessage =>
      'The photo will be removed from your account.';

  @override
  String get projectsTitle => 'My Projects';

  @override
  String projectsActive(int count) {
    return '$count active projects';
  }

  @override
  String get projectsFilterAll => 'All';

  @override
  String get projectsFilterActive => 'Active';

  @override
  String get projectsFilterClosed => 'Closed';

  @override
  String get projectsEmpty => 'Your project will appear here';

  @override
  String get projectsEmptySubtitle =>
      'When a project is created for you or you add one via invite link, it will show up in this list.';

  @override
  String get projectsCreateButton => 'Create project';

  @override
  String get projectsLoadError => 'Error loading projects';

  @override
  String get projectDetailTitle => 'Project Details';

  @override
  String get projectDetailWorker => 'Worker';

  @override
  String get projectDetailBudget => 'Total Amount';

  @override
  String get projectDetailDeadline => 'Deadline';

  @override
  String get projectDetailPhases => 'Phases';

  @override
  String get projectDetailPayment => 'Payment';

  @override
  String get projectDetailInfoSection => 'INFO';

  @override
  String get projectDetailPhasesSection => 'PHASES';

  @override
  String get projectDetailPaymentSection => 'PAYMENT';

  @override
  String get projectDetailLocation => 'Location';

  @override
  String get projectRateWorkerSection => 'RATING';

  @override
  String get projectRateWorkerSubtitle => 'How was the work on this project?';

  @override
  String get projectRateWorkerFeedbackLabel => 'Comment (optional)';

  @override
  String get projectRateWorkerSubmit => 'Submit rating';

  @override
  String get projectRateWorkerThanks => 'Thank you for your feedback.';

  @override
  String projectRateWorkerYourScore(int score) {
    return 'Your score: $score out of 5';
  }

  @override
  String projectRateWorkerError(String message) {
    return 'Could not submit: $message';
  }

  @override
  String get projectDraftSaved => 'Draft saved';

  @override
  String get projectDraftDescription =>
      'This project is saved as a draft. Submit for validation to start the matching process with workers.';

  @override
  String get projectSubmitForValidation => 'Submit for Validation';

  @override
  String get projectSubmitSuccess => 'Project submitted for validation!';

  @override
  String projectSubmitError(String error) {
    return 'Error submitting: $error';
  }

  @override
  String get projectSignContract => 'Sign Contract';

  @override
  String get projectSignContractDescription =>
      'Sign the contract to confirm your participation in this project.';

  @override
  String get projectPaymentRequired => 'Payment required';

  @override
  String get projectPaymentRequiredDescription =>
      'The worker has been assigned and is waiting to start. Pay to unlock the execution of the phases.';

  @override
  String get projectPayButton => 'Pay and Start Project';

  @override
  String get projectViewFinancials => 'View financial details →';

  @override
  String projectPhaseLabel(int order, String name) {
    return 'Phase $order — $name';
  }

  @override
  String get projectEscrowLabel => 'Escrow';

  @override
  String get projectReleasedLabel => 'Released';

  @override
  String projectEscrowValue(String amount) {
    return '€ $amount locked';
  }

  @override
  String projectCardPhase(int validated, int total) {
    return 'Phase $validated/$total';
  }

  @override
  String get phaseValidateButton => 'Validate';

  @override
  String get phaseStatusValidated => 'Validated';

  @override
  String get phaseStatusUnderReview => 'Under review';

  @override
  String get phaseStatusEvidenceUploaded => 'Evidence uploaded';

  @override
  String get phaseStatusInProgress => 'In progress';

  @override
  String get phaseStatusRejected => 'Rejected';

  @override
  String get phaseStatusPending => 'Pending';

  @override
  String get createProjectTitle => 'New Project';

  @override
  String get createProjectStep1 => 'Basic Info';

  @override
  String get createProjectStep2 => 'Phases';

  @override
  String get createProjectStep3 => 'Review';

  @override
  String get createProjectTitleLabel => 'Project title';

  @override
  String get createProjectDescLabel => 'Description';

  @override
  String get createProjectLocationLabel => 'Location';

  @override
  String get createProjectBudgetLabel => 'Total budget (€)';

  @override
  String get createProjectDeadlineLabel => 'Deadline';

  @override
  String get createProjectNextButton => 'Continue';

  @override
  String get createProjectSubmitButton => 'Create Project';

  @override
  String get createProjectAddPhase => '+ Add Phase';

  @override
  String createProjectStepLabel(int step) {
    return 'New Project — Step $step/3';
  }

  @override
  String get createProjectPhasesTitle => 'Project Phases';

  @override
  String get createProjectPhaseNameLabel => 'Phase name';

  @override
  String get createProjectPhaseAmountLabel => 'Estimated value (€)';

  @override
  String get createProjectSaveDraft => 'Save Draft';

  @override
  String get createProjectDraftSaved => 'Draft saved!';

  @override
  String get createProjectSentForValidation =>
      'Project submitted for validation!';

  @override
  String get createProjectSelectDeadline => 'Select deadline';

  @override
  String get createProjectInvalidAmount => 'Invalid amount';

  @override
  String get createProjectReviewTitle => 'Review';

  @override
  String get validatePhaseTitle => 'Validate Phase';

  @override
  String get validatePhaseEvidence => 'Worker Evidence';

  @override
  String get validatePhaseApprove => 'Approve Phase';

  @override
  String get validatePhaseReject => 'Reject Phase';

  @override
  String get validatePhaseWarning =>
      'Upon approval, the amount will be released to the worker.';

  @override
  String get validatePhaseEvidenceSection => 'WORKER EVIDENCE';

  @override
  String get validatePhaseNoEvidence => 'No evidence uploaded';

  @override
  String get validatePhaseSuccess => 'Phase validated successfully!';

  @override
  String get validatePhaseApproveConfirmTitle => 'Approve Phase?';

  @override
  String get validatePhaseRejectConfirmTitle => 'Reject Phase?';

  @override
  String get validatePhaseApproveConfirmBody =>
      'The phase payment will be released to the worker.';

  @override
  String get validatePhaseRejectConfirmBody =>
      'The worker will need to resubmit the evidence.';

  @override
  String get validatePhaseApproveButton => 'Approve';

  @override
  String get validatePhaseRejectButton => 'Reject';

  @override
  String get validatePhaseApproveAction => '✓ Approve Phase';

  @override
  String get validatePhaseRejectAction => '✕ Reject Phase';

  @override
  String validatePhaseAmountWarning(String amount) {
    return 'Upon approval, € $amount will be released to the worker.';
  }

  @override
  String validatePhaseDetailTitle(int order, String name) {
    return 'Validate — Phase $order: $name';
  }

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get onboardingPage1Title => 'Create your project';

  @override
  String get onboardingPage1Subtitle =>
      'Describe the service, define phases and budget with ease.';

  @override
  String get onboardingPage2Title => 'We find the professional';

  @override
  String get onboardingPage2Subtitle =>
      'Automatic matching with certified and highly rated workers.';

  @override
  String get onboardingPage3Title => 'Pay securely';

  @override
  String get onboardingPage3Subtitle =>
      'Escrow releases the amount only after your approval of each phase.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get notificationsEmpty => 'No notifications';

  @override
  String get notificationsLoadError => 'Error loading';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusInValidation => 'In Validation';

  @override
  String get statusMatched => 'Matched';

  @override
  String get statusContractSigned => 'Contract Signed';

  @override
  String get statusActiveEscrow => 'Active Escrow';

  @override
  String get statusInExecution => 'In Execution';

  @override
  String get statusClosing => 'Closing';

  @override
  String get statusClosed => 'Completed';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusAwaitingMatch => 'Awaiting Match';

  @override
  String get errorGeneric => 'An error occurred. Please try again.';

  @override
  String get errorFieldRequired => 'Required field';

  @override
  String get errorInvalidEmail => 'Invalid email';

  @override
  String get errorPasswordShort => 'Minimum 6 characters';

  @override
  String get errorPasswordMismatch => 'Passwords don\'t match';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonSave => 'Save';

  @override
  String get commonBack => 'Back';

  @override
  String get commonOr => 'or';

  @override
  String get navProjects => 'Projects';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navProfile => 'Profile';

  @override
  String get pushChannelName => 'OX Notifications';

  @override
  String get pushChannelDescription => 'OX Field Services notifications';

  @override
  String get notifUserWelcomeTitle => 'Welcome to OX Field Service';

  @override
  String get notifUserWelcomeBody =>
      'Your account has been created successfully.';

  @override
  String get notifProjectCreatedClientTitle => 'Project created';

  @override
  String notifProjectCreatedClientBody(String projectTitle) {
    return 'The project \"$projectTitle\" has been created.';
  }

  @override
  String get notifProjectCreatedAdminTitle => 'New project';

  @override
  String notifProjectCreatedAdminBody(String projectTitle) {
    return 'A client created the project \"$projectTitle\".';
  }

  @override
  String get notifProjectInValidationTitle => 'Project under validation';

  @override
  String notifProjectInValidationBody(String projectTitle) {
    return '\"$projectTitle\" has been submitted for validation.';
  }

  @override
  String get notifProjectMatchedTitle => 'Project updated';

  @override
  String notifProjectMatchedBody(String projectTitle) {
    return 'The project \"$projectTitle\" has advanced in the workflow.';
  }

  @override
  String get notifProjectActivatedTitle => 'Project active';

  @override
  String notifProjectActivatedBody(String projectTitle) {
    return 'The project \"$projectTitle\" is now in progress.';
  }

  @override
  String get notifProjectClosingTitle => 'Project closing';

  @override
  String notifProjectClosingBody(String projectTitle) {
    return 'All phases of \"$projectTitle\" have been validated.';
  }

  @override
  String get notifProjectClosedTitle => 'Project closed';

  @override
  String notifProjectClosedBody(String projectTitle) {
    return 'The project \"$projectTitle\" has been closed.';
  }

  @override
  String get notifProjectRejectedTitle => 'Project rejected';

  @override
  String notifProjectRejectedBody(String projectTitle) {
    return 'The project \"$projectTitle\" has been rejected.';
  }

  @override
  String get notifPhaseStartedTitle => 'Phase started';

  @override
  String notifPhaseStartedBody(String phaseName, String projectTitle) {
    return 'Phase \"$phaseName\" of project \"$projectTitle\" has started.';
  }

  @override
  String get notifPhaseEvidenceUploadedClientTitle => 'New evidence';

  @override
  String notifPhaseEvidenceUploadedClientBody(
      String phaseName, String projectTitle) {
    return 'The worker submitted evidence for phase \"$phaseName\" in \"$projectTitle\".';
  }

  @override
  String get notifPhaseEvidenceUploadedAdminTitle => 'Evidence received';

  @override
  String notifPhaseEvidenceUploadedAdminBody(
      String phaseName, String projectTitle) {
    return 'Project \"$projectTitle\" — phase \"$phaseName\".';
  }

  @override
  String get notifPhaseUnderReviewTitle => 'Phase under review';

  @override
  String notifPhaseUnderReviewBody(String phaseName, String projectTitle) {
    return 'Phase \"$phaseName\" of \"$projectTitle\" is awaiting your validation.';
  }

  @override
  String get notifPhaseValidatedClientTitle => 'Phase validated';

  @override
  String notifPhaseValidatedClientBody(String phaseName, String projectTitle) {
    return 'Phase \"$phaseName\" of project \"$projectTitle\" has been validated.';
  }

  @override
  String get notifPhaseValidatedWorkerTitle => 'Phase approved';

  @override
  String notifPhaseValidatedWorkerBody(String phaseName, String projectTitle) {
    return 'Your phase \"$phaseName\" was approved in \"$projectTitle\".';
  }

  @override
  String get notifPhaseRejectedWorkerTitle => 'Phase rejected';

  @override
  String notifPhaseRejectedWorkerBody(String phaseName, String projectTitle) {
    return 'Phase \"$phaseName\" of \"$projectTitle\" was rejected and needs adjustments.';
  }

  @override
  String get notifPhaseRejectedClientTitle => 'Rejection recorded';

  @override
  String notifPhaseRejectedClientBody(String phaseName, String projectTitle) {
    return 'Phase \"$phaseName\" of \"$projectTitle\" has been marked as rejected.';
  }

  @override
  String get notifContractCreatedTitle => 'New contract';

  @override
  String notifContractCreatedBody(String projectTitle) {
    return 'You have been assigned to project \"$projectTitle\". Sign the contract to continue.';
  }

  @override
  String get notifWorkerInvitedTitle => 'Project invitation';

  @override
  String notifWorkerInvitedBody(String projectTitle) {
    return 'You have been selected for the project \"$projectTitle\".';
  }

  @override
  String get notifWorkerAssignedTitle => 'Assignment confirmed';

  @override
  String notifWorkerAssignedBody(String projectTitle) {
    return 'You are assigned to the project \"$projectTitle\".';
  }

  @override
  String get notifContractSignedClientTitle => 'Contract signed';

  @override
  String notifContractSignedClientBody(String projectTitle) {
    return 'The contract for project \"$projectTitle\" has been signed by the worker.';
  }

  @override
  String get notifContractSignedWorkerTitle => 'Contract signed';

  @override
  String notifContractSignedWorkerBody(String projectTitle) {
    return 'You have signed the contract for project \"$projectTitle\".';
  }

  @override
  String get notifEscrowHeldTitle => 'Payment in escrow';

  @override
  String notifEscrowHeldBody(String projectTitle) {
    return 'The funds for project \"$projectTitle\" are held in escrow.';
  }

  @override
  String get notifPaymentTransferredWorkerTitle => 'Transfer received';

  @override
  String notifPaymentTransferredWorkerBody(String amount, String projectTitle) {
    return '€ $amount has been credited for project \"$projectTitle\".';
  }

  @override
  String get notifPaymentTransferredAdminTitle => 'Payment transferred';

  @override
  String notifPaymentTransferredAdminBody(String projectTitle) {
    return 'Project \"$projectTitle\" — worker transfer registered.';
  }

  @override
  String get notifEscrowReleasedWorkerTitle => 'Payment released';

  @override
  String notifEscrowReleasedWorkerBody(String projectTitle) {
    return 'The payment for project \"$projectTitle\" has been released.';
  }

  @override
  String get notifEscrowReleasedClientTitle => 'Payment completed';

  @override
  String notifEscrowReleasedClientBody(String projectTitle) {
    return 'The payment for project \"$projectTitle\" has been transferred successfully.';
  }

  @override
  String get notifPaymentFailedTitle => 'Payment failed';

  @override
  String notifPaymentFailedBody(String projectTitle) {
    return 'Could not complete the payment for project \"$projectTitle\".';
  }

  @override
  String get notifWorkerRatedTitle => 'New review';

  @override
  String notifWorkerRatedBody(String score, String projectTitle) {
    return 'You received a score of $score on project \"$projectTitle\".';
  }

  @override
  String get notifInviteRedeemedClientTitle => 'Project added to your account';

  @override
  String notifInviteRedeemedClientBody(String projectTitle) {
    return 'You can track phases and complete payment for \"$projectTitle\".';
  }

  @override
  String get notifInviteRedeemedAdminTitle => 'Invite redeemed';

  @override
  String notifInviteRedeemedAdminBody(String clientName, String projectTitle) {
    return '$clientName accepted the invite for project \"$projectTitle\".';
  }

  @override
  String get paymentTitle => 'Payment';

  @override
  String get paymentConfirmTitle => 'Confirm payment';

  @override
  String get paymentConfirmBody =>
      'The amount will be held in secure escrow. It will be released to the worker only after you validate each project phase.';

  @override
  String get paymentTestModeHint =>
      'Test mode: use card 4242 4242 4242 4242, any future expiry, any CVC.';

  @override
  String get paymentPayNow => 'Pay now';

  @override
  String get paymentProcessing => 'Processing…';

  @override
  String get paymentAlreadyPaidSnack =>
      'Payment has already been made for this contract.';

  @override
  String get paymentDoneWaitingSnack =>
      'Payment submitted! Waiting for confirmation…';

  @override
  String get paymentErrorClientSecret =>
      'Payment session was not returned by the server.';

  @override
  String get paymentMerchantDisplayName => 'OX Field Services';

  @override
  String get paymentStripePrimaryButton => 'Pay';

  @override
  String get paymentEscrowStatusHeading => 'Escrow status';

  @override
  String get paymentEscrowBrand => 'Escrow';

  @override
  String get paymentEscrowStatusHeld => 'Held';

  @override
  String get paymentEscrowStatusReleased => 'Released';

  @override
  String get paymentEscrowStatusRefunded => 'Refunded';

  @override
  String get paymentTotalContractValue => 'Total contract value';

  @override
  String get paymentDistributionHeading => 'DISTRIBUTION';

  @override
  String get paymentSplitWorker => 'Worker (70%)';

  @override
  String get paymentSplitPlatform => 'OX platform (30%)';

  @override
  String get paymentEscrowReleaseInfo =>
      'Payment is released automatically after you approve each project phase.';

  @override
  String get paymentCancelledStripe => 'Payment cancelled';

  @override
  String paymentErrorLine(String details) {
    return 'Error: $details';
  }

  @override
  String get redeemTitle => 'Add project by link';

  @override
  String get redeemSubtitle =>
      'Paste the link sent by your administrator or enter the invite token.';

  @override
  String get redeemInputHint => 'https://app.ox.example/i/... or token';

  @override
  String get redeemAddByLink => 'Add by link';

  @override
  String redeemPreviewClient(String name) {
    return 'Client: $name';
  }

  @override
  String redeemPreviewExpires(String date) {
    return 'Expires on $date';
  }

  @override
  String get redeemButton => 'Add to my account';

  @override
  String get redeemRetry => 'Try again';

  @override
  String get redeemErrorExpired =>
      'This invite has expired. Ask your administrator for a new link.';

  @override
  String get redeemErrorRevoked =>
      'This invite was revoked. Contact your administrator.';

  @override
  String get redeemErrorWrongEmail =>
      'This link was created for a different email. Sign in with the correct account or request a new link.';

  @override
  String get redeemErrorGeneric =>
      'Invalid invite. Check the link and try again.';

  @override
  String get redeemErrorNotFound =>
      'Invite not found on this server. The app must use the same API URL as the admin panel — set --dart-define=API_BASE_URL=https://your-backend… when building.';

  @override
  String get redeemErrorNetwork =>
      'Could not reach the server. Check network and API URL.';

  @override
  String get redeemErrorRoleMustBeClient =>
      'Only client accounts can redeem invites. Check your role via POST /auth/sync.';
}
