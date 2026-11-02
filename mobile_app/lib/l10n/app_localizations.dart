import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations(this.locale, this._values);

  final Locale locale;
  final Map<String, String> _values;

  static const supportedLocales = [Locale('en'), Locale('fr')];
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations? of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations);

  static Future<AppLocalizations> load(Locale locale) async {
    final language =
        supportedLocales.any(
          (supported) => supported.languageCode == locale.languageCode,
        )
        ? locale.languageCode
        : 'en';
    final source = await rootBundle.loadString('lib/l10n/app_$language.arb');
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Localization file must contain a JSON map.');
    }
    final values = <String, String>{};
    for (final entry in decoded.entries) {
      if (entry.key.startsWith('@')) continue;
      if (entry.value is! String) {
        throw FormatException('Localization value "${entry.key}" is not text.');
      }
      values[entry.key] = entry.value as String;
    }
    return AppLocalizations(locale, values);
  }

  String _text(String key) {
    final value = _values[key];
    if (value == null) {
      throw StateError(
        'Localization key "$key" is missing for ${locale.languageCode}.',
      );
    }
    return value;
  }

  String get appTitle => _text('appTitle');
  String get loginSubtitle => _text('loginSubtitle');
  String get email => _text('email');
  String get password => _text('password');
  String get loginWithStrapi => _text('loginWithStrapi');
  String get continueDemo => _text('continueDemo');
  String get backendReady => _text('backendReady');
  String get home => _text('home');
  String get rooms => _text('rooms');
  String get routines => _text('routines');
  String get timeline => _text('timeline');
  String get settings => _text('settings');
  String get greeting => _text('greeting');
  String get houseSummary => _text('houseSummary');
  String get modeHome => _text('modeHome');
  String get homeMode => _text('homeMode');
  String get connectionModes => _text('connectionModes');
  String get securityArmed => _text('securityArmed');
  String get climate => _text('climate');
  String get energy => _text('energy');
  String get security => _text('security');
  String get activeRoutines => _text('activeRoutines');
  String get heatingOn => _text('heatingOn');
  String get peakAt => _text('peakAt');
  String get pausedRoutines => _text('pausedRoutines');
  String get consumption => _text('consumption');
  String get today => _text('today');
  String get awayMode => _text('awayMode');
  String get emergencyOff => _text('emergencyOff');
  String get recentEvents => _text('recentEvents');
  String get seeAll => _text('seeAll');
  String get smartRoutines => _text('smartRoutines');
  String get open => _text('open');
  String get currentTemperature => _text('currentTemperature');
  String get triggerConditionsActions => _text('triggerConditionsActions');
  String get executionHistory => _text('executionHistory');
  String get causalChain => _text('causalChain');
  String get theme => _text('theme');
  String get language => _text('language');
  String get connectionMode => _text('connectionMode');
  String get mockMode => _text('mockMode');
  String get liveMode => _text('liveMode');
  String get offlineMode => _text('offlineMode');
  String get backendBaseUrl => _text('backendBaseUrl');
  String get retry => _text('retry');
  String get emptyTitle => _text('emptyTitle');
  String get emptyMessage => _text('emptyMessage');
  String get ruleEditor => _text('ruleEditor');
  String get modesAndOverrides => _text('modesAndOverrides');
  String get contextViewer => _text('contextViewer');
  String get conflictsAndRobustness => _text('conflictsAndRobustness');
  String get save => _text('save');
  String get cancel => _text('cancel');
  String get resolve => _text('resolve');
  String get addOverride => _text('addOverride');
  String get enabled => _text('enabled');
  String get priority => _text('priority');
  String get occupancy => _text('occupancy');
  String get weather => _text('weather');
  String get openWindow => _text('openWindow');
  String get noConflicts => _text('noConflicts');
  String get ruleConflict => _text('ruleConflict');
  String get resolveByPriority => _text('resolveByPriority');
  String get splashTagline => _text('splashTagline');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
    (supported) => supported.languageCode == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
