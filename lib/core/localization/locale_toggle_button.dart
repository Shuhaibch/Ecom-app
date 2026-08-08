import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ecom/core/localization/locale_cubit.dart';
import 'package:ecom/l10n/app_localizations.dart';

class LocaleToggleButton extends StatelessWidget {
  const LocaleToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;
    return IconButton(
      icon: const Icon(Icons.translate),
      tooltip: AppLocalizations.of(context)!.switchLanguage,
      onPressed: () => context.read<LocaleCubit>().toggle(),
      isSelected: locale.languageCode == 'ar',
    );
  }
}
