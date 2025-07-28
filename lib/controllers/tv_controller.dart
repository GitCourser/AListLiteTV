import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:alist_flutter/contant/native_bridge.dart';
import 'package:alist_flutter/generated_api.dart';
import 'package:alist_flutter/generated/l10n.dart';
import 'package:alist_flutter/pages/web/web.dart';
import 'package:alist_flutter/pages/alist/alist.dart';
import 'package:alist_flutter/pages/settings/settings.dart';
import 'package:alist_flutter/pages/alist/log_list_view.dart' as alist;

/// TV界面控制器，管理焦点导航、服务状态和服务器信息
class TVController extends GetxController {
  // 按钮焦点导航相关
  final currentFocusIndex = 0.obs;
  final buttonCount = 4; // 启动、网页、日志、设置
  
  // 服务状态相关
  final isServiceRunning = false.obs;
  final isServiceStarting = false.obs;
  final serviceError = ''.obs;
  
  // 服务器信息相关
  final serverUrl = ''.obs;
  final alistVersion = ''.obs;
  
  // 日志管理
  final logs = <Log>[].obs;
  
  // 事件接收器
  MyEventReceiver? _eventReceiver;
  
  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  @override
  void onClose() {
    _eventReceiver = null;
    
    // 清理页面状态
    clearPageHistory();
    
    print('TVController已清理');
    super.onClose();
  }

  /// 初始化控制器
  Future<void> _initializeController() async {
    try {
      // 初始化页面状态
      currentPageIndex.value = 0; // 确保从TV主页开始
      pageHistory.clear();
      
      // 设置默认焦点到启动按钮（仅在初始化时设置一次）
      currentFocusIndex.value = 0;
      
      // 设置事件接收器
      _setupEventReceiver();
      
      // 获取初始状态
      await _loadInitialData();
      
      print('TVController初始化完成，当前页面: ${getCurrentPageName()}');
    } catch (e) {
      print('TVController初始化失败: $e');
      serviceError.value = '初始化失败: $e';
    }
  }

  /// 设置事件接收器
  void _setupEventReceiver() {
    _eventReceiver = MyEventReceiver(
      (isRunning) {
        isServiceRunning.value = isRunning;
        isServiceStarting.value = false;
        if (isRunning) {
          serviceError.value = '';
        }
        // 立即更新服务器URL
        _updateServerUrl();
        print('服务状态已更新: ${isRunning ? "运行中" : "已停止"}');
      },
      (log) {
        // 添加日志到列表
        addLog(log);
      },
    );
    Event.setup(_eventReceiver);
    print('TVController事件接收器已设置');
  }

  /// 重新设置事件接收器（用于服务重启后重新接收日志）
  void resetEventReceiver() {
    _setupEventReceiver();
    print('TVController事件接收器已重置');
  }

  /// 加载初始数据
  Future<void> _loadInitialData() async {
    try {
      // 获取AList版本
      final version = await NativeBridge.android.getAListVersion();
      alistVersion.value = version;
      
      // 获取服务运行状态
      final running = await NativeBridge.android.isRunning();
      isServiceRunning.value = running;
      
      // 更新服务器URL
      await _updateServerUrl();
    } catch (e) {
      print('加载初始数据失败: $e');
      serviceError.value = '加载数据失败: $e';
    }
  }

  /// 更新服务器URL
  Future<void> _updateServerUrl() async {
    try {
      if (isServiceRunning.value) {
        final serverAddress = await NativeBridge.android.getServerAddress();
        final serverPort = await NativeBridge.android.getAListHttpPort();
        serverUrl.value = '$serverAddress:${serverPort}';
      } else {
        serverUrl.value = '服务未启动';
      }
    } catch (e) {
      print('更新服务器URL失败: $e');
      serverUrl.value = '获取地址失败';
    }
  }

  // ========== 焦点导航方法 ==========
  // 2x2网格布局映射：
  // 0: 启动按钮 (行0, 列0)  1: 网页按钮 (行0, 列1)
  // 2: 日志按钮 (行1, 列0)  3: 设置按钮 (行1, 列1)
  static const List<List<int>> gridLayout = [
    [0, 1], // 第一行
    [2, 3], // 第二行
  ];

