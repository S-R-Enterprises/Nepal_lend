import 'package:flutter/material.dart';

import 'app_localizations.dart';
import 'app_localizations_en.dart';

/// Safe lookup for generated localizations.
///
/// Falls back to English when a widget is rendered outside [NepalLendApp]'s
/// localization delegates (unit/widget tests and isolated storybook widgets).
class L10n {
  const L10n._();

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations) ??
      AppLocalizationsEn();
}
