import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:alist_flutter/controllers/tv_controller.dart';
import 'package:alist_flutter/widgets/tv/tv_button.dart';
import 'package:alist_flutter/widgets/tv/server_info_panel.dart';
import 'package:alist_flutter/generated/l10n.dart';
import 'package:alist_flutter/pages/web/web.dart';
import 'package:alist_flutter/pages/alist/alist.dart';
import 'package:alist_flutter/pages/settings/settings.dart';

/// TV主页面，提供左右分栏布局：左半部分为2x2按钮，右半部分分为服务器信息二维码和操作提示
class TVHomePage extends StatefulWidget {
  const TVHomePage({super.key});

  @override
  State<TVHomePage> createState() => _TVHomePageState();
}

class _TVHomePageState extends State<TVHomePage> with WidgetsBindingObserver {
  late TVController _tvController;
  late FocusNode _keyboardFocusNode;

  @override
  void initState() {
    super.initState();
    
    // 强制横屏显示
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    // 初始化控制器
    _tvController = Get.put(TVController());
    
    // 初始化键盘焦点节点
    _keyboardFocusNode = FocusNode();
    
    // 添加应用生命周期监听
    WidgetsBinding.instance.addObserver(this);
    
    // 在下一帧请求焦点并维护页面状态
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardFocusNode.requestFocus();
      
      // 确保页面状态正确
      _tvController.currentPageIndex.value = 0;
      
      print('TV主页面已加载，焦点已设置');
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        // 应用恢复时，确保焦点正确
        if (mounted && _tvController.isOnTVHomePage()) {
          _keyboardFocusNode.requestFocus();
          print('应用恢复，TV主页面焦点已恢复');
        }
        break;
      case AppLifecycleState.paused:
        // 应用暂停时的处理
        print('应用暂停');
        break;
      default:
        break;
    }
  }

  /// 处理键盘事件
  bool _handleKeyEvent(KeyEvent event) {
    return _tvController.handleKeyEvent(event);
  }

  /// 获取按钮数据列表
  List<TVButtonData> _getButtonData() {
    return [
      // 启动按钮 (索引 0)
      TVButtonData(
        title: _tvController.isServiceRunning.value ? '停止服务' : '启动服务',
        icon: _tvController.isServiceRunning.value ? Icons.stop : Icons.play_arrow,
        onPressed: _tvController.toggleService,
        isEnabled: !_tvController.isServiceStarting.value,
        iconColor: _tvController.isServiceRunning.value 
            ? Colors.red[600]  // 停止服务时使用红色
            : Colors.green[600], // 启动服务时使用绿色
      ),
      // 网页按钮 (索引 1)
      TVButtonData(
        title: S.current.webPage,
        icon: Icons.web,
        onPressed: _tvController.navigateToWeb,
        isEnabled: _tvController.isServiceRunning.value,
        iconColor: Colors.blue[600], // 蓝色表示网页
      ),
      // 日志按钮 (索引 2)
      TVButtonData(
        title: '日志',
        icon: Icons.list_alt,
        onPressed: _tvController.navigateToLogs,
        isEnabled: true,
        iconColor: Colors.orange[600], // 橙色表示日志
      ),
      // 设置按钮 (索引 3)
      TVButtonData(
        title: S.current.settings,
        icon: Icons.settings,
        onPressed: _tvController.navigateToSettings,
        isEnabled: true,
        iconColor: Colors.grey[600], // 灰色表示设置
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                // 左半部分：按钮区域
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 标题
                      Text(
                        'AList Lite TV',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // 2x2按钮网格
                      Obx(() {
                        final buttonData = _getButtonData();
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 第一行按钮
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // 启动按钮
                                Flexible(
                                  child: TVButton(
                                    title: buttonData[0].title,
                                    icon: buttonData[0].icon,
                                    onPressed: buttonData[0].onPressed,
                                    isEnabled: buttonData[0].isEnabled,
                                    isFocused: _tvController.isFocused(0),
                                    onFocusChange: () => _tvController.setFocus(0),
                                    iconColor: buttonData[0].iconColor,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // 网页按钮
                                Flexible(
                                  child: TVButton(
                                    title: buttonData[1].title,
                                    icon: buttonData[1].icon,
                                    onPressed: buttonData[1].onPressed,
                                    isEnabled: buttonData[1].isEnabled,
                                    isFocused: _tvController.isFocused(1),
                                    onFocusChange: () => _tvController.setFocus(1),
                                    iconColor: buttonData[1].iconColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            // 第二行按钮
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // 日志按钮
                                Flexible(
                                  child: TVButton(
                                    title: buttonData[2].title,
                                    icon: buttonData[2].icon,
                                    onPressed: buttonData[2].onPressed,
                                    isEnabled: buttonData[2].isEnabled,
                                    isFocused: _tvController.isFocused(2),
                                    onFocusChange: () => _tvController.setFocus(2),
                                    iconColor: buttonData[2].iconColor,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // 设置按钮
                                Flexible(
                                  child: TVButton(
                                    title: buttonData[3].title,
                                    icon: buttonData[3].icon,
                                    onPressed: buttonData[3].onPressed,
                                    isEnabled: buttonData[3].isEnabled,
                                    isFocused: _tvController.isFocused(3),
                                    onFocusChange: () => _tvController.setFocus(3),
                                    iconColor: buttonData[3].iconColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
                      
                      const SizedBox(height: 32),
                      
                      // 服务状态指示器
                      Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _tvController.isServiceRunning.value
                              ? colorScheme.primaryContainer
                              : colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_tvController.isServiceStarting.value)
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.primary,
                                ),
                              )
                            else
                              Icon(
                                _tvController.isServiceRunning.value
                                    ? Icons.check_circle
                                    : Icons.error,
                                size: 16,
                                color: _tvController.isServiceRunning.value
                                    ? colorScheme.primary
                                    : colorScheme.error,
                              ),
                            const SizedBox(width: 8),
                            Text(
                              _tvController.isServiceStarting.value
                                  ? (_tvController.isServiceRunning.value ? '正在停止...' : '正在启动...')
                                  : (_tvController.isServiceRunning.value ? '服务运行中' : '服务已停止'),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: _tvController.isServiceRunning.value
                                    ? colorScheme.primary
                                    : colorScheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )),
                      
                      // 错误信息显示
                      Obx(() => _tvController.serviceError.value.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colorScheme.errorContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _tvController.serviceError.value,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.error,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : const SizedBox.shrink()),
                    ],
                  ),
                ),
                
                const SizedBox(width: 32),
                
                // 右半部分：服务器信息和操作提示
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      // 服务器信息和二维码
                      Expanded(
                        flex: 1,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ServerInfoPanel(),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 20),
                      
                      // 操作提示
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 操作提示容器，高度匹配ServerInfoPanel
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return Container(
                                  height: 390, // 设置固定高度匹配ServerInfoPanel
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceVariant.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: colorScheme.outline.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: colorScheme.primary,
                                        size: 28,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        '遥控器操作提示',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '• 方向键：切换按钮\n• 确认键：执行操作\n• Tab键：顺序切换\n• 数字键1-4：快速选择\n• 返回键：退出应用\n• Home键：返回主页',
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: colorScheme.onSurface.withOpacity(0.8),
                                                height: 1.5,
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}