  /// 移动焦点到下一个按钮（顺时针循环）
  void moveFocusNext() {
    final newIndex = (currentFocusIndex.value + 1) % buttonCount;
    _setFocusDirectly(newIndex);
  }

  /// 移动焦点到上一个按钮（逆时针循环）
  void moveFocusPrevious() {
    final newIndex = (currentFocusIndex.value - 1 + buttonCount) % buttonCount;
    _setFocusDirectly(newIndex);
  }

  /// 向右移动焦点（循环导航）
  void moveFocusRight() {
    // 简化的右移逻辑：0->1, 1->0, 2->3, 3->2
    int newIndex;
    switch (currentFocusIndex.value) {
      case 0: newIndex = 1; break; // 启动 -> 网页
      case 1: newIndex = 0; break; // 网页 -> 启动
      case 2: newIndex = 3; break; // 日志 -> 设置
      case 3: newIndex = 2; break; // 设置 -> 日志
      default: newIndex = 0;
    }
    _setFocusDirectly(newIndex);
  }

  /// 向左移动焦点（循环导航）
  void moveFocusLeft() {
    // 简化的左移逻辑：与右移相同（在2x2网格中左右是对称的）
    moveFocusRight();
  }

  /// 向下移动焦点（循环导航）
  void moveFocusDown() {
    // 简化的下移逻辑：0->2, 1->3, 2->0, 3->1
    int newIndex;
    switch (currentFocusIndex.value) {
      case 0: newIndex = 2; break; // 启动 -> 日志
      case 1: newIndex = 3; break; // 网页 -> 设置
      case 2: newIndex = 0; break; // 日志 -> 启动
      case 3: newIndex = 1; break; // 设置 -> 网页
      default: newIndex = 0;
    }
    _setFocusDirectly(newIndex);
  }

  /// 向上移动焦点（循环导航）
  void moveFocusUp() {
    // 简化的上移逻辑：与下移相同（在2x2网格中上下是对称的）
    moveFocusDown();
  }

  /// 直接设置焦点到指定按钮（无动画，立即响应）
  void _setFocusDirectly(int index) {
    if (index >= 0 && index < buttonCount) {
      // 立即更新焦点索引
      currentFocusIndex.value = index;
      
      // 简单的触觉反馈
      HapticFeedback.selectionClick();
      
      print('焦点切换到按钮 $index (${_getButtonName(index)})');
    }
  }

  /// 设置焦点到指定按钮（无动画，用于直接设置）
  void setFocus(int index) {
    if (index >= 0 && index < buttonCount) {
      currentFocusIndex.value = index;
    }
  }

  /// 检查指定按钮是否有焦点
  bool isFocused(int index) {
    return currentFocusIndex.value == index;
  }

  /// 获取当前焦点按钮的名称
  String getCurrentFocusedButtonName() {
    return _getButtonName(currentFocusIndex.value);
  }

  /// 获取按钮名称
  String _getButtonName(int index) {
    switch (index) {
      case 0: return '启动按钮';
      case 1: return '网页按钮';
      case 2: return '日志按钮';
      case 3: return '设置按钮';
      default: return '未知按钮';
    }
  }

  /// 重置焦点到默认位置（启动按钮）- 仅在初始化时使用
  void resetFocusToDefault() {
    _setFocusDirectly(0);
    print('焦点已重置到默认位置（启动按钮）');
  }

  // ========== 服务控制方法 ==========

  /// 切换服务状态（启动/停止）
  /// 这个方法集成了原有浮动按钮的服务控制逻辑
  Future<void> toggleService() async {
    if (isServiceStarting.value) {
      return; // 正在操作中，忽略操作
    }

    try {
      serviceError.value = '';
      isServiceStarting.value = true;
      
      // 重新设置事件接收器，确保能接收到新的日志
      resetEventReceiver();
      
      // 调用原生服务启动方法
      // 注意：原有逻辑总是调用startService()，由原生层决定启动或停止
      await NativeBridge.android.startService();
      
      // 等待状态更新
      await _waitForServiceStatusChange();
      
    } catch (e) {
      print('切换服务状态失败: $e');
      serviceError.value = '操作失败: $e';
      isServiceStarting.value = false;
      
      // 显示错误消息
      Get.showSnackbar(GetSnackBar(
        message: '服务操作失败: $e',
        duration: const Duration(seconds: 3),
        backgroundColor: Get.theme.colorScheme.errorContainer,
      ));
    }
  }

