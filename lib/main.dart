import 'package:device_preview_minus/device_preview_minus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:refer_and_earn/refer_and_earn/color_class.dart';
import 'package:refer_and_earn/refer_and_earn/controller/provider/refer_provider.dart';
import 'package:refer_and_earn/refer_and_earn/model/chatboat_model/message_data.dart' show MessageDataAdapter;
import 'package:refer_and_earn/refer_and_earn/model/chatboat_model/message_model.dart' show MessageModelAdapter, MessageModel;
import 'package:refer_and_earn/refer_and_earn/view/screens/refer_screen.dart';
import 'package:toastification/toastification.dart';
import 'package:window_manager/window_manager.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(MessageDataAdapter());
  Hive.registerAdapter(MessageModelAdapter());

  await Hive.openBox<MessageModel>('messages');
  

  // Initialize window manager for desktop platforms
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux)) {
    await windowManager.ensureInitialized();
    WindowOptions options = const WindowOptions(title: "FoodChow");
    windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.maximize();
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setMinimumSize(const Size(600, 750));
    });
  }

  // Set the WebView platform to use webview_windows on Windows
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    await windowManager.ensureInitialized();
  }

  runApp(
    DevicePreview(
      enabled: kDebugMode,
      builder: (context) {
        return const ToastificationWrapper(child: MyApp());
      },
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
          colorScheme: ColorScheme.fromSeed(seedColor: ColorsClass.primary),
        ),
        home: const ReferScreen(),
      ),
    );
  }
}
