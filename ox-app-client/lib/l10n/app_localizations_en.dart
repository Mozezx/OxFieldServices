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
  String get loginTitle => 'Bem-vindo de volta';

  @override
  String get loginSubtitle => 'Entre na sua conta OX';

  @override
  String get loginEmailLabel => 'E-mail';

  @override
  String get loginPasswordLabel => 'Senha';

  @override
  String get loginButton => 'Entrar';

  @override
  String get loginGoogleButton => 'Entrar com Google';

  @override
  String get loginNoAccount => 'Não tem conta? Cadastre-se';

  @override
  String get loginForgotPassword => 'Esqueceu a senha?';

  @override
  String get registerTitle => 'Criar conta';

  @override
  String get registerNameLabel => 'Nome completo';

  @override
  String get registerConfirmPasswordLabel => 'Confirmar senha';

  @override
  String get registerButton => 'Criar conta';

  @override
  String get registerHasAccount => 'Já tenho conta';

  @override
  String get registerRoleClient => 'Sou cliente';

  @override
  String get registerRoleWorker => 'Sou trabalhador';

  @override
  String get projectsTitle => 'Meus Projetos';

  @override
  String projectsActive(int count) {
    return '$count projetos ativos';
  }

  @override
  String get projectsFilterAll => 'Todos';

  @override
  String get projectsFilterActive => 'Ativos';

  @override
  String get projectsFilterClosed => 'Fechados';

  @override
  String get projectsEmpty => 'Nenhum projeto ainda';

  @override
  String get projectsEmptySubtitle =>
      'Crie seu primeiro projeto para encontrar um profissional.';

  @override
  String get projectsCreateButton => 'Criar projeto';

  @override
  String get projectDetailTitle => 'Detalhes do Projeto';

  @override
  String get projectDetailWorker => 'Trabalhador';

  @override
  String get projectDetailBudget => 'Valor Total';

  @override
  String get projectDetailDeadline => 'Prazo';

  @override
  String get projectDetailPhases => 'Fases';

  @override
  String get projectDetailPayment => 'Pagamento';

  @override
  String get createProjectTitle => 'Novo Projeto';

  @override
  String get createProjectStep1 => 'Informações Básicas';

  @override
  String get createProjectStep2 => 'Fases';

  @override
  String get createProjectStep3 => 'Revisão';

  @override
  String get createProjectTitleLabel => 'Título do projeto';

  @override
  String get createProjectDescLabel => 'Descrição';

  @override
  String get createProjectLocationLabel => 'Localização';

  @override
  String get createProjectBudgetLabel => 'Orçamento total (€)';

  @override
  String get createProjectDeadlineLabel => 'Prazo';

  @override
  String get createProjectNextButton => 'Continuar';

  @override
  String get createProjectSubmitButton => 'Criar Projeto';

  @override
  String get createProjectAddPhase => '+ Adicionar Fase';

  @override
  String get validatePhaseTitle => 'Validar Fase';

  @override
  String get validatePhaseEvidence => 'Evidências do Trabalhador';

  @override
  String get validatePhaseApprove => 'Aprovar Fase';

  @override
  String get validatePhaseReject => 'Rejeitar Fase';

  @override
  String get validatePhaseWarning =>
      'Ao aprovar, o valor será liberado ao trabalhador.';

  @override
  String get statusDraft => 'Rascunho';

  @override
  String get statusInValidation => 'Em Validação';

  @override
  String get statusMatched => 'Match feito';

  @override
  String get statusContractSigned => 'Contrato assinado';

  @override
  String get statusActiveEscrow => 'Escrow ativo';

  @override
  String get statusInExecution => 'Em Execução';

  @override
  String get statusClosing => 'Encerrando';

  @override
  String get statusClosed => 'Concluído';

  @override
  String get statusRejected => 'Rejeitado';

  @override
  String get statusAwaitingMatch => 'Aguardando match';

  @override
  String get errorGeneric => 'Ocorreu um erro. Tente novamente.';

  @override
  String get errorFieldRequired => 'Campo obrigatório';

  @override
  String get errorInvalidEmail => 'E-mail inválido';

  @override
  String get errorPasswordShort => 'Mínimo 6 caracteres';

  @override
  String get errorPasswordMismatch => 'Senhas não conferem';

  @override
  String get commonLoading => 'Carregando...';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get commonSave => 'Salvar';

  @override
  String get commonBack => 'Voltar';

  @override
  String get commonOr => 'ou';
}
