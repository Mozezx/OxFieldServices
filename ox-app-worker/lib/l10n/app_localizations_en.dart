// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OX Worker';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Password';

  @override
  String get errorFieldRequired => 'Required field';

  @override
  String get errorInvalidEmail => 'Invalid e-mail';

  @override
  String get errorPasswordShort => 'Minimum 6 characters';

  @override
  String get errorPasswordMismatch => 'Passwords don\'t match';

  @override
  String commonErrorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get loginSubtitle => 'Sign in to your worker account';

  @override
  String get loginButton => 'Sign in';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginOrContinueWith => 'or continue with';

  @override
  String get loginNoAccount => 'Don\'t have an account? ';

  @override
  String get loginRegisterLink => 'Sign up';

  @override
  String get registerTitle => 'Create worker account';

  @override
  String get registerNameLabel => 'Full name';

  @override
  String get registerConfirmPasswordLabel => 'Confirm password';

  @override
  String get registerButton => 'Create account';

  @override
  String get registerHasAccount => 'I already have an account';

  @override
  String get registerWorkerBadge => 'Worker account';

  @override
  String get forgotPasswordTitle => 'Forgot password?';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your e-mail and we\'ll send you a link to reset your password.';

  @override
  String get forgotPasswordSendButton => 'Send reset link';

  @override
  String get forgotPasswordSuccessTitle => 'E-mail sent!';

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
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get onboardingPage1Title => 'Opportunities for you';

  @override
  String get onboardingPage1Subtitle =>
      'See projects and invitations matching your skills and availability.';

  @override
  String get onboardingPage2Title => 'Execute with clarity';

  @override
  String get onboardingPage2Subtitle =>
      'Track phases, upload evidence and keep the client informed.';

  @override
  String get onboardingPage3Title => 'Get paid securely';

  @override
  String get onboardingPage3Subtitle =>
      'Payments via Stripe Connect after each phase is approved by the client.';

  @override
  String get navJobs => 'Jobs';

  @override
  String get navExecution => 'In Progress';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navPayments => 'Payments';

  @override
  String get navProfile => 'Profile';

  @override
  String get pushChannelName => 'OX Notifications';

  @override
  String get pushChannelDescription => 'OX Field Services notifications';

  @override
  String get workerStatusAvailable => 'Available';

  @override
  String get workerStatusUnavailable => 'Unavailable';

  @override
  String workerRating(String rating) {
    return 'Rating: $rating';
  }

  @override
  String get defaultWorkerName => 'Worker';

  @override
  String get jobsActiveSection => 'MY ACTIVE JOBS';

  @override
  String get jobsAvailableSection => 'AVAILABLE JOBS FOR YOU';

  @override
  String get jobsNoActive => 'No active jobs';

  @override
  String get jobsNoActiveSubtitle => 'Accept an available job to get started.';

  @override
  String get jobsNoAvailable => 'Your work will appear here';

  @override
  String get jobsNoAvailableSubtitle =>
      'New jobs that match your profile will appear here when they become available.';

  @override
  String get jobsLoadError => 'Error loading jobs';

  @override
  String get jobCompatibility => 'Match: ';

  @override
  String get jobContinueExecution => 'Continue execution';

  @override
  String get jobViewDetails => 'View details';

  @override
  String phaseOrderLabel(int order) {
    return 'Phase $order';
  }

  @override
  String phaseOrderAndName(int order, String name) {
    return 'Phase $order — $name';
  }

  @override
  String get jobDetailTitle => 'Job Details';

  @override
  String get jobInfoSection => 'INFORMATION';

  @override
  String get jobPhasesPaymentsSection => 'PHASES & PAYMENTS';

  @override
  String get jobInfoDeadline => 'Deadline';

  @override
  String get jobInfoLocation => 'Location';

  @override
  String get jobInfoDescription => 'Description';

  @override
  String get jobTotal => 'Total';

  @override
  String get jobAcceptedSuccess => 'Job accepted successfully!';

  @override
  String get jobsNoContractError =>
      'No contract found for this project. Wait for admin assignment.';

  @override
  String get jobAcceptButton => 'Accept Job';

  @override
  String get jobDeclineButton => 'Decline';

  @override
  String get jobAwaitingPaymentMsg =>
      'Contract signed. Waiting for the client to make the payment to start execution.';

  @override
  String get jobAwaitingStartMsg =>
      'Payment confirmed! The project will be activated shortly and phases will appear in the \"In Progress\" tab.';

  @override
  String get jobAcceptDialogTitle => 'Accept Job';

  @override
  String get jobAcceptDialogContent =>
      'By accepting, you commit to executing all phases as agreed. Do you want to continue?';

  @override
  String get dialogAccept => 'Accept';

  @override
  String get statusInExecution => 'In execution';

  @override
  String get statusActiveEscrow => 'Active escrow';

  @override
  String get statusContractSigned => 'Contract signed';

  @override
  String get executionTitle => 'In Progress';

  @override
  String get executionNoPhases => 'No phases in progress';

  @override
  String get executionNoPhasesSubtitle =>
      'When you accept a job and the client pays, your phases will appear here for you to execute.';

  @override
  String executionLoadError(String error) {
    return 'Error loading phases: $error';
  }

  @override
  String get phaseExecutionTitle => 'Phase Execution';

  @override
  String get phaseChecklist => 'PHASE CHECKLIST';

  @override
  String get phaseChecklistItemMaterials => 'Materials prepared';

  @override
  String get phaseChecklistItemPpe => 'PPE in use';

  @override
  String get phaseChecklistItemWorkStarted => 'Work started';

  @override
  String get phaseChecklistItemSafety => 'Safety check';

  @override
  String get phaseChecklistItemPhotoDoc => 'Photo documentation';

  @override
  String get phaseEvidences => 'EVIDENCE';

  @override
  String phaseEvidenceCount(int images, int videos) {
    return '$images photo(s) • $videos video(s)';
  }

  @override
  String phaseAmountLabel(String amount) {
    return '€ $amount in this phase';
  }

  @override
  String get phaseReadyMsg =>
      'Ready to start? Begin the phase to unlock evidence uploads.';

  @override
  String get phaseStartButton => 'Start Phase';

  @override
  String get phaseErrorNotFound => 'Phase not found.';

  @override
  String get phaseErrorNeedEvidenceBeforeSubmit =>
      'Upload at least one piece of evidence before submitting for review.';

  @override
  String get phaseAddMedia => 'Add photo / video';

  @override
  String get phaseSubmitButton => 'Submit for Review';

  @override
  String get phaseAddMinPhotos => 'Add at least 3 photos/videos to submit';

  @override
  String get phaseAddRequiredMedia =>
      'You must upload 1 photo and 1 video (30s to 1m30s).';

  @override
  String get phaseAwaitingReview =>
      'Waiting for the client to review and validate the phase.';

  @override
  String get phaseSubmittedSuccess => 'Phase submitted for client review!';

  @override
  String get phaseStartedSuccess =>
      'Phase started! You can now upload evidence.';

  @override
  String get phaseSubmitDialogTitle => 'Submit for Review';

  @override
  String get phaseSubmitDialogContent =>
      'The client will be notified to review the submitted evidence. Upon approval, this phase\'s payment will be released to you.';

  @override
  String get dialogSend => 'Submit';

  @override
  String get phaseNoActiveTitle => 'No phases in progress';

  @override
  String get phaseNoActiveSubtitle =>
      'Accept an available job to start executing your phases.';

  @override
  String get phaseStatusInProgress => 'In progress';

  @override
  String get phaseStatusUnderReview => 'Under review';

  @override
  String get phaseStatusEvidenceUploaded => 'Evidence uploaded';

  @override
  String get phaseStatusValidated => 'Validated';

  @override
  String get phaseStatusRejected => 'Rejected';

  @override
  String get phaseStatusPending => 'Pending';

  @override
  String get phaseStatusAwaitingStart => 'Awaiting start';

  @override
  String uploadTitle(int count) {
    return 'Evidence ($count/2)';
  }

  @override
  String get uploadNoPhoto => 'No photo selected';

  @override
  String get uploadMinPhotos => 'Minimum 3 photos to submit the phase';

  @override
  String get uploadNoMediaSelected => 'No evidence selected';

  @override
  String get uploadNeedPhotoAndVideo =>
      'Required: 1 photo and 1 video between 30s and 1m30s';

  @override
  String get uploadSelectedPhoto => 'Selected photo';

  @override
  String get uploadSelectedVideo => 'Selected video';

  @override
  String uploadSelectedVideoWithDuration(String duration) {
    return 'Selected video ($duration)';
  }

  @override
  String get uploadRecordVideo => 'Record video';

  @override
  String get uploadVideoFromGallery => 'Video from gallery';

  @override
  String get uploadConfirmRequired => 'Upload photo and video';

  @override
  String get uploadVideoDurationInvalid =>
      'Video must be between 30s and 1m30s.';

  @override
  String get uploadTakePhoto => 'Take photo';

  @override
  String get uploadFromGallery => 'From gallery';

  @override
  String uploadConfirmButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Confirm ($count files)',
      one: 'Confirm (1 file)',
    );
    return '$_temp0';
  }

  @override
  String get uploadUploading => 'Uploading...';

  @override
  String get uploadSuccess => 'Evidence uploaded successfully!';

  @override
  String uploadError(String error) {
    return 'Upload error: $error';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get notificationsEmpty => 'No notifications';

  @override
  String get notificationsLoadError => 'Error loading';

  @override
  String notificationsLoadErrorWithDetail(String error) {
    return 'Error loading: $error';
  }

  @override
  String get paymentsTitle => 'My Payments';

  @override
  String get paymentsTotalReceived => 'TOTAL RECEIVED';

  @override
  String get paymentsReleasedLabel => 'Released payments';

  @override
  String get paymentsLoadError => 'Error loading payments';

  @override
  String get paymentsEmpty => 'No payments yet';

  @override
  String get paymentsEmptySubtitle =>
      'Payments will appear here as your phases are validated.';

  @override
  String get paymentsConnectSetupMessage =>
      'Set up your account to receive payouts. Same secure Stripe flow as in your profile.';

  @override
  String get paymentStatusReleased => 'Released';

  @override
  String paymentStatusReleasedOn(String date) {
    return 'Released on $date';
  }

  @override
  String get paymentStatusPending => 'Awaiting release';

  @override
  String get paymentDefaultTitle => 'Payment';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get profileLogoutTitle => 'Sign out';

  @override
  String get profileLogoutConfirm => 'Do you want to sign out?';

  @override
  String get profileStatusSection => 'STATUS';

  @override
  String get profileSkillsSection => 'SKILLS';

  @override
  String get profileAvailabilityLabel => 'Availability';

  @override
  String get profileShelterLabel => 'Shelter Certification';

  @override
  String get profileCertifiedValue => 'Certified';

  @override
  String get profileNotCertifiedValue => 'Not certified';

  @override
  String get profileSkillsHint => 'Tap skills to select them';

  @override
  String get profileMarkUnavailable => 'Mark as Unavailable';

  @override
  String get profileMarkAvailable => 'Mark as Available';

  @override
  String profileSignoutError(String error) {
    return 'Sign out error: $error';
  }

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
  String get bankSection => 'PAYMENT ACCOUNT';

  @override
  String get bankNotStartedDesc =>
      'Set up your Stripe account to receive payments for completed jobs.';

  @override
  String get bankConfigureButton => 'Set up now';

  @override
  String get bankPendingDesc =>
      'Your account was created, but some information is still needed to start receiving:';

  @override
  String get bankContinueButton => 'Continue setup';

  @override
  String get bankActivePaymentInfo =>
      'Payments are deposited within 2 business days after each phase is validated by the client.';

  @override
  String get bankUpdateButton => 'Update bank details';

  @override
  String get bankRestrictedDefault =>
      'There are pending issues blocking your payouts.';

  @override
  String get bankResolveButton => 'Resolve issues';

  @override
  String get bankStatusActive => 'Active';

  @override
  String get bankStatusPending => 'Under review';

  @override
  String get bankStatusRestricted => 'Suspended';

  @override
  String get bankStatusNotConfigured => 'Not configured';

  @override
  String get bankAccountDefault => 'Bank account';

  @override
  String get bankOnboardingError => 'Could not open onboarding link';

  @override
  String get bankRetryButton => 'Try again';

  @override
  String bankStatusError(String error) {
    return 'Error checking status: $error';
  }

  @override
  String get bankReqFullName => 'Full name';

  @override
  String get bankReqBirthDate => 'Date of birth';

  @override
  String get bankReqIdDocument => 'Identity document';

  @override
  String get bankReqAddress => 'Home address';

  @override
  String get bankReqBankData => 'Bank details (IBAN or account)';

  @override
  String get bankReqStripeTerms => 'Accept Stripe terms';

  @override
  String get bankReqProfile => 'Professional profile';

  @override
  String get bankStripeDisabledPastDue =>
      'Some information is missing or overdue. Finish your details in Stripe to receive payouts again.';

  @override
  String get bankStripeDisabledPendingVerification =>
      'Stripe is verifying your information. Check back later, or complete any extra steps they request.';

  @override
  String get bankStripeDisabledUnderReview =>
      'Your account is under review. Wait for an update, or add information if Stripe asks.';

  @override
  String get bankStripeDisabledRejected =>
      'Stripe did not accept this payment account. Contact OX support if you need help.';

  @override
  String get bankReqProductDescription =>
      'Description of your activity or services';

  @override
  String get bankReqBusinessType => 'Business type (individual or company)';

  @override
  String get bankReqRepresentativeDetails => 'Legal representative details';

  @override
  String get bankReqRepresentativeAddress => 'Representative’s address';

  @override
  String get bankReqCompanyInfo => 'Company information';

  @override
  String get bankReqContactEmailPhone => 'Contact email or phone';

  @override
  String get bankReqWebsiteOrSocial => 'Business website or online presence';

  @override
  String get bankReqAdditionalVerification =>
      'Extra document or verification requested by Stripe';

  @override
  String get bankReqFallbackStripeForm =>
      'Missing information — complete it in Stripe’s secure form';

  @override
  String get bankConnectBrowserHint =>
      'Opens Stripe in the browser. When done, return to this app to refresh your account status.';

  @override
  String get stripeConnectBannerMessage =>
      'Payment account incomplete. Finish setup in your profile to receive transfers.';

  @override
  String get stripeConnectBannerCta => 'Go to profile';

  @override
  String get notifUserWelcomeTitle => 'Welcome to OX Field Service';

  @override
  String get notifUserWelcomeBody => 'Your account was created successfully.';

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
  String get notifContractCreatedTitle => 'New contract';

  @override
  String notifContractCreatedBody(String projectTitle) {
    return 'You have been assigned to the project \"$projectTitle\". Sign the contract to continue.';
  }

  @override
  String get notifContractSignedWorkerTitle => 'Contract signed';

  @override
  String notifContractSignedWorkerBody(String projectTitle) {
    return 'You signed the contract for project \"$projectTitle\".';
  }

  @override
  String get notifEscrowHeldTitle => 'Payment in escrow';

  @override
  String notifEscrowHeldBody(String projectTitle) {
    return 'The value of project \"$projectTitle\" is held in escrow.';
  }

  @override
  String get notifProjectActivatedTitle => 'Project active';

  @override
  String notifProjectActivatedBody(String projectTitle) {
    return 'The project \"$projectTitle\" is underway.';
  }

  @override
  String get notifPhaseStartedTitle => 'Phase started';

  @override
  String notifPhaseStartedBody(String phaseName, String projectTitle) {
    return 'Phase \"$phaseName\" of project \"$projectTitle\" has been started.';
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
  String get notifPaymentTransferredWorkerTitle => 'Transfer received';

  @override
  String notifPaymentTransferredWorkerBody(String amount, String projectTitle) {
    return '€ $amount was credited for project \"$projectTitle\".';
  }

  @override
  String get notifEscrowReleasedWorkerTitle => 'Payment released';

  @override
  String notifEscrowReleasedWorkerBody(String projectTitle) {
    return 'The payment for project \"$projectTitle\" has been released.';
  }

  @override
  String get notifProjectClosedTitle => 'Project closed';

  @override
  String notifProjectClosedBody(String projectTitle) {
    return 'The project \"$projectTitle\" has been closed.';
  }

  @override
  String get notifWorkerRatedTitle => 'New rating';

  @override
  String notifWorkerRatedBody(String score, String projectTitle) {
    return 'You received a rating of $score for project \"$projectTitle\".';
  }

  @override
  String get notifProjectCreatedClientTitle => 'Project created';

  @override
  String notifProjectCreatedClientBody(String projectTitle) {
    return 'The project \"$projectTitle\" was created.';
  }

  @override
  String get notifProjectCreatedAdminTitle => 'New project';

  @override
  String notifProjectCreatedAdminBody(String projectTitle) {
    return 'The client created the project \"$projectTitle\".';
  }

  @override
  String get notifProjectInValidationTitle => 'Project in validation';

  @override
  String notifProjectInValidationBody(String projectTitle) {
    return '\"$projectTitle\" was sent for validation.';
  }

  @override
  String get notifProjectMatchedTitle => 'Project updated';

  @override
  String notifProjectMatchedBody(String projectTitle) {
    return 'The project \"$projectTitle\" moved forward in the flow.';
  }

  @override
  String get notifProjectClosingTitle => 'Project closing';

  @override
  String notifProjectClosingBody(String projectTitle) {
    return 'All phases of \"$projectTitle\" have been validated. Closing in progress.';
  }

  @override
  String get notifProjectRejectedTitle => 'Project rejected';

  @override
  String notifProjectRejectedBody(String projectTitle) {
    return 'The project \"$projectTitle\" was rejected.';
  }

  @override
  String get notifProjectUpdatedGenericTitle => 'Project updated';

  @override
  String notifProjectUpdatedGenericBody(String projectTitle) {
    return 'The status of project \"$projectTitle\" changed.';
  }

  @override
  String get notifPhaseEvidenceUploadedClientTitle => 'New evidence';

  @override
  String notifPhaseEvidenceUploadedClientBody(
      String phaseName, String projectTitle) {
    return 'The worker submitted evidence for phase \"$phaseName\" on \"$projectTitle\".';
  }

  @override
  String get notifPhaseEvidenceUploadedAdminTitle => 'Evidence received';

  @override
  String notifPhaseEvidenceUploadedAdminBody(
      String projectTitle, String phaseName) {
    return 'Project \"$projectTitle\" — phase \"$phaseName\".';
  }

  @override
  String get notifPhaseUnderReviewClientTitle => 'Phase under review';

  @override
  String notifPhaseUnderReviewClientBody(
      String phaseName, String projectTitle) {
    return 'Phase \"$phaseName\" of \"$projectTitle\" is awaiting your validation.';
  }

  @override
  String get notifPhaseValidatedClientTitle => 'Phase validated';

  @override
  String notifPhaseValidatedClientBody(String phaseName, String projectTitle) {
    return 'Phase \"$phaseName\" of project \"$projectTitle\" was validated.';
  }

  @override
  String get notifPhaseRejectedClientTitle => 'Rejection recorded';

  @override
  String notifPhaseRejectedClientBody(String phaseName, String projectTitle) {
    return 'Phase \"$phaseName\" was marked as rejected on project \"$projectTitle\".';
  }

  @override
  String get notifContractSignedClientTitle => 'Contract signed';

  @override
  String notifContractSignedClientBody(String projectTitle) {
    return 'The contract for project \"$projectTitle\" was signed by the worker.';
  }

  @override
  String get notifContractSignedAdminTitle => 'Contract signed';

  @override
  String notifContractSignedAdminBody(String projectTitle) {
    return 'Project \"$projectTitle\" — contract signed.';
  }

  @override
  String get notifEscrowReleasedClientTitle => 'Payment completed';

  @override
  String notifEscrowReleasedClientBody(String projectTitle) {
    return 'The payment for project \"$projectTitle\" was transferred successfully.';
  }

  @override
  String get notifPaymentTransferredAdminTitle => 'Payment transferred';

  @override
  String notifPaymentTransferredAdminBody(String projectTitle) {
    return 'Project \"$projectTitle\" — transfer to worker recorded.';
  }

  @override
  String get notifPaymentFailedTitle => 'Payment failed';

  @override
  String notifPaymentFailedBody(String projectTitle) {
    return 'Could not complete payment for project \"$projectTitle\".';
  }

  @override
  String get notifPaymentFailedAdminTitle => 'Payment failed';

  @override
  String notifPaymentFailedAdminBody(String projectTitle) {
    return 'Project \"$projectTitle\" — payment failed.';
  }
}
