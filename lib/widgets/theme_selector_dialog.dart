import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../generated/l10n.dart';
import '../controllers/theme_controller.dart';

class ThemeSelectorDialog extends StatelessWidget {
  const ThemeSelectorDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    
    return AlertDialog(
      title: Text(S.of(context).themeMode),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() => RadioListTile<ThemeMode>(
            title: Text(S.of(context).themeModeLight),
            value: ThemeMode.light,
            groupValue: themeController.themeMode,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                themeController.setThemeMode(value);
                Get.back();
              }
            },
          )),
          Obx(() => RadioListTile<ThemeMode>(
            title: Text(S.of(context).themeModeDark),
            value: ThemeMode.dark,
            groupValue: themeController.themeMode,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                themeController.setThemeMode(value);
                Get.back();
              }
            },
          )),
          Obx(() => RadioListTile<ThemeMode>(
            title: Text(S.of(context).themeModeSystem),
            value: ThemeMode.system,
            groupValue: themeController.themeMode,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                themeController.setThemeMode(value);
                Get.back();
              }
            },
          )),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(S.of(context).cancel),
        ),
      ],
    );
  }
}