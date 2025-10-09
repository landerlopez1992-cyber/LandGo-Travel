import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🆕 KLARNA WEBVIEW PAGE
/// Muestra el checkout de Klarna en un Webview
class KlarnaWebviewPageWidget extends StatefulWidget {
  final String checkoutUrl;
  final String returnUrl;
  final String paymentIntentId;

  const KlarnaWebviewPageWidget({
    super.key,
    required this.checkoutUrl,
    required this.returnUrl,
    required this.paymentIntentId,
  });

  @override
  State<KlarnaWebviewPageWidget> createState() => _KlarnaWebviewPageWidgetState();
}

class _KlarnaWebviewPageWidgetState extends State<KlarnaWebviewPageWidget> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF1A1A1A))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('🔍 DEBUG: Page started loading: $url');
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            print('🔍 DEBUG: Page finished loading: $url');
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            print('🔍 DEBUG: Navigation request: ${request.url}');

            // Detectar redirección de vuelta a la app
            if (request.url.startsWith(widget.returnUrl)) {
              _handleReturnUrl(request.url);
              return NavigationDecision.prevent;
            }

            // Permitir navegación normal
            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ Webview error: ${error.description}');
            print('❌ Error code: ${error.errorCode}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  void _handleReturnUrl(String url) {
    print('🔍 DEBUG: Handling return URL: $url');

    final uri = Uri.parse(url);
    final status = uri.queryParameters['redirect_status'];

    print('🔍 DEBUG: Redirect status: $status');

    // Cerrar Webview y devolver resultado
    if (status == 'succeeded') {
      print('✅ Klarna payment succeeded');
      Navigator.pop(context, {'status': 'success', 'paymentIntentId': widget.paymentIntentId});
    } else if (status == 'failed') {
      print('❌ Klarna payment failed');
      Navigator.pop(context, {'status': 'failed', 'paymentIntentId': widget.paymentIntentId});
    } else {
      print('⏳ Klarna payment status: $status');
      Navigator.pop(context, {'status': status, 'paymentIntentId': widget.paymentIntentId});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF4DD0E1)),
          onPressed: () {
            // Usuario canceló el pago
            print('🔄 User cancelled Klarna payment');
            Navigator.pop(context, {'status': 'cancelled', 'paymentIntentId': widget.paymentIntentId});
          },
        ),
        title: Text(
          'Klarna Checkout',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Webview
          WebViewWidget(controller: _controller),

          // Loading indicator
          if (_isLoading)
            Container(
              color: const Color(0xFF1A1A1A),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo de Klarna (turquesa)
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4DD0E1).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.schedule,
                        size: 40,
                        color: Color(0xFF4DD0E1),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Loading spinner
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DD0E1)),
                    ),
                    const SizedBox(height: 16),
                    // Texto
                    Text(
                      'Loading Klarna...',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

