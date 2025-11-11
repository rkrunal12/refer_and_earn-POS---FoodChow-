import 'dart:io';

import 'package:device_preview_minus/device_preview_minus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:provider/provider.dart';
import 'package:refer_and_earn/chatboat/controller/chat_boat_controller.dart';
import 'package:refer_and_earn/refer_and_earn/color_class.dart';
import 'package:refer_and_earn/refer_and_earn/controller/provider/refer_provider.dart';
import 'package:refer_and_earn/refer_and_earn/view/screens/refer_screen.dart';
import 'package:toastification/toastification.dart';
import 'package:window_manager/window_manager.dart';

import 'chatboat/model/message_data.dart';
import 'chatboat/model/message_model.dart';
import 'chatboat/model/title_item.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
  } else {
    await Hive.initFlutter(); // For mobile and web
  }

  Hive.registerAdapter(MessageDataAdapter());
  Hive.registerAdapter(MessageModelAdapter());
  Hive.registerAdapter(TitleItemAdapter());
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReferralProvider()),
        ChangeNotifierProvider(create: (_) => ChatBoatProvider()),
      ],
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
