import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:refer_and_earn/refer_and_earn/color_class.dart';
import 'package:refer_and_earn/refer_and_earn/controller/provider/refer_provider.dart';
import 'package:refer_and_earn/refer_and_earn/view/screens/refer_screen.dart';
import 'package:toastification/toastification.dart';
import 'package:window_manager/window_manager.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux)) {
    await windowManager.ensureInitialized();

    WindowOptions options = const WindowOptions(
      title: "FoodChow",
    );

    windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.maximize();
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setMinimumSize(const Size(500, 750));
    });
  }

  runApp(
    ToastificationWrapper(
      child: const MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (context) => ReferralProvider(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'FoodChow',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: "Poppins",
          colorScheme: ColorScheme.fromSeed(seedColor: ColorsClass.primary),
        ),
        home: const ReferScreen(),
      ),
    );
  }
}
