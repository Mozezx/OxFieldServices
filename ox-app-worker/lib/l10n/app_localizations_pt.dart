// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'OX Trabalhador';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Senha';

  @override
  String get errorFieldRequired => 'Campo obrigatório';

  @override
  String get errorInvalidEmail => 'E-mail inválido';

  @override
  String get errorPasswordShort => 'Mínimo 6 caracteres';

  @override
  String get errorPasswordMismatch => 'Senhas não coincidem';

  @override
  String commonErrorWithMessage(String message) {
    return 'Erro: $message';
  }

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get loginSubtitle => 'Entre na sua conta de trabalhador';

  @override
  String get loginButton => 'Entrar';

  @override
  String get loginForgotPassword => 'Esqueceu a senha?';

  @override
  String get loginOrContinueWith => 'ou continue com';

  @override
  String get loginNoAccount => 'Não tem conta? ';

  @override
  String get loginRegisterLink => 'Cadastre-se';

  @override
  String get registerTitle => 'Criar conta de trabalhador';

  @override
  String get registerNameLabel => 'Nome completo';

  @override
  String get registerConfirmPasswordLabel => 'Confirmar senha';

  @override
  String get registerButton => 'Criar conta';

  @override
  String get registerHasAccount => 'Já tenho conta';

  @override
  String get registerWorkerBadge => 'Conta de trabalhador';

  @override
  String get forgotPasswordTitle => 'Esqueceu a senha?';

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
  String get onboardingSkip => 'Pular';

  @override
  String get onboardingContinue => 'Continuar';

  @override
  String get onboardingStart => 'Começar';

  @override
  String get onboardingPage1Title => 'Oportunidades para você';

  @override
  String get onboardingPage1Subtitle =>
      'Veja projetos e convites compatíveis com suas habilidades e disponibilidade.';

  @override
  String get onboardingPage2Title => 'Execute com clareza';

  @override
  String get onboardingPage2Subtitle =>
      'Acompanhe fases, envie evidências e mantenha o cliente informado.';

  @override
  String get onboardingPage3Title => 'Receba com segurança';

  @override
  String get onboardingPage3Subtitle =>
      'Pagamentos via Stripe Connect após a aprovação de cada fase pelo cliente.';

  @override
  String get navJobs => 'Jobs';

  @override
  String get navExecution => 'Em Execução';

  @override
  String get navNotifications => 'Notificações';

  @override
  String get navPayments => 'Pagamentos';

  @override
  String get navProfile => 'Perfil';

  @override
  String get pushChannelName => 'OX Notificações';

  @override
  String get pushChannelDescription => 'Notificações do OX Field Services';

  @override
  String get workerStatusAvailable => 'Disponível';

  @override
  String get workerStatusUnavailable => 'Indisponível';

  @override
  String workerRating(String rating) {
    return 'Avaliação: $rating';
  }

  @override
  String get defaultWorkerName => 'Trabalhador';

  @override
  String get jobsActiveSection => 'MEUS JOBS ATIVOS';

  @override
  String get jobsAvailableSection => 'JOBS DISPONÍVEIS PARA VOCÊ';

  @override
  String get jobsNoActive => 'Nenhum job ativo';

  @override
  String get jobsNoActiveSubtitle => 'Aceite um job disponível para começar.';

  @override
  String get jobsNoAvailable => 'Seu trabalho vai aparecer aqui';

  @override
  String get jobsNoAvailableSubtitle =>
      'Novos trabalhos compatíveis com o seu perfil aparecerão aqui quando estiverem disponíveis.';

  @override
  String get jobsLoadError => 'Erro ao carregar jobs';

  @override
  String get jobCompatibility => 'Compatibilidade: ';

  @override
  String get jobContinueExecution => 'Continuar execução';

  @override
  String get jobViewDetails => 'Ver detalhes';

  @override
  String phaseOrderLabel(int order) {
    return 'Fase $order';
  }

  @override
  String phaseOrderAndName(int order, String name) {
    return 'Fase $order — $name';
  }

  @override
  String get jobDetailTitle => 'Detalhes do Job';

  @override
  String get jobInfoSection => 'INFORMAÇÕES';

  @override
  String get jobPhasesPaymentsSection => 'FASES E PAGAMENTOS';

  @override
  String get jobInfoDeadline => 'Prazo';

  @override
  String get jobInfoLocation => 'Local';

  @override
  String get jobInfoDescription => 'Descrição';

  @override
  String get jobTotal => 'Total';

  @override
  String get jobAcceptedSuccess => 'Job aceito com sucesso!';

  @override
  String get jobsNoContractError =>
      'Nenhum contrato encontrado para este projeto. Aguarde a atribuição do admin.';

  @override
  String get jobAcceptButton => 'Aceitar Job';

  @override
  String get jobDeclineButton => 'Recusar';

  @override
  String get jobAwaitingPaymentMsg =>
      'Contrato assinado. Aguardando o cliente efetuar o pagamento para iniciar a execução.';

  @override
  String get jobAwaitingStartMsg =>
      'Pagamento confirmado! O projeto será ativado em breve e as fases aparecerão na aba \"Em Execução\".';

  @override
  String get jobAcceptDialogTitle => 'Aceitar Job';

  @override
  String get jobAcceptDialogContent =>
      'Ao aceitar, você se compromete a executar todas as fases conforme acordado. Deseja continuar?';

  @override
  String get dialogAccept => 'Aceitar';

  @override
  String get statusInExecution => 'Em execução';

  @override
  String get statusActiveEscrow => 'Escrow ativo';

  @override
  String get statusContractSigned => 'Contrato assinado';

  @override
  String get executionTitle => 'Em Execução';

  @override
  String get executionNoPhases => 'Nenhuma fase em execução';

  @override
  String get executionNoPhasesSubtitle =>
      'Quando você aceitar um job e o cliente pagar, suas fases aparecerão aqui para você executar.';

  @override
  String executionLoadError(String error) {
    return 'Erro ao carregar fases: $error';
  }

  @override
  String get phaseExecutionTitle => 'Execução da Fase';

  @override
  String get phaseChecklist => 'CHECKLIST DA FASE';

  @override
  String get phaseChecklistItemMaterials => 'Materiais separados';

  @override
  String get phaseChecklistItemPpe => 'EPIs utilizados';

  @override
  String get phaseChecklistItemWorkStarted => 'Trabalho iniciado';

  @override
  String get phaseChecklistItemSafety => 'Verificação de segurança';

  @override
  String get phaseChecklistItemPhotoDoc => 'Documentação fotográfica';

  @override
  String get phaseEvidences => 'EVIDÊNCIAS';

  @override
  String phaseEvidenceCount(int images, int videos) {
    return '$images foto(s) • $videos vídeo(s)';
  }

  @override
  String phaseAmountLabel(String amount) {
    return '€ $amount nesta fase';
  }

  @override
  String get phaseReadyMsg =>
      'Pronto para começar? Inicie a fase para liberar o upload de evidências.';

  @override
  String get phaseStartButton => 'Iniciar Fase';

  @override
  String get phaseErrorNotFound => 'Fase não encontrada.';

  @override
  String get phaseErrorNeedEvidenceBeforeSubmit =>
      'Faça upload de pelo menos uma evidência antes de enviar para revisão.';

  @override
  String get phaseAddMedia => 'Adicionar foto / vídeo';

  @override
  String get phaseSubmitButton => 'Enviar para Revisão';

  @override
  String get phaseAddMinPhotos =>
      'Adicione pelo menos 3 fotos/vídeos para poder enviar';

  @override
  String get phaseAddRequiredMedia =>
      'É obrigatório enviar 1 foto e 1 vídeo (30s a 1m30s).';

  @override
  String get phaseAwaitingReview =>
      'Aguardando o cliente revisar e validar a fase.';

  @override
  String get phaseSubmittedSuccess => 'Fase enviada para revisão do cliente!';

  @override
  String get phaseStartedSuccess =>
      'Fase iniciada! Você pode subir as evidências.';

  @override
  String get phaseSubmitDialogTitle => 'Enviar para Revisão';

  @override
  String get phaseSubmitDialogContent =>
      'O cliente será notificado para revisar as evidências enviadas. Ao aprovar, o pagamento desta fase será liberado para você.';

  @override
  String get dialogSend => 'Enviar';

  @override
  String get phaseNoActiveTitle => 'Nenhuma fase em execução';

  @override
  String get phaseNoActiveSubtitle =>
      'Aceite um job disponível para começar a executar suas fases.';

  @override
  String get phaseStatusInProgress => 'Em execução';

  @override
  String get phaseStatusUnderReview => 'Em revisão';

  @override
  String get phaseStatusEvidenceUploaded => 'Evidências enviadas';

  @override
  String get phaseStatusValidated => 'Validada';

  @override
  String get phaseStatusRejected => 'Rejeitada';

  @override
  String get phaseStatusPending => 'Pendente';

  @override
  String get phaseStatusAwaitingStart => 'Aguardando início';

  @override
  String uploadTitle(int count) {
    return 'Evidências ($count/2)';
  }

  @override
  String get uploadNoPhoto => 'Nenhuma foto selecionada';

  @override
  String get uploadMinPhotos => 'Mínimo 3 fotos para enviar a fase';

  @override
  String get uploadNoMediaSelected => 'Nenhuma evidência selecionada';

  @override
  String get uploadNeedPhotoAndVideo =>
      'Obrigatório: 1 foto e 1 vídeo entre 30s e 1m30s';

  @override
  String get uploadSelectedPhoto => 'Foto selecionada';

  @override
  String get uploadSelectedVideo => 'Vídeo selecionado';

  @override
  String uploadSelectedVideoWithDuration(String duration) {
    return 'Vídeo selecionado ($duration)';
  }

  @override
  String get uploadRecordVideo => 'Gravar vídeo';

  @override
  String get uploadVideoFromGallery => 'Vídeo da galeria';

  @override
  String get uploadConfirmRequired => 'Enviar foto e vídeo';

  @override
  String get uploadVideoDurationInvalid =>
      'O vídeo deve ter entre 30s e 1m30s.';

  @override
  String get uploadTakePhoto => 'Tirar foto';

  @override
  String get uploadFromGallery => 'Da galeria';

  @override
  String uploadConfirmButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Confirmar ($count arquivos)',
      one: 'Confirmar (1 arquivo)',
    );
    return '$_temp0';
  }

  @override
  String get uploadUploading => 'Enviando...';

  @override
  String get uploadSuccess => 'Evidências enviadas com sucesso!';

  @override
  String uploadError(String error) {
    return 'Erro no upload: $error';
  }

  @override
  String get notificationsTitle => 'Notificações';

  @override
  String get notificationsMarkAllRead => 'Ler todas';

  @override
  String get notificationsEmpty => 'Nenhuma notificação';

  @override
  String get notificationsLoadError => 'Erro ao carregar';

  @override
  String notificationsLoadErrorWithDetail(String error) {
    return 'Erro ao carregar: $error';
  }

  @override
  String get paymentsTitle => 'Meus Pagamentos';

  @override
  String get paymentsTotalReceived => 'TOTAL RECEBIDO';

  @override
  String get paymentsReleasedLabel => 'Pagamentos liberados';

  @override
  String get paymentsLoadError => 'Erro ao carregar pagamentos';

  @override
  String get paymentsEmpty => 'Nenhum pagamento ainda';

  @override
  String get paymentsEmptySubtitle =>
      'Os pagamentos aparecerão aqui conforme suas fases forem validadas.';

  @override
  String get paymentsConnectSetupMessage =>
      'Configure sua conta para receber pagamentos. O botão abre o mesmo fluxo seguro da Stripe usado no perfil.';

  @override
  String get paymentStatusReleased => 'Liberado';

  @override
  String paymentStatusReleasedOn(String date) {
    return 'Liberado em $date';
  }

  @override
  String get paymentStatusPending => 'Aguardando liberação';

  @override
  String get paymentDefaultTitle => 'Pagamento';

  @override
  String get profileTitle => 'Meu Perfil';

  @override
  String get profileLogoutTitle => 'Sair';

  @override
  String get profileLogoutConfirm => 'Deseja sair da sua conta?';

  @override
  String get profileStatusSection => 'STATUS';

  @override
  String get profileSkillsSection => 'HABILIDADES';

  @override
  String get profileAvailabilityLabel => 'Disponibilidade';

  @override
  String get profileShelterLabel => 'Certificação Shelter';

  @override
  String get profileCertifiedValue => 'Certificado';

  @override
  String get profileNotCertifiedValue => 'Não certificado';

  @override
  String get profileSkillsHint => 'Toque nas habilidades para selecioná-las';

  @override
  String get profileMarkUnavailable => 'Marcar como Indisponível';

  @override
  String get profileMarkAvailable => 'Marcar como Disponível';

  @override
  String profileSignoutError(String error) {
    return 'Erro ao sair: $error';
  }

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
  String get bankSection => 'CONTA DE RECEBIMENTO';

  @override
  String get bankNotStartedDesc =>
      'Configure sua conta Stripe para receber pagamentos pelos jobs concluídos.';

  @override
  String get bankConfigureButton => 'Configurar agora';

  @override
  String get bankPendingDesc =>
      'Sua conta foi criada, mas algumas informações ainda são necessárias para começar a receber:';

  @override
  String get bankContinueButton => 'Continuar cadastro';

  @override
  String get bankActivePaymentInfo =>
      'Pagamentos são depositados em até 2 dias úteis após cada fase ser validada pelo cliente.';

  @override
  String get bankUpdateButton => 'Atualizar dados bancários';

  @override
  String get bankRestrictedDefault =>
      'Há pendências bloqueando os recebimentos.';

  @override
  String get bankResolveButton => 'Resolver pendências';

  @override
  String get bankStatusActive => 'Ativo';

  @override
  String get bankStatusPending => 'Em verificação';

  @override
  String get bankStatusRestricted => 'Suspenso';

  @override
  String get bankStatusNotConfigured => 'Não configurado';

  @override
  String get bankAccountDefault => 'Conta bancária';

  @override
  String get bankOnboardingError =>
      'Não foi possível abrir o link de onboarding';

  @override
  String get bankRetryButton => 'Tentar novamente';

  @override
  String bankStatusError(String error) {
    return 'Erro ao verificar status: $error';
  }

  @override
  String get bankReqFullName => 'Nome completo';

  @override
  String get bankReqBirthDate => 'Data de nascimento';

  @override
  String get bankReqIdDocument => 'Documento de identidade';

  @override
  String get bankReqAddress => 'Endereço residencial';

  @override
  String get bankReqBankData => 'Dados bancários (IBAN ou conta)';

  @override
  String get bankReqStripeTerms => 'Aceitar termos da Stripe';

  @override
  String get bankReqProfile => 'Perfil profissional';

  @override
  String get bankStripeDisabledPastDue =>
      'Faltam informações ou há dados em atraso na sua conta. Conclua o cadastro na Stripe para voltar a receber.';

  @override
  String get bankStripeDisabledPendingVerification =>
      'A Stripe está a verificar os seus dados. Volte mais tarde ou complete o que pedirem no formulário.';

  @override
  String get bankStripeDisabledUnderReview =>
      'A sua conta está em análise. Aguarde ou atualize os dados se a Stripe pedir.';

  @override
  String get bankStripeDisabledRejected =>
      'A conta de pagamentos não foi aceite pela Stripe. Contacte o suporte OX se precisar de ajuda.';

  @override
  String get bankReqProductDescription =>
      'Descrição da atividade ou dos serviços';

  @override
  String get bankReqBusinessType => 'Tipo de negócio (individual ou empresa)';

  @override
  String get bankReqRepresentativeDetails => 'Dados do representante legal';

  @override
  String get bankReqRepresentativeAddress => 'Morada do representante';

  @override
  String get bankReqCompanyInfo => 'Dados da empresa';

  @override
  String get bankReqContactEmailPhone => 'Email ou telefone de contacto';

  @override
  String get bankReqWebsiteOrSocial => 'Site ou presença online do negócio';

  @override
  String get bankReqAdditionalVerification =>
      'Documento ou verificação extra pedida pela Stripe';

  @override
  String get bankReqFallbackStripeForm =>
      'Informação em falta — complete no formulário seguro da Stripe';

  @override
  String get bankConnectBrowserHint =>
      'Abre o fluxo da Stripe no navegador. Ao terminar, volte a este app para atualizar o estado da conta.';

  @override
  String get stripeConnectBannerMessage =>
      'Conta de pagamentos incompleta. Conclua no perfil para receber transferências.';

  @override
  String get stripeConnectBannerCta => 'Ir ao perfil';

  @override
  String get notifUserWelcomeTitle => 'Bem-vindo ao OX Field Service';

  @override
  String get notifUserWelcomeBody => 'Sua conta foi criada com sucesso.';

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
  String get notifContractCreatedTitle => 'Novo contrato';

  @override
  String notifContractCreatedBody(String projectTitle) {
    return 'Você foi atribuído ao projeto \"$projectTitle\". Assine o contrato para continuar.';
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
  String get notifProjectActivatedTitle => 'Projeto ativo';

  @override
  String notifProjectActivatedBody(String projectTitle) {
    return 'O projeto \"$projectTitle\" está em andamento.';
  }

  @override
  String get notifPhaseStartedTitle => 'Fase iniciada';

  @override
  String notifPhaseStartedBody(String phaseName, String projectTitle) {
    return 'A fase \"$phaseName\" do projeto \"$projectTitle\" foi iniciada.';
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
  String get notifPaymentTransferredWorkerTitle => 'Transferência recebida';

  @override
  String notifPaymentTransferredWorkerBody(String amount, String projectTitle) {
    return 'Foi creditado € $amount no projeto \"$projectTitle\".';
  }

  @override
  String get notifEscrowReleasedWorkerTitle => 'Pagamento liberado';

  @override
  String notifEscrowReleasedWorkerBody(String projectTitle) {
    return 'O pagamento do projeto \"$projectTitle\" foi liberado.';
  }

  @override
  String get notifProjectClosedTitle => 'Projeto encerrado';

  @override
  String notifProjectClosedBody(String projectTitle) {
    return 'O projeto \"$projectTitle\" foi encerrado.';
  }

  @override
  String get notifWorkerRatedTitle => 'Nova avaliação';

  @override
  String notifWorkerRatedBody(String score, String projectTitle) {
    return 'Você recebeu nota $score no projeto \"$projectTitle\".';
  }

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
    return 'O cliente criou o projeto \"$projectTitle\".';
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
  String get notifProjectClosingTitle => 'Projeto em encerramento';

  @override
  String notifProjectClosingBody(String projectTitle) {
    return 'Todas as fases de \"$projectTitle\" foram validadas. Encerramento em curso.';
  }

  @override
  String get notifProjectRejectedTitle => 'Projeto rejeitado';

  @override
  String notifProjectRejectedBody(String projectTitle) {
    return 'O projeto \"$projectTitle\" foi rejeitado.';
  }

  @override
  String get notifProjectUpdatedGenericTitle => 'Projeto atualizado';

  @override
  String notifProjectUpdatedGenericBody(String projectTitle) {
    return 'O status do projeto \"$projectTitle\" mudou.';
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
      String projectTitle, String phaseName) {
    return 'Projeto \"$projectTitle\" — fase \"$phaseName\".';
  }

  @override
  String get notifPhaseUnderReviewClientTitle => 'Fase em revisão';

  @override
  String notifPhaseUnderReviewClientBody(
      String phaseName, String projectTitle) {
    return 'A fase \"$phaseName\" de \"$projectTitle\" está aguardando sua validação.';
  }

  @override
  String get notifPhaseValidatedClientTitle => 'Fase validada';

  @override
  String notifPhaseValidatedClientBody(String phaseName, String projectTitle) {
    return 'A fase \"$phaseName\" do projeto \"$projectTitle\" foi validada.';
  }

  @override
  String get notifPhaseRejectedClientTitle => 'Rejeição registrada';

  @override
  String notifPhaseRejectedClientBody(String phaseName, String projectTitle) {
    return 'A fase \"$phaseName\" foi marcada como rejeitada no projeto \"$projectTitle\".';
  }

  @override
  String get notifContractSignedClientTitle => 'Contrato assinado';

  @override
  String notifContractSignedClientBody(String projectTitle) {
    return 'O contrato do projeto \"$projectTitle\" foi assinado pelo trabalhador.';
  }

  @override
  String get notifContractSignedAdminTitle => 'Contrato assinado';

  @override
  String notifContractSignedAdminBody(String projectTitle) {
    return 'Projeto \"$projectTitle\" — contrato assinado.';
  }

  @override
  String get notifEscrowReleasedClientTitle => 'Pagamento concluído';

  @override
  String notifEscrowReleasedClientBody(String projectTitle) {
    return 'O pagamento do projeto \"$projectTitle\" foi transferido com sucesso.';
  }

  @override
  String get notifPaymentTransferredAdminTitle => 'Pagamento transferido';

  @override
  String notifPaymentTransferredAdminBody(String projectTitle) {
    return 'Projeto \"$projectTitle\" — transferência ao trabalhador registrada.';
  }

  @override
  String get notifPaymentFailedTitle => 'Falha no pagamento';

  @override
  String notifPaymentFailedBody(String projectTitle) {
    return 'Não foi possível concluir o pagamento do projeto \"$projectTitle\".';
  }

  @override
  String get notifPaymentFailedAdminTitle => 'Falha no pagamento';

  @override
  String notifPaymentFailedAdminBody(String projectTitle) {
    return 'Projeto \"$projectTitle\" — pagamento falhou.';
  }
}
