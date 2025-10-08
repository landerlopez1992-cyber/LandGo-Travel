import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/stripe_service.dart';
import '/components/back_button_widget.dart';
import 'add_card_page_model.dart';
export 'add_card_page_model.dart';

/// **ADD CARD PAGE - LANDGO TRAVEL**
/// 
/// Pantalla dedicada SOLO para agregar nuevas tarjetas usando Stripe CardField SDK.
/// Esta página es diferente a PaymentCardsPage (que es para seleccionar y pagar).
/// 
/// **FUNCIONALIDADES:**
/// - Formulario seguro con CardField de Stripe SDK
/// - Validación automática de tarjetas
/// - Creación de Customer ID si no existe
/// - Guardado de tarjeta en Stripe
/// - Diseño moderno con gradientes LandGo Travel

class AddCardPageWidget extends StatefulWidget {
  const AddCardPageWidget({super.key});

  static String routeName = 'AddCardPage';
  static String routePath = '/addCardPage';

  @override
  State<AddCardPageWidget> createState() => _AddCardPageWidgetState();
}

class _AddCardPageWidgetState extends State<AddCardPageWidget> {
  late AddCardPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _cardFieldKey = GlobalKey();
  bool _isLoading = false;
  bool _cardComplete = false;
  String? _cardholderNameError;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddCardPageModel());
    _model.cardholderNameController ??= TextEditingController();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ============================================================================
  // VALIDACIÓN DE CAMPOS
  // ============================================================================

  void _validateCardholderName() {
    final name = _model.cardholderNameController?.text.trim() ?? '';
    setState(() {
      if (name.isEmpty) {
        _cardholderNameError = 'Cardholder name is required';
      } else if (name.length < 2) {
        _cardholderNameError = 'Name must be at least 2 characters';
      } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
        _cardholderNameError = 'Name can only contain letters and spaces';
      } else {
        _cardholderNameError = null;
      }
    });
  }

  // ============================================================================
  // AGREGAR TARJETA A STRIPE
  // ============================================================================
  Future<void> _addCard() async {
    // Validar campos antes de proceder
    _validateCardholderName();
    
    if (!_cardComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete your card information'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    final cardholderName = _model.cardholderNameController?.text.trim() ?? '';
    if (cardholderName.isEmpty || _cardholderNameError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_cardholderNameError ?? 'Please enter cardholder name'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔍 ========================================');
      print('🔍 ADD CARD PAGE - ADDING NEW CARD');
      print('🔍 ========================================');

      final currentUser = SupaFlow.client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      print('🔍 User ID: ${currentUser.id}');
      print('🔍 Cardholder Name: $cardholderName');

      // VALIDAR QUE CARDFIELD ESTÉ COMPLETO
      if (!_cardComplete) {
        throw Exception('Please complete all card details before saving.');
      }
      
      if (_cardFieldKey.currentState == null) {
        throw Exception('Card field not ready. Please try again.');
      }
      
      print('🔍 CardField state: ${_cardFieldKey.currentState}');
      print('🔍 Card complete: $_cardComplete');

      // 1. CREAR PAYMENTMETHOD USANDO CARDFIELD (SDK STRIPE)
      print('🔍 Creating PaymentMethod with CardField...');
      final paymentMethodData = await StripeService.createPaymentMethodFromCardField(
        cardholderName: cardholderName,
      );

      final paymentMethodId = paymentMethodData['id'];
      print('✅ PaymentMethod created: $paymentMethodId');

      // 2. OBTENER O CREAR STRIPE CUSTOMER ID
      print('🔍 Fetching profile to get/create Stripe Customer ID...');
      final profileResponse = await SupaFlow.client
          .from('profiles')
          .select('stripe_customer_id, email, full_name')
          .eq('id', currentUser.id)
          .maybeSingle();

      String? stripeCustomerId = profileResponse?['stripe_customer_id'];

      // Si no tiene Customer ID, crear uno
      if (stripeCustomerId == null || stripeCustomerId.isEmpty) {
        print('⚠️ No Stripe Customer ID found, creating new customer...');
        stripeCustomerId = await StripeService.createCustomer(
          email: currentUser.email ?? '',
          name: profileResponse?['full_name'] ?? 'Usuario',
        );

        print('✅ Stripe Customer created: $stripeCustomerId');

        // Guardar Customer ID en el perfil
        await SupaFlow.client
            .from('profiles')
            .update({'stripe_customer_id': stripeCustomerId})
            .eq('id', currentUser.id);

        print('✅ Stripe Customer ID saved to profile');
      } else {
        print('✅ Stripe Customer ID found: $stripeCustomerId');
      }

      // 3. ADJUNTAR PAYMENTMETHOD AL CUSTOMER
      print('🔍 Attaching PaymentMethod to Customer...');
      await StripeService.attachPaymentMethodToCustomer(
        customerId: stripeCustomerId,
        paymentMethodId: paymentMethodId,
      );

      print('✅ PaymentMethod attached successfully');

      // 4. MOSTRAR ÉXITO Y REGRESAR
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Card added successfully! ✅'),
              ],
            ),
            backgroundColor: const Color(0xFF4DD0E1),
            duration: const Duration(seconds: 2),
          ),
        );

        // Regresar a Payment Methods Page
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.pop();
        }
      }

      print('✅ ========================================');
    } catch (e, stackTrace) {
      print('❌ Error adding card: $e');
      print('❌ Stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding card: ${e.toString()}'),
            backgroundColor: const Color(0xFFDC2626),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFF1A1A1A),
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
          child: Column(
            children: [
              // HEADER
              _buildHeader(),
              
              // FORMULARIO
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Instrucciones
                      _buildInstructions(),
                      const SizedBox(height: 32),
                      
                      // CardField de Stripe (SDK)
                      _buildCardField(),
                      const SizedBox(height: 24),
                      
                      // Cardholder Name
                      _buildCardholderNameField(),
                      const SizedBox(height: 32),
                      
                      // Botones
                      _buildButtons(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // HEADER
  // ============================================================================
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
                    context.goNamed('PaymentMethodsPage');
                  }
                },
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 20),
          // Tarjeta 3D moderna y realista
          Transform.rotate(
            angle: -0.03, // Ligera inclinación para efecto 3D (igual que PaymentMethods)
            child: Container(
              width: 180, // Mismo tamaño que PaymentMethods
              height: 110, // Mismo tamaño que PaymentMethods
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
                  // Patrón de fondo sutil
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.transparent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  // Chip de la tarjeta
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
                  // Logo de tarjeta
                  Positioned(
                    right: 16,
                    top: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'CARD',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
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
                      'YOUR NAME',
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
          const SizedBox(height: 28),
          Text(
            'Add New Card',
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
            'Securely save your payment method',
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

  // ============================================================================
  // INSTRUCCIONES
  // ============================================================================
  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4DD0E1).withOpacity(0.15),
            const Color(0xFF26C6DA).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4DD0E1).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4DD0E1).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4DD0E1), Color(0xFF26C6DA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4DD0E1).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🔐 Secure Payment',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Protected by Stripe • Bank-level encryption',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // CARDFIELD (STRIPE SDK)
  // ============================================================================
  Widget _buildCardField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.credit_card_rounded,
              color: Color(0xFF4DD0E1),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Card Information',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _cardComplete 
                  ? const Color(0xFF4DD0E1)
                  : Colors.white.withOpacity(0.15),
              width: _cardComplete ? 2.5 : 1.5,
            ),
            boxShadow: _cardComplete ? [
              BoxShadow(
                color: const Color(0xFF4DD0E1).withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ] : [],
          ),
          child: CardField(
            key: _cardFieldKey,
            onCardChanged: (card) {
              setState(() {
                _cardComplete = card?.complete ?? false;
              });
              print('🔍 Card complete: $_cardComplete');
            },
            dangerouslyGetFullCardDetails: false,
          ),
        ),
        if (_cardComplete)
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4DD0E1).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF4DD0E1),
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '✓ Card validated successfully',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF4DD0E1),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ============================================================================
  // CARDHOLDER NAME
  // ============================================================================
  Widget _buildCardholderNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.person_rounded,
              color: Color(0xFF4DD0E1),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Cardholder Name',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _cardholderNameError != null 
                  ? const Color(0xFFDC2626).withOpacity(0.8)
                  : Colors.white.withOpacity(0.15),
              width: _cardholderNameError != null ? 2.0 : 1.5,
            ),
          ),
          child: TextField(
            controller: _model.cardholderNameController,
            onChanged: (value) {
              // Validar en tiempo real
              _validateCardholderName();
            },
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
            decoration: InputDecoration(
              hintText: 'John Doe',
              hintStyle: GoogleFonts.outfit(
                color: Colors.white38,
                fontSize: 16,
                letterSpacing: 0.3,
              ),
              prefixIcon: Container(
                padding: const EdgeInsets.all(12),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4DD0E1).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: Color(0xFF4DD0E1),
                    size: 20,
                  ),
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
            ),
            textCapitalization: TextCapitalization.words,
          ),
        ),
        // Mensaje de error debajo del campo
        if (_cardholderNameError != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFDC2626).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFDC2626),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _cardholderNameError!,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFDC2626),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ============================================================================
  // BOTONES
  // ============================================================================
  Widget _buildButtons() {
    final bool isButtonEnabled = !_isLoading && _cardComplete;
    
    return Column(
      children: [
        // Botón Save Card
        Container(
          width: double.infinity,
          height: 68,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isButtonEnabled
                  ? [const Color(0xFF4DD0E1), const Color(0xFF26C6DA)]
                  : [const Color(0xFF424242), const Color(0xFF303030)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: isButtonEnabled
                ? [
                    BoxShadow(
                      color: const Color(0xFF4DD0E1).withOpacity(0.5),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                      spreadRadius: -3,
                    ),
                  ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: isButtonEnabled ? _addCard : null,
              child: Center(
                child: _isLoading
                    ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3.5,
                        ),
                      )
                    : Row(
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
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'Save Card Securely',
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
        const SizedBox(height: 14),
        
        // Botón Cancel
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFDC2626).withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFDC2626).withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _isLoading
                  ? null
                  : () {
                      if (Navigator.of(context).canPop()) {
                        context.pop();
                      } else {
                        context.goNamed('PaymentMethodsPage');
                      }
                    },
              child: Center(
                child: Text(
                  'Cancel',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFDC2626),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

