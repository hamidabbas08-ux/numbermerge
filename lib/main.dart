import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'services/ad_service.dart';
import 'controllers/game_controller.dart';
import 'views/screens/game_screen.dart';

void main() async {
  // فلٹر وجیٹس بائنڈنگ کو یقینی بنانا تاکہ لوکل میموری لوڈ ہو سکے
  WidgetsFlutterBinding.ensureInitialized();

  // تمام بنیادی سروسز کا آغاز
  final storageService = await StorageService.init();
  final adService = AdService();
  await adService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<GameController>(
          create: (_) => GameController(storageService, adService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // گیم کنٹرولر سے موجودہ تھیم کی حالت حاصل کرنا
    final gameController = Provider.of<GameController>(context);

    return MaterialApp(
      title: 'Number Merge Puzzle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: gameController.darkTheme ? ThemeMode.dark : ThemeMode.light,
      home: const GameScreen(),
    );
  }
}
