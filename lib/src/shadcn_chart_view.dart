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
  final void Function(InAppWebViewController controller, WebUri? url)? onLoadStop;

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
      _htmlFuture = kIsWeb ? Future<String>.value('') : _loadChartHtml();
    } else if (oldWidget.data != widget.data) {
      _controller.updateData(widget.data);
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
        await _controller.updateData(widget.data);
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
}
