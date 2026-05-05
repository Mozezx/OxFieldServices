import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('pt'),
    Locale('en'),
    Locale('nl'),
    Locale('es')
  ];

  /// No description provided for @appName.
  ///
  /// In pt, this message translates to:
  /// **'OX Services'**
  String get appName;

  /// No description provided for @loginTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo de volta'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Entre na sua conta OX'**
  String get loginSubtitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get loginPasswordLabel;

  /// No description provided for @loginButton.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get loginButton;

  /// No description provided for @loginGoogleButton.
  ///
  /// In pt, this message translates to:
  /// **'Entrar com Google'**
  String get loginGoogleButton;

  /// No description provided for @loginNoAccount.
  ///
  /// In pt, this message translates to:
  /// **'Não tem conta? Cadastre-se'**
  String get loginNoAccount;

  /// No description provided for @loginForgotPassword.
  ///
  /// In pt, this message translates to:
  /// **'Esqueceu a senha?'**
  String get loginForgotPassword;

  /// No description provided for @loginOrContinueWith.
  ///
  /// In pt, this message translates to:
  /// **'ou continue com'**
  String get loginOrContinueWith;

  /// No description provided for @registerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get registerTitle;

  /// No description provided for @registerNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome completo'**
  String get registerNameLabel;

  /// No description provided for @registerConfirmPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar senha'**
  String get registerConfirmPasswordLabel;

  /// No description provided for @registerButton.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get registerButton;

  /// No description provided for @registerHasAccount.
  ///
  /// In pt, this message translates to:
  /// **'Já tenho conta'**
  String get registerHasAccount;

  /// No description provided for @registerRoleClient.
  ///
  /// In pt, this message translates to:
  /// **'Sou cliente'**
  String get registerRoleClient;

  /// No description provided for @registerRoleWorker.
  ///
  /// In pt, this message translates to:
  /// **'Sou trabalhador'**
  String get registerRoleWorker;

  /// No description provided for @registerAccountType.
  ///
  /// In pt, this message translates to:
  /// **'Tipo de conta'**
  String get registerAccountType;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Digite seu e-mail e enviaremos um link para redefinir sua senha.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordSendButton.
  ///
  /// In pt, this message translates to:
  /// **'Enviar link de redefinição'**
  String get forgotPasswordSendButton;

  /// No description provided for @forgotPasswordSuccessTitle.
  ///
  /// In pt, this message translates to:
  /// **'E-mail enviado!'**
  String get forgotPasswordSuccessTitle;

  /// No description provided for @forgotPasswordSuccessBody.
  ///
  /// In pt, this message translates to:
  /// **'Verifique sua caixa de entrada em {email} e clique no link para redefinir sua senha.'**
  String forgotPasswordSuccessBody(String email);

  /// No description provided for @forgotPasswordBackToLogin.
  ///
  /// In pt, this message translates to:
  /// **'Voltar ao login'**
  String get forgotPasswordBackToLogin;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nova senha'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Digite e confirme sua nova senha.'**
  String get resetPasswordSubtitle;

  /// No description provided for @resetPasswordNewLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nova senha'**
  String get resetPasswordNewLabel;

  /// No description provided for @resetPasswordConfirmLabel.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar nova senha'**
  String get resetPasswordConfirmLabel;

  /// No description provided for @resetPasswordButton.
  ///
  /// In pt, this message translates to:
  /// **'Redefinir senha'**
  String get resetPasswordButton;

  /// No description provided for @resetPasswordSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Senha redefinida com sucesso!'**
  String get resetPasswordSuccess;

  /// No description provided for @profileTitle.
  ///
  /// In pt, this message translates to:
  /// **'Meu Perfil'**
  String get profileTitle;

  /// No description provided for @profileLogoutTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get profileLogoutTitle;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza que deseja sair?'**
  String get profileLogoutConfirm;

  /// No description provided for @profileLogoutButton.
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta'**
  String get profileLogoutButton;

  /// No description provided for @profilePaymentMethods.
  ///
  /// In pt, this message translates to:
  /// **'Métodos de pagamento'**
  String get profilePaymentMethods;

  /// No description provided for @profilePaymentMethodsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Cartões salvos para pagamentos rápidos'**
  String get profilePaymentMethodsSubtitle;

  /// No description provided for @profilePhotoTitle.
  ///
  /// In pt, this message translates to:
  /// **'Foto de perfil'**
  String get profilePhotoTitle;

  /// No description provided for @profilePhotoChangeHint.
  ///
  /// In pt, this message translates to:
  /// **'Toque para alterar'**
  String get profilePhotoChangeHint;

  /// No description provided for @profilePhotoGallery.
  ///
  /// In pt, this message translates to:
  /// **'Galeria'**
  String get profilePhotoGallery;

  /// No description provided for @profilePhotoCamera.
  ///
  /// In pt, this message translates to:
  /// **'Câmera'**
  String get profilePhotoCamera;

  /// No description provided for @profilePhotoRemove.
  ///
  /// In pt, this message translates to:
  /// **'Remover foto'**
  String get profilePhotoRemove;

  /// No description provided for @profilePhotoPromptTitle.
  ///
  /// In pt, this message translates to:
  /// **'Adicione uma foto de perfil'**
  String get profilePhotoPromptTitle;

  /// No description provided for @profilePhotoPromptBody.
  ///
  /// In pt, this message translates to:
  /// **'Ajuda a personalizar a sua conta. Pode alterar mais tarde nas definições de perfil.'**
  String get profilePhotoPromptBody;

  /// No description provided for @profilePhotoPromptLater.
  ///
  /// In pt, this message translates to:
  /// **'Agora não'**
  String get profilePhotoPromptLater;

  /// No description provided for @profilePhotoUploadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível enviar a foto. Tente novamente.'**
  String get profilePhotoUploadError;

  /// No description provided for @profilePhotoSizeError.
  ///
  /// In pt, this message translates to:
  /// **'A imagem é demasiado grande (máx. 5 MB).'**
  String get profilePhotoSizeError;

  /// No description provided for @profilePhotoTypeError.
  ///
  /// In pt, this message translates to:
  /// **'Use JPEG ou PNG.'**
  String get profilePhotoTypeError;

  /// No description provided for @profilePhotoRemoveMessage.
  ///
  /// In pt, this message translates to:
  /// **'A foto será removida da sua conta.'**
  String get profilePhotoRemoveMessage;

  /// No description provided for @projectsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Meus Projetos'**
  String get projectsTitle;

  /// No description provided for @projectsActive.
  ///
  /// In pt, this message translates to:
  /// **'{count} projetos ativos'**
  String projectsActive(int count);

  /// No description provided for @projectsFilterAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get projectsFilterAll;

  /// No description provided for @projectsFilterActive.
  ///
  /// In pt, this message translates to:
  /// **'Ativos'**
  String get projectsFilterActive;

  /// No description provided for @projectsFilterClosed.
  ///
  /// In pt, this message translates to:
  /// **'Fechados'**
  String get projectsFilterClosed;

  /// No description provided for @projectsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Sua obra vai aparecer aqui'**
  String get projectsEmpty;

  /// No description provided for @projectsEmptySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Quando uma obra for criada para você ou quando adicionar uma por link de convite, ela aparecerá nesta lista.'**
  String get projectsEmptySubtitle;

  /// No description provided for @projectsCreateButton.
  ///
  /// In pt, this message translates to:
  /// **'Criar projeto'**
  String get projectsCreateButton;

  /// No description provided for @projectsLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar projetos'**
  String get projectsLoadError;

  /// No description provided for @projectDetailTitle.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes do Projeto'**
  String get projectDetailTitle;

  /// No description provided for @projectDetailWorker.
  ///
  /// In pt, this message translates to:
  /// **'Trabalhador'**
  String get projectDetailWorker;

  /// No description provided for @projectDetailBudget.
  ///
  /// In pt, this message translates to:
  /// **'Valor Total'**
  String get projectDetailBudget;

  /// No description provided for @projectDetailDeadline.
  ///
  /// In pt, this message translates to:
  /// **'Prazo'**
  String get projectDetailDeadline;

  /// No description provided for @projectDetailPhases.
  ///
  /// In pt, this message translates to:
  /// **'Fases'**
  String get projectDetailPhases;

  /// No description provided for @projectDetailPayment.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento'**
  String get projectDetailPayment;

  /// No description provided for @projectDetailInfoSection.
  ///
  /// In pt, this message translates to:
  /// **'INFORMAÇÕES'**
  String get projectDetailInfoSection;

  /// No description provided for @projectDetailPhasesSection.
  ///
  /// In pt, this message translates to:
  /// **'FASES'**
  String get projectDetailPhasesSection;

  /// No description provided for @projectDetailPaymentSection.
  ///
  /// In pt, this message translates to:
  /// **'PAGAMENTO'**
  String get projectDetailPaymentSection;

  /// No description provided for @projectDetailLocation.
  ///
  /// In pt, this message translates to:
  /// **'Local'**
  String get projectDetailLocation;

  /// No description provided for @projectRateWorkerSection.
  ///
  /// In pt, this message translates to:
  /// **'AVALIAÇÃO'**
  String get projectRateWorkerSection;

  /// No description provided for @projectRateWorkerSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Como foi o trabalho neste projeto?'**
  String get projectRateWorkerSubtitle;

  /// No description provided for @projectRateWorkerFeedbackLabel.
  ///
  /// In pt, this message translates to:
  /// **'Comentário (opcional)'**
  String get projectRateWorkerFeedbackLabel;

  /// No description provided for @projectRateWorkerSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Enviar avaliação'**
  String get projectRateWorkerSubmit;

  /// No description provided for @projectRateWorkerThanks.
  ///
  /// In pt, this message translates to:
  /// **'Obrigado pela sua avaliação.'**
  String get projectRateWorkerThanks;

  /// No description provided for @projectRateWorkerYourScore.
  ///
  /// In pt, this message translates to:
  /// **'A sua nota: {score} de 5'**
  String projectRateWorkerYourScore(int score);

  /// No description provided for @projectRateWorkerError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível enviar: {message}'**
  String projectRateWorkerError(String message);

  /// No description provided for @projectDraftSaved.
  ///
  /// In pt, this message translates to:
  /// **'Rascunho salvo'**
  String get projectDraftSaved;

  /// No description provided for @projectDraftDescription.
  ///
  /// In pt, this message translates to:
  /// **'Este projeto está salvo como rascunho. Envie para validação para iniciar o processo de matching com trabalhadores.'**
  String get projectDraftDescription;

  /// No description provided for @projectSubmitForValidation.
  ///
  /// In pt, this message translates to:
  /// **'Enviar para Validação'**
  String get projectSubmitForValidation;

  /// No description provided for @projectSubmitSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Projeto enviado para validação!'**
  String get projectSubmitSuccess;

  /// No description provided for @projectSubmitError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao enviar: {error}'**
  String projectSubmitError(String error);

  /// No description provided for @projectSignContract.
  ///
  /// In pt, this message translates to:
  /// **'Assinar Contrato'**
  String get projectSignContract;

  /// No description provided for @projectSignContractDescription.
  ///
  /// In pt, this message translates to:
  /// **'Assine o contrato para confirmar sua participação neste projeto.'**
  String get projectSignContractDescription;

  /// No description provided for @projectPaymentRequired.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento necessário'**
  String get projectPaymentRequired;

  /// No description provided for @projectPaymentRequiredDescription.
  ///
  /// In pt, this message translates to:
  /// **'O trabalhador foi designado e aguarda o início. Pague para liberar a execução das fases.'**
  String get projectPaymentRequiredDescription;

  /// No description provided for @projectPayButton.
  ///
  /// In pt, this message translates to:
  /// **'Pagar e Iniciar Projeto'**
  String get projectPayButton;

  /// No description provided for @projectViewFinancials.
  ///
  /// In pt, this message translates to:
  /// **'Ver detalhes financeiros →'**
  String get projectViewFinancials;

  /// No description provided for @projectPhaseLabel.
  ///
  /// In pt, this message translates to:
  /// **'Fase {order} — {name}'**
  String projectPhaseLabel(int order, String name);

  /// No description provided for @projectEscrowLabel.
  ///
  /// In pt, this message translates to:
  /// **'Escrow'**
  String get projectEscrowLabel;

  /// No description provided for @projectReleasedLabel.
  ///
  /// In pt, this message translates to:
  /// **'Liberado'**
  String get projectReleasedLabel;

  /// No description provided for @projectEscrowValue.
  ///
  /// In pt, this message translates to:
  /// **'€ {amount} bloqueado'**
  String projectEscrowValue(String amount);

  /// No description provided for @projectCardPhase.
  ///
  /// In pt, this message translates to:
  /// **'Fase {validated}/{total}'**
  String projectCardPhase(int validated, int total);

  /// No description provided for @phaseValidateButton.
  ///
  /// In pt, this message translates to:
  /// **'Validar'**
  String get phaseValidateButton;

  /// No description provided for @phaseStatusValidated.
  ///
  /// In pt, this message translates to:
  /// **'Validada'**
  String get phaseStatusValidated;

  /// No description provided for @phaseStatusUnderReview.
  ///
  /// In pt, this message translates to:
  /// **'Em revisão'**
  String get phaseStatusUnderReview;

  /// No description provided for @phaseStatusEvidenceUploaded.
  ///
  /// In pt, this message translates to:
  /// **'Evidências enviadas'**
  String get phaseStatusEvidenceUploaded;

  /// No description provided for @phaseStatusInProgress.
  ///
  /// In pt, this message translates to:
  /// **'Em execução'**
  String get phaseStatusInProgress;

  /// No description provided for @phaseStatusRejected.
  ///
  /// In pt, this message translates to:
  /// **'Rejeitada'**
  String get phaseStatusRejected;

  /// No description provided for @phaseStatusPending.
  ///
  /// In pt, this message translates to:
  /// **'Pendente'**
  String get phaseStatusPending;

  /// No description provided for @createProjectTitle.
  ///
  /// In pt, this message translates to:
  /// **'Novo Projeto'**
  String get createProjectTitle;

  /// No description provided for @createProjectStep1.
  ///
  /// In pt, this message translates to:
  /// **'Informações Básicas'**
  String get createProjectStep1;

  /// No description provided for @createProjectStep2.
  ///
  /// In pt, this message translates to:
  /// **'Fases'**
  String get createProjectStep2;

  /// No description provided for @createProjectStep3.
  ///
  /// In pt, this message translates to:
  /// **'Revisão'**
  String get createProjectStep3;

  /// No description provided for @createProjectTitleLabel.
  ///
  /// In pt, this message translates to:
  /// **'Título do projeto'**
  String get createProjectTitleLabel;

  /// No description provided for @createProjectDescLabel.
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
  String get createProjectDescLabel;

  /// No description provided for @createProjectLocationLabel.
  ///
  /// In pt, this message translates to:
  /// **'Localização'**
  String get createProjectLocationLabel;

  /// No description provided for @createProjectBudgetLabel.
  ///
  /// In pt, this message translates to:
  /// **'Orçamento total (€)'**
  String get createProjectBudgetLabel;

  /// No description provided for @createProjectDeadlineLabel.
  ///
  /// In pt, this message translates to:
  /// **'Prazo'**
  String get createProjectDeadlineLabel;

  /// No description provided for @createProjectNextButton.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get createProjectNextButton;

  /// No description provided for @createProjectSubmitButton.
  ///
  /// In pt, this message translates to:
  /// **'Criar Projeto'**
  String get createProjectSubmitButton;

  /// No description provided for @createProjectAddPhase.
  ///
  /// In pt, this message translates to:
  /// **'+ Adicionar Fase'**
  String get createProjectAddPhase;

  /// No description provided for @createProjectStepLabel.
  ///
  /// In pt, this message translates to:
  /// **'Novo Projeto — Etapa {step}/3'**
  String createProjectStepLabel(int step);

  /// No description provided for @createProjectPhasesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Fases do Projeto'**
  String get createProjectPhasesTitle;

  /// No description provided for @createProjectPhaseNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome da fase'**
  String get createProjectPhaseNameLabel;

  /// No description provided for @createProjectPhaseAmountLabel.
  ///
  /// In pt, this message translates to:
  /// **'Valor estimado (€)'**
  String get createProjectPhaseAmountLabel;

  /// No description provided for @createProjectSaveDraft.
  ///
  /// In pt, this message translates to:
  /// **'Salvar Rascunho'**
  String get createProjectSaveDraft;

  /// No description provided for @createProjectDraftSaved.
  ///
  /// In pt, this message translates to:
  /// **'Rascunho salvo!'**
  String get createProjectDraftSaved;

  /// No description provided for @createProjectSentForValidation.
  ///
  /// In pt, this message translates to:
  /// **'Projeto enviado para validação!'**
  String get createProjectSentForValidation;

  /// No description provided for @createProjectSelectDeadline.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar prazo'**
  String get createProjectSelectDeadline;

  /// No description provided for @createProjectInvalidAmount.
  ///
  /// In pt, this message translates to:
  /// **'Valor inválido'**
  String get createProjectInvalidAmount;

  /// No description provided for @createProjectReviewTitle.
  ///
  /// In pt, this message translates to:
  /// **'Revisão'**
  String get createProjectReviewTitle;

  /// No description provided for @validatePhaseTitle.
  ///
  /// In pt, this message translates to:
  /// **'Validar Fase'**
  String get validatePhaseTitle;

  /// No description provided for @validatePhaseEvidence.
  ///
  /// In pt, this message translates to:
  /// **'Evidências do Trabalhador'**
  String get validatePhaseEvidence;

  /// No description provided for @validatePhaseApprove.
  ///
  /// In pt, this message translates to:
  /// **'Aprovar Fase'**
  String get validatePhaseApprove;

  /// No description provided for @validatePhaseReject.
  ///
  /// In pt, this message translates to:
  /// **'Rejeitar Fase'**
  String get validatePhaseReject;

  /// No description provided for @validatePhaseWarning.
  ///
  /// In pt, this message translates to:
  /// **'Ao aprovar, o valor será liberado ao trabalhador.'**
  String get validatePhaseWarning;

  /// No description provided for @validatePhaseEvidenceSection.
  ///
  /// In pt, this message translates to:
  /// **'EVIDÊNCIAS DO TRABALHADOR'**
  String get validatePhaseEvidenceSection;

  /// No description provided for @validatePhaseNoEvidence.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma evidência enviada'**
  String get validatePhaseNoEvidence;

  /// No description provided for @validatePhaseSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Fase validada com sucesso!'**
  String get validatePhaseSuccess;

  /// No description provided for @validatePhaseApproveConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Aprovar Fase?'**
  String get validatePhaseApproveConfirmTitle;

  /// No description provided for @validatePhaseRejectConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Rejeitar Fase?'**
  String get validatePhaseRejectConfirmTitle;

  /// No description provided for @validatePhaseApproveConfirmBody.
  ///
  /// In pt, this message translates to:
  /// **'O pagamento da fase será liberado ao trabalhador.'**
  String get validatePhaseApproveConfirmBody;

  /// No description provided for @validatePhaseRejectConfirmBody.
  ///
  /// In pt, this message translates to:
  /// **'O trabalhador deverá reenviar as evidências.'**
  String get validatePhaseRejectConfirmBody;

  /// No description provided for @validatePhaseApproveButton.
  ///
  /// In pt, this message translates to:
  /// **'Aprovar'**
  String get validatePhaseApproveButton;

  /// No description provided for @validatePhaseRejectButton.
  ///
  /// In pt, this message translates to:
  /// **'Rejeitar'**
  String get validatePhaseRejectButton;

  /// No description provided for @validatePhaseApproveAction.
  ///
  /// In pt, this message translates to:
  /// **'✓ Aprovar Fase'**
  String get validatePhaseApproveAction;

  /// No description provided for @validatePhaseRejectAction.
  ///
  /// In pt, this message translates to:
  /// **'✕ Rejeitar Fase'**
  String get validatePhaseRejectAction;

  /// No description provided for @validatePhaseAmountWarning.
  ///
  /// In pt, this message translates to:
  /// **'Ao aprovar, € {amount} será liberado ao trabalhador.'**
  String validatePhaseAmountWarning(String amount);

  /// No description provided for @validatePhaseDetailTitle.
  ///
  /// In pt, this message translates to:
  /// **'Validar — Fase {order}: {name}'**
  String validatePhaseDetailTitle(int order, String name);

  /// No description provided for @onboardingSkip.
  ///
  /// In pt, this message translates to:
  /// **'Pular'**
  String get onboardingSkip;

  /// No description provided for @onboardingStart.
  ///
  /// In pt, this message translates to:
  /// **'Começar'**
  String get onboardingStart;

  /// No description provided for @onboardingPage1Title.
  ///
  /// In pt, this message translates to:
  /// **'Crie seu projeto'**
  String get onboardingPage1Title;

  /// No description provided for @onboardingPage1Subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Descreva o serviço, defina fases e orçamento com facilidade.'**
  String get onboardingPage1Subtitle;

  /// No description provided for @onboardingPage2Title.
  ///
  /// In pt, this message translates to:
  /// **'Encontramos o profissional'**
  String get onboardingPage2Title;

  /// No description provided for @onboardingPage2Subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Matching automático com trabalhadores certificados e bem avaliados.'**
  String get onboardingPage2Subtitle;

  /// No description provided for @onboardingPage3Title.
  ///
  /// In pt, this message translates to:
  /// **'Pague com segurança'**
  String get onboardingPage3Title;

  /// No description provided for @onboardingPage3Subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Escrow libera o valor só após sua aprovação de cada fase.'**
  String get onboardingPage3Subtitle;

  /// No description provided for @notificationsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Notificações'**
  String get notificationsTitle;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In pt, this message translates to:
  /// **'Ler todas'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma notificação'**
  String get notificationsEmpty;

  /// No description provided for @notificationsLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar'**
  String get notificationsLoadError;

  /// No description provided for @statusDraft.
  ///
  /// In pt, this message translates to:
  /// **'Rascunho'**
  String get statusDraft;

  /// No description provided for @statusInValidation.
  ///
  /// In pt, this message translates to:
  /// **'Em Validação'**
  String get statusInValidation;

  /// No description provided for @statusMatched.
  ///
  /// In pt, this message translates to:
  /// **'Match feito'**
  String get statusMatched;

  /// No description provided for @statusContractSigned.
  ///
  /// In pt, this message translates to:
  /// **'Contrato assinado'**
  String get statusContractSigned;

  /// No description provided for @statusActiveEscrow.
  ///
  /// In pt, this message translates to:
  /// **'Escrow ativo'**
  String get statusActiveEscrow;

  /// No description provided for @statusInExecution.
  ///
  /// In pt, this message translates to:
  /// **'Em Execução'**
  String get statusInExecution;

  /// No description provided for @statusClosing.
  ///
  /// In pt, this message translates to:
  /// **'Encerrando'**
  String get statusClosing;

  /// No description provided for @statusClosed.
  ///
  /// In pt, this message translates to:
  /// **'Concluído'**
  String get statusClosed;

  /// No description provided for @statusRejected.
  ///
  /// In pt, this message translates to:
  /// **'Rejeitado'**
  String get statusRejected;

  /// No description provided for @statusAwaitingMatch.
  ///
  /// In pt, this message translates to:
  /// **'Aguardando match'**
  String get statusAwaitingMatch;

  /// No description provided for @errorGeneric.
  ///
  /// In pt, this message translates to:
  /// **'Ocorreu um erro. Tente novamente.'**
  String get errorGeneric;

  /// No description provided for @errorFieldRequired.
  ///
  /// In pt, this message translates to:
  /// **'Campo obrigatório'**
  String get errorFieldRequired;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In pt, this message translates to:
  /// **'E-mail inválido'**
  String get errorInvalidEmail;

  /// No description provided for @errorPasswordShort.
  ///
  /// In pt, this message translates to:
  /// **'Mínimo 6 caracteres'**
  String get errorPasswordShort;

  /// No description provided for @errorPasswordMismatch.
  ///
  /// In pt, this message translates to:
  /// **'Senhas não conferem'**
  String get errorPasswordMismatch;

  /// No description provided for @commonLoading.
  ///
  /// In pt, this message translates to:
  /// **'Carregando...'**
  String get commonLoading;

  /// No description provided for @commonCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get commonConfirm;

  /// No description provided for @commonSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get commonSave;

  /// No description provided for @commonBack.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get commonBack;

  /// No description provided for @commonOr.
  ///
  /// In pt, this message translates to:
  /// **'ou'**
  String get commonOr;

  /// No description provided for @navProjects.
  ///
  /// In pt, this message translates to:
  /// **'Projetos'**
  String get navProjects;

  /// No description provided for @navNotifications.
  ///
  /// In pt, this message translates to:
  /// **'Notificações'**
  String get navNotifications;

  /// No description provided for @navProfile.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get navProfile;

  /// No description provided for @pushChannelName.
  ///
  /// In pt, this message translates to:
  /// **'OX Notificações'**
  String get pushChannelName;

  /// No description provided for @pushChannelDescription.
  ///
  /// In pt, this message translates to:
  /// **'Notificações do OX Field Services'**
  String get pushChannelDescription;

  /// No description provided for @notifUserWelcomeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo ao OX Field Service'**
  String get notifUserWelcomeTitle;

  /// No description provided for @notifUserWelcomeBody.
  ///
  /// In pt, this message translates to:
  /// **'Sua conta foi criada com sucesso.'**
  String get notifUserWelcomeBody;

  /// No description provided for @notifProjectCreatedClientTitle.
  ///
  /// In pt, this message translates to:
  /// **'Projeto criado'**
  String get notifProjectCreatedClientTitle;

  /// No description provided for @notifProjectCreatedClientBody.
  ///
  /// In pt, this message translates to:
  /// **'O projeto \"{projectTitle}\" foi criado.'**
  String notifProjectCreatedClientBody(String projectTitle);

  /// No description provided for @notifProjectCreatedAdminTitle.
  ///
  /// In pt, this message translates to:
  /// **'Novo projeto'**
  String get notifProjectCreatedAdminTitle;

  /// No description provided for @notifProjectCreatedAdminBody.
  ///
  /// In pt, this message translates to:
  /// **'Cliente criou o projeto \"{projectTitle}\".'**
  String notifProjectCreatedAdminBody(String projectTitle);

  /// No description provided for @notifProjectInValidationTitle.
  ///
  /// In pt, this message translates to:
  /// **'Projeto em validação'**
  String get notifProjectInValidationTitle;

  /// No description provided for @notifProjectInValidationBody.
  ///
  /// In pt, this message translates to:
  /// **'\"{projectTitle}\" foi enviado para validação.'**
  String notifProjectInValidationBody(String projectTitle);

  /// No description provided for @notifProjectMatchedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Projeto atualizado'**
  String get notifProjectMatchedTitle;

  /// No description provided for @notifProjectMatchedBody.
  ///
  /// In pt, this message translates to:
  /// **'O projeto \"{projectTitle}\" avançou no fluxo.'**
  String notifProjectMatchedBody(String projectTitle);

  /// No description provided for @notifProjectActivatedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Projeto ativo'**
  String get notifProjectActivatedTitle;

  /// No description provided for @notifProjectActivatedBody.
  ///
  /// In pt, this message translates to:
  /// **'O projeto \"{projectTitle}\" está em andamento.'**
  String notifProjectActivatedBody(String projectTitle);

  /// No description provided for @notifProjectClosingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Projeto em encerramento'**
  String get notifProjectClosingTitle;

  /// No description provided for @notifProjectClosingBody.
  ///
  /// In pt, this message translates to:
  /// **'Todas as fases de \"{projectTitle}\" foram validadas.'**
  String notifProjectClosingBody(String projectTitle);

  /// No description provided for @notifProjectClosedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Projeto encerrado'**
  String get notifProjectClosedTitle;

  /// No description provided for @notifProjectClosedBody.
  ///
  /// In pt, this message translates to:
  /// **'O projeto \"{projectTitle}\" foi encerrado.'**
  String notifProjectClosedBody(String projectTitle);

  /// No description provided for @notifProjectRejectedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Projeto rejeitado'**
  String get notifProjectRejectedTitle;

  /// No description provided for @notifProjectRejectedBody.
  ///
  /// In pt, this message translates to:
  /// **'O projeto \"{projectTitle}\" foi rejeitado.'**
  String notifProjectRejectedBody(String projectTitle);

  /// No description provided for @notifPhaseStartedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Fase iniciada'**
  String get notifPhaseStartedTitle;

  /// No description provided for @notifPhaseStartedBody.
  ///
  /// In pt, this message translates to:
  /// **'A fase \"{phaseName}\" do projeto \"{projectTitle}\" foi iniciada.'**
  String notifPhaseStartedBody(String phaseName, String projectTitle);

  /// No description provided for @notifPhaseEvidenceUploadedClientTitle.
  ///
  /// In pt, this message translates to:
  /// **'Novas evidências'**
  String get notifPhaseEvidenceUploadedClientTitle;

  /// No description provided for @notifPhaseEvidenceUploadedClientBody.
  ///
  /// In pt, this message translates to:
  /// **'O trabalhador enviou evidências para a fase \"{phaseName}\" em \"{projectTitle}\".'**
  String notifPhaseEvidenceUploadedClientBody(
      String phaseName, String projectTitle);

  /// No description provided for @notifPhaseEvidenceUploadedAdminTitle.
  ///
  /// In pt, this message translates to:
  /// **'Evidências recebidas'**
  String get notifPhaseEvidenceUploadedAdminTitle;

  /// No description provided for @notifPhaseEvidenceUploadedAdminBody.
  ///
  /// In pt, this message translates to:
  /// **'Projeto \"{projectTitle}\" — fase \"{phaseName}\".'**
  String notifPhaseEvidenceUploadedAdminBody(
      String phaseName, String projectTitle);

  /// No description provided for @notifPhaseUnderReviewTitle.
  ///
  /// In pt, this message translates to:
  /// **'Fase em revisão'**
  String get notifPhaseUnderReviewTitle;

  /// No description provided for @notifPhaseUnderReviewBody.
  ///
  /// In pt, this message translates to:
  /// **'A fase \"{phaseName}\" de \"{projectTitle}\" aguarda sua validação.'**
  String notifPhaseUnderReviewBody(String phaseName, String projectTitle);

  /// No description provided for @notifPhaseValidatedClientTitle.
  ///
  /// In pt, this message translates to:
  /// **'Fase validada'**
  String get notifPhaseValidatedClientTitle;

  /// No description provided for @notifPhaseValidatedClientBody.
  ///
  /// In pt, this message translates to:
  /// **'A fase \"{phaseName}\" do projeto \"{projectTitle}\" foi validada.'**
  String notifPhaseValidatedClientBody(String phaseName, String projectTitle);

  /// No description provided for @notifPhaseValidatedWorkerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Fase aprovada'**
  String get notifPhaseValidatedWorkerTitle;

  /// No description provided for @notifPhaseValidatedWorkerBody.
  ///
  /// In pt, this message translates to:
  /// **'Sua fase \"{phaseName}\" foi aprovada em \"{projectTitle}\".'**
  String notifPhaseValidatedWorkerBody(String phaseName, String projectTitle);

  /// No description provided for @notifPhaseRejectedWorkerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Fase rejeitada'**
  String get notifPhaseRejectedWorkerTitle;

  /// No description provided for @notifPhaseRejectedWorkerBody.
  ///
  /// In pt, this message translates to:
  /// **'A fase \"{phaseName}\" de \"{projectTitle}\" foi rejeitada e precisa de ajustes.'**
  String notifPhaseRejectedWorkerBody(String phaseName, String projectTitle);

  /// No description provided for @notifPhaseRejectedClientTitle.
  ///
  /// In pt, this message translates to:
  /// **'Rejeição registrada'**
  String get notifPhaseRejectedClientTitle;

  /// No description provided for @notifPhaseRejectedClientBody.
  ///
  /// In pt, this message translates to:
  /// **'A fase \"{phaseName}\" de \"{projectTitle}\" foi marcada como rejeitada.'**
  String notifPhaseRejectedClientBody(String phaseName, String projectTitle);

  /// No description provided for @notifContractCreatedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Novo contrato'**
  String get notifContractCreatedTitle;

  /// No description provided for @notifContractCreatedBody.
  ///
  /// In pt, this message translates to:
  /// **'Você foi atribuído ao projeto \"{projectTitle}\". Assine o contrato para continuar.'**
  String notifContractCreatedBody(String projectTitle);

  /// No description provided for @notifWorkerInvitedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Convite para projeto'**
  String get notifWorkerInvitedTitle;

  /// No description provided for @notifWorkerInvitedBody.
  ///
  /// In pt, this message translates to:
  /// **'Você foi selecionado para o projeto \"{projectTitle}\".'**
  String notifWorkerInvitedBody(String projectTitle);

  /// No description provided for @notifWorkerAssignedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Atribuição confirmada'**
  String get notifWorkerAssignedTitle;

  /// No description provided for @notifWorkerAssignedBody.
  ///
  /// In pt, this message translates to:
  /// **'Você está atribuído ao projeto \"{projectTitle}\".'**
  String notifWorkerAssignedBody(String projectTitle);

  /// No description provided for @notifContractSignedClientTitle.
  ///
  /// In pt, this message translates to:
  /// **'Contrato assinado'**
  String get notifContractSignedClientTitle;

  /// No description provided for @notifContractSignedClientBody.
  ///
  /// In pt, this message translates to:
  /// **'O contrato do projeto \"{projectTitle}\" foi assinado pelo trabalhador.'**
  String notifContractSignedClientBody(String projectTitle);

  /// No description provided for @notifContractSignedWorkerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Contrato assinado'**
  String get notifContractSignedWorkerTitle;

  /// No description provided for @notifContractSignedWorkerBody.
  ///
  /// In pt, this message translates to:
  /// **'Você assinou o contrato do projeto \"{projectTitle}\".'**
  String notifContractSignedWorkerBody(String projectTitle);

  /// No description provided for @notifEscrowHeldTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento em escrow'**
  String get notifEscrowHeldTitle;

  /// No description provided for @notifEscrowHeldBody.
  ///
  /// In pt, this message translates to:
  /// **'O valor do projeto \"{projectTitle}\" está retido em escrow.'**
  String notifEscrowHeldBody(String projectTitle);

  /// No description provided for @notifPaymentTransferredWorkerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Transferência recebida'**
  String get notifPaymentTransferredWorkerTitle;

  /// No description provided for @notifPaymentTransferredWorkerBody.
  ///
  /// In pt, this message translates to:
  /// **'Foi creditado € {amount} no projeto \"{projectTitle}\".'**
  String notifPaymentTransferredWorkerBody(String amount, String projectTitle);

  /// No description provided for @notifPaymentTransferredAdminTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento transferido'**
  String get notifPaymentTransferredAdminTitle;

  /// No description provided for @notifPaymentTransferredAdminBody.
  ///
  /// In pt, this message translates to:
  /// **'Projeto \"{projectTitle}\" — transferência ao trabalhador registrada.'**
  String notifPaymentTransferredAdminBody(String projectTitle);

  /// No description provided for @notifEscrowReleasedWorkerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento liberado'**
  String get notifEscrowReleasedWorkerTitle;

  /// No description provided for @notifEscrowReleasedWorkerBody.
  ///
  /// In pt, this message translates to:
  /// **'O pagamento do projeto \"{projectTitle}\" foi liberado.'**
  String notifEscrowReleasedWorkerBody(String projectTitle);

  /// No description provided for @notifEscrowReleasedClientTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento concluído'**
  String get notifEscrowReleasedClientTitle;

  /// No description provided for @notifEscrowReleasedClientBody.
  ///
  /// In pt, this message translates to:
  /// **'O pagamento do projeto \"{projectTitle}\" foi transferido com sucesso.'**
  String notifEscrowReleasedClientBody(String projectTitle);

  /// No description provided for @notifPaymentFailedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Falha no pagamento'**
  String get notifPaymentFailedTitle;

  /// No description provided for @notifPaymentFailedBody.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível concluir o pagamento do projeto \"{projectTitle}\".'**
  String notifPaymentFailedBody(String projectTitle);

  /// No description provided for @notifWorkerRatedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nova avaliação'**
  String get notifWorkerRatedTitle;

  /// No description provided for @notifWorkerRatedBody.
  ///
  /// In pt, this message translates to:
  /// **'Você recebeu nota {score} no projeto \"{projectTitle}\".'**
  String notifWorkerRatedBody(String score, String projectTitle);

  /// No description provided for @notifInviteRedeemedClientTitle.
  ///
  /// In pt, this message translates to:
  /// **'Obra adicionada à sua conta'**
  String get notifInviteRedeemedClientTitle;

  /// No description provided for @notifInviteRedeemedClientBody.
  ///
  /// In pt, this message translates to:
  /// **'Pode acompanhar as fases e finalizar o pagamento de \"{projectTitle}\".'**
  String notifInviteRedeemedClientBody(String projectTitle);

  /// No description provided for @notifInviteRedeemedAdminTitle.
  ///
  /// In pt, this message translates to:
  /// **'Convite resgatado'**
  String get notifInviteRedeemedAdminTitle;

  /// No description provided for @notifInviteRedeemedAdminBody.
  ///
  /// In pt, this message translates to:
  /// **'{clientName} aceitou o convite para a obra \"{projectTitle}\".'**
  String notifInviteRedeemedAdminBody(String clientName, String projectTitle);

  /// No description provided for @paymentTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento'**
  String get paymentTitle;

  /// No description provided for @paymentConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar pagamento'**
  String get paymentConfirmTitle;

  /// No description provided for @paymentConfirmBody.
  ///
  /// In pt, this message translates to:
  /// **'O valor ficará bloqueado em escrow seguro. Será liberado para o trabalhador apenas após você validar cada fase do projeto.'**
  String get paymentConfirmBody;

  /// No description provided for @paymentTestModeHint.
  ///
  /// In pt, this message translates to:
  /// **'Modo teste: use o cartão 4242 4242 4242 4242, qualquer data futura, qualquer CVC.'**
  String get paymentTestModeHint;

  /// No description provided for @paymentPayNow.
  ///
  /// In pt, this message translates to:
  /// **'Pagar agora'**
  String get paymentPayNow;

  /// No description provided for @paymentProcessing.
  ///
  /// In pt, this message translates to:
  /// **'Processando...'**
  String get paymentProcessing;

  /// No description provided for @paymentAlreadyPaidSnack.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento já foi efetuado para este contrato.'**
  String get paymentAlreadyPaidSnack;

  /// No description provided for @paymentDoneWaitingSnack.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento realizado! Aguardando confirmação...'**
  String get paymentDoneWaitingSnack;

  /// No description provided for @paymentErrorClientSecret.
  ///
  /// In pt, this message translates to:
  /// **'Sessão de pagamento não foi devolvida pelo servidor.'**
  String get paymentErrorClientSecret;

  /// No description provided for @paymentMerchantDisplayName.
  ///
  /// In pt, this message translates to:
  /// **'OX Field Services'**
  String get paymentMerchantDisplayName;

  /// No description provided for @paymentStripePrimaryButton.
  ///
  /// In pt, this message translates to:
  /// **'Pagar'**
  String get paymentStripePrimaryButton;

  /// No description provided for @paymentEscrowStatusHeading.
  ///
  /// In pt, this message translates to:
  /// **'Status do Escrow'**
  String get paymentEscrowStatusHeading;

  /// No description provided for @paymentEscrowBrand.
  ///
  /// In pt, this message translates to:
  /// **'Escrow'**
  String get paymentEscrowBrand;

  /// No description provided for @paymentEscrowStatusHeld.
  ///
  /// In pt, this message translates to:
  /// **'Bloqueado'**
  String get paymentEscrowStatusHeld;

  /// No description provided for @paymentEscrowStatusReleased.
  ///
  /// In pt, this message translates to:
  /// **'Liberado'**
  String get paymentEscrowStatusReleased;

  /// No description provided for @paymentEscrowStatusRefunded.
  ///
  /// In pt, this message translates to:
  /// **'Reembolsado'**
  String get paymentEscrowStatusRefunded;

  /// No description provided for @paymentTotalContractValue.
  ///
  /// In pt, this message translates to:
  /// **'Valor total do contrato'**
  String get paymentTotalContractValue;

  /// No description provided for @paymentDistributionHeading.
  ///
  /// In pt, this message translates to:
  /// **'DISTRIBUIÇÃO'**
  String get paymentDistributionHeading;

  /// No description provided for @paymentSplitWorker.
  ///
  /// In pt, this message translates to:
  /// **'Trabalhador (70%)'**
  String get paymentSplitWorker;

  /// No description provided for @paymentSplitPlatform.
  ///
  /// In pt, this message translates to:
  /// **'Plataforma OX (30%)'**
  String get paymentSplitPlatform;

  /// No description provided for @paymentEscrowReleaseInfo.
  ///
  /// In pt, this message translates to:
  /// **'O pagamento é liberado automaticamente após você aprovar cada fase do projeto.'**
  String get paymentEscrowReleaseInfo;

  /// No description provided for @paymentCancelledStripe.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento cancelado'**
  String get paymentCancelledStripe;

  /// No description provided for @paymentErrorLine.
  ///
  /// In pt, this message translates to:
  /// **'Erro: {details}'**
  String paymentErrorLine(String details);

  /// No description provided for @redeemTitle.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar obra por link'**
  String get redeemTitle;

  /// No description provided for @redeemSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Cole o link enviado pelo administrador ou insira o token do convite.'**
  String get redeemSubtitle;

  /// No description provided for @redeemInputHint.
  ///
  /// In pt, this message translates to:
  /// **'https://app.ox.example/i/... ou token'**
  String get redeemInputHint;

  /// No description provided for @redeemAddByLink.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar por link'**
  String get redeemAddByLink;

  /// No description provided for @redeemPreviewClient.
  ///
  /// In pt, this message translates to:
  /// **'Cliente: {name}'**
  String redeemPreviewClient(String name);

  /// No description provided for @redeemPreviewExpires.
  ///
  /// In pt, this message translates to:
  /// **'Expira em {date}'**
  String redeemPreviewExpires(String date);

  /// No description provided for @redeemButton.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar à minha conta'**
  String get redeemButton;

  /// No description provided for @redeemRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get redeemRetry;

  /// No description provided for @redeemErrorExpired.
  ///
  /// In pt, this message translates to:
  /// **'Este convite expirou. Peça um novo link ao administrador.'**
  String get redeemErrorExpired;

  /// No description provided for @redeemErrorRevoked.
  ///
  /// In pt, this message translates to:
  /// **'Este convite foi revogado. Contacte o administrador.'**
  String get redeemErrorRevoked;

  /// No description provided for @redeemErrorWrongEmail.
  ///
  /// In pt, this message translates to:
  /// **'Este link foi gerado para outro email. Entre com a conta correta ou peça um novo link.'**
  String get redeemErrorWrongEmail;

  /// No description provided for @redeemErrorGeneric.
  ///
  /// In pt, this message translates to:
  /// **'Convite inválido. Verifique o link e tente novamente.'**
  String get redeemErrorGeneric;

  /// No description provided for @redeemErrorNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Convite não encontrado neste servidor. A app deve usar o mesmo URL da API que o painel admin — ao compilar, defina --dart-define=API_BASE_URL=https://seu-backend…'**
  String get redeemErrorNotFound;

  /// No description provided for @redeemErrorNetwork.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível contactar o servidor. Verifique a rede e o endereço da API.'**
  String get redeemErrorNetwork;

  /// No description provided for @redeemErrorRoleMustBeClient.
  ///
  /// In pt, this message translates to:
  /// **'Só contas com perfil cliente podem resgatar o convite. Confirme o seu papel em POST /auth/sync.'**
  String get redeemErrorRoleMustBeClient;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'nl', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'nl':
      return AppLocalizationsNl();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
