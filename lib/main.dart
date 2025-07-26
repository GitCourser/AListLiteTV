import 'package:alist_flutter/generated/l10n.dart';
import 'package:alist_flutter/pages/app_update_dialog.dart';
import 'package:alist_flutter/pages/tv/tv_home_page.dart';
import 'package:alist_flutter/controllers/theme_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'contant/native_bridge.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Android
  if (!kIsWeb &&
      kDebugMode &&
      defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // 初始化应用控制器和主题控制器
    Get.put(_AppController());
    final themeController = Get.put(ThemeController());
    
    return Obx(() => GetMaterialApp(
      title: 'AListLiteATV',
      themeMode: themeController.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueGrey,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blueGrey,
        /* dark theme settings */
      ),
      supportedLocales: S.delegate.supportedLocales,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const TVHomePage(),
    ));
  }
}

class _AppController extends GetxController {
  @override
  void onInit() async {
    // 保持应用更新检查功能
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (await NativeBridge.appConfig.isAutoCheckUpdateEnabled()) {
        AppUpdateDialog.checkUpdateAndShowDialog(Get.context!, null);
      }
    });

    super.onInit();
  }
}
