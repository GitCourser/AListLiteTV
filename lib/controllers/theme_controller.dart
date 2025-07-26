import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../contant/native_bridge.dart';

class ThemeController extends GetxController {
  final _themeMode = ThemeMode.system.obs;

  ThemeMode get themeMode => _themeMode.value;

  @override
  void onInit() async {
    super.onInit();
    await loadThemeMode();
  }

  Future<void> loadThemeMode() async {
    try {
      final mode = await NativeBridge.appConfig.getThemeMode();
      _themeMode.value = _intToThemeMode(mode);
    } catch (e) {
      // 如果获取失败，使用默认值
      _themeMode.value = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode.value = mode;
    await NativeBridge.appConfig.setThemeMode(_themeModeToInt(mode));
    Get.changeThemeMode(mode);
  }

  ThemeMode _intToThemeMode(int mode) {
    switch (mode) {
      case 0:
        return ThemeMode.light;
      case 1:
        return ThemeMode.dark;
      case 2:
      default:
        return ThemeMode.system;
    }
  }

  int _themeModeToInt(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 0;
      case ThemeMode.dark:
        return 1;
      case ThemeMode.system:
      default:
        return 2;
    }
  }

  String getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'themeModeLight';
      case ThemeMode.dark:
        return 'themeModeDark';
      case ThemeMode.system:
      default:
        return 'themeModeSystem';
    }
  }
}