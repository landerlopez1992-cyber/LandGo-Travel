import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🆕 PAYMENT WEBVIEW PAGE
/// Webview genérico para métodos de pago (Klarna, Afterpay, etc.)
class PaymentWebviewPageWidget extends StatefulWidget {
  final String checkoutUrl;
  final String returnUrl;
  final String paymentIntentId;
  final String paymentMethodName; // 'Klarna', 'Afterpay', etc.

  const PaymentWebviewPageWidget({
    super.key,
    required this.checkoutUrl,
    required this.returnUrl,
    required this.paymentIntentId,
    required this.paymentMethodName,
  });

  static const String routeName = 'PaymentWebviewPage';
  static const String routePath = '/paymentWebviewPage';

  @override
  State<PaymentWebviewPageWidget> createState() => _PaymentWebviewPageWidgetState();
}

class _PaymentWebviewPageWidgetState extends State<PaymentWebviewPageWidget> {
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
      ..setBackgroundColor(Colors.white) // Cambiar a blanco para métodos de pago
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
      print('✅ ${widget.paymentMethodName} payment succeeded');
      Navigator.pop(context, {'status': 'success', 'paymentIntentId': widget.paymentIntentId});
    } else if (status == 'failed') {
      print('❌ ${widget.paymentMethodName} payment failed');
      Navigator.pop(context, {'status': 'failed', 'paymentIntentId': widget.paymentIntentId});
    } else {
      print('⏳ ${widget.paymentMethodName} payment status: $status');
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
            print('🔄 User cancelled ${widget.paymentMethodName} payment');
            Navigator.pop(context, {'status': 'cancelled', 'paymentIntentId': widget.paymentIntentId});
          },
        ),
        title: Text(
          '${widget.paymentMethodName} Checkout',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Webview con ajuste responsivo
            Container(
              width: double.infinity,
              height: double.infinity,
              child: WebViewWidget(controller: _controller),
            ),

            // Loading indicator
            if (_isLoading)
              Container(
                color: const Color(0xFF1A1A1A),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo del método de pago (turquesa)
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
                        'Loading ${widget.paymentMethodName}...',
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
      ),
    );
  }
}
