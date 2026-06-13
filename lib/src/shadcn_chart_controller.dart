import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'shadcn_chart_models.dart';

/// Controls a mounted [ShadcnChartView] via JavaScript bridge functions
/// such as `window.updateChartData`.
///
/// Scripts queued before the WebView attaches run automatically on [attach].
class ShadcnChartController {
  InAppWebViewController? _webViewController;
  final List<String> _pendingScripts = <String>[];

  /// Replaces chart data without rebuilding the WebView.
  Future<void> updateData(ShadcnChartData data) {
    final json = data.toJson();
    return _evaluate('window.updateChartData(${jsonEncode(json)});');
  }

  /// Executes raw JavaScript in the chart WebView.
  Future<void> evaluateJavascript(String source) => _evaluate(source);

  /// Binds this controller to a created WebView and flushes pending scripts.
  Future<void> attach(InAppWebViewController controller) async {
    _webViewController = controller;
    final scripts = List<String>.of(_pendingScripts);
    _pendingScripts.clear();
    for (final source in scripts) {
      await controller.evaluateJavascript(source: source);
    }
  }

  /// Clears the WebView binding when the view disposes an auto-created controller.
  void detach() {
    _webViewController = null;
    _pendingScripts.clear();
  }

  Future<void> _evaluate(String source) async {
    final controller = _webViewController;
    if (controller == null) {
      _pendingScripts.add(source);
      return;
    }

    await controller.evaluateJavascript(source: source);
  }
}
