import 'package:flutter/widgets.dart';

import 'package:ecom/core/error/failures.dart';
import 'package:ecom/l10n/app_localizations.dart';

String localizeFailure(BuildContext context, Failure failure) {
  final l10n = AppLocalizations.of(context)!;
  return switch (failure) {
    NetworkFailure() => l10n.noInternetConnection,
    _ => l10n.somethingWentWrong,
  };
}
