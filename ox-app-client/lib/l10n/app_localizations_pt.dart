// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

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
  String get loginOrContinueWith => 'ou continue com';

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
  String get registerAccountType => 'Tipo de conta';

  @override
  String get forgotPasswordSubtitle =>
      'Digite seu e-mail e enviaremos um link para redefinir sua senha.';

  @override
  String get forgotPasswordSendButton => 'Enviar link de redefinição';

  @override
  String get forgotPasswordSuccessTitle => 'E-mail enviado!';

  @override
  String forgotPasswordSuccessBody(String email) {
    return 'Verifique sua caixa de entrada em $email e clique no link para redefinir sua senha.';
  }

  @override
  String get forgotPasswordBackToLogin => 'Voltar ao login';

  @override
  String get resetPasswordTitle => 'Nova senha';

  @override
  String get resetPasswordSubtitle => 'Digite e confirme sua nova senha.';

  @override
  String get resetPasswordNewLabel => 'Nova senha';

  @override
  String get resetPasswordConfirmLabel => 'Confirmar nova senha';

  @override
  String get resetPasswordButton => 'Redefinir senha';

  @override
  String get resetPasswordSuccess => 'Senha redefinida com sucesso!';

  @override
  String get profileTitle => 'Meu Perfil';

  @override
  String get profileLogoutTitle => 'Sair';

  @override
  String get profileLogoutConfirm => 'Tem certeza que deseja sair?';

  @override
  String get profileLogoutButton => 'Sair da conta';

  @override
  String get profilePaymentMethods => 'Métodos de pagamento';

  @override
  String get profilePaymentMethodsSubtitle =>
      'Cartões salvos para pagamentos rápidos';

  @override
  String get profilePhotoTitle => 'Foto de perfil';

  @override
  String get profilePhotoChangeHint => 'Toque para alterar';

  @override
  String get profilePhotoGallery => 'Galeria';

  @override
  String get profilePhotoCamera => 'Câmera';

  @override
  String get profilePhotoRemove => 'Remover foto';

  @override
  String get profilePhotoPromptTitle => 'Adicione uma foto de perfil';

  @override
  String get profilePhotoPromptBody =>
      'Ajuda a personalizar a sua conta. Pode alterar mais tarde nas definições de perfil.';

  @override
  String get profilePhotoPromptLater => 'Agora não';

  @override
  String get profilePhotoUploadError =>
      'Não foi possível enviar a foto. Tente novamente.';

  @override
  String get profilePhotoSizeError =>
      'A imagem é demasiado grande (máx. 5 MB).';

  @override
  String get profilePhotoTypeError => 'Use JPEG ou PNG.';

  @override
  String get profilePhotoRemoveMessage => 'A foto será removida da sua conta.';

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
  String get projectsEmpty => 'Sua obra vai aparecer aqui';

  @override
  String get projectsEmptySubtitle =>
      'Quando uma obra for criada para você ou quando adicionar uma por link de convite, ela aparecerá nesta lista.';

  @override
  String get projectsCreateButton => 'Criar projeto';

  @override
  String get projectsLoadError => 'Erro ao carregar projetos';

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
  String get projectDetailInfoSection => 'INFORMAÇÕES';

  @override
  String get projectDetailPhasesSection => 'FASES';

  @override
  String get projectDetailPaymentSection => 'PAGAMENTO';

  @override
  String get projectDetailLocation => 'Local';

  @override
  String get projectRateWorkerSection => 'AVALIAÇÃO';

  @override
  String get projectRateWorkerSubtitle => 'Como foi o trabalho neste projeto?';

  @override
  String get projectRateWorkerFeedbackLabel => 'Comentário (opcional)';

  @override
  String get projectRateWorkerSubmit => 'Enviar avaliação';

  @override
  String get projectRateWorkerThanks => 'Obrigado pela sua avaliação.';

  @override
  String projectRateWorkerYourScore(int score) {
    return 'A sua nota: $score de 5';
  }

  @override
  String projectRateWorkerError(String message) {
    return 'Não foi possível enviar: $message';
  }

  @override
  String get projectDraftSaved => 'Rascunho salvo';

  @override
  String get projectDraftDescription =>
      'Este projeto está salvo como rascunho. Envie para validação para iniciar o processo de matching com trabalhadores.';

  @override
  String get projectSubmitForValidation => 'Enviar para Validação';

  @override
  String get projectSubmitSuccess => 'Projeto enviado para validação!';

  @override
  String projectSubmitError(String error) {
    return 'Erro ao enviar: $error';
  }

  @override
  String get projectSignContract => 'Assinar Contrato';

  @override
  String get projectSignContractDescription =>
      'Assine o contrato para confirmar sua participação neste projeto.';

  @override
  String get projectPaymentRequired => 'Pagamento necessário';

  @override
  String get projectPaymentRequiredDescription =>
      'O trabalhador foi designado e aguarda o início. Pague para liberar a execução das fases.';

  @override
  String get projectPayButton => 'Pagar e Iniciar Projeto';

  @override
  String get projectViewFinancials => 'Ver detalhes financeiros →';

  @override
  String projectPhaseLabel(int order, String name) {
    return 'Fase $order — $name';
  }

  @override
  String get projectEscrowLabel => 'Escrow';

  @override
  String get projectReleasedLabel => 'Liberado';

  @override
  String projectEscrowValue(String amount) {
    return '€ $amount bloqueado';
  }

  @override
  String projectCardPhase(int validated, int total) {
    return 'Fase $validated/$total';
  }

  @override
  String get phaseValidateButton => 'Validar';

  @override
  String get phaseStatusValidated => 'Validada';

  @override
  String get phaseStatusUnderReview => 'Em revisão';

  @override
  String get phaseStatusEvidenceUploaded => 'Evidências enviadas';

  @override
  String get phaseStatusInProgress => 'Em execução';

  @override
  String get phaseStatusRejected => 'Rejeitada';

  @override
  String get phaseStatusPending => 'Pendente';

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
  String createProjectStepLabel(int step) {
    return 'Novo Projeto — Etapa $step/3';
  }

  @override
  String get createProjectPhasesTitle => 'Fases do Projeto';

  @override
  String get createProjectPhaseNameLabel => 'Nome da fase';

  @override
  String get createProjectPhaseAmountLabel => 'Valor estimado (€)';

  @override
  String get createProjectSaveDraft => 'Salvar Rascunho';

  @override
  String get createProjectDraftSaved => 'Rascunho salvo!';

  @override
  String get createProjectSentForValidation =>
      'Projeto enviado para validação!';

  @override
  String get createProjectSelectDeadline => 'Selecionar prazo';

  @override
  String get createProjectInvalidAmount => 'Valor inválido';

  @override
  String get createProjectReviewTitle => 'Revisão';

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
  String get validatePhaseEvidenceSection => 'EVIDÊNCIAS DO TRABALHADOR';

  @override
  String get validatePhaseNoEvidence => 'Nenhuma evidência enviada';

  @override
  String get validatePhaseSuccess => 'Fase validada com sucesso!';

  @override
  String get validatePhaseApproveConfirmTitle => 'Aprovar Fase?';

  @override
  String get validatePhaseRejectConfirmTitle => 'Rejeitar Fase?';

  @override
  String get validatePhaseApproveConfirmBody =>
      'O pagamento da fase será liberado ao trabalhador.';

  @override
  String get validatePhaseRejectConfirmBody =>
      'O trabalhador deverá reenviar as evidências.';

  @override
  String get validatePhaseApproveButton => 'Aprovar';

  @override
  String get validatePhaseRejectButton => 'Rejeitar';

  @override
  String get validatePhaseApproveAction => '✓ Aprovar Fase';

  @override
  String get validatePhaseRejectAction => '✕ Rejeitar Fase';

  @override
  String validatePhaseAmountWarning(String amount) {
    return 'Ao aprovar, € $amount será liberado ao trabalhador.';
  }

  @override
  String validatePhaseDetailTitle(int order, String name) {
    return 'Validar — Fase $order: $name';
  }

  @override
  String get onboardingSkip => 'Pular';

  @override
  String get onboardingStart => 'Começar';

  @override
  String get onboardingPage1Title => 'Crie seu projeto';

  @override
  String get onboardingPage1Subtitle =>
      'Descreva o serviço, defina fases e orçamento com facilidade.';

  @override
  String get onboardingPage2Title => 'Encontramos o profissional';

  @override
  String get onboardingPage2Subtitle =>
      'Matching automático com trabalhadores certificados e bem avaliados.';

  @override
  String get onboardingPage3Title => 'Pague com segurança';

  @override
  String get onboardingPage3Subtitle =>
      'Escrow libera o valor só após sua aprovação de cada fase.';

  @override
  String get notificationsTitle => 'Notificações';

  @override
  String get notificationsMarkAllRead => 'Ler todas';

  @override
  String get notificationsEmpty => 'Nenhuma notificação';

  @override
  String get notificationsLoadError => 'Erro ao carregar';

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

  @override
  String get navProjects => 'Projetos';

  @override
  String get navNotifications => 'Notificações';

  @override
  String get navProfile => 'Perfil';

  @override
  String get pushChannelName => 'OX Notificações';

  @override
  String get pushChannelDescription => 'Notificações do OX Field Services';

  @override
  String get notifUserWelcomeTitle => 'Bem-vindo ao OX Field Service';

  @override
  String get notifUserWelcomeBody => 'Sua conta foi criada com sucesso.';

  @override
  String get notifProjectCreatedClientTitle => 'Projeto criado';

  @override
  String notifProjectCreatedClientBody(String projectTitle) {
    return 'O projeto \"$projectTitle\" foi criado.';
  }

  @override
  String get notifProjectCreatedAdminTitle => 'Novo projeto';

  @override
  String notifProjectCreatedAdminBody(String projectTitle) {
    return 'Cliente criou o projeto \"$projectTitle\".';
  }

  @override
  String get notifProjectInValidationTitle => 'Projeto em validação';

  @override
  String notifProjectInValidationBody(String projectTitle) {
    return '\"$projectTitle\" foi enviado para validação.';
  }

  @override
  String get notifProjectMatchedTitle => 'Projeto atualizado';

  @override
  String notifProjectMatchedBody(String projectTitle) {
    return 'O projeto \"$projectTitle\" avançou no fluxo.';
  }

  @override
  String get notifProjectActivatedTitle => 'Projeto ativo';

  @override
  String notifProjectActivatedBody(String projectTitle) {
    return 'O projeto \"$projectTitle\" está em andamento.';
  }

  @override
  String get notifProjectClosingTitle => 'Projeto em encerramento';

  @override
  String notifProjectClosingBody(String projectTitle) {
    return 'Todas as fases de \"$projectTitle\" foram validadas.';
  }

  @override
  String get notifProjectClosedTitle => 'Projeto encerrado';

  @override
  String notifProjectClosedBody(String projectTitle) {
    return 'O projeto \"$projectTitle\" foi encerrado.';
  }

  @override
  String get notifProjectRejectedTitle => 'Projeto rejeitado';

  @override
  String notifProjectRejectedBody(String projectTitle) {
    return 'O projeto \"$projectTitle\" foi rejeitado.';
  }

  @override
  String get notifPhaseStartedTitle => 'Fase iniciada';

  @override
  String notifPhaseStartedBody(String phaseName, String projectTitle) {
    return 'A fase \"$phaseName\" do projeto \"$projectTitle\" foi iniciada.';
  }

  @override
  String get notifPhaseEvidenceUploadedClientTitle => 'Novas evidências';

  @override
  String notifPhaseEvidenceUploadedClientBody(
      String phaseName, String projectTitle) {
    return 'O trabalhador enviou evidências para a fase \"$phaseName\" em \"$projectTitle\".';
  }

  @override
  String get notifPhaseEvidenceUploadedAdminTitle => 'Evidências recebidas';

  @override
  String notifPhaseEvidenceUploadedAdminBody(
      String phaseName, String projectTitle) {
    return 'Projeto \"$projectTitle\" — fase \"$phaseName\".';
  }

  @override
  String get notifPhaseUnderReviewTitle => 'Fase em revisão';

  @override
  String notifPhaseUnderReviewBody(String phaseName, String projectTitle) {
    return 'A fase \"$phaseName\" de \"$projectTitle\" aguarda sua validação.';
  }

  @override
  String get notifPhaseValidatedClientTitle => 'Fase validada';

  @override
  String notifPhaseValidatedClientBody(String phaseName, String projectTitle) {
    return 'A fase \"$phaseName\" do projeto \"$projectTitle\" foi validada.';
  }

  @override
  String get notifPhaseValidatedWorkerTitle => 'Fase aprovada';

  @override
  String notifPhaseValidatedWorkerBody(String phaseName, String projectTitle) {
    return 'Sua fase \"$phaseName\" foi aprovada em \"$projectTitle\".';
  }

  @override
  String get notifPhaseRejectedWorkerTitle => 'Fase rejeitada';

  @override
  String notifPhaseRejectedWorkerBody(String phaseName, String projectTitle) {
    return 'A fase \"$phaseName\" de \"$projectTitle\" foi rejeitada e precisa de ajustes.';
  }

  @override
  String get notifPhaseRejectedClientTitle => 'Rejeição registrada';

  @override
  String notifPhaseRejectedClientBody(String phaseName, String projectTitle) {
    return 'A fase \"$phaseName\" de \"$projectTitle\" foi marcada como rejeitada.';
  }

  @override
  String get notifContractCreatedTitle => 'Novo contrato';

  @override
  String notifContractCreatedBody(String projectTitle) {
    return 'Você foi atribuído ao projeto \"$projectTitle\". Assine o contrato para continuar.';
  }

  @override
  String get notifWorkerInvitedTitle => 'Convite para projeto';

  @override
  String notifWorkerInvitedBody(String projectTitle) {
    return 'Você foi selecionado para o projeto \"$projectTitle\".';
  }

  @override
  String get notifWorkerAssignedTitle => 'Atribuição confirmada';

  @override
  String notifWorkerAssignedBody(String projectTitle) {
    return 'Você está atribuído ao projeto \"$projectTitle\".';
  }

  @override
  String get notifContractSignedClientTitle => 'Contrato assinado';

  @override
  String notifContractSignedClientBody(String projectTitle) {
    return 'O contrato do projeto \"$projectTitle\" foi assinado pelo trabalhador.';
  }

  @override
  String get notifContractSignedWorkerTitle => 'Contrato assinado';

  @override
  String notifContractSignedWorkerBody(String projectTitle) {
    return 'Você assinou o contrato do projeto \"$projectTitle\".';
  }

  @override
  String get notifEscrowHeldTitle => 'Pagamento em escrow';

  @override
  String notifEscrowHeldBody(String projectTitle) {
    return 'O valor do projeto \"$projectTitle\" está retido em escrow.';
  }

  @override
  String get notifPaymentTransferredWorkerTitle => 'Transferência recebida';

  @override
  String notifPaymentTransferredWorkerBody(String amount, String projectTitle) {
    return 'Foi creditado € $amount no projeto \"$projectTitle\".';
  }

  @override
  String get notifPaymentTransferredAdminTitle => 'Pagamento transferido';

  @override
  String notifPaymentTransferredAdminBody(String projectTitle) {
    return 'Projeto \"$projectTitle\" — transferência ao trabalhador registrada.';
  }

  @override
  String get notifEscrowReleasedWorkerTitle => 'Pagamento liberado';

  @override
  String notifEscrowReleasedWorkerBody(String projectTitle) {
    return 'O pagamento do projeto \"$projectTitle\" foi liberado.';
  }

  @override
  String get notifEscrowReleasedClientTitle => 'Pagamento concluído';

  @override
  String notifEscrowReleasedClientBody(String projectTitle) {
    return 'O pagamento do projeto \"$projectTitle\" foi transferido com sucesso.';
  }

  @override
  String get notifPaymentFailedTitle => 'Falha no pagamento';

  @override
  String notifPaymentFailedBody(String projectTitle) {
    return 'Não foi possível concluir o pagamento do projeto \"$projectTitle\".';
  }

  @override
  String get notifWorkerRatedTitle => 'Nova avaliação';

  @override
  String notifWorkerRatedBody(String score, String projectTitle) {
    return 'Você recebeu nota $score no projeto \"$projectTitle\".';
  }

  @override
  String get notifInviteRedeemedClientTitle => 'Obra adicionada à sua conta';

  @override
  String notifInviteRedeemedClientBody(String projectTitle) {
    return 'Pode acompanhar as fases e finalizar o pagamento de \"$projectTitle\".';
  }

  @override
  String get notifInviteRedeemedAdminTitle => 'Convite resgatado';

  @override
  String notifInviteRedeemedAdminBody(String clientName, String projectTitle) {
    return '$clientName aceitou o convite para a obra \"$projectTitle\".';
  }

  @override
  String get paymentTitle => 'Pagamento';

  @override
  String get paymentConfirmTitle => 'Confirmar pagamento';

  @override
  String get paymentConfirmBody =>
      'O valor ficará bloqueado em escrow seguro. Será liberado para o trabalhador apenas após você validar cada fase do projeto.';

  @override
  String get paymentTestModeHint =>
      'Modo teste: use o cartão 4242 4242 4242 4242, qualquer data futura, qualquer CVC.';

  @override
  String get paymentPayNow => 'Pagar agora';

  @override
  String get paymentProcessing => 'Processando...';

  @override
  String get paymentAlreadyPaidSnack =>
      'Pagamento já foi efetuado para este contrato.';

  @override
  String get paymentDoneWaitingSnack =>
      'Pagamento realizado! Aguardando confirmação...';

  @override
  String get paymentErrorClientSecret =>
      'Sessão de pagamento não foi devolvida pelo servidor.';

  @override
  String get paymentMerchantDisplayName => 'OX Field Services';

  @override
  String get paymentStripePrimaryButton => 'Pagar';

  @override
  String get paymentEscrowStatusHeading => 'Status do Escrow';

  @override
  String get paymentEscrowBrand => 'Escrow';

  @override
  String get paymentEscrowStatusHeld => 'Bloqueado';

  @override
  String get paymentEscrowStatusReleased => 'Liberado';

  @override
  String get paymentEscrowStatusRefunded => 'Reembolsado';

  @override
  String get paymentTotalContractValue => 'Valor total do contrato';

  @override
  String get paymentDistributionHeading => 'DISTRIBUIÇÃO';

  @override
  String get paymentSplitWorker => 'Trabalhador (70%)';

  @override
  String get paymentSplitPlatform => 'Plataforma OX (30%)';

  @override
  String get paymentEscrowReleaseInfo =>
      'O pagamento é liberado automaticamente após você aprovar cada fase do projeto.';

  @override
  String get paymentCancelledStripe => 'Pagamento cancelado';

  @override
  String paymentErrorLine(String details) {
    return 'Erro: $details';
  }

  @override
  String get redeemTitle => 'Adicionar obra por link';

  @override
  String get redeemSubtitle =>
      'Cole o link enviado pelo administrador ou insira o token do convite.';

  @override
  String get redeemInputHint => 'https://app.ox.example/i/... ou token';

  @override
  String get redeemAddByLink => 'Adicionar por link';

  @override
  String redeemPreviewClient(String name) {
    return 'Cliente: $name';
  }

  @override
  String redeemPreviewExpires(String date) {
    return 'Expira em $date';
  }

  @override
  String get redeemButton => 'Adicionar à minha conta';

  @override
  String get redeemRetry => 'Tentar de novo';

  @override
  String get redeemErrorExpired =>
      'Este convite expirou. Peça um novo link ao administrador.';

  @override
  String get redeemErrorRevoked =>
      'Este convite foi revogado. Contacte o administrador.';

  @override
  String get redeemErrorWrongEmail =>
      'Este link foi gerado para outro email. Entre com a conta correta ou peça um novo link.';

  @override
  String get redeemErrorGeneric =>
      'Convite inválido. Verifique o link e tente novamente.';

  @override
  String get redeemErrorNotFound =>
      'Convite não encontrado neste servidor. A app deve usar o mesmo URL da API que o painel admin — ao compilar, defina --dart-define=API_BASE_URL=https://seu-backend…';

  @override
  String get redeemErrorNetwork =>
      'Não foi possível contactar o servidor. Verifique a rede e o endereço da API.';

  @override
  String get redeemErrorRoleMustBeClient =>
      'Só contas com perfil cliente podem resgatar o convite. Confirme o seu papel em POST /auth/sync.';
}
