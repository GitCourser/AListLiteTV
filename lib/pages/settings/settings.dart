import 'dart:developer';
import 'dart:ffi';

import 'package:alist_flutter/contant/native_bridge.dart';
import 'package:alist_flutter/generated_api.dart';
import 'package:alist_flutter/pages/alist/pwd_edit_dialog.dart';
import 'package:alist_flutter/pages/alist/number_input_dialog.dart';
import 'package:alist_flutter/pages/alist/about_dialog.dart';
import 'package:alist_flutter/pages/app_update_dialog.dart';
import 'package:alist_flutter/pages/settings/preference_widgets.dart';
import 'package:alist_flutter/controllers/theme_controller.dart';
import 'package:alist_flutter/controllers/tv_controller.dart';
import 'package:alist_flutter/widgets/theme_selector_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../generated/l10n.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() {
    return _SettingsScreenState();
  }
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    _lifecycleListener = AppLifecycleListener(
      onResume: () async {
        final controller = Get.put(_SettingsController());
        controller.updateData();
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Allow auto-rotation for settings page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    final controller = Get.put(_SettingsController());
    // 确保主题控制器已初始化
    Get.put(ThemeController());
    return Scaffold(
        body: Obx(
      () => ListView(
        children: [
          // SizedBox(height: MediaQuery.of(context).padding.top),
          Visibility(
            visible: !controller._managerStorageGranted.value ||
                !controller._notificationGranted.value ||
                !controller._storageGranted.value,
            child: DividerPreference(title: S.of(context).importantSettings),
          ),
          Visibility(
            visible: !controller._managerStorageGranted.value,
            child: BasicPreference(
              title: S.of(context).grantManagerStoragePermission,
              subtitle: S.of(context).grantStoragePermissionDesc,
              onTap: () {
                Permission.manageExternalStorage.request();
              },
            ),
          ),
          Visibility(
              visible: !controller._storageGranted.value,
              child: BasicPreference(
                title: S.of(context).grantStoragePermission,
                subtitle: S.of(context).grantStoragePermissionDesc,
                onTap: () {
                  Permission.storage.request();
                },
              )),

          Visibility(
              visible: !controller._notificationGranted.value,
              child: BasicPreference(
                title: S.of(context).grantNotificationPermission,
                subtitle: S.of(context).grantNotificationPermissionDesc,
                onTap: () {
                  Permission.notification.request();
                },
              )),

          DividerPreference(title: S.of(context).alistConfig),

          BasicPreference(
            title: S.of(context).setAdminPassword,
            subtitle: "修改AList管理员密码",
            leading: const Icon(Icons.password),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => PwdEditDialog(onConfirm: (pwd) {
                  Get.showSnackbar(GetSnackBar(
                    title: S.of(context).setAdminPassword,
                    message: "密码已更新",
                    duration: const Duration(seconds: 2),
                  ));
                  NativeBridge.android.setAdminPwd(pwd);
                }),
              );
            },
          ),

          BasicPreference(
            title: S.of(context).httpPort,
            subtitle: S.of(context).httpPortDesc,
            leading: const Icon(Icons.network_check),
            trailing: Text(
              controller.httpPort.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => NumberInputDialog(
                  title: S.of(context).httpPort,
                  labelText: S.of(context).httpPort,
                  initialValue: controller.httpPort,
                  minValue: 1024,
                  maxValue: 65535,
                  onConfirm: (value) {
                    controller.httpPort = value;
                    
                    // 通知TVController刷新端口信息
                    try {
                      final tvController = Get.find<TVController>();
                      // tvController.refreshServiceStatus();
                    } catch (e) {
                      // TVController可能不存在，忽略错误
                    }
                    
                    Get.showSnackbar(GetSnackBar(
                      title: S.of(context).httpPort,
                      message: S.of(context).configUpdated,
                      duration: const Duration(seconds: 2),
                    ));
                  },
                ),
              );
            },
          ),

          BasicPreference(
            title: S.of(context).delayedStart,
            subtitle: S.of(context).delayedStartDesc,
            leading: const Icon(Icons.timer),
            trailing: Text(
              "${controller.delayedStart}s",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => NumberInputDialog(
                  title: S.of(context).delayedStart,
                  labelText: S.of(context).delayedStart,
                  initialValue: controller.delayedStart,
                  minValue: 0,
                  maxValue: 999999,
                  onConfirm: (value) {
                    controller.delayedStart = value;
                    Get.showSnackbar(GetSnackBar(
                      title: S.of(context).delayedStart,
                      message: S.of(context).configUpdated,
                      duration: const Duration(seconds: 2),
                    ));
                  },
                ),
              );
            },
          ),

          DividerPreference(title: S.of(context).general),

          SwitchPreference(
            title: S.of(context).autoCheckForUpdates,
            subtitle: S.of(context).autoCheckForUpdatesDesc,
            icon: const Icon(Icons.system_update),
            value: controller.autoUpdate,
            onChanged: (value) {
              controller.autoUpdate = value;
            },
          ),
          SwitchPreference(
            title: S.of(context).wakeLock,
            subtitle: S.of(context).wakeLockDesc,
            icon: const Icon(Icons.screen_lock_portrait),
            value: controller.wakeLock,
            onChanged: (value) {
              controller.wakeLock = value;
            },
          ),
          SwitchPreference(
            title: S.of(context).bootAutoStartService,
            subtitle: S.of(context).bootAutoStartServiceDesc,
            icon: const Icon(Icons.power_settings_new),
            value: controller.startAtBoot,
            onChanged: (value) {
              controller.startAtBoot = value;
            },
          ),

          BasicPreference(
            title: S.of(context).dataDirectory,
            subtitle: controller._dataDir.value,
            leading: const Icon(Icons.folder),
            onTap: () async {
              final path = await FilePicker.platform.getDirectoryPath();

              if (path == null) {
                Get.showSnackbar(GetSnackBar(
                    message: S.current.setDefaultDirectory,
                    duration: const Duration(seconds: 3),
                    mainButton: TextButton(
                      onPressed: () {
                        controller.setDataDir("");
                        Get.back();
                      },
                      child: Text(S.current.confirm),
                    )));
              } else {
                controller.setDataDir(path);
              }
            },
          ),
          DividerPreference(title: S.of(context).uiSettings),
          
          BasicPreference(
            title: S.of(context).themeMode,
            subtitle: S.of(context).themeModeDesc,
            leading: const Icon(Icons.palette),
            trailing: Obx(() {
              final themeController = Get.find<ThemeController>();
              return Text(
                _getThemeModeDisplayText(context, themeController.themeMode),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            }),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const ThemeSelectorDialog(),
              );
            },
          ),
          
          SwitchPreference(
              icon: const Icon(Icons.pan_tool_alt_outlined),
              title: S.of(context).silentJumpApp,
              subtitle: S.of(context).silentJumpAppDesc,
              value: controller._silentJumpApp.value,
              onChanged: (value) {
                controller.silentJumpApp = value;
              }),
          
          DividerPreference(title: S.of(context).about),
          
          BasicPreference(
            title: S.of(context).checkForUpdates,
            subtitle: "检查应用更新",
            leading: const Icon(Icons.system_update),
            onTap: () async {
              AppUpdateDialog.checkUpdateAndShowDialog(context, (b) {
                if (!b) {
                  Get.showSnackbar(GetSnackBar(
                      message: S.of(context).currentIsLatestVersion,
                      duration: const Duration(seconds: 2)));
                }
              });
            },
          ),
          
          BasicPreference(
            title: S.of(context).about,
            subtitle: "关于应用",
            leading: const Icon(Icons.info),
            onTap: () {
              showDialog(context: context, builder: ((context){
                return const AppAboutDialog();
              }));
            },
          ),
        ],
      ),
    ));
  }

  String _getThemeModeDisplayText(BuildContext context, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return S.of(context).themeModeLight;
      case ThemeMode.dark:
        return S.of(context).themeModeDark;
      case ThemeMode.system:
      default:
        return S.of(context).themeModeSystem;
    }
  }
}

class _SettingsController extends GetxController {
  final _dataDir = "".obs;
  final _autoUpdate = true.obs;
  final _managerStorageGranted = true.obs;
  final _notificationGranted = true.obs;
  final _storageGranted = true.obs;
  
  // AList配置相关的响应式变量
  final _httpPort = 5244.obs;
  final _delayedStart = 0.obs;

  setDataDir(String value) async {
    NativeBridge.appConfig.setDataDir(value);
    _dataDir.value = await NativeBridge.appConfig.getDataDir();
  }

  get dataDir => _dataDir.value;

  set autoUpdate(value) => {
        _autoUpdate.value = value,
        NativeBridge.appConfig.setAutoCheckUpdateEnabled(value)
      };

  get autoUpdate => _autoUpdate.value;

  final _wakeLock = true.obs;

  set wakeLock(value) => {
        _wakeLock.value = value,
        NativeBridge.appConfig.setWakeLockEnabled(value)
      };

  get wakeLock => _wakeLock.value;

  final _autoStart = true.obs;

  set startAtBoot(value) => {
        _autoStart.value = value,
        NativeBridge.appConfig.setStartAtBootEnabled(value)
      };

  get startAtBoot => _autoStart.value;



  final _silentJumpApp = false.obs;

  get silentJumpApp => _silentJumpApp.value;

  set silentJumpApp(value) => {
        _silentJumpApp.value = value,
        NativeBridge.appConfig.setSilentJumpAppEnabled(value)
      };

  // AList HTTP端口的getter和setter
  int get httpPort => _httpPort.value;

  set httpPort(int value) {
    _httpPort.value = value;
    NativeBridge.android.setAListHttpPort(value);
  }

  // AList延时启动的getter和setter
  int get delayedStart => _delayedStart.value;

  set delayedStart(int value) {
    _delayedStart.value = value;
    NativeBridge.android.setAListDelayedStart(value);
  }

  @override
  void onInit() async {
    updateData();

    super.onInit();
  }

  void updateData() async {
    final cfg = AppConfig();
    cfg.isAutoCheckUpdateEnabled().then((value) => autoUpdate = value);
    cfg.isWakeLockEnabled().then((value) => wakeLock = value);
    cfg.isStartAtBootEnabled().then((value) => startAtBoot = value);
    cfg.isSilentJumpAppEnabled().then((value) => silentJumpApp = value);

    _dataDir.value = await cfg.getDataDir();

    // 初始化AList配置数据
    try {
      _httpPort.value = await NativeBridge.android.getAListHttpPort();
      _delayedStart.value = await NativeBridge.android.getAListDelayedStart();
    } catch (e) {
      log('Failed to load AList configuration: $e');
      // 使用默认值
      _httpPort.value = 5244;
      _delayedStart.value = 0;
    }

    final sdk = await NativeBridge.common.getDeviceSdkInt();
    // A11
    if (sdk >= 30) {
      _managerStorageGranted.value =
          await Permission.manageExternalStorage.isGranted;
    } else {
      _managerStorageGranted.value = true;
      _storageGranted.value = await Permission.storage.isGranted;
    }

    // A12
    if (sdk >= 32) {
      _notificationGranted.value = await Permission.notification.isGranted;
    } else {
      _notificationGranted.value = true;
    }
  }
}
