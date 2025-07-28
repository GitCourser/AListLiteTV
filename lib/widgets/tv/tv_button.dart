import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// TV优化的按钮组件，支持焦点状态和遥控器导航
class TVButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final bool isFocused;
  final VoidCallback? onFocusChange;
  final Color? iconColor;

  const TVButton({
    super.key,
    required this.title,
    required this.icon,
    this.onPressed,
    this.isEnabled = true,
    this.isFocused = false,
    this.onFocusChange,
    this.iconColor,
  });

  @override
  State<TVButton> createState() => _TVButtonState();
}

class _TVButtonState extends State<TVButton> {
  @override
  void didUpdateWidget(TVButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当焦点状态改变时，触发重建
    if (widget.isFocused != oldWidget.isFocused) {
      setState(() {});
    }
  }

  void _handleTap() {
    if (widget.isEnabled && widget.onPressed != null) {
      // 简单触觉反馈
      HapticFeedback.selectionClick();
      
      // 立即执行回调
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isFocused 
              ? colorScheme.primary 
              : colorScheme.outline.withOpacity(0.3),
          width: widget.isFocused ? 3.0 : 2.0,
        ),
        color: widget.isEnabled
            ? (widget.isFocused 
                ? colorScheme.primaryContainer
                : colorScheme.surface)
            : colorScheme.surface.withOpacity(0.5),
        boxShadow: widget.isFocused
            ? [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _handleTap,
          onFocusChange: (hasFocus) {
            widget.onFocusChange?.call();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 图标
                Expanded(
                  flex: 2,
                  child: Icon(
                    widget.icon,
                    size: 36,
                    color: widget.isEnabled
                        ? (widget.iconColor ?? // 优先使用自定义颜色
                            (widget.isFocused
                                ? colorScheme.primary
                                : colorScheme.onSurface))
                        : colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 8),
                // 文字
                Expanded(
                  flex: 1,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: widget.isEnabled
                            ? (widget.isFocused
                                ? colorScheme.primary
                                : colorScheme.onSurface)
                            : colorScheme.onSurface.withOpacity(0.4),
                        fontWeight:
                            widget.isFocused ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
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

/// TV按钮数据模型
class TVButtonData {
  final String title;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final Color? iconColor;

  const TVButtonData({
    required this.title,
    required this.icon,
    this.onPressed,
    this.isEnabled = true,
    this.iconColor,
  });
}