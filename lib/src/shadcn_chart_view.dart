import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'shadcn_chart_controller.dart';
import 'shadcn_chart_models.dart';
import 'shadcn_chart_utils.dart';

/// Embeds a bundled shadcn/Recharts renderer inside an [InAppWebView].
///
/// Wrap in a bounded parent such as [SizedBox]:
///
/// ```dart
/// SizedBox(
///   height: 320,
///   child: ShadcnChartView(data: chartData),
/// )
/// ```
///
/// For live updates after load, pass a [ShadcnChartController].
class ShadcnChartView extends StatefulWidget {
  /// Creates a chart view for a typed chart payload.
  const ShadcnChartView({
    super.key,
    required this.data,
    this.controller,
    this.settings,
    this.backgroundColor = Colors.transparent,
    this.onWebViewCreated,
    this.onLoadStop,
    this.onReceivedError,
    this.loadingBuilder,
  });

  /// Typed chart data sent to the embedded renderer.
  final ShadcnChartData data;

  /// Optional controller for live data and theme updates.
  final ShadcnChartController? controller;

  /// Optional WebView settings. Defaults are suitable for bundled assets.
  final InAppWebViewSettings? settings;

  /// Background shown behind the WebView.
  final Color backgroundColor;

  /// Called immediately after the underlying [InAppWebView] is created.
  final void Function(InAppWebViewController controller)? onWebViewCreated;

  /// Called when the chart HTML finishes loading and initial data is applied.
  final void Function(InAppWebViewController controller, WebUri? url)?
      onLoadStop;

  /// Called when the WebView fails to load a chart resource.
  final void Function(
    InAppWebViewController controller,
    WebResourceRequest request,
    WebResourceError error,
  )? onReceivedError;

  /// Builder shown while the bundled HTML asset is loading.
  final WidgetBuilder? loadingBuilder;

  @override
  State<ShadcnChartView> createState() => _ShadcnChartViewState();
}

class _ShadcnChartViewState extends State<ShadcnChartView> {
  late final ShadcnChartController _controller;
  late final bool _ownsController;
  late Future<String> _htmlFuture;
  Future<void>? _attachFuture;
  bool _hasLoaded = false;
  String? _lastHostThemeJson;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? ShadcnChartController();
    _htmlFuture = _loadChartHtml();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.detach();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ShadcnChartView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.type != widget.data.type) {
      _hasLoaded = false;
      _htmlFuture = _loadChartHtml();
    } else if (jsonEncode(oldWidget.data.toJson()) !=
        jsonEncode(widget.data.toJson())) {
      _controller.updateData(widget.data);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoaded) {
      _syncHostTheme();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: widget.backgroundColor,
      child: FutureBuilder<String>(
        future: _htmlFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return widget.loadingBuilder?.call(context) ??
                const Center(child: CircularProgressIndicator());
          }

          return _buildWebView(html: snapshot.data!);
        },
      ),
    );
  }

  Widget _buildWebView({required String html}) {
    return InAppWebView(
      key: ValueKey<String>(widget.data.type.packageAssetKey),
      initialData: InAppWebViewInitialData(
        data: html,
        baseUrl: WebUri('https://localhost/'),
        mimeType: 'text/html',
        encoding: 'utf8',
      ),
      initialSettings: widget.settings ?? _defaultSettings(),
      onWebViewCreated: (controller) {
        _attachFuture = _controller.attach(controller);
        widget.onWebViewCreated?.call(controller);
      },
      onLoadStop: (controller, url) async {
        await _attachFuture;
        _hasLoaded = true;
        await _syncHostTheme(force: true);
        await _applyInitialChartData();
        widget.onLoadStop?.call(controller, url);
      },
      onReceivedError: widget.onReceivedError,
    );
  }

  InAppWebViewSettings _defaultSettings() {
    return InAppWebViewSettings(
      javaScriptEnabled: true,
      transparentBackground: widget.backgroundColor == Colors.transparent,
      disableContextMenu: true,
      disableHorizontalScroll: true,
      disableVerticalScroll: true,
      horizontalScrollBarEnabled: false,
      verticalScrollBarEnabled: false,
      supportZoom: false,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
    );
  }

  Future<String> _loadChartHtml() {
    return rootBundle.loadString(widget.data.type.packageAssetKey);
  }

  Future<void> _applyInitialChartData() {
    return _controller.updateData(widget.data);
  }

  Future<void> _syncHostTheme({bool force = false}) async {
    final hostThemeJson = jsonEncode(_hostThemePayload(context));
    if (!force && hostThemeJson == _lastHostThemeJson) {
      return;
    }

    _lastHostThemeJson = hostThemeJson;
    await _controller.evaluateJavascript(
      'window.setHostTheme($hostThemeJson);',
    );
  }
}

Map<String, String> _hostThemePayload(BuildContext context) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textColor = theme.textTheme.bodyMedium?.color ?? colorScheme.onSurface;
  final cardColor = theme.cardTheme.color ?? colorScheme.surfaceContainerLow;

  return {
    'brightness': theme.brightness.name,
    'background': colorToCssHex(colorScheme.surface),
    'foreground': colorToCssHex(textColor),
    'card': colorToCssHex(cardColor),
    'cardForeground': colorToCssHex(colorScheme.onSurface),
    'popover': colorToCssHex(colorScheme.surfaceContainerHighest),
    'popoverForeground': colorToCssHex(colorScheme.onSurface),
    'primary': colorToCssHex(colorScheme.primary),
    'primaryForeground': colorToCssHex(colorScheme.onPrimary),
    'secondary': colorToCssHex(colorScheme.secondaryContainer),
    'secondaryForeground': colorToCssHex(colorScheme.onSecondaryContainer),
    'muted': colorToCssHex(colorScheme.surfaceContainerHighest),
    'mutedForeground': colorToCssHex(colorScheme.onSurfaceVariant),
    'accent': colorToCssHex(colorScheme.tertiaryContainer),
    'accentForeground': colorToCssHex(colorScheme.onTertiaryContainer),
    'destructive': colorToCssHex(colorScheme.error),
    'border': colorToCssHex(colorScheme.outlineVariant),
    'input': colorToCssHex(colorScheme.outlineVariant),
    'ring': colorToCssHex(colorScheme.primary),
    'chart1': colorToCssHex(colorScheme.primary),
    'chart2': colorToCssHex(colorScheme.tertiary),
    'chart3': colorToCssHex(colorScheme.secondary),
    'chart4': colorToCssHex(colorScheme.error),
    'chart5': colorToCssHex(colorScheme.primaryContainer),
  };
}
