import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'shadcn_chart_controller.dart';
import 'shadcn_chart_models.dart';

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

  /// Builder shown while the bundled HTML asset is loading on native platforms.
  final WidgetBuilder? loadingBuilder;

  @override
  State<ShadcnChartView> createState() => _ShadcnChartViewState();
}

class _ShadcnChartViewState extends State<ShadcnChartView> {
  late final ShadcnChartController _controller;
  late Future<String> _htmlFuture;
  bool _hasLoaded = false;
  String? _lastHostThemeJson;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ShadcnChartController();
    _htmlFuture = kIsWeb ? Future<String>.value('') : _loadChartHtml();
  }

  @override
  void didUpdateWidget(covariant ShadcnChartView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.type != widget.data.type) {
      _hasLoaded = false;
      _htmlFuture = kIsWeb ? Future<String>.value('') : _loadChartHtml();
    } else if (oldWidget.data != widget.data) {
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
      child: kIsWeb
          ? _buildWebView()
          : FutureBuilder<String>(
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

  Widget _buildWebView({String? html}) {
    return InAppWebView(
      key: ValueKey<String>(widget.data.type.packageAssetKey),
      initialData: kIsWeb
          ? null
          : InAppWebViewInitialData(
              data: html!,
              baseUrl: WebUri('https://localhost/'),
              mimeType: 'text/html',
              encoding: 'utf8',
            ),
      initialUrlRequest: kIsWeb
          ? URLRequest(
              url: WebUri.uri(
                Uri.base.resolve('assets/${widget.data.type.packageAssetKey}'),
              ),
            )
          : null,
      initialSettings: widget.settings ?? _defaultSettings(),
      onWebViewCreated: (controller) {
        _controller.attach(controller);
        widget.onWebViewCreated?.call(controller);
      },
      onLoadStop: (controller, url) async {
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

  Future<void> _applyInitialChartData() async {
    await _controller.updateData(widget.data);
    if (!kIsWeb) {
      return;
    }

    // Web iframes can finish navigation before the chart bundle installs
    // window.updateChartData; retry so the first Dart payload is not lost.
    for (final delayMs in const [50, 150, 400]) {
      await Future<void>.delayed(Duration(milliseconds: delayMs));
      if (!mounted) {
        return;
      }
      await _controller.updateData(widget.data);
    }
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
    'background': _colorToCssHex(colorScheme.surface),
    'foreground': _colorToCssHex(textColor),
    'card': _colorToCssHex(cardColor),
    'cardForeground': _colorToCssHex(colorScheme.onSurface),
    'popover': _colorToCssHex(colorScheme.surfaceContainerHighest),
    'popoverForeground': _colorToCssHex(colorScheme.onSurface),
    'primary': _colorToCssHex(colorScheme.primary),
    'primaryForeground': _colorToCssHex(colorScheme.onPrimary),
    'secondary': _colorToCssHex(colorScheme.secondaryContainer),
    'secondaryForeground': _colorToCssHex(colorScheme.onSecondaryContainer),
    'muted': _colorToCssHex(colorScheme.surfaceContainerHighest),
    'mutedForeground': _colorToCssHex(colorScheme.onSurfaceVariant),
    'accent': _colorToCssHex(colorScheme.tertiaryContainer),
    'accentForeground': _colorToCssHex(colorScheme.onTertiaryContainer),
    'destructive': _colorToCssHex(colorScheme.error),
    'border': _colorToCssHex(colorScheme.outlineVariant),
    'input': _colorToCssHex(colorScheme.outlineVariant),
    'ring': _colorToCssHex(colorScheme.primary),
    'chart1': _colorToCssHex(colorScheme.primary),
    'chart2': _colorToCssHex(colorScheme.tertiary),
    'chart3': _colorToCssHex(colorScheme.secondary),
    'chart4': _colorToCssHex(colorScheme.error),
    'chart5': _colorToCssHex(colorScheme.primaryContainer),
  };
}

String _colorToCssHex(Color color) {
  // ignore: deprecated_member_use
  final value = color.value;
  final alpha = (value >> 24) & 0xff;
  final red = (value >> 16) & 0xff;
  final green = (value >> 8) & 0xff;
  final blue = value & 0xff;
  final channels =
      alpha == 0xff ? [red, green, blue] : [red, green, blue, alpha];
  return '#${channels.map((channel) => channel.toRadixString(16).padLeft(2, '0')).join()}';
}
