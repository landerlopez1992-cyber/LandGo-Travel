import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/back_button_widget.dart';
import '/backend/supabase/supabase.dart';
import '/services/stripe_service.dart';
import 'payment_methods_page_model.dart';
export 'payment_methods_page_model.dart';

class PaymentMethodsPageWidget extends StatefulWidget {
  const PaymentMethodsPageWidget({super.key});

  static const String routeName = 'PaymentMethodsPage';
  static const String routePath = '/paymentMethodsPage';

  @override
  State<PaymentMethodsPageWidget> createState() => _PaymentMethodsPageWidgetState();
}

class _PaymentMethodsPageWidgetState extends State<PaymentMethodsPageWidget> {
  late PaymentMethodsPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Variables para datos del usuario
  bool _isLoading = true;
  List<Map<String, dynamic>> _paymentMethods = [];
  String? _stripeCustomerId;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PaymentMethodsPageModel());
    _loadPaymentMethods();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Cargar métodos de pago guardados
  Future<void> _loadPaymentMethods() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final currentUser = SupaFlow.client.auth.currentUser;
      if (currentUser == null) {
        print('❌ No user logged in');
        return;
      }

      print('🔍 ========================================');
      print('🔍 PAYMENT METHODS PAGE - LOADING CARDS');
      print('🔍 ========================================');
      print('🔍 User ID: ${currentUser.id}');
      print('🔍 User Email: ${currentUser.email}');

      // Obtener Stripe Customer ID del perfil
      print('🔍 Fetching profile data from Supabase...');
      final profileResponse = await SupaFlow.client
          .from('profiles')
          .select('stripe_customer_id, email, full_name')
          .eq('id', currentUser.id)
          .maybeSingle();

      print('🔍 Profile Response: $profileResponse');
      print('🔍 stripe_customer_id value: ${profileResponse?['stripe_customer_id']}');
      print('🔍 stripe_customer_id type: ${profileResponse?['stripe_customer_id']?.runtimeType}');

      if (profileResponse != null && profileResponse['stripe_customer_id'] != null) {
        _stripeCustomerId = profileResponse['stripe_customer_id'];
        
        // Verificar si el customer ID no está vacío
        if (_stripeCustomerId!.isEmpty) {
          print('⚠️ Stripe Customer ID exists but is EMPTY');
          setState(() {
            _isLoading = false;
          });
          return;
        }
        
        print('✅ Stripe Customer ID found: $_stripeCustomerId');
        print('🔍 Calling Stripe API to list payment methods...');

        try {
          // Obtener tarjetas guardadas vía Edge Function
          final paymentMethods = await StripeService.listPaymentMethods(
            customerId: _stripeCustomerId!,
          );

          print('✅ Stripe API Response: ${paymentMethods.length} cards found');
          
          if (paymentMethods.isNotEmpty) {
            print('🔍 Card details:');
            for (var i = 0; i < paymentMethods.length; i++) {
              final card = paymentMethods[i];
              print('  Card ${i + 1}:');
              print('    - ID: ${card['id']}');
              print('    - Brand: ${card['card']?['brand']}');
              print('    - Last4: ${card['card']?['last4']}');
            }
          }

          setState(() {
            _paymentMethods = paymentMethods;
            _isLoading = false;
          });

          print('✅ Payment methods loaded successfully');
        } catch (stripeError) {
          print('❌ Stripe API Error: $stripeError');
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        print('⚠️ No Stripe Customer ID found in profile');
        print('⚠️ This user has never added a card before');
        print('⚠️ They need to add their first card from Payment Cards Page');
        setState(() {
          _isLoading = false;
        });
      }
      
      print('🔍 ========================================');
    } catch (e, stackTrace) {
      print('❌ Error loading payment methods: $e');
      print('❌ Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Navegar a agregar nueva tarjeta
  Future<void> _addNewCard() async {
    print('🔍 Add New Card button tapped');
    // Navegar a la nueva página dedicada para agregar tarjetas (AddCardPage)
    await context.pushNamed('AddCardPage');
    
    // Recargar tarjetas cuando regrese
    print('✅ Regresó de AddCardPage, recargando lista...');
    _loadPaymentMethods();
  }

  // Eliminar tarjeta
  Future<void> _deleteCard(String paymentMethodId, String last4) async {
    // Mostrar confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          title: Text(
            'Delete Card?',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to delete card ending in $last4?',
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF4DD0E1),
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        // Mostrar loading
        _showLoadingModal('Deleting card...');

        // Eliminar tarjeta vía Stripe
        await StripeService.detachPaymentMethod(
          paymentMethodId: paymentMethodId,
        );

        // Cerrar loading
        if (mounted) Navigator.of(context).pop();

        // Mostrar éxito
        _showSuccessModal('Card deleted successfully!');

        // Recargar lista
        _loadPaymentMethods();
      } catch (e) {
        // Cerrar loading
        if (mounted) Navigator.of(context).pop();

        // Mostrar error
        _showErrorModal('Error deleting card: ${e.toString()}');
      }
    }
  }

  // Modal de loading
  void _showLoadingModal(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: Color(0xFF4DD0E1),
                ),
                const SizedBox(height: 24),
                Text(
                  message,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF2C2C2C),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Modal de éxito
  void _showSuccessModal(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 30),
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0F7FA),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      color: Color(0xFF4DD0E1),
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Success!',
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4DD0E1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Continue',
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Modal de error
  void _showErrorModal(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 30),
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.close,
                      color: Color(0xFFDC2626),
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Error!',
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Try Again',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFF1A1A1A),
        extendBodyBehindAppBar: false,
        extendBody: false,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1A1A1A),
                const Color(0xFF000000),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            top: true,
            child: Column(
              children: [
                // Header
                _buildHeader(),
                
                // Content
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF4DD0E1),
                            strokeWidth: 3.5,
                          ),
                        )
                      : _paymentMethods.isEmpty
                          ? _buildEmptyState()
                          : _buildCardsList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A1A),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              StandardBackButton(
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    context.pop();
                  } else {
                    context.goNamed('ProfilePage');
                  }
                },
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 20),
          // Icono de tarjeta realista 3D - Diseño premium
          Transform.rotate(
            angle: -0.03, // Ligera inclinación para efecto 3D
            child: Container(
              width: 180,
              height: 110,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4DD0E1),
                    Color(0xFF26C6DA),
                    Color(0xFF00ACC1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4DD0E1).withOpacity(0.6),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                    spreadRadius: -8,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Chip de tarjeta
                  Positioned(
                    left: 16,
                    top: 16,
                    child: Container(
                      width: 24,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          color: Colors.white,
                          width: 0.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'CHIP',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF4DD0E1),
                            fontSize: 6,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Número de tarjeta simulado
                  Positioned(
                    left: 16,
                    bottom: 32,
                    child: Text(
                      '•••• •••• •••• ••••',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ),
                  // Nombre del titular
                  Positioned(
                    left: 16,
                    bottom: 12,
                    child: Text(
                      'CARD HOLDER',
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  // Fecha de expiración
                  Positioned(
                    right: 16,
                    bottom: 12,
                    child: Text(
                      'MM/YY',
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  // Icono de "+" para agregar
                  Positioned(
                    right: 12,
                    top: 40,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Payment Methods',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Manage your saved cards securely',
            style: GoogleFonts.outfit(
              color: Colors.white60,
              fontSize: 15,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono con gradiente y animación
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4DD0E1), Color(0xFF26C6DA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4DD0E1).withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: const Icon(
                Icons.credit_card_outlined,
                color: Colors.white,
                size: 70,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No Cards Added',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add your first payment method to make\nquick and secure payments',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            // Botón Premium - Diseño V2
            Container(
              width: double.infinity,
              height: 68,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4DD0E1), Color(0xFF26C6DA)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4DD0E1).withOpacity(0.5),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                    spreadRadius: -3,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: _addNewCard,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.add_card_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Add Your First Card',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardsList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _paymentMethods.length,
            itemBuilder: (context, index) {
              final card = _paymentMethods[index];
              return _buildCardItem(card);
            },
          ),
        ),
        // Botón Premium - Diseño V2
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            width: double.infinity,
            height: 68,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4DD0E1), Color(0xFF26C6DA)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4DD0E1).withOpacity(0.5),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                  spreadRadius: -3,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: _addNewCard,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.add_card_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Add New Card',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardItem(Map<String, dynamic> card) {
    final brand = (card['card']?['brand'] ?? 'card').toString().toUpperCase();
    final last4 = card['card']?['last4'] ?? '••••';
    final expMonth = card['card']?['exp_month']?.toString().padLeft(2, '0') ?? '00';
    final expYear = card['card']?['exp_year']?.toString().substring(2) ?? '00';
    final paymentMethodId = card['id'] ?? '';
    
    // Obtener el nombre del titular de la tarjeta
    final cardholderName = card['billing_details']?['name'] ?? 'CARD HOLDER';
    final displayName = cardholderName.isNotEmpty ? cardholderName.toUpperCase() : 'CARD HOLDER';

    // Colores y gradientes según marca de tarjeta - DISEÑO PREMIUM V2
    List<Color> cardGradient = [const Color(0xFF2C2C2C), const Color(0xFF1A1A1A)];
    Color brandColor = const Color(0xFF4DD0E1);
    IconData brandIcon = Icons.credit_card_rounded;
    Color accentColor = const Color(0xFF4DD0E1);
    
    if (brand.contains('VISA')) {
      cardGradient = [const Color(0xFF1A1F71), const Color(0xFF0F1449)];
      brandColor = const Color(0xFF1A1F71);
      brandIcon = Icons.credit_card_rounded;
      accentColor = const Color(0xFF4DD0E1);
    } else if (brand.contains('MASTERCARD')) {
      cardGradient = [const Color(0xFFEB001B), const Color(0xFFCC0015)];
      brandColor = const Color(0xFFEB001B);
      brandIcon = Icons.credit_card_rounded;
      accentColor = const Color(0xFFF79E1B);
    } else if (brand.contains('AMEX')) {
      cardGradient = [const Color(0xFF006FCF), const Color(0xFF004A8C)];
      brandColor = const Color(0xFF006FCF);
      brandIcon = Icons.credit_card_rounded;
      accentColor = const Color(0xFF00B4D8);
    } else if (brand.contains('DISCOVER')) {
      cardGradient = [const Color(0xFFFF6000), const Color(0xFFE55100)];
      brandColor = const Color(0xFFFF6000);
      brandIcon = Icons.credit_card_rounded;
      accentColor = const Color(0xFFFFB800);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      height: 200, // Altura ajustada para mejor proporción
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22), // Más redondeado
        boxShadow: [
          BoxShadow(
            color: brandColor.withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 12),
            spreadRadius: -3, // Efecto flotante
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(20), // Padding optimizado para altura reducida
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con icono y botón eliminar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icono de tarjeta con contenedor premium
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.25),
                        Colors.white.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    brandIcon,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                // Botón eliminar premium
                GestureDetector(
                  onTap: () => _deleteCard(paymentMethodId, last4),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.withOpacity(0.3),
                          Colors.red.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Número de tarjeta con estilo premium
            Text(
              '•••• •••• •••• $last4',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 22, // Ajustado para altura reducida
                fontWeight: FontWeight.w800,
                letterSpacing: 2.2, // Ajustado
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10), // Ajustado para altura reducida
            // Nombre del titular de la tarjeta
            Text(
              displayName,
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.9),
                fontSize: 15, // Ligeramente reducido
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2, // Ajustado
                height: 1.1,
              ),
            ),
            const SizedBox(height: 14), // Ajustado para altura reducida
            // Footer con marca y fecha
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Marca con contenedor
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    brand,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                // Fecha de expiración con estilo
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: accentColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '$expMonth/$expYear',
                    style: GoogleFonts.outfit(
                      color: accentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