  /// 等待服务状态变化（简化版本，主要依赖事件接收器）
  Future<void> _waitForServiceStatusChange() async {
    // 等待一小段时间让原生服务处理请求
    await Future.delayed(const Duration(milliseconds: 800));
    
    // 如果事件接收器还没有更新状态，手动检查一次
    if (isServiceStarting.value) {
      try {
        final running = await NativeBridge.android.isRunning();
        isServiceRunning.value = running;
        isServiceStarting.value = false;
        await _updateServerUrl();
        
        // 显示状态消息
        final message = running ? '服务启动成功' : '服务已停止';
        final bgColor = running 
            ? Get.theme.colorScheme.primaryContainer
            : Get.theme.colorScheme.surfaceVariant;
            
        Get.showSnackbar(GetSnackBar(
          message: message,
          duration: const Duration(seconds: 2),
          backgroundColor: bgColor,
        ));
      } catch (e) {
        print('检查服务状态失败: $e');
        serviceError.value = '状态检查失败: $e';
        isServiceStarting.value = false;
        
        Get.showSnackbar(GetSnackBar(
          message: '服务操作可能失败: $e',
          duration: const Duration(seconds: 3),
          backgroundColor: Get.theme.colorScheme.errorContainer,
        ));
      }
    }
  }

  /// 添加日志（集成原有AListController的addLog方法）
  void addLog(Log log) {
    logs.add(log);
    // 限制日志数量，避免内存占用过多
    if (logs.length > 1000) {
      logs.removeRange(0, logs.length - 1000);
    }
  }

  /// 获取最新的日志
  List<Log> getRecentLogs([int count = 50]) {
    if (logs.length <= count) {
      return logs.toList();
    }
    return logs.sublist(logs.length - count);
  }

  /// 处理服务启动失败的情况
  void handleServiceStartFailure(String error) {
    isServiceStarting.value = false;
    isServiceRunning.value = false;
    serviceError.value = error;
    serverUrl.value = '服务启动失败';
    
    // 添加错误日志
    addLog(Log(
      3, // ERROR level
      DateTime.now().toString(),
      '服务启动失败: $error',
    ));
    
    Get.showSnackbar(GetSnackBar(
      message: '服务启动失败: $error',
      duration: const Duration(seconds: 4),
      backgroundColor: Get.theme.colorScheme.errorContainer,
    ));
  }

  /// 检查服务是否可以启动（检查前置条件）
  Future<bool> canStartService() async {
    try {
      // 检查是否已经在运行
      if (isServiceRunning.value) {
        return true;
      }
      
      // 检查是否正在启动
      if (isServiceStarting.value) {
        return false;
      }
      
      // 这里可以添加其他前置条件检查
      // 比如检查存储权限、网络状态等
      
      return true;
    } catch (e) {
      print('检查服务启动条件失败: $e');
      return false;
    }
  }

  /// 强制刷新服务状态（仅在必要时使用）
  // Future<void> refreshServiceStatus() async {
  //   try {
  //     // 只获取初始状态，不依赖定时器
  //     final running = await NativeBridge.android.isRunning();
  //     isServiceRunning.value = running;
      
  //     final port = await NativeBridge.android.getAListHttpPort();
  //     serverPort.value = port;
      
  //     await _updateServerUrl();
      
  //     print('服务状态已手动刷新: ${running ? "运行中" : "已停止"}');
  //   } catch (e) {
  //     print('刷新服务状态失败: $e');
  //     serviceError.value = '刷新失败: $e';
  //   }
  // }

  // ========== 页面导航和状态管理 ==========
  
  // 页面状态管理
  final currentPageIndex = 0.obs; // 0: TV主页, 1: 网页, 2: 日志, 3: 设置
  final pageHistory = <int>[].obs; // 页面历史栈
  
