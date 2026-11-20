import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../api/api_client.dart';

class GamePlayerScreen extends StatefulWidget {
  final String gameUid;
  final String provider;
  final String gameTitle;
  final String? directLaunchUrl;

  const GamePlayerScreen({
    super.key,
    required this.gameUid,
    required this.provider,
    required this.gameTitle,
    this.directLaunchUrl,
  });

  @override
  State<GamePlayerScreen> createState() => _GamePlayerScreenState();
}

class _GamePlayerScreenState extends State<GamePlayerScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasInjectedSession = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final username = prefs.getString('username') ?? '';
      final password = prefs.getString('user_password') ?? '';
      final sessCookie = prefs.getString('sess_cookie') ?? '';

      // Set cookie in WebView CookieManager so PHP session is active immediately
      final cookieManager = WebViewCookieManager();
      if (sessCookie.isNotEmpty) {
        await cookieManager.setCookie(
          WebViewCookie(
            name: 'AURA777_SESS',
            value: sessCookie,
            domain: '.aura777.info',
            path: '/',
          ),
        );
      }

      final targetGameUrl = "https://aura777.info/play_game.php?game_id=${widget.gameUid}&provider=${widget.provider}";

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              if (mounted) setState(() => _isLoading = true);
            },
            onPageFinished: (String url) async {
              if (mounted) setState(() => _isLoading = false);

              // If redirected to login.php, auto-fill and auto-submit credentials seamlessly in the background
              if (url.contains("login.php")) {
                if (!_hasInjectedSession && username.isNotEmpty && password.isNotEmpty) {
                  _hasInjectedSession = true;
                  final script = """
                    (function() {
                      try {
                        var uInput = document.querySelector('input[name="username"]');
                        var pInput = document.querySelector('input[name="password"]');
                        var form = document.querySelector('form');
                        if (uInput && pInput && form) {
                          uInput.value = '${username.replaceAll("'", "\\'")}';
                          pInput.value = '${password.replaceAll("'", "\\'")}';
                          form.submit();
                        }
                      } catch(e) {}
                    })();
                  """;
                  await _controller.runJavaScript(script);
                }
              }
            },
            onWebResourceError: (WebResourceError error) {
              // Ignore non-fatal resource errors
            },
            onNavigationRequest: (NavigationRequest request) {
              // Keep all game sessions, API calls and provider frames strictly inside the app
              return NavigationDecision.navigate;
            },
          ),
        );

      // If user has saved credentials, perform seamless web session handshake first
      if (username.isNotEmpty && password.isNotEmpty && sessCookie.isEmpty) {
        final loginUrl = "https://aura777.info/login.php?redirect=${Uri.encodeComponent('/play_game.php?game_id=${widget.gameUid}&provider=${widget.provider}')}";
        
        final postBody = Uint8List.fromList(
          utf8.encode("username=${Uri.encodeComponent(username)}&password=${Uri.encodeComponent(password)}"),
        );

        await _controller.loadRequest(
          Uri.parse(loginUrl),
          method: LoadRequestMethod.post,
          body: postBody,
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
            "X-Requested-With": "com.aura777.app",
          },
        );
      } else {
        await _controller.loadRequest(
          Uri.parse(targetGameUrl),
          headers: {
            if (token.isNotEmpty) "Authorization": "Bearer $token",
            "X-Requested-With": "com.aura777.app",
          },
        );
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Embedded In-App Game View
            if (_errorMessage == null)
              WebViewWidget(controller: _controller)
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: AppTheme.danger, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                        child: const Text("Go Back"),
                      ),
                    ],
                  ),
                ),
              ),

            // Loading HUD
            if (_isLoading)
              Container(
                color: Colors.black87,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: AppTheme.gold),
                      const SizedBox(height: 14),
                      Text(
                        "Loading ${widget.gameTitle}...",
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

            // Top Floating Controls: Game Title & Close Button
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24, width: 0.8),
                    ),
                    child: Text(
                      widget.gameTitle,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),

                  // Exit Floating Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.danger.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black54, blurRadius: 4),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.close, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            "Exit",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
