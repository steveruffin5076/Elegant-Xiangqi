import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'game/campaign_progress.dart';
import 'screens/home_screen.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await CampaignProgress.init();
  await themeController.loadSaved();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ElegantXiangqiApp());
}

class ElegantXiangqiApp extends StatelessWidget {
  const ElegantXiangqiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        final palette = themeController.palette;
        return MaterialApp(
          title: 'Elegant Xiangqi',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: palette.appBarBackground,
              primary: palette.appBarBackground,
              secondary: palette.pieceRim,
            ),
            scaffoldBackgroundColor: palette.scaffoldBackground,
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}