  // 页面名称映射
  static const Map<int, String> pageNames = {
    0: 'TV主页',
    1: '网页',
    2: '日志',
    3: '设置',
  };

  /// 导航到网页页面
  void navigateToWeb() {
    if (isServiceRunning.value) {
      _navigateToPage(1, () => const WebScreen(key: ValueKey('web')));
    } else {
      Get.showSnackbar(GetSnackBar(
        message: '请先启动服务',
        duration: const Duration(seconds: 2),
        backgroundColor: Get.theme.colorScheme.errorContainer,
      ));
    }
  }

  /// 导航到日志页面（AListScreen）
  void navigateToLogs() {
    // 确保AList控制器存在并同步日志数据
    final alistController = Get.put(AListController());
    
    // 强制刷新AList控制器的事件接收器，确保能接收到新的日志
    alistController.setupEventReceiver();
    
    // 将TVController的Log转换为AList页面需要的Log格式
    final alistLogs = logs.map((tvLog) => 
      // 使用AList页面的Log类型，注意构造函数参数顺序：level, time, content
      alist.Log(tvLog.level, tvLog.time, tvLog.log)
    ).toList();
    
    // 清空原有日志并添加新日志，确保显示最新的完整日志
    alistController.logs.clear();
    alistController.logs.addAll(alistLogs);
    
    // 同时确保两个控制器的事件接收器都能正常工作
    resetEventReceiver();
    
    print('同步了 ${alistLogs.length} 条日志到AList页面，事件接收器已重置');
    
    _navigateToPage(2, () => const AListScreen());
  }

  /// 导航到设置页面
  void navigateToSettings() {
    _navigateToPage(3, () => const SettingsScreen());
  }

  /// 通用页面导航方法
  void _navigateToPage(int pageIndex, Widget Function() pageBuilder) {
    // 记录当前页面到历史栈
    if (currentPageIndex.value != pageIndex) {
      pageHistory.add(currentPageIndex.value);
      currentPageIndex.value = pageIndex;
      
      // 导航到新页面
      Get.to(
        pageBuilder,
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      )?.then((_) {
        // 页面返回时恢复状态
        _onPageReturned();
        
        // 如果返回到TV主页面，确保横屏方向
        if (currentPageIndex.value == 0) {
          _ensureTVHomePageOrientation();
        }
      });
      
      print('导航到${pageNames[pageIndex]}页面');
    }
  }

  /// 返回TV主页面
  void navigateBackToTVHome() {
    if (currentPageIndex.value != 0) {
      // 清空历史栈并返回主页
      pageHistory.clear();
      currentPageIndex.value = 0;
      
      // 返回到主页面
      Get.until((route) => route.isFirst);
      
      // 确保横屏方向
      _ensureTVHomePageOrientation();
      
      print('返回TV主页面');
      
      // 显示返回提示
      Get.showSnackbar(GetSnackBar(
        message: '已返回TV主页',
        duration: const Duration(seconds: 1),
        backgroundColor: Get.theme.colorScheme.primaryContainer,
      ));
    }
  }

  /// 返回上一页面
  void navigateBack() {
    if (pageHistory.isNotEmpty) {
      final previousPageIndex = pageHistory.removeLast();
      currentPageIndex.value = previousPageIndex;
      
      Get.back();
      
      // 如果返回到TV主页面，确保横屏方向
      if (previousPageIndex == 0) {
        _ensureTVHomePageOrientation();
      }
      print('返回到${pageNames[previousPageIndex]}页面');
    } else {
      // 没有历史记录，返回TV主页
      navigateBackToTVHome();
    }
  }

  /// 页面返回时的处理
  void _onPageReturned() {
    if (pageHistory.isNotEmpty) {
      currentPageIndex.value = pageHistory.removeLast();
    } else {
      currentPageIndex.value = 0; // 返回TV主页
    }
    print('页面返回，当前页面: ${pageNames[currentPageIndex.value]}');
  }

  /// 获取当前页面名称
  String getCurrentPageName() {
    return pageNames[currentPageIndex.value] ?? '未知页面';
  }

