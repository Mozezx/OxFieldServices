import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Empilha [detailPath] sobre [basePath] para que o utilizador possa voltar
/// (ex.: abrir detalhe a partir de push sem substituir a lista com `go` só no detalhe).
void goThenPushDetail(
  GoRouter router, {
  required String basePath,
  required String detailPath,
}) {
  router.go(basePath);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    router.push(detailPath);
  });
}
