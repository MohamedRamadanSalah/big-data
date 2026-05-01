import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'data/database/db_helper.dart';
import 'presentation/init/init_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bootstrap the FFI-backed SQLite factory (FTS5 support).
  await DbHelper.initFfi();

  // Portrait only.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const PageSearchApp());
}

class PageSearchApp extends StatelessWidget {
  const PageSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PageSearch',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      // InitScreen handles the one-time DB copy, then navigates to SearchScreen.
      home: const InitScreen(),
    );
  }
}