  /// 检查是否在TV主页
  bool isOnTVHomePage() {
    return currentPageIndex.value == 0;
  }

  /// 检查是否可以返回
  bool canGoBack() {
    return pageHistory.isNotEmpty || currentPageIndex.value != 0;
  }

  /// 清除页面历史
  void clearPageHistory() {
    pageHistory.clear();
    currentPageIndex.value = 0;
  }

  /// 确保TV主页面的横屏方向
  void _ensureTVHomePageOrientation() {
    // 延迟一小段时间确保页面完全加载后再设置方向
    Future.delayed(const Duration(milliseconds: 100), () {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      print('已确保TV主页面横屏方向');
    });
  }

  /// 处理键盘事件（简化版本，立即响应）
  bool handleKeyEvent(KeyEvent event) {
    // 只处理按键按下事件，忽略重复和释放事件以避免多次触发
    if (event is! KeyDownEvent) {
      return false;
    }
    
    final key = event.logicalKey;
    
    // 处理具体按键
    switch (key) {
      case LogicalKeyboardKey.arrowUp:
        moveFocusUp();
        return true;
        
      case LogicalKeyboardKey.arrowDown:
        moveFocusDown();
        return true;
        
      case LogicalKeyboardKey.arrowLeft:
        moveFocusLeft();
        return true;
        
      case LogicalKeyboardKey.arrowRight:
        moveFocusRight();
        return true;
        
      case LogicalKeyboardKey.select:
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.space:
        _executeCurrentButtonWithFeedback();
        return true;
        
      case LogicalKeyboardKey.escape:
      case LogicalKeyboardKey.goBack:
        return _handleBackKey();
        
      case LogicalKeyboardKey.home:
        navigateBackToTVHome();
        return true;
        
      // 数字键快速导航
      case LogicalKeyboardKey.digit1:
        _setFocusDirectly(0);
        return true;
      case LogicalKeyboardKey.digit2:
        _setFocusDirectly(1);
        return true;
      case LogicalKeyboardKey.digit3:
        _setFocusDirectly(2);
        return true;
      case LogicalKeyboardKey.digit4:
        _setFocusDirectly(3);
        return true;
        
      // Tab键循环导航
      case LogicalKeyboardKey.tab:
        moveFocusNext();
        return true;
        
      default:
        return false;
    }
  }

  /// 处理返回键
  bool _handleBackKey() {
    if (isOnTVHomePage()) {
      // 在TV主页面，直接返回桌面
      SystemNavigator.pop();
      return true;
    } else {
      // 在其他页面时返回TV主页
      navigateBackToTVHome();
      return true;
    }
  }

  /// 执行当前按钮操作（带反馈）
  void _executeCurrentButtonWithFeedback() {
    // 简单触觉反馈
    HapticFeedback.selectionClick();
    
    // 执行按钮操作
    _executeCurrentButton();
    
    print('执行按钮操作: ${getCurrentFocusedButtonName()}');
  }

  /// 执行当前焦点按钮的操作
  void _executeCurrentButton() {
    switch (currentFocusIndex.value) {
      case 0: // 启动按钮
        toggleService();
        break;
      case 1: // 网页按钮
        navigateToWeb();
        break;
      case 2: // 日志按钮
        navigateToLogs();
        break;
      case 3: // 设置按钮
        navigateToSettings();
        break;
    }
  }
}

/// 事件接收器，用于接收原生服务的状态和日志事件
class MyEventReceiver extends Event {
  final Function(bool isRunning) statusCallback;
  final Function(Log log) logCallback;

  MyEventReceiver(this.statusCallback, this.logCallback);

  @override
  void onServiceStatusChanged(bool isRunning) {
    statusCallback(isRunning);
  }

  @override
  void onServerLog(int level, String time, String log) {
    logCallback(Log(level, time, log));
  }
}

/// 日志数据模型
class Log {
  final int level;
  final String time;
  final String log;

  Log(this.level, this.time, this.log);

  @override
  String toString() {
    return 'Log{level: $level, time: $time, log: $log}';
  }
}