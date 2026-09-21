import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/game_screen.dart';
import 'theme/colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
    return MaterialApp(
      title: 'Elegant Xiangqi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.huanghuali,
          primary: AppColors.huanghuali,
          secondary: AppColors.gold,
        ),
        scaffoldBackgroundColor: AppColors.jadeWhite,
      ),
      home: const GameScreen(),
    );
  }
}
