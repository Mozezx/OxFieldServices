// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'OX Trabajador';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get errorFieldRequired => 'Campo obligatorio';

  @override
  String get errorInvalidEmail => 'E-mail inválido';

  @override
  String get errorPasswordShort => 'Mínimo 6 caracteres';

  @override
  String get errorPasswordMismatch => 'Las contraseñas no coinciden';

  @override
  String commonErrorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get loginSubtitle => 'Ingresa a tu cuenta de trabajador';

  @override
  String get loginButton => 'Ingresar';

  @override
  String get loginForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get loginOrContinueWith => 'o continúa con';

  @override
  String get loginNoAccount => '¿No tienes cuenta? ';

  @override
  String get loginRegisterLink => 'Regístrate';

  @override
  String get registerTitle => 'Crear cuenta de trabajador';

  @override
  String get registerNameLabel => 'Nombre completo';

  @override
  String get registerConfirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get registerButton => 'Crear cuenta';

  @override
  String get registerHasAccount => 'Ya tengo cuenta';

  @override
  String get registerWorkerBadge => 'Cuenta de trabajador';

  @override
  String get forgotPasswordTitle => '¿Olvidaste tu contraseña?';

  @override
  String get forgotPasswordSubtitle =>
      'Ingresa tu e-mail y te enviaremos un enlace para restablecer tu contraseña.';

  @override
  String get forgotPasswordSendButton => 'Enviar enlace de restablecimiento';

  @override
  String get forgotPasswordSuccessTitle => '¡E-mail enviado!';

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
  String get onboardingSkip => 'Omitir';

  @override
  String get onboardingContinue => 'Continuar';

  @override
  String get onboardingStart => 'Comenzar';

  @override
  String get onboardingPage1Title => 'Oportunidades para ti';

  @override
  String get onboardingPage1Subtitle =>
      'Ve proyectos e invitaciones compatibles con tus habilidades y disponibilidad.';

  @override
  String get onboardingPage2Title => 'Ejecuta con claridad';

  @override
  String get onboardingPage2Subtitle =>
      'Sigue las fases, sube evidencias y mantén al cliente informado.';

  @override
  String get onboardingPage3Title => 'Cobra con seguridad';

  @override
  String get onboardingPage3Subtitle =>
      'Pagos vía Stripe Connect tras la aprobación de cada fase por el cliente.';

  @override
  String get navJobs => 'Trabajos';

  @override
  String get navExecution => 'En ejecución';

  @override
  String get navNotifications => 'Notificaciones';

  @override
  String get navPayments => 'Pagos';

  @override
  String get navProfile => 'Perfil';

  @override
  String get pushChannelName => 'OX Notificaciones';

  @override
  String get pushChannelDescription => 'Notificaciones de OX Field Services';

  @override
  String get workerStatusAvailable => 'Disponible';

  @override
  String get workerStatusUnavailable => 'No disponible';

  @override
  String workerRating(String rating) {
    return 'Calificación: $rating';
  }

  @override
  String get defaultWorkerName => 'Trabajador';

  @override
  String get jobsActiveSection => 'MIS TRABAJOS ACTIVOS';

  @override
  String get jobsAvailableSection => 'TRABAJOS DISPONIBLES PARA TI';

  @override
  String get jobsNoActive => 'Sin trabajos activos';

  @override
  String get jobsNoActiveSubtitle =>
      'Acepta un trabajo disponible para comenzar.';

  @override
  String get jobsNoAvailable => 'Tu trabajo aparecerá aquí';

  @override
  String get jobsNoAvailableSubtitle =>
      'Los nuevos trabajos compatibles con tu perfil aparecerán aquí cuando estén disponibles.';

  @override
  String get jobsLoadError => 'Error al cargar trabajos';

  @override
  String get jobCompatibility => 'Compatibilidad: ';

  @override
  String get jobContinueExecution => 'Continuar ejecución';

  @override
  String get jobViewDetails => 'Ver detalles';

  @override
  String phaseOrderLabel(int order) {
    return 'Fase $order';
  }

  @override
  String phaseOrderAndName(int order, String name) {
    return 'Fase $order — $name';
  }

  @override
  String get jobDetailTitle => 'Detalles del trabajo';

  @override
  String get jobInfoSection => 'INFORMACIÓN';

  @override
  String get jobPhasesPaymentsSection => 'FASES Y PAGOS';

  @override
  String get jobInfoDeadline => 'Plazo';

  @override
  String get jobInfoLocation => 'Ubicación';

  @override
  String get jobInfoDescription => 'Descripción';

  @override
  String get jobTotal => 'Total';

  @override
  String get jobAcceptedSuccess => '¡Trabajo aceptado con éxito!';

  @override
  String get jobsNoContractError =>
      'No se encontró un contrato para este proyecto. Espera la asignación del administrador.';

  @override
  String get jobAcceptButton => 'Aceptar trabajo';

  @override
  String get jobDeclineButton => 'Rechazar';

  @override
  String get jobAwaitingPaymentMsg =>
      'Contrato firmado. Esperando que el cliente realice el pago para iniciar la ejecución.';

  @override
  String get jobAwaitingStartMsg =>
      '¡Pago confirmado! El proyecto se activará pronto y las fases aparecerán en la pestaña \"En ejecución\".';

  @override
  String get jobAcceptDialogTitle => 'Aceptar trabajo';

  @override
  String get jobAcceptDialogContent =>
      'Al aceptar, te comprometes a ejecutar todas las fases según lo acordado. ¿Deseas continuar?';

  @override
  String get dialogAccept => 'Aceptar';

  @override
  String get statusInExecution => 'En ejecución';

  @override
  String get statusActiveEscrow => 'Escrow activo';

  @override
  String get statusContractSigned => 'Contrato firmado';

  @override
  String get executionTitle => 'En ejecución';

  @override
  String get executionNoPhases => 'Sin fases en ejecución';

  @override
  String get executionNoPhasesSubtitle =>
      'Cuando aceptes un trabajo y el cliente pague, tus fases aparecerán aquí para ejecutar.';

  @override
  String executionLoadError(String error) {
    return 'Error al cargar fases: $error';
  }

  @override
  String get phaseExecutionTitle => 'Ejecución de fase';

  @override
  String get phaseChecklist => 'LISTA DE VERIFICACIÓN';

  @override
  String get phaseChecklistItemMaterials => 'Materiales preparados';

  @override
  String get phaseChecklistItemPpe => 'EPP en uso';

  @override
  String get phaseChecklistItemWorkStarted => 'Trabajo iniciado';

  @override
  String get phaseChecklistItemSafety => 'Verificación de seguridad';

  @override
  String get phaseChecklistItemPhotoDoc => 'Documentación fotográfica';

  @override
  String get phaseEvidences => 'EVIDENCIAS';

  @override
  String phaseEvidenceCount(int count) {
    return '$count/3 obligatorias';
  }

  @override
  String phaseAmountLabel(String amount) {
    return '€ $amount en esta fase';
  }

  @override
  String get phaseReadyMsg =>
      '¿Listo para comenzar? Inicia la fase para habilitar la carga de evidencias.';

  @override
  String get phaseStartButton => 'Iniciar fase';

  @override
  String get phaseErrorNotFound => 'Fase no encontrada.';

  @override
  String get phaseErrorNeedEvidenceBeforeSubmit =>
      'Sube al menos una evidencia antes de enviar a revisión.';

  @override
  String get phaseAddMedia => 'Agregar foto / video';

  @override
  String get phaseSubmitButton => 'Enviar para revisión';

  @override
  String get phaseAddMinPhotos => 'Agrega al menos 3 fotos/videos para enviar';

  @override
  String get phaseAwaitingReview =>
      'Esperando que el cliente revise y valide la fase.';

  @override
  String get phaseSubmittedSuccess =>
      '¡Fase enviada para revisión del cliente!';

  @override
  String get phaseStartedSuccess =>
      '¡Fase iniciada! Ya puedes subir las evidencias.';

  @override
  String get phaseSubmitDialogTitle => 'Enviar para revisión';

  @override
  String get phaseSubmitDialogContent =>
      'El cliente será notificado para revisar las evidencias enviadas. Al aprobar, el pago de esta fase será liberado para ti.';

  @override
  String get dialogSend => 'Enviar';

  @override
  String get phaseNoActiveTitle => 'Sin fases en ejecución';

  @override
  String get phaseNoActiveSubtitle =>
      'Acepta un trabajo disponible para comenzar a ejecutar tus fases.';

  @override
  String get phaseStatusInProgress => 'En ejecución';

  @override
  String get phaseStatusUnderReview => 'En revisión';

  @override
  String get phaseStatusEvidenceUploaded => 'Evidencias enviadas';

  @override
  String get phaseStatusValidated => 'Validada';

  @override
  String get phaseStatusRejected => 'Rechazada';

  @override
  String get phaseStatusPending => 'Pendiente';

  @override
  String get phaseStatusAwaitingStart => 'Esperando inicio';

  @override
  String uploadTitle(int count) {
    return 'Evidencias ($count/3)';
  }

  @override
  String get uploadNoPhoto => 'Sin foto seleccionada';

  @override
  String get uploadMinPhotos => 'Mínimo 3 fotos para enviar la fase';

  @override
  String get uploadTakePhoto => 'Tomar foto';

  @override
  String get uploadFromGallery => 'De la galería';

  @override
  String uploadConfirmButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Confirmar ($count archivos)',
      one: 'Confirmar (1 archivo)',
    );
    return '$_temp0';
  }

  @override
  String get uploadUploading => 'Enviando...';

  @override
  String get uploadSuccess => '¡Evidencias enviadas con éxito!';

  @override
  String uploadError(String error) {
    return 'Error al subir: $error';
  }

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get notificationsMarkAllRead => 'Marcar todo como leído';

  @override
  String get notificationsEmpty => 'Sin notificaciones';

  @override
  String get notificationsLoadError => 'Error al cargar';

  @override
  String notificationsLoadErrorWithDetail(String error) {
    return 'Error al cargar: $error';
  }

  @override
  String get paymentsTitle => 'Mis pagos';

  @override
  String get paymentsTotalReceived => 'TOTAL RECIBIDO';

  @override
  String get paymentsReleasedLabel => 'Pagos liberados';

  @override
  String get paymentsLoadError => 'Error al cargar pagos';

  @override
  String get paymentsEmpty => 'Sin pagos aún';

  @override
  String get paymentsEmptySubtitle =>
      'Los pagos aparecerán aquí conforme se validen tus fases.';

  @override
  String get paymentsConnectSetupMessage =>
      'Configura tu cuenta para recibir pagos. Mismo flujo seguro de Stripe que en el perfil.';

  @override
  String get paymentStatusReleased => 'Liberado';

  @override
  String paymentStatusReleasedOn(String date) {
    return 'Liberado el $date';
  }

  @override
  String get paymentStatusPending => 'Esperando liberación';

  @override
  String get paymentDefaultTitle => 'Pago';

  @override
  String get profileTitle => 'Mi perfil';

  @override
  String get profileLogoutTitle => 'Cerrar sesión';

  @override
  String get profileLogoutConfirm => '¿Deseas cerrar sesión?';

  @override
  String get profileStatusSection => 'ESTADO';

  @override
  String get profileSkillsSection => 'HABILIDADES';

  @override
  String get profileAvailabilityLabel => 'Disponibilidad';

  @override
  String get profileShelterLabel => 'Certificación Shelter';

  @override
  String get profileCertifiedValue => 'Certificado';

  @override
  String get profileNotCertifiedValue => 'No certificado';

  @override
  String get profileSkillsHint => 'Toca las habilidades para seleccionarlas';

  @override
  String get profileMarkUnavailable => 'Marcar como no disponible';

  @override
  String get profileMarkAvailable => 'Marcar como disponible';

  @override
  String profileSignoutError(String error) {
    return 'Error al cerrar sesión: $error';
  }

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
  String get bankSection => 'CUENTA DE COBRO';

  @override
  String get bankNotStartedDesc =>
      'Configura tu cuenta Stripe para recibir pagos por los trabajos completados.';

  @override
  String get bankConfigureButton => 'Configurar ahora';

  @override
  String get bankPendingDesc =>
      'Tu cuenta fue creada, pero aún se necesita información para comenzar a recibir:';

  @override
  String get bankContinueButton => 'Continuar registro';

  @override
  String get bankActivePaymentInfo =>
      'Los pagos se depositan en un máximo de 2 días hábiles después de que el cliente valide cada fase.';

  @override
  String get bankUpdateButton => 'Actualizar datos bancarios';

  @override
  String get bankRestrictedDefault => 'Hay pendientes que bloquean tus cobros.';

  @override
  String get bankResolveButton => 'Resolver pendientes';

  @override
  String get bankStatusActive => 'Activo';

  @override
  String get bankStatusPending => 'En verificación';

  @override
  String get bankStatusRestricted => 'Suspendido';

  @override
  String get bankStatusNotConfigured => 'No configurado';

  @override
  String get bankAccountDefault => 'Cuenta bancaria';

  @override
  String get bankOnboardingError =>
      'No se pudo abrir el enlace de incorporación';

  @override
  String get bankRetryButton => 'Reintentar';

  @override
  String bankStatusError(String error) {
    return 'Error al verificar estado: $error';
  }

  @override
  String get bankReqFullName => 'Nombre completo';

  @override
  String get bankReqBirthDate => 'Fecha de nacimiento';

  @override
  String get bankReqIdDocument => 'Documento de identidad';

  @override
  String get bankReqAddress => 'Dirección residencial';

  @override
  String get bankReqBankData => 'Datos bancarios (IBAN o cuenta)';

  @override
  String get bankReqStripeTerms => 'Aceptar términos de Stripe';

  @override
  String get bankReqProfile => 'Perfil profesional';

  @override
  String get bankStripeDisabledPastDue =>
      'Falta información o hay datos atrasados. Completa el registro en Stripe para volver a cobrar.';

  @override
  String get bankStripeDisabledPendingVerification =>
      'Stripe está verificando tus datos. Vuelve más tarde o completa lo que te pidan.';

  @override
  String get bankStripeDisabledUnderReview =>
      'Tu cuenta está en revisión. Espera o actualiza los datos si Stripe lo solicita.';

  @override
  String get bankStripeDisabledRejected =>
      'Stripe no aceptó esta cuenta de cobros. Contacta con soporte OX si necesitas ayuda.';

  @override
  String get bankReqProductDescription =>
      'Descripción de tu actividad o servicios';

  @override
  String get bankReqBusinessType => 'Tipo de negocio (autónomo o empresa)';

  @override
  String get bankReqRepresentativeDetails => 'Datos del representante legal';

  @override
  String get bankReqRepresentativeAddress => 'Dirección del representante';

  @override
  String get bankReqCompanyInfo => 'Datos de la empresa';

  @override
  String get bankReqContactEmailPhone => 'Correo o teléfono de contacto';

  @override
  String get bankReqWebsiteOrSocial =>
      'Sitio web o presencia online del negocio';

  @override
  String get bankReqAdditionalVerification =>
      'Documento o verificación adicional de Stripe';

  @override
  String get bankReqFallbackStripeForm =>
      'Falta información: complétala en el formulario seguro de Stripe';

  @override
  String get bankConnectBrowserHint =>
      'Abre el flujo de Stripe en el navegador. Al terminar, vuelve a esta app para actualizar el estado.';

  @override
  String get stripeConnectBannerMessage =>
      'Cuenta de pagos incompleta. Completa el perfil para recibir transferencias.';

  @override
  String get stripeConnectBannerCta => 'Ir al perfil';

  @override
  String get notifUserWelcomeTitle => 'Bienvenido a OX Field Service';

  @override
  String get notifUserWelcomeBody => 'Tu cuenta fue creada con éxito.';

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
  String get notifContractCreatedTitle => 'Nuevo contrato';

  @override
  String notifContractCreatedBody(String projectTitle) {
    return 'Has sido asignado al proyecto \"$projectTitle\". Firma el contrato para continuar.';
  }

  @override
  String get notifContractSignedWorkerTitle => 'Contrato firmado';

  @override
  String notifContractSignedWorkerBody(String projectTitle) {
    return 'Firmaste el contrato del proyecto \"$projectTitle\".';
  }

  @override
  String get notifEscrowHeldTitle => 'Pago en escrow';

  @override
  String notifEscrowHeldBody(String projectTitle) {
    return 'El valor del proyecto \"$projectTitle\" está retenido en escrow.';
  }

  @override
  String get notifProjectActivatedTitle => 'Proyecto activo';

  @override
  String notifProjectActivatedBody(String projectTitle) {
    return 'El proyecto \"$projectTitle\" está en marcha.';
  }

  @override
  String get notifPhaseStartedTitle => 'Fase iniciada';

  @override
  String notifPhaseStartedBody(String phaseName, String projectTitle) {
    return 'La fase \"$phaseName\" del proyecto \"$projectTitle\" fue iniciada.';
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
  String get notifPaymentTransferredWorkerTitle => 'Transferencia recibida';

  @override
  String notifPaymentTransferredWorkerBody(String amount, String projectTitle) {
    return 'Se acreditaron € $amount en el proyecto \"$projectTitle\".';
  }

  @override
  String get notifEscrowReleasedWorkerTitle => 'Pago liberado';

  @override
  String notifEscrowReleasedWorkerBody(String projectTitle) {
    return 'El pago del proyecto \"$projectTitle\" fue liberado.';
  }

  @override
  String get notifProjectClosedTitle => 'Proyecto cerrado';

  @override
  String notifProjectClosedBody(String projectTitle) {
    return 'El proyecto \"$projectTitle\" fue cerrado.';
  }

  @override
  String get notifWorkerRatedTitle => 'Nueva calificación';

  @override
  String notifWorkerRatedBody(String score, String projectTitle) {
    return 'Recibiste una calificación de $score en el proyecto \"$projectTitle\".';
  }

  @override
  String get notifProjectCreatedClientTitle => 'Proyecto creado';

  @override
  String notifProjectCreatedClientBody(String projectTitle) {
    return 'El proyecto \"$projectTitle\" fue creado.';
  }

  @override
  String get notifProjectCreatedAdminTitle => 'Nuevo proyecto';

  @override
  String notifProjectCreatedAdminBody(String projectTitle) {
    return 'El cliente creó el proyecto \"$projectTitle\".';
  }

  @override
  String get notifProjectInValidationTitle => 'Proyecto en validación';

  @override
  String notifProjectInValidationBody(String projectTitle) {
    return '\"$projectTitle\" fue enviado a validación.';
  }

  @override
  String get notifProjectMatchedTitle => 'Proyecto actualizado';

  @override
  String notifProjectMatchedBody(String projectTitle) {
    return 'El proyecto \"$projectTitle\" avanzó en el flujo.';
  }

  @override
  String get notifProjectClosingTitle => 'Proyecto en cierre';

  @override
  String notifProjectClosingBody(String projectTitle) {
    return 'Todas las fases de \"$projectTitle\" fueron validadas. Cierre en curso.';
  }

  @override
  String get notifProjectRejectedTitle => 'Proyecto rechazado';

  @override
  String notifProjectRejectedBody(String projectTitle) {
    return 'El proyecto \"$projectTitle\" fue rechazado.';
  }

  @override
  String get notifProjectUpdatedGenericTitle => 'Proyecto actualizado';

  @override
  String notifProjectUpdatedGenericBody(String projectTitle) {
    return 'El estado del proyecto \"$projectTitle\" cambió.';
  }

  @override
  String get notifPhaseEvidenceUploadedClientTitle => 'Nuevas evidencias';

  @override
  String notifPhaseEvidenceUploadedClientBody(
      String phaseName, String projectTitle) {
    return 'El trabajador envió evidencias para la fase \"$phaseName\" en \"$projectTitle\".';
  }

  @override
  String get notifPhaseEvidenceUploadedAdminTitle => 'Evidencias recibidas';

  @override
  String notifPhaseEvidenceUploadedAdminBody(
      String projectTitle, String phaseName) {
    return 'Proyecto \"$projectTitle\" — fase \"$phaseName\".';
  }

  @override
  String get notifPhaseUnderReviewClientTitle => 'Fase en revisión';

  @override
  String notifPhaseUnderReviewClientBody(
      String phaseName, String projectTitle) {
    return 'La fase \"$phaseName\" de \"$projectTitle\" espera tu validación.';
  }

  @override
  String get notifPhaseValidatedClientTitle => 'Fase validada';

  @override
  String notifPhaseValidatedClientBody(String phaseName, String projectTitle) {
    return 'La fase \"$phaseName\" del proyecto \"$projectTitle\" fue validada.';
  }

  @override
  String get notifPhaseRejectedClientTitle => 'Rechazo registrado';

  @override
  String notifPhaseRejectedClientBody(String phaseName, String projectTitle) {
    return 'La fase \"$phaseName\" fue marcada como rechazada en el proyecto \"$projectTitle\".';
  }

  @override
  String get notifContractSignedClientTitle => 'Contrato firmado';

  @override
  String notifContractSignedClientBody(String projectTitle) {
    return 'El contrato del proyecto \"$projectTitle\" fue firmado por el trabajador.';
  }

  @override
  String get notifContractSignedAdminTitle => 'Contrato firmado';

  @override
  String notifContractSignedAdminBody(String projectTitle) {
    return 'Proyecto \"$projectTitle\" — contrato firmado.';
  }

  @override
  String get notifEscrowReleasedClientTitle => 'Pago completado';

  @override
  String notifEscrowReleasedClientBody(String projectTitle) {
    return 'El pago del proyecto \"$projectTitle\" se transfirió correctamente.';
  }

  @override
  String get notifPaymentTransferredAdminTitle => 'Pago transferido';

  @override
  String notifPaymentTransferredAdminBody(String projectTitle) {
    return 'Proyecto \"$projectTitle\" — transferencia al trabajador registrada.';
  }

  @override
  String get notifPaymentFailedTitle => 'Fallo en el pago';

  @override
  String notifPaymentFailedBody(String projectTitle) {
    return 'No se pudo completar el pago del proyecto \"$projectTitle\".';
  }

  @override
  String get notifPaymentFailedAdminTitle => 'Fallo en el pago';

  @override
  String notifPaymentFailedAdminBody(String projectTitle) {
    return 'Proyecto \"$projectTitle\" — pago fallido.';
  }
}
