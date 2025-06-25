import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HelpChatBotPage extends StatefulWidget {
  const HelpChatBotPage({super.key});

  @override
  State<HelpChatBotPage> createState() => _HelpChatBotPageState();
}

class _HelpChatBotPageState extends State<HelpChatBotPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..loadRequest(
        Uri.parse(
          'https://cdn.botpress.cloud/webchat/v3.0/shareable.html?configUrl=https://files.bpcontent.cloud/2025/05/30/23/20250530234252-MFQIJFBH.json',
        ),
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajuda')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
