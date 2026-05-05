// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'OX Services';

  @override
  String get loginTitle => 'Bienvenido de nuevo';

  @override
  String get loginSubtitle => 'Inicia sesión en tu cuenta OX';

  @override
  String get loginEmailLabel => 'Correo electrónico';

  @override
  String get loginPasswordLabel => 'Contraseña';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get loginGoogleButton => 'Iniciar sesión con Google';

  @override
  String get loginNoAccount => '¿No tienes cuenta? Regístrate';

  @override
  String get loginForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get loginOrContinueWith => 'o continúa con';

  @override
  String get registerTitle => 'Crear cuenta';

  @override
  String get registerNameLabel => 'Nombre completo';

  @override
  String get registerConfirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get registerButton => 'Crear cuenta';

  @override
  String get registerHasAccount => 'Ya tengo cuenta';

  @override
  String get registerRoleClient => 'Soy cliente';

  @override
  String get registerRoleWorker => 'Soy trabajador';

  @override
  String get registerAccountType => 'Tipo de cuenta';

  @override
  String get forgotPasswordSubtitle =>
      'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.';

  @override
  String get forgotPasswordSendButton => 'Enviar enlace de restablecimiento';

  @override
  String get forgotPasswordSuccessTitle => '¡Correo enviado!';

  @override
  String forgotPasswordSuccessBody(String email) {
    return 'Revisa tu bandeja de entrada en $email y haz clic en el enlace para restablecer tu contraseña.';
  }

  @override
  String get forgotPasswordBackToLogin => 'Volver al inicio de sesión';

  @override
  String get resetPasswordTitle => 'Nueva contraseña';

  @override
  String get resetPasswordSubtitle => 'Ingresa y confirma tu nueva contraseña.';

  @override
  String get resetPasswordNewLabel => 'Nueva contraseña';

  @override
  String get resetPasswordConfirmLabel => 'Confirmar nueva contraseña';

  @override
  String get resetPasswordButton => 'Restablecer contraseña';

  @override
  String get resetPasswordSuccess => '¡Contraseña restablecida con éxito!';

  @override
  String get profileTitle => 'Mi Perfil';

  @override
  String get profileLogoutTitle => 'Salir';

  @override
  String get profileLogoutConfirm => '¿Estás seguro de que quieres salir?';

  @override
  String get profileLogoutButton => 'Cerrar sesión';

  @override
  String get profilePaymentMethods => 'Métodos de pago';

  @override
  String get profilePaymentMethodsSubtitle =>
      'Tarjetas guardadas para pagos rápidos';

  @override
  String get profilePhotoTitle => 'Foto de perfil';

  @override
  String get profilePhotoChangeHint => 'Toca para cambiar';

  @override
  String get profilePhotoGallery => 'Galería';

  @override
  String get profilePhotoCamera => 'Cámara';

  @override
  String get profilePhotoRemove => 'Eliminar foto';

  @override
  String get profilePhotoPromptTitle => 'Añade una foto de perfil';

  @override
  String get profilePhotoPromptBody =>
      'Ayuda a personalizar tu cuenta. Puedes cambiarla más tarde en el perfil.';

  @override
  String get profilePhotoPromptLater => 'Ahora no';

  @override
  String get profilePhotoUploadError =>
      'No se pudo subir la foto. Inténtalo de nuevo.';

  @override
  String get profilePhotoSizeError =>
      'La imagen es demasiado grande (máx. 5 MB).';

  @override
  String get profilePhotoTypeError => 'Usa JPEG o PNG.';

  @override
  String get profilePhotoRemoveMessage => 'La foto se eliminará de tu cuenta.';

  @override
  String get projectsTitle => 'Mis Proyectos';

  @override
  String projectsActive(int count) {
    return '$count proyectos activos';
  }

  @override
  String get projectsFilterAll => 'Todos';

  @override
  String get projectsFilterActive => 'Activos';

  @override
  String get projectsFilterClosed => 'Cerrados';

  @override
  String get projectsEmpty => 'Tu obra aparecerá aquí';

  @override
  String get projectsEmptySubtitle =>
      'Cuando se cree una obra para ti o añadas una con un enlace de invitación, aparecerá en esta lista.';

  @override
  String get projectsCreateButton => 'Crear proyecto';

  @override
  String get projectsLoadError => 'Error al cargar proyectos';

  @override
  String get projectDetailTitle => 'Detalles del Proyecto';

  @override
  String get projectDetailWorker => 'Trabajador';

  @override
  String get projectDetailBudget => 'Importe Total';

  @override
  String get projectDetailDeadline => 'Plazo';

  @override
  String get projectDetailPhases => 'Fases';

  @override
  String get projectDetailPayment => 'Pago';

  @override
  String get projectDetailInfoSection => 'INFORMACIÓN';

  @override
  String get projectDetailPhasesSection => 'FASES';

  @override
  String get projectDetailPaymentSection => 'PAGO';

  @override
  String get projectDetailLocation => 'Lugar';

  @override
  String get projectRateWorkerSection => 'VALORACIÓN';

  @override
  String get projectRateWorkerSubtitle =>
      '¿Cómo fue el trabajo en este proyecto?';

  @override
  String get projectRateWorkerFeedbackLabel => 'Comentario (opcional)';

  @override
  String get projectRateWorkerSubmit => 'Enviar valoración';

  @override
  String get projectRateWorkerThanks => 'Gracias por su valoración.';

  @override
  String projectRateWorkerYourScore(int score) {
    return 'Su nota: $score de 5';
  }

  @override
  String projectRateWorkerError(String message) {
    return 'No se pudo enviar: $message';
  }

  @override
  String get projectDraftSaved => 'Borrador guardado';

  @override
  String get projectDraftDescription =>
      'Este proyecto está guardado como borrador. Envíalo para validación para iniciar el proceso de emparejamiento con trabajadores.';

  @override
  String get projectSubmitForValidation => 'Enviar para Validación';

  @override
  String get projectSubmitSuccess => '¡Proyecto enviado para validación!';

  @override
  String projectSubmitError(String error) {
    return 'Error al enviar: $error';
  }

  @override
  String get projectSignContract => 'Firmar Contrato';

  @override
  String get projectSignContractDescription =>
      'Firma el contrato para confirmar tu participación en este proyecto.';

  @override
  String get projectPaymentRequired => 'Pago requerido';

  @override
  String get projectPaymentRequiredDescription =>
      'El trabajador ha sido asignado y está esperando comenzar. Paga para desbloquear la ejecución de las fases.';

  @override
  String get projectPayButton => 'Pagar e Iniciar Proyecto';

  @override
  String get projectViewFinancials => 'Ver detalles financieros →';

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
  String get phaseStatusUnderReview => 'En revisión';

  @override
  String get phaseStatusEvidenceUploaded => 'Evidencias enviadas';

  @override
  String get phaseStatusInProgress => 'En ejecución';

  @override
  String get phaseStatusRejected => 'Rechazada';

  @override
  String get phaseStatusPending => 'Pendiente';

  @override
  String get createProjectTitle => 'Nuevo Proyecto';

  @override
  String get createProjectStep1 => 'Información Básica';

  @override
  String get createProjectStep2 => 'Fases';

  @override
  String get createProjectStep3 => 'Revisión';

  @override
  String get createProjectTitleLabel => 'Título del proyecto';

  @override
  String get createProjectDescLabel => 'Descripción';

  @override
  String get createProjectLocationLabel => 'Ubicación';

  @override
  String get createProjectBudgetLabel => 'Presupuesto total (€)';

  @override
  String get createProjectDeadlineLabel => 'Plazo';

  @override
  String get createProjectNextButton => 'Continuar';

  @override
  String get createProjectSubmitButton => 'Crear Proyecto';

  @override
  String get createProjectAddPhase => '+ Agregar Fase';

  @override
  String createProjectStepLabel(int step) {
    return 'Nuevo Proyecto — Paso $step/3';
  }

  @override
  String get createProjectPhasesTitle => 'Fases del Proyecto';

  @override
  String get createProjectPhaseNameLabel => 'Nombre de la fase';

  @override
  String get createProjectPhaseAmountLabel => 'Valor estimado (€)';

  @override
  String get createProjectSaveDraft => 'Guardar Borrador';

  @override
  String get createProjectDraftSaved => '¡Borrador guardado!';

  @override
  String get createProjectSentForValidation =>
      '¡Proyecto enviado para validación!';

  @override
  String get createProjectSelectDeadline => 'Seleccionar plazo';

  @override
  String get createProjectInvalidAmount => 'Importe inválido';

  @override
  String get createProjectReviewTitle => 'Revisión';

  @override
  String get validatePhaseTitle => 'Validar Fase';

  @override
  String get validatePhaseEvidence => 'Evidencia del Trabajador';

  @override
  String get validatePhaseApprove => 'Aprobar Fase';

  @override
  String get validatePhaseReject => 'Rechazar Fase';

  @override
  String get validatePhaseWarning =>
      'Al aprobar, el importe será liberado al trabajador.';

  @override
  String get validatePhaseEvidenceSection => 'EVIDENCIAS DEL TRABAJADOR';

  @override
  String get validatePhaseNoEvidence => 'Sin evidencias enviadas';

  @override
  String get validatePhaseSuccess => '¡Fase validada con éxito!';

  @override
  String get validatePhaseApproveConfirmTitle => '¿Aprobar Fase?';

  @override
  String get validatePhaseRejectConfirmTitle => '¿Rechazar Fase?';

  @override
  String get validatePhaseApproveConfirmBody =>
      'El pago de la fase será liberado al trabajador.';

  @override
  String get validatePhaseRejectConfirmBody =>
      'El trabajador deberá reenviar las evidencias.';

  @override
  String get validatePhaseApproveButton => 'Aprobar';

  @override
  String get validatePhaseRejectButton => 'Rechazar';

  @override
  String get validatePhaseApproveAction => '✓ Aprobar Fase';

  @override
  String get validatePhaseRejectAction => '✕ Rechazar Fase';

  @override
  String validatePhaseAmountWarning(String amount) {
    return 'Al aprobar, € $amount será liberado al trabajador.';
  }

  @override
  String validatePhaseDetailTitle(int order, String name) {
    return 'Validar — Fase $order: $name';
  }

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get onboardingStart => 'Comenzar';

  @override
  String get onboardingPage1Title => 'Crea tu proyecto';

  @override
  String get onboardingPage1Subtitle =>
      'Describe el servicio, define fases y presupuesto con facilidad.';

  @override
  String get onboardingPage2Title => 'Encontramos al profesional';

  @override
  String get onboardingPage2Subtitle =>
      'Emparejamiento automático con trabajadores certificados y bien valorados.';

  @override
  String get onboardingPage3Title => 'Paga con seguridad';

  @override
  String get onboardingPage3Subtitle =>
      'Escrow libera el importe solo después de tu aprobación de cada fase.';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get notificationsMarkAllRead => 'Marcar todo como leído';

  @override
  String get notificationsEmpty => 'Sin notificaciones';

  @override
  String get notificationsLoadError => 'Error al cargar';

  @override
  String get statusDraft => 'Borrador';

  @override
  String get statusInValidation => 'En Validación';

  @override
  String get statusMatched => 'Emparejado';

  @override
  String get statusContractSigned => 'Contrato firmado';

  @override
  String get statusActiveEscrow => 'Escrow activo';

  @override
  String get statusInExecution => 'En Ejecución';

  @override
  String get statusClosing => 'Cerrando';

  @override
  String get statusClosed => 'Completado';

  @override
  String get statusRejected => 'Rechazado';

  @override
  String get statusAwaitingMatch => 'Esperando emparejamiento';

  @override
  String get errorGeneric => 'Ocurrió un error. Inténtalo de nuevo.';

  @override
  String get errorFieldRequired => 'Campo obligatorio';

  @override
  String get errorInvalidEmail => 'Correo electrónico inválido';

  @override
  String get errorPasswordShort => 'Mínimo 6 caracteres';

  @override
  String get errorPasswordMismatch => 'Las contraseñas no coinciden';

  @override
  String get commonLoading => 'Cargando...';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonBack => 'Volver';

  @override
  String get commonOr => 'o';

  @override
  String get navProjects => 'Proyectos';

  @override
  String get navNotifications => 'Notificaciones';

  @override
  String get navProfile => 'Perfil';

  @override
  String get pushChannelName => 'OX Notificaciones';

  @override
  String get pushChannelDescription => 'Notificaciones de OX Field Services';

  @override
  String get notifUserWelcomeTitle => 'Bienvenido a OX Field Service';

  @override
  String get notifUserWelcomeBody => 'Tu cuenta ha sido creada exitosamente.';

  @override
  String get notifProjectCreatedClientTitle => 'Proyecto creado';

  @override
  String notifProjectCreatedClientBody(String projectTitle) {
    return 'El proyecto \"$projectTitle\" ha sido creado.';
  }

  @override
  String get notifProjectCreatedAdminTitle => 'Nuevo proyecto';

  @override
  String notifProjectCreatedAdminBody(String projectTitle) {
    return 'Un cliente creó el proyecto \"$projectTitle\".';
  }

  @override
  String get notifProjectInValidationTitle => 'Proyecto en validación';

  @override
  String notifProjectInValidationBody(String projectTitle) {
    return '\"$projectTitle\" fue enviado para validación.';
  }

  @override
  String get notifProjectMatchedTitle => 'Proyecto actualizado';

  @override
  String notifProjectMatchedBody(String projectTitle) {
    return 'El proyecto \"$projectTitle\" avanzó en el flujo.';
  }

  @override
  String get notifProjectActivatedTitle => 'Proyecto activo';

  @override
  String notifProjectActivatedBody(String projectTitle) {
    return 'El proyecto \"$projectTitle\" está en marcha.';
  }

  @override
  String get notifProjectClosingTitle => 'Proyecto en cierre';

  @override
  String notifProjectClosingBody(String projectTitle) {
    return 'Todas las fases de \"$projectTitle\" han sido validadas.';
  }

  @override
  String get notifProjectClosedTitle => 'Proyecto cerrado';

  @override
  String notifProjectClosedBody(String projectTitle) {
    return 'El proyecto \"$projectTitle\" ha sido cerrado.';
  }

  @override
  String get notifProjectRejectedTitle => 'Proyecto rechazado';

  @override
  String notifProjectRejectedBody(String projectTitle) {
    return 'El proyecto \"$projectTitle\" ha sido rechazado.';
  }

  @override
  String get notifPhaseStartedTitle => 'Fase iniciada';

  @override
  String notifPhaseStartedBody(String phaseName, String projectTitle) {
    return 'La fase \"$phaseName\" del proyecto \"$projectTitle\" ha comenzado.';
  }

  @override
  String get notifPhaseEvidenceUploadedClientTitle => 'Nueva evidencia';

  @override
  String notifPhaseEvidenceUploadedClientBody(
      String phaseName, String projectTitle) {
    return 'El trabajador envió evidencia para la fase \"$phaseName\" en \"$projectTitle\".';
  }

  @override
  String get notifPhaseEvidenceUploadedAdminTitle => 'Evidencia recibida';

  @override
  String notifPhaseEvidenceUploadedAdminBody(
      String phaseName, String projectTitle) {
    return 'Proyecto \"$projectTitle\" — fase \"$phaseName\".';
  }

  @override
  String get notifPhaseUnderReviewTitle => 'Fase en revisión';

  @override
  String notifPhaseUnderReviewBody(String phaseName, String projectTitle) {
    return 'La fase \"$phaseName\" de \"$projectTitle\" está esperando tu validación.';
  }

  @override
  String get notifPhaseValidatedClientTitle => 'Fase validada';

  @override
  String notifPhaseValidatedClientBody(String phaseName, String projectTitle) {
    return 'La fase \"$phaseName\" del proyecto \"$projectTitle\" ha sido validada.';
  }

  @override
  String get notifPhaseValidatedWorkerTitle => 'Fase aprobada';

  @override
  String notifPhaseValidatedWorkerBody(String phaseName, String projectTitle) {
    return 'Tu fase \"$phaseName\" fue aprobada en \"$projectTitle\".';
  }

  @override
  String get notifPhaseRejectedWorkerTitle => 'Fase rechazada';

  @override
  String notifPhaseRejectedWorkerBody(String phaseName, String projectTitle) {
    return 'La fase \"$phaseName\" de \"$projectTitle\" fue rechazada y necesita ajustes.';
  }

  @override
  String get notifPhaseRejectedClientTitle => 'Rechazo registrado';

  @override
  String notifPhaseRejectedClientBody(String phaseName, String projectTitle) {
    return 'La fase \"$phaseName\" de \"$projectTitle\" ha sido marcada como rechazada.';
  }

  @override
  String get notifContractCreatedTitle => 'Nuevo contrato';

  @override
  String notifContractCreatedBody(String projectTitle) {
    return 'Has sido asignado al proyecto \"$projectTitle\". Firma el contrato para continuar.';
  }

  @override
  String get notifWorkerInvitedTitle => 'Invitación a proyecto';

  @override
  String notifWorkerInvitedBody(String projectTitle) {
    return 'Has sido seleccionado para el proyecto \"$projectTitle\".';
  }

  @override
  String get notifWorkerAssignedTitle => 'Asignación confirmada';

  @override
  String notifWorkerAssignedBody(String projectTitle) {
    return 'Estás asignado al proyecto \"$projectTitle\".';
  }

  @override
  String get notifContractSignedClientTitle => 'Contrato firmado';

  @override
  String notifContractSignedClientBody(String projectTitle) {
    return 'El contrato del proyecto \"$projectTitle\" fue firmado por el trabajador.';
  }

  @override
  String get notifContractSignedWorkerTitle => 'Contrato firmado';

  @override
  String notifContractSignedWorkerBody(String projectTitle) {
    return 'Has firmado el contrato del proyecto \"$projectTitle\".';
  }

  @override
  String get notifEscrowHeldTitle => 'Pago en escrow';

  @override
  String notifEscrowHeldBody(String projectTitle) {
    return 'Los fondos del proyecto \"$projectTitle\" están retenidos en escrow.';
  }

  @override
  String get notifPaymentTransferredWorkerTitle => 'Transferencia recibida';

  @override
  String notifPaymentTransferredWorkerBody(String amount, String projectTitle) {
    return 'Se acreditaron € $amount en el proyecto \"$projectTitle\".';
  }

  @override
  String get notifPaymentTransferredAdminTitle => 'Pago transferido';

  @override
  String notifPaymentTransferredAdminBody(String projectTitle) {
    return 'Proyecto \"$projectTitle\" — transferencia al trabajador registrada.';
  }

  @override
  String get notifEscrowReleasedWorkerTitle => 'Pago liberado';

  @override
  String notifEscrowReleasedWorkerBody(String projectTitle) {
    return 'El pago del proyecto \"$projectTitle\" ha sido liberado.';
  }

  @override
  String get notifEscrowReleasedClientTitle => 'Pago completado';

  @override
  String notifEscrowReleasedClientBody(String projectTitle) {
    return 'El pago del proyecto \"$projectTitle\" fue transferido exitosamente.';
  }

  @override
  String get notifPaymentFailedTitle => 'Fallo en el pago';

  @override
  String notifPaymentFailedBody(String projectTitle) {
    return 'No se pudo completar el pago del proyecto \"$projectTitle\".';
  }

  @override
  String get notifWorkerRatedTitle => 'Nueva valoración';

  @override
  String notifWorkerRatedBody(String score, String projectTitle) {
    return 'Recibiste una puntuación de $score en el proyecto \"$projectTitle\".';
  }

  @override
  String get notifInviteRedeemedClientTitle => 'Obra añadida a tu cuenta';

  @override
  String notifInviteRedeemedClientBody(String projectTitle) {
    return 'Puedes seguir las fases y completar el pago de \"$projectTitle\".';
  }

  @override
  String get notifInviteRedeemedAdminTitle => 'Invitación canjeada';

  @override
  String notifInviteRedeemedAdminBody(String clientName, String projectTitle) {
    return '$clientName aceptó la invitación para la obra \"$projectTitle\".';
  }

  @override
  String get paymentTitle => 'Pago';

  @override
  String get paymentConfirmTitle => 'Confirmar pago';

  @override
  String get paymentConfirmBody =>
      'El importe quedará bloqueado en un escrow seguro. Se liberará al trabajador solo después de que valides cada fase del proyecto.';

  @override
  String get paymentTestModeHint =>
      'Modo prueba: usa la tarjeta 4242 4242 4242 4242, cualquier fecha futura, cualquier CVC.';

  @override
  String get paymentPayNow => 'Pagar ahora';

  @override
  String get paymentProcessing => 'Procesando…';

  @override
  String get paymentAlreadyPaidSnack =>
      'El pago de este contrato ya se realizó.';

  @override
  String get paymentDoneWaitingSnack =>
      '¡Pago enviado! Esperando confirmación…';

  @override
  String get paymentErrorClientSecret =>
      'La sesión de pago no fue devuelta por el servidor.';

  @override
  String get paymentMerchantDisplayName => 'OX Field Services';

  @override
  String get paymentStripePrimaryButton => 'Pagar';

  @override
  String get paymentEscrowStatusHeading => 'Estado del escrow';

  @override
  String get paymentEscrowBrand => 'Escrow';

  @override
  String get paymentEscrowStatusHeld => 'Retenido';

  @override
  String get paymentEscrowStatusReleased => 'Liberado';

  @override
  String get paymentEscrowStatusRefunded => 'Reembolsado';

  @override
  String get paymentTotalContractValue => 'Valor total del contrato';

  @override
  String get paymentDistributionHeading => 'DISTRIBUCIÓN';

  @override
  String get paymentSplitWorker => 'Trabajador (70%)';

  @override
  String get paymentSplitPlatform => 'Plataforma OX (30%)';

  @override
  String get paymentEscrowReleaseInfo =>
      'El pago se libera automáticamente después de que apruebes cada fase del proyecto.';

  @override
  String get paymentCancelledStripe => 'Pago cancelado';

  @override
  String paymentErrorLine(String details) {
    return 'Error: $details';
  }

  @override
  String get redeemTitle => 'Agregar obra por enlace';

  @override
  String get redeemSubtitle =>
      'Pega el enlace enviado por el administrador o introduce el token de invitación.';

  @override
  String get redeemInputHint => 'https://app.ox.example/i/... o token';

  @override
  String get redeemAddByLink => 'Agregar por enlace';

  @override
  String redeemPreviewClient(String name) {
    return 'Cliente: $name';
  }

  @override
  String redeemPreviewExpires(String date) {
    return 'Expira el $date';
  }

  @override
  String get redeemButton => 'Agregar a mi cuenta';

  @override
  String get redeemRetry => 'Intentar de nuevo';

  @override
  String get redeemErrorExpired =>
      'Esta invitación ha caducado. Solicita un nuevo enlace al administrador.';

  @override
  String get redeemErrorRevoked =>
      'Esta invitación fue revocada. Contacta al administrador.';

  @override
  String get redeemErrorWrongEmail =>
      'Este enlace fue creado para otro correo. Inicia sesión con la cuenta correcta o solicita un nuevo enlace.';

  @override
  String get redeemErrorGeneric =>
      'Invitación inválida. Verifica el enlace e intenta de nuevo.';

  @override
  String get redeemErrorNotFound =>
      'Invitación no encontrada en este servidor. La app debe usar la misma URL de API que el panel admin — define --dart-define=API_BASE_URL=https://tu-backend… al compilar.';

  @override
  String get redeemErrorNetwork =>
      'No se pudo contactar con el servidor. Comprueba la red y la URL de la API.';

  @override
  String get redeemErrorRoleMustBeClient =>
      'Solo cuentas cliente pueden canjear invitaciones. Revisa tu rol con POST /auth/sync.';
}
