import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/locale_provider.dart';
import 'l10n/generated/app_localizations.dart';
import 'router.dart';
import 'theme/theme.dart';

class KarlyApp extends ConsumerStatefulWidget {
  const KarlyApp({super.key});

  @override
  ConsumerState<KarlyApp> createState() => _KarlyAppState();
}

class _KarlyAppState extends ConsumerState<KarlyApp> {
  late final _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Kârly',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
