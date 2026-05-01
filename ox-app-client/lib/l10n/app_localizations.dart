import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
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
    Locale('en'),
    Locale('nl'),
    Locale('pt')
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
  /// **'Nenhum projeto ainda'**
  String get projectsEmpty;

  /// No description provided for @projectsEmptySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Crie seu primeiro projeto para encontrar um profissional.'**
  String get projectsEmptySubtitle;

  /// No description provided for @projectsCreateButton.
  ///
  /// In pt, this message translates to:
  /// **'Criar projeto'**
  String get projectsCreateButton;

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
      <String>['en', 'nl', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
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
