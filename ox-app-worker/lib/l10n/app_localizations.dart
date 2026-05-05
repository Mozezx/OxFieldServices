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

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'OX Trabalhador'**
  String get appTitle;

  /// No description provided for @emailLabel.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get passwordLabel;

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
  /// **'Senhas não coincidem'**
  String get errorPasswordMismatch;

  /// No description provided for @commonErrorWithMessage.
  ///
  /// In pt, this message translates to:
  /// **'Erro: {message}'**
  String commonErrorWithMessage(String message);

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

  /// No description provided for @loginSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Entre na sua conta de trabalhador'**
  String get loginSubtitle;

  /// No description provided for @loginButton.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get loginButton;

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

  /// No description provided for @loginNoAccount.
  ///
  /// In pt, this message translates to:
  /// **'Não tem conta? '**
  String get loginNoAccount;

  /// No description provided for @loginRegisterLink.
  ///
  /// In pt, this message translates to:
  /// **'Cadastre-se'**
  String get loginRegisterLink;

  /// No description provided for @registerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta de trabalhador'**
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

  /// No description provided for @registerWorkerBadge.
  ///
  /// In pt, this message translates to:
  /// **'Conta de trabalhador'**
  String get registerWorkerBadge;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In pt, this message translates to:
  /// **'Esqueceu a senha?'**
  String get forgotPasswordTitle;

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

  /// No description provided for @onboardingSkip.
  ///
  /// In pt, this message translates to:
  /// **'Pular'**
  String get onboardingSkip;

  /// No description provided for @onboardingContinue.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get onboardingContinue;

  /// No description provided for @onboardingStart.
  ///
  /// In pt, this message translates to:
  /// **'Começar'**
  String get onboardingStart;

  /// No description provided for @onboardingPage1Title.
  ///
  /// In pt, this message translates to:
  /// **'Oportunidades para você'**
  String get onboardingPage1Title;

  /// No description provided for @onboardingPage1Subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Veja projetos e convites compatíveis com suas habilidades e disponibilidade.'**
  String get onboardingPage1Subtitle;

  /// No description provided for @onboardingPage2Title.
  ///
  /// In pt, this message translates to:
  /// **'Execute com clareza'**
  String get onboardingPage2Title;

  /// No description provided for @onboardingPage2Subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Acompanhe fases, envie evidências e mantenha o cliente informado.'**
  String get onboardingPage2Subtitle;

  /// No description provided for @onboardingPage3Title.
  ///
  /// In pt, this message translates to:
  /// **'Receba com segurança'**
  String get onboardingPage3Title;

  /// No description provided for @onboardingPage3Subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Pagamentos via Stripe Connect após a aprovação de cada fase pelo cliente.'**
  String get onboardingPage3Subtitle;

  /// No description provided for @navJobs.
  ///
  /// In pt, this message translates to:
  /// **'Jobs'**
  String get navJobs;

  /// No description provided for @navExecution.
  ///
  /// In pt, this message translates to:
  /// **'Em Execução'**
  String get navExecution;

  /// No description provided for @navNotifications.
  ///
  /// In pt, this message translates to:
  /// **'Notificações'**
  String get navNotifications;

  /// No description provided for @navPayments.
  ///
  /// In pt, this message translates to:
  /// **'Pagamentos'**
  String get navPayments;

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

  /// No description provided for @workerStatusAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Disponível'**
  String get workerStatusAvailable;

  /// No description provided for @workerStatusUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Indisponível'**
  String get workerStatusUnavailable;

  /// No description provided for @workerRating.
  ///
  /// In pt, this message translates to:
  /// **'Avaliação: {rating}'**
  String workerRating(String rating);

  /// No description provided for @defaultWorkerName.
  ///
  /// In pt, this message translates to:
  /// **'Trabalhador'**
  String get defaultWorkerName;

  /// No description provided for @jobsActiveSection.
  ///
  /// In pt, this message translates to:
  /// **'MEUS JOBS ATIVOS'**
  String get jobsActiveSection;

  /// No description provided for @jobsAvailableSection.
  ///
  /// In pt, this message translates to:
  /// **'JOBS DISPONÍVEIS PARA VOCÊ'**
  String get jobsAvailableSection;

  /// No description provided for @jobsNoActive.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum job ativo'**
  String get jobsNoActive;

  /// No description provided for @jobsNoActiveSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Aceite um job disponível para começar.'**
  String get jobsNoActiveSubtitle;

  /// No description provided for @jobsNoAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Seu trabalho vai aparecer aqui'**
  String get jobsNoAvailable;

  /// No description provided for @jobsNoAvailableSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Novos trabalhos compatíveis com o seu perfil aparecerão aqui quando estiverem disponíveis.'**
  String get jobsNoAvailableSubtitle;

  /// No description provided for @jobsLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar jobs'**
  String get jobsLoadError;

  /// No description provided for @jobCompatibility.
  ///
  /// In pt, this message translates to:
  /// **'Compatibilidade: '**
  String get jobCompatibility;

  /// No description provided for @jobContinueExecution.
  ///
  /// In pt, this message translates to:
  /// **'Continuar execução'**
  String get jobContinueExecution;

  /// No description provided for @jobViewDetails.
  ///
  /// In pt, this message translates to:
  /// **'Ver detalhes'**
  String get jobViewDetails;

  /// No description provided for @phaseOrderLabel.
  ///
  /// In pt, this message translates to:
  /// **'Fase {order}'**
  String phaseOrderLabel(int order);

  /// No description provided for @phaseOrderAndName.
  ///
  /// In pt, this message translates to:
  /// **'Fase {order} — {name}'**
  String phaseOrderAndName(int order, String name);

  /// No description provided for @jobDetailTitle.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes do Job'**
  String get jobDetailTitle;

  /// No description provided for @jobInfoSection.
  ///
  /// In pt, this message translates to:
  /// **'INFORMAÇÕES'**
  String get jobInfoSection;

  /// No description provided for @jobPhasesPaymentsSection.
  ///
  /// In pt, this message translates to:
  /// **'FASES E PAGAMENTOS'**
  String get jobPhasesPaymentsSection;

  /// No description provided for @jobInfoDeadline.
  ///
  /// In pt, this message translates to:
  /// **'Prazo'**
  String get jobInfoDeadline;

  /// No description provided for @jobInfoLocation.
  ///
  /// In pt, this message translates to:
  /// **'Local'**
  String get jobInfoLocation;

  /// No description provided for @jobInfoDescription.
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
  String get jobInfoDescription;

  /// No description provided for @jobTotal.
  ///
  /// In pt, this message translates to:
  /// **'Total'**
  String get jobTotal;

  /// No description provided for @jobAcceptedSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Job aceito com sucesso!'**
  String get jobAcceptedSuccess;

  /// No description provided for @jobsNoContractError.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum contrato encontrado para este projeto. Aguarde a atribuição do admin.'**
  String get jobsNoContractError;

  /// No description provided for @jobAcceptButton.
  ///
  /// In pt, this message translates to:
  /// **'Aceitar Job'**
  String get jobAcceptButton;

  /// No description provided for @jobDeclineButton.
  ///
  /// In pt, this message translates to:
  /// **'Recusar'**
  String get jobDeclineButton;

  /// No description provided for @jobAwaitingPaymentMsg.
  ///
  /// In pt, this message translates to:
  /// **'Contrato assinado. Aguardando o cliente efetuar o pagamento para iniciar a execução.'**
  String get jobAwaitingPaymentMsg;

  /// No description provided for @jobAwaitingStartMsg.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento confirmado! O projeto será ativado em breve e as fases aparecerão na aba \"Em Execução\".'**
  String get jobAwaitingStartMsg;

  /// No description provided for @jobAcceptDialogTitle.
  ///
  /// In pt, this message translates to:
  /// **'Aceitar Job'**
  String get jobAcceptDialogTitle;

  /// No description provided for @jobAcceptDialogContent.
  ///
  /// In pt, this message translates to:
  /// **'Ao aceitar, você se compromete a executar todas as fases conforme acordado. Deseja continuar?'**
  String get jobAcceptDialogContent;

  /// No description provided for @dialogAccept.
  ///
  /// In pt, this message translates to:
  /// **'Aceitar'**
  String get dialogAccept;

  /// No description provided for @statusInExecution.
  ///
  /// In pt, this message translates to:
  /// **'Em execução'**
  String get statusInExecution;

  /// No description provided for @statusActiveEscrow.
  ///
  /// In pt, this message translates to:
  /// **'Escrow ativo'**
  String get statusActiveEscrow;

  /// No description provided for @statusContractSigned.
  ///
  /// In pt, this message translates to:
  /// **'Contrato assinado'**
  String get statusContractSigned;

  /// No description provided for @executionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Em Execução'**
  String get executionTitle;

  /// No description provided for @executionNoPhases.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma fase em execução'**
  String get executionNoPhases;

  /// No description provided for @executionNoPhasesSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Quando você aceitar um job e o cliente pagar, suas fases aparecerão aqui para você executar.'**
  String get executionNoPhasesSubtitle;

  /// No description provided for @executionLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar fases: {error}'**
  String executionLoadError(String error);

  /// No description provided for @phaseExecutionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Execução da Fase'**
  String get phaseExecutionTitle;

  /// No description provided for @phaseChecklist.
  ///
  /// In pt, this message translates to:
  /// **'CHECKLIST DA FASE'**
  String get phaseChecklist;

  /// No description provided for @phaseChecklistItemMaterials.
  ///
  /// In pt, this message translates to:
  /// **'Materiais separados'**
  String get phaseChecklistItemMaterials;

  /// No description provided for @phaseChecklistItemPpe.
  ///
  /// In pt, this message translates to:
  /// **'EPIs utilizados'**
  String get phaseChecklistItemPpe;

  /// No description provided for @phaseChecklistItemWorkStarted.
  ///
  /// In pt, this message translates to:
  /// **'Trabalho iniciado'**
  String get phaseChecklistItemWorkStarted;

  /// No description provided for @phaseChecklistItemSafety.
  ///
  /// In pt, this message translates to:
  /// **'Verificação de segurança'**
  String get phaseChecklistItemSafety;

  /// No description provided for @phaseChecklistItemPhotoDoc.
  ///
  /// In pt, this message translates to:
  /// **'Documentação fotográfica'**
  String get phaseChecklistItemPhotoDoc;

  /// No description provided for @phaseEvidences.
  ///
  /// In pt, this message translates to:
  /// **'EVIDÊNCIAS'**
  String get phaseEvidences;

  /// No description provided for @phaseEvidenceCount.
  ///
  /// In pt, this message translates to:
  /// **'{count}/3 obrigatórias'**
  String phaseEvidenceCount(int count);

  /// No description provided for @phaseAmountLabel.
  ///
  /// In pt, this message translates to:
  /// **'€ {amount} nesta fase'**
  String phaseAmountLabel(String amount);

  /// No description provided for @phaseReadyMsg.
  ///
  /// In pt, this message translates to:
  /// **'Pronto para começar? Inicie a fase para liberar o upload de evidências.'**
  String get phaseReadyMsg;

  /// No description provided for @phaseStartButton.
  ///
  /// In pt, this message translates to:
  /// **'Iniciar Fase'**
  String get phaseStartButton;

  /// No description provided for @phaseErrorNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Fase não encontrada.'**
  String get phaseErrorNotFound;

  /// No description provided for @phaseErrorNeedEvidenceBeforeSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Faça upload de pelo menos uma evidência antes de enviar para revisão.'**
  String get phaseErrorNeedEvidenceBeforeSubmit;

  /// No description provided for @phaseAddMedia.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar foto / vídeo'**
  String get phaseAddMedia;

  /// No description provided for @phaseSubmitButton.
  ///
  /// In pt, this message translates to:
  /// **'Enviar para Revisão'**
  String get phaseSubmitButton;

  /// No description provided for @phaseAddMinPhotos.
  ///
  /// In pt, this message translates to:
  /// **'Adicione pelo menos 3 fotos/vídeos para poder enviar'**
  String get phaseAddMinPhotos;

  /// No description provided for @phaseAwaitingReview.
  ///
  /// In pt, this message translates to:
  /// **'Aguardando o cliente revisar e validar a fase.'**
  String get phaseAwaitingReview;

  /// No description provided for @phaseSubmittedSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Fase enviada para revisão do cliente!'**
  String get phaseSubmittedSuccess;

  /// No description provided for @phaseStartedSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Fase iniciada! Você pode subir as evidências.'**
  String get phaseStartedSuccess;

  /// No description provided for @phaseSubmitDialogTitle.
  ///
  /// In pt, this message translates to:
  /// **'Enviar para Revisão'**
  String get phaseSubmitDialogTitle;

  /// No description provided for @phaseSubmitDialogContent.
  ///
  /// In pt, this message translates to:
  /// **'O cliente será notificado para revisar as evidências enviadas. Ao aprovar, o pagamento desta fase será liberado para você.'**
  String get phaseSubmitDialogContent;

  /// No description provided for @dialogSend.
  ///
  /// In pt, this message translates to:
  /// **'Enviar'**
  String get dialogSend;

  /// No description provided for @phaseNoActiveTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma fase em execução'**
  String get phaseNoActiveTitle;

  /// No description provided for @phaseNoActiveSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Aceite um job disponível para começar a executar suas fases.'**
  String get phaseNoActiveSubtitle;

  /// No description provided for @phaseStatusInProgress.
  ///
  /// In pt, this message translates to:
  /// **'Em execução'**
  String get phaseStatusInProgress;

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

  /// No description provided for @phaseStatusValidated.
  ///
  /// In pt, this message translates to:
  /// **'Validada'**
  String get phaseStatusValidated;

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

  /// No description provided for @phaseStatusAwaitingStart.
  ///
  /// In pt, this message translates to:
  /// **'Aguardando início'**
  String get phaseStatusAwaitingStart;

  /// No description provided for @uploadTitle.
  ///
  /// In pt, this message translates to:
  /// **'Evidências ({count}/3)'**
  String uploadTitle(int count);

  /// No description provided for @uploadNoPhoto.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma foto selecionada'**
  String get uploadNoPhoto;

  /// No description provided for @uploadMinPhotos.
  ///
  /// In pt, this message translates to:
  /// **'Mínimo 3 fotos para enviar a fase'**
  String get uploadMinPhotos;

  /// No description provided for @uploadTakePhoto.
  ///
  /// In pt, this message translates to:
  /// **'Tirar foto'**
  String get uploadTakePhoto;

  /// No description provided for @uploadFromGallery.
  ///
  /// In pt, this message translates to:
  /// **'Da galeria'**
  String get uploadFromGallery;

  /// No description provided for @uploadConfirmButton.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Confirmar (1 arquivo)} other{Confirmar ({count} arquivos)}}'**
  String uploadConfirmButton(int count);

  /// No description provided for @uploadUploading.
  ///
  /// In pt, this message translates to:
  /// **'Enviando...'**
  String get uploadUploading;

  /// No description provided for @uploadSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Evidências enviadas com sucesso!'**
  String get uploadSuccess;

  /// No description provided for @uploadError.
  ///
  /// In pt, this message translates to:
  /// **'Erro no upload: {error}'**
  String uploadError(String error);

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

  /// No description provided for @notificationsLoadErrorWithDetail.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar: {error}'**
  String notificationsLoadErrorWithDetail(String error);

  /// No description provided for @paymentsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Meus Pagamentos'**
  String get paymentsTitle;

  /// No description provided for @paymentsTotalReceived.
  ///
  /// In pt, this message translates to:
  /// **'TOTAL RECEBIDO'**
  String get paymentsTotalReceived;

  /// No description provided for @paymentsReleasedLabel.
  ///
  /// In pt, this message translates to:
  /// **'Pagamentos liberados'**
  String get paymentsReleasedLabel;

  /// No description provided for @paymentsLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar pagamentos'**
  String get paymentsLoadError;

  /// No description provided for @paymentsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum pagamento ainda'**
  String get paymentsEmpty;

  /// No description provided for @paymentsEmptySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Os pagamentos aparecerão aqui conforme suas fases forem validadas.'**
  String get paymentsEmptySubtitle;

  /// No description provided for @paymentsConnectSetupMessage.
  ///
  /// In pt, this message translates to:
  /// **'Configure sua conta para receber pagamentos. O botão abre o mesmo fluxo seguro da Stripe usado no perfil.'**
  String get paymentsConnectSetupMessage;

  /// No description provided for @paymentStatusReleased.
  ///
  /// In pt, this message translates to:
  /// **'Liberado'**
  String get paymentStatusReleased;

  /// No description provided for @paymentStatusReleasedOn.
  ///
  /// In pt, this message translates to:
  /// **'Liberado em {date}'**
  String paymentStatusReleasedOn(String date);

  /// No description provided for @paymentStatusPending.
  ///
  /// In pt, this message translates to:
  /// **'Aguardando liberação'**
  String get paymentStatusPending;

  /// No description provided for @paymentDefaultTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento'**
  String get paymentDefaultTitle;

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
  /// **'Deseja sair da sua conta?'**
  String get profileLogoutConfirm;

  /// No description provided for @profileStatusSection.
  ///
  /// In pt, this message translates to:
  /// **'STATUS'**
  String get profileStatusSection;

  /// No description provided for @profileSkillsSection.
  ///
  /// In pt, this message translates to:
  /// **'HABILIDADES'**
  String get profileSkillsSection;

  /// No description provided for @profileAvailabilityLabel.
  ///
  /// In pt, this message translates to:
  /// **'Disponibilidade'**
  String get profileAvailabilityLabel;

  /// No description provided for @profileShelterLabel.
  ///
  /// In pt, this message translates to:
  /// **'Certificação Shelter'**
  String get profileShelterLabel;

  /// No description provided for @profileCertifiedValue.
  ///
  /// In pt, this message translates to:
  /// **'Certificado'**
  String get profileCertifiedValue;

  /// No description provided for @profileNotCertifiedValue.
  ///
  /// In pt, this message translates to:
  /// **'Não certificado'**
  String get profileNotCertifiedValue;

  /// No description provided for @profileSkillsHint.
  ///
  /// In pt, this message translates to:
  /// **'Toque nas habilidades para selecioná-las'**
  String get profileSkillsHint;

  /// No description provided for @profileMarkUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Marcar como Indisponível'**
  String get profileMarkUnavailable;

  /// No description provided for @profileMarkAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Marcar como Disponível'**
  String get profileMarkAvailable;

  /// No description provided for @profileSignoutError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao sair: {error}'**
  String profileSignoutError(String error);

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

  /// No description provided for @bankSection.
  ///
  /// In pt, this message translates to:
  /// **'CONTA DE RECEBIMENTO'**
  String get bankSection;

  /// No description provided for @bankNotStartedDesc.
  ///
  /// In pt, this message translates to:
  /// **'Configure sua conta Stripe para receber pagamentos pelos jobs concluídos.'**
  String get bankNotStartedDesc;

  /// No description provided for @bankConfigureButton.
  ///
  /// In pt, this message translates to:
  /// **'Configurar agora'**
  String get bankConfigureButton;

  /// No description provided for @bankPendingDesc.
  ///
  /// In pt, this message translates to:
  /// **'Sua conta foi criada, mas algumas informações ainda são necessárias para começar a receber:'**
  String get bankPendingDesc;

  /// No description provided for @bankContinueButton.
  ///
  /// In pt, this message translates to:
  /// **'Continuar cadastro'**
  String get bankContinueButton;

  /// No description provided for @bankActivePaymentInfo.
  ///
  /// In pt, this message translates to:
  /// **'Pagamentos são depositados em até 2 dias úteis após cada fase ser validada pelo cliente.'**
  String get bankActivePaymentInfo;

  /// No description provided for @bankUpdateButton.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar dados bancários'**
  String get bankUpdateButton;

  /// No description provided for @bankRestrictedDefault.
  ///
  /// In pt, this message translates to:
  /// **'Há pendências bloqueando os recebimentos.'**
  String get bankRestrictedDefault;

  /// No description provided for @bankResolveButton.
  ///
  /// In pt, this message translates to:
  /// **'Resolver pendências'**
  String get bankResolveButton;

  /// No description provided for @bankStatusActive.
  ///
  /// In pt, this message translates to:
  /// **'Ativo'**
  String get bankStatusActive;

  /// No description provided for @bankStatusPending.
  ///
  /// In pt, this message translates to:
  /// **'Em verificação'**
  String get bankStatusPending;

  /// No description provided for @bankStatusRestricted.
  ///
  /// In pt, this message translates to:
  /// **'Suspenso'**
  String get bankStatusRestricted;

  /// No description provided for @bankStatusNotConfigured.
  ///
  /// In pt, this message translates to:
  /// **'Não configurado'**
  String get bankStatusNotConfigured;

  /// No description provided for @bankAccountDefault.
  ///
  /// In pt, this message translates to:
  /// **'Conta bancária'**
  String get bankAccountDefault;

  /// No description provided for @bankOnboardingError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir o link de onboarding'**
  String get bankOnboardingError;

  /// No description provided for @bankRetryButton.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get bankRetryButton;

  /// No description provided for @bankStatusError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao verificar status: {error}'**
  String bankStatusError(String error);

  /// No description provided for @bankReqFullName.
  ///
  /// In pt, this message translates to:
  /// **'Nome completo'**
  String get bankReqFullName;

  /// No description provided for @bankReqBirthDate.
  ///
  /// In pt, this message translates to:
  /// **'Data de nascimento'**
  String get bankReqBirthDate;

  /// No description provided for @bankReqIdDocument.
  ///
  /// In pt, this message translates to:
  /// **'Documento de identidade'**
  String get bankReqIdDocument;

  /// No description provided for @bankReqAddress.
  ///
  /// In pt, this message translates to:
  /// **'Endereço residencial'**
  String get bankReqAddress;

  /// No description provided for @bankReqBankData.
  ///
  /// In pt, this message translates to:
  /// **'Dados bancários (IBAN ou conta)'**
  String get bankReqBankData;

  /// No description provided for @bankReqStripeTerms.
  ///
  /// In pt, this message translates to:
  /// **'Aceitar termos da Stripe'**
  String get bankReqStripeTerms;

  /// No description provided for @bankReqProfile.
  ///
  /// In pt, this message translates to:
  /// **'Perfil profissional'**
  String get bankReqProfile;

  /// No description provided for @bankStripeDisabledPastDue.
  ///
  /// In pt, this message translates to:
  /// **'Faltam informações ou há dados em atraso na sua conta. Conclua o cadastro na Stripe para voltar a receber.'**
  String get bankStripeDisabledPastDue;

  /// No description provided for @bankStripeDisabledPendingVerification.
  ///
  /// In pt, this message translates to:
  /// **'A Stripe está a verificar os seus dados. Volte mais tarde ou complete o que pedirem no formulário.'**
  String get bankStripeDisabledPendingVerification;

  /// No description provided for @bankStripeDisabledUnderReview.
  ///
  /// In pt, this message translates to:
  /// **'A sua conta está em análise. Aguarde ou atualize os dados se a Stripe pedir.'**
  String get bankStripeDisabledUnderReview;

  /// No description provided for @bankStripeDisabledRejected.
  ///
  /// In pt, this message translates to:
  /// **'A conta de pagamentos não foi aceite pela Stripe. Contacte o suporte OX se precisar de ajuda.'**
  String get bankStripeDisabledRejected;

  /// No description provided for @bankReqProductDescription.
  ///
  /// In pt, this message translates to:
  /// **'Descrição da atividade ou dos serviços'**
  String get bankReqProductDescription;

  /// No description provided for @bankReqBusinessType.
  ///
  /// In pt, this message translates to:
  /// **'Tipo de negócio (individual ou empresa)'**
  String get bankReqBusinessType;

  /// No description provided for @bankReqRepresentativeDetails.
  ///
  /// In pt, this message translates to:
  /// **'Dados do representante legal'**
  String get bankReqRepresentativeDetails;

  /// No description provided for @bankReqRepresentativeAddress.
  ///
  /// In pt, this message translates to:
  /// **'Morada do representante'**
  String get bankReqRepresentativeAddress;

  /// No description provided for @bankReqCompanyInfo.
  ///
  /// In pt, this message translates to:
  /// **'Dados da empresa'**
  String get bankReqCompanyInfo;

  /// No description provided for @bankReqContactEmailPhone.
  ///
  /// In pt, this message translates to:
  /// **'Email ou telefone de contacto'**
  String get bankReqContactEmailPhone;

  /// No description provided for @bankReqWebsiteOrSocial.
  ///
  /// In pt, this message translates to:
  /// **'Site ou presença online do negócio'**
  String get bankReqWebsiteOrSocial;

  /// No description provided for @bankReqAdditionalVerification.
  ///
  /// In pt, this message translates to:
  /// **'Documento ou verificação extra pedida pela Stripe'**
  String get bankReqAdditionalVerification;

  /// No description provided for @bankReqFallbackStripeForm.
  ///
  /// In pt, this message translates to:
  /// **'Informação em falta — complete no formulário seguro da Stripe'**
  String get bankReqFallbackStripeForm;

  /// No description provided for @bankConnectBrowserHint.
  ///
  /// In pt, this message translates to:
  /// **'Abre o fluxo da Stripe no navegador. Ao terminar, volte a este app para atualizar o estado da conta.'**
  String get bankConnectBrowserHint;

  /// No description provided for @stripeConnectBannerMessage.
  ///
  /// In pt, this message translates to:
  /// **'Conta de pagamentos incompleta. Conclua no perfil para receber transferências.'**
  String get stripeConnectBannerMessage;

  /// No description provided for @stripeConnectBannerCta.
  ///
  /// In pt, this message translates to:
  /// **'Ir ao perfil'**
  String get stripeConnectBannerCta;

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
  /// **'O cliente criou o projeto \"{projectTitle}\".'**
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

  /// No description provided for @notifProjectClosingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Projeto em encerramento'**
  String get notifProjectClosingTitle;

  /// No description provided for @notifProjectClosingBody.
  ///
  /// In pt, this message translates to:
  /// **'Todas as fases de \"{projectTitle}\" foram validadas. Encerramento em curso.'**
  String notifProjectClosingBody(String projectTitle);

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

  /// No description provided for @notifProjectUpdatedGenericTitle.
  ///
  /// In pt, this message translates to:
  /// **'Projeto atualizado'**
  String get notifProjectUpdatedGenericTitle;

  /// No description provided for @notifProjectUpdatedGenericBody.
  ///
  /// In pt, this message translates to:
  /// **'O status do projeto \"{projectTitle}\" mudou.'**
  String notifProjectUpdatedGenericBody(String projectTitle);

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
      String projectTitle, String phaseName);

  /// No description provided for @notifPhaseUnderReviewClientTitle.
  ///
  /// In pt, this message translates to:
  /// **'Fase em revisão'**
  String get notifPhaseUnderReviewClientTitle;

  /// No description provided for @notifPhaseUnderReviewClientBody.
  ///
  /// In pt, this message translates to:
  /// **'A fase \"{phaseName}\" de \"{projectTitle}\" está aguardando sua validação.'**
  String notifPhaseUnderReviewClientBody(String phaseName, String projectTitle);

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

  /// No description provided for @notifPhaseRejectedClientTitle.
  ///
  /// In pt, this message translates to:
  /// **'Rejeição registrada'**
  String get notifPhaseRejectedClientTitle;

  /// No description provided for @notifPhaseRejectedClientBody.
  ///
  /// In pt, this message translates to:
  /// **'A fase \"{phaseName}\" foi marcada como rejeitada no projeto \"{projectTitle}\".'**
  String notifPhaseRejectedClientBody(String phaseName, String projectTitle);

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

  /// No description provided for @notifContractSignedAdminTitle.
  ///
  /// In pt, this message translates to:
  /// **'Contrato assinado'**
  String get notifContractSignedAdminTitle;

  /// No description provided for @notifContractSignedAdminBody.
  ///
  /// In pt, this message translates to:
  /// **'Projeto \"{projectTitle}\" — contrato assinado.'**
  String notifContractSignedAdminBody(String projectTitle);

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

  /// No description provided for @notifPaymentFailedAdminTitle.
  ///
  /// In pt, this message translates to:
  /// **'Falha no pagamento'**
  String get notifPaymentFailedAdminTitle;

  /// No description provided for @notifPaymentFailedAdminBody.
  ///
  /// In pt, this message translates to:
  /// **'Projeto \"{projectTitle}\" — pagamento falhou.'**
  String notifPaymentFailedAdminBody(String projectTitle);
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
