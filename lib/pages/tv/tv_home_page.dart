import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:alist_flutter/controllers/tv_controller.dart';
import 'package:alist_flutter/widgets/tv/tv_button.dart';
import 'package:alist_flutter/widgets/tv/qr_code_panel.dart';
import 'package:alist_flutter/generated/l10n.dart';

/// TV主页面，采用响应式布局，分为上、中、下三部分
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
    _forceSetLandscapeOrientation();
    
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // 每次页面依赖变化时（包括从其他页面返回时）强制设置横屏
    if (mounted) {
      _forceSetLandscapeOrientation();
      print('TV主页面依赖变化，已强制设置横屏');
    }
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
        // 应用恢复时，确保横屏方向
        if (mounted && _tvController.isOnTVHomePage()) {
          _forceSetLandscapeOrientation();
          _keyboardFocusNode.requestFocus();
          print('应用恢复，TV主页面横屏');
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

  /// 强制设置横屏方向
  void _forceSetLandscapeOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
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
        title: _tvController.isServiceRunning.value ? '停止' : '启动',
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
        iconColor: Colors.purple[600], // 紫色表示设置
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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1600),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // 上：标题
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          'AList Lite TV',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(flex: 1),
                      // 中：核心交互区
                      Expanded(
                        flex: 12,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                                // 按钮区 (50%)
                                Expanded(
                                  flex: 5,
                                  child: Obx(() {
                                    final buttonData = _getButtonData();
                                    return Column(
                                      children: [
                                        // 上排按钮
                                        Expanded(
                                          flex: 3, // 增加按钮高度
                                          child: Row(
                                            children: [
                                              // 启动按钮
                                              Expanded(
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
                                              Expanded(
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
                                        ),
                                        const Spacer(),
                                        // 下排按钮
                                        Expanded(
                                          flex: 3, // 增加按钮高度
                                          child: Row(
                                            children: [
                                              // 日志按钮
                                              Expanded(
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
                                              Expanded(
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
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                                const SizedBox(width: 20),

                                // 二维码区 (30%)
                                const Expanded(
                                  flex: 3,
                                  child: QRCodePanel(),
                                ),
                                const SizedBox(width: 20),

                                // 操作提示区 (20%)
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceVariant.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: colorScheme.outline.withOpacity(0.2),
                                      ),
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            color: colorScheme.primary,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            '操作提示',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              color: colorScheme.primary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            '• 方向键：切换按钮\n• 数字键：快速选择\n• 确认键：执行操作\n• 返回键：返回桌面\n• 设置中可切换主题',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: colorScheme.onSurface
                                                  .withOpacity(0.8),
                                              height: 1.5,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      ),
                      const Spacer(flex: 1),
                      // 下：服务状态
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Obx(() {
                          final isRunning = _tvController.isServiceRunning.value;
                          final isStarting =
                              _tvController.isServiceStarting.value;
                          final serverUrl = _tvController.serverUrl.value;
                          final error = _tvController.serviceError.value;

                          String statusText;
                          if (isStarting) {
                            statusText =
                                isRunning ? '正在停止...' : '正在启动...';
                          } else {
                            statusText =
                                isRunning ? '服务运行中' : '服务已停止';
                          }
                          if (isRunning && !isStarting) {
                            statusText += ' @ $serverUrl';
                            Clipboard.setData(ClipboardData(text: 'http://$serverUrl'));
                          }

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isRunning
                                      ? colorScheme.primaryContainer
                                      : colorScheme.errorContainer,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isStarting)
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
                                        isRunning
                                            ? Icons.check_circle
                                            : Icons.error,
                                        size: 16,
                                        color: isRunning
                                            ? colorScheme.primary
                                            : colorScheme.error,
                                      ),
                                    const SizedBox(width: 8),
                                    Text(
                                      statusText,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: isRunning
                                            ? colorScheme.primary
                                            : colorScheme.error,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (error.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Text(
                                    error,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.error,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}