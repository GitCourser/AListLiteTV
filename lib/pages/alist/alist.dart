import 'dart:developer';
import 'dart:io';

import 'package:alist_flutter/generated_api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../generated/l10n.dart';
import '../../utils/intent_utils.dart';
import 'log_list_view.dart';

class AListScreen extends StatelessWidget {
  const AListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Allow auto-rotation for AList page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    final ui = Get.put(AListController());

    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            title: Obx(() => Text("AListLite - ${ui.alistVersion.value}"))),

        body: Obx(() => LogListView(logs: ui.logs.value)));
  }
}

class MyEventReceiver extends Event {
  Function(Log log) logCb;
  Function(bool isRunning) statusCb;

  MyEventReceiver(this.statusCb, this.logCb);

  @override
  void onServiceStatusChanged(bool isRunning) {
    statusCb(isRunning);
  }

  @override
  void onServerLog(int level, String time, String log) {
    logCb(Log(level, time, log));
  }
}

class AListController extends GetxController {
  final ScrollController _scrollController = ScrollController();
  var isSwitch = false.obs;
  var alistVersion = "".obs;

  var logs = <Log>[].obs;

  void clearLog() {
    logs.clear();
  }

  void addLog(Log log) {
    logs.add(log);
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  /// 设置事件接收器（用于重新初始化日志接收）
  void setupEventReceiver() {
    // 创建新的事件接收器实例
    final newReceiver = MyEventReceiver(
        (isRunning) => isSwitch.value = isRunning, 
        (log) => addLog(log)
    );
    
    // 重新设置事件接收器
    Event.setup(newReceiver);
    print('AListController事件接收器已重新设置');
  }

  @override
  void onInit() {
    setupEventReceiver();
    Android().getAListVersion().then((value) => alistVersion.value = value);
    Android().isRunning().then((value) => isSwitch.value = value);

    super.onInit();
  }
}
