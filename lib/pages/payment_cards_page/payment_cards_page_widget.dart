import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'dart:convert';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/back_button_widget.dart';
import '/payment/payment_success_pag/payment_success_pag_widget.dart';
import '/pages/payment_failed_pag/payment_failed_pag_widget.dart';
import '/backend/supabase/supabase.dart';
import '/services/stripe_service.dart';
import 'payment_cards_page_model.dart';
export 'payment_cards_page_model.dart';

class PaymentCardsPageWidget extends StatefulWidget {
  const PaymentCardsPageWidget({super.key});

  static const String routeName = 'PaymentCardsPage';
  static const String routePath = '/paymentCardsPage';

  @override
  State<PaymentCardsPageWidget> createState() => _PaymentCardsPageWidgetState();
}

class _PaymentCardsPageWidgetState extends State<PaymentCardsPageWidget> {
  late PaymentCardsPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Variables para recibir parámetros
  String _amount = '0.00';
  String _selectedPaymentMethod = 'stripe';
  
  // Variables para tarjetas
  List<Map<String, dynamic>> _savedCards = [];
  bool _isLoadingCards = true;
  bool _isAddingCard = false; // Para mostrar/ocultar formulario
  bool _isSavingCard = false; // Para loading del botón
  Map<String, dynamic>? _selectedCard;
  
  // Variables para validación de tarjeta
  String _detectedCardBrand = '';
  int _maxCardLength = 19; // Default para Visa/Mastercard

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PaymentCardsPageModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
    
    print('🔍 DEBUG: PaymentCards initState');
    _loadSavedCards();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadParameters();
  }

  @override
  void didUpdateWidget(covariant PaymentCardsPageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recargar cuando el widget se actualiza (ej: cuando regresas de AddCardPage)
    print('🔍 DEBUG: Widget updated - reloading payment methods');
    _loadSavedCards();
  }

  void _loadParameters() {
    // Intentar obtener datos del extra
    final route = ModalRoute.of(context);
    print('🔍 DEBUG: Route settings: ${route?.settings}');
    
    final extraData = route?.settings.arguments as Map<String, dynamic>?;
    print('🔍 DEBUG: Extra data: $extraData');
    
    if (extraData != null) {
      if (extraData.containsKey('amount')) {
        _amount = extraData['amount'] ?? '0.00';
        print('🔍 DEBUG: Loaded amount from extra: $_amount');
      }
      if (extraData.containsKey('paymentMethod')) {
        _selectedPaymentMethod = extraData['paymentMethod'] ?? 'stripe';
        print('🔍 DEBUG: Loaded payment method from extra: $_selectedPaymentMethod');
      }
    }
    
    print('🔍 DEBUG: Final amount: $_amount, payment method: $_selectedPaymentMethod');
    
    // Forzar rebuild para mostrar los datos actualizados
    if (mounted) {
      setState(() {});
    }
  }

  void _loadSavedCards() async {
    setState(() {
      _isLoadingCards = true;
    });
    
    try {
      print('🔍 ========================================');
      print('🔍 PAYMENT CARDS PAGE - LOADING SAVED CARDS');
      print('🔍 ========================================');
      
      // Obtener usuario actual
      final currentUser = SupaFlow.client.auth.currentUser;
      if (currentUser == null) {
        print('❌ No user logged in');
        setState(() {
          _isLoadingCards = false;
        });
        return;
      }

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

      if (profileResponse == null) {
        print('⚠️ No profile found');
        setState(() {
          _savedCards = [];
          _isLoadingCards = false;
        });
        return;
      }

      final stripeCustomerId = profileResponse['stripe_customer_id'];
      if (stripeCustomerId == null || stripeCustomerId.isEmpty) {
        print('⚠️ No Stripe Customer ID found in profile');
        setState(() {
          _savedCards = [];
          _isLoadingCards = false;
        });
        return;
      }

      print('✅ Stripe Customer ID: $stripeCustomerId');

      // Obtener tarjetas desde Stripe (NO desde Supabase)
      print('🔍 Fetching payment methods from Stripe...');
      final paymentMethods = await StripeService.listPaymentMethods(
        customerId: stripeCustomerId,
      );

      print('✅ Payment methods loaded: ${paymentMethods.length} cards');
      print('🔍 Payment methods data: $paymentMethods');
      
      if (mounted) {
        setState(() {
          _savedCards = paymentMethods;
          _isLoadingCards = false;
        });
      }

      print('✅ ========================================');
    } catch (e, stackTrace) {
      print('❌ Error loading saved cards: $e');
      print('❌ Stack trace: $stackTrace');
      
      if (mounted) {
        setState(() {
          _savedCards = [];
          _isLoadingCards = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFF1A1A1A), // FONDO NEGRO LANDGO
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con botón de regreso - ESTANDARIZADO
                  Row(
                    children: [
                      StandardBackButton(
                        onPressed: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            context.goNamedAuth('MainPage', context.mounted);
                          }
                        },
                      ),
                      const Spacer(),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Título "Payment Cards" centrado
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Payment Cards',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Amount: \$${_amount}',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF4DD0E1),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Method: ${_selectedPaymentMethod == 'stripe' ? 'Stripe' : 'Apple Pay'}',
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Saved Cards Section
                  _buildSavedCardsSection(),
                  
                  const SizedBox(height: 20),
                  
                  // Add New Card Button - Siempre visible
                  if (!_isAddingCard)
                    _buildAddNewCardButton(),
                  
                  const SizedBox(height: 20),
                  
                  // Add New Card Form - Mostrar cuando se presiona el botón
                  if (_isAddingCard)
                    _buildAddNewCardSection(),
                  
                  const SizedBox(height: 40),
                  
                  // Continue Payment Button
                  _buildContinuePaymentButton(),
                  
                  const SizedBox(height: 100), // ESPACIO PARA BOTTOM NAV
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSavedCardsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C), // GRIS OSCURO LANDGO
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saved Cards',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          if (_isLoadingCards)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DD0E1)),
              ),
            )
          else if (_savedCards.isEmpty)
            _buildNoCardsMessage()
          else
            _buildCardsList(),
        ],
      ),
    );
  }

  Widget _buildNoCardsMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF37474F).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4DD0E1).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.credit_card_off,
            color: const Color(0xFF4DD0E1),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'No saved cards',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a new card below to save it for future payments',
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCardsList() {
    return Column(
      children: _savedCards.map((card) => _buildCardItem(card)).toList(),
    );
  }

  Widget _buildCardItem(Map<String, dynamic> card) {
    // Estructura de Stripe: card['card']['brand'], card['card']['last4'], etc.
    final cardData = card['card'] as Map<String, dynamic>? ?? {};
    final brand = (cardData['brand'] ?? 'card').toString().toUpperCase();
    final last4 = (cardData['last4'] ?? '****').toString();
    final expMonth = (cardData['exp_month']?.toString() ?? '00').padLeft(2, '0');
    final expYear = (cardData['exp_year']?.toString().substring(2) ?? '00');
    final isSelected = _selectedCard?['id'] == card['id'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C), // GRIS OSCURO LANDGO
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
            ? const Color(0xFF4DD0E1) // TURQUESA cuando está seleccionada
            : Colors.white.withOpacity(0.1),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Radio Button para selección
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: () => _selectCard(card),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF4DD0E1) : Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                  color: isSelected ? const Color(0xFF4DD0E1) : Colors.transparent,
                ),
                child: isSelected 
                  ? const Icon(
                      Icons.check,
                      color: Colors.black,
                      size: 16,
                    )
                  : null,
              ),
            ),
          ),
          
          // Card Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  // Card Brand Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getCardBrandColor(brand),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _getCardBrandIcon(brand),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Card Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${_getCardBrandName(brand)} •••• $last4',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Expires $expMonth/$expYear',
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Delete Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: () => _deleteCard(card),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFDC2626),
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddNewCardSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C), // GRIS OSCURO LANDGO
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add New Card',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // CardField seguro (Stripe SDK)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF37474F),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const CardField(
              dangerouslyGetFullCardDetails: false,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Cardholder Name Field
          _buildTextField(
            controller: _model.cardholderNameController ?? TextEditingController(),
            label: 'Cardholder Name',
            hint: 'John Doe',
            keyboardType: TextInputType.text,
          ),
          
          const SizedBox(height: 20),
          
          // Buttons Row
          Row(
            children: [
              // Cancel Button
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFDC2626),
                      width: 2,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        setState(() {
                          _isAddingCard = false;
                          // Limpiar campos
                          _model.cardNumberController?.clear();
                          _model.expiryController?.clear();
                          _model.cvvController?.clear();
                          _model.cardholderNameController?.clear();
                          _detectedCardBrand = '';
                        });
                      },
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFDC2626),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Add Card Button
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4DD0E1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _isSavingCard ? null : _addNewCard,
                      child: Center(
                        child: _isSavingCard
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text(
                              'Add Card',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardNumberField() {
    // Ya no se usa el TextField manual; ahora el CardField maneja la captura
    return const SizedBox.shrink();
  }

  Widget _buildExpiryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expiry Date',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _model.expiryController ?? TextEditingController(),
          keyboardType: TextInputType.number,
          maxLength: 5,
          inputFormatters: [
            _ExpiryDateInputFormatter(),
          ],
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'MM/YY',
            hintStyle: GoogleFonts.outfit(
              color: Colors.white54,
              fontSize: 16,
            ),
            filled: true,
            fillColor: const Color(0xFF37474F),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF4DD0E1),
                width: 2,
              ),
            ),
            counterText: '',
          ),
        ),
      ],
    );
  }

  Widget _buildCVVField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CVV',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _model.cvvController ?? TextEditingController(),
          keyboardType: TextInputType.number,
          maxLength: _detectedCardBrand == 'amex' ? 4 : 3,
          onChanged: (value) {
            final formatted = _formatCVV(value);
            if (formatted != value) {
              _model.cvvController?.text = formatted;
              _model.cvvController?.selection = TextSelection.fromPosition(
                TextPosition(offset: formatted.length),
              );
            }
          },
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: _detectedCardBrand == 'amex' ? '1234' : '123',
            hintStyle: GoogleFonts.outfit(
              color: Colors.white54,
              fontSize: 16,
            ),
            filled: true,
            fillColor: const Color(0xFF37474F),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF4DD0E1),
                width: 2,
              ),
            ),
            counterText: '',
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextInputType keyboardType,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(
              color: Colors.white54,
              fontSize: 16,
            ),
            filled: true,
            fillColor: const Color(0xFF37474F),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF4DD0E1),
                width: 2,
              ),
            ),
            counterText: '',
          ),
        ),
      ],
    );
  }

  Widget _buildContinuePaymentButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: _selectedCard != null 
          ? const Color(0xFF4DD0E1) // TURQUESA LANDGO cuando hay tarjeta seleccionada
          : Colors.grey, // Gris cuando no hay tarjeta seleccionada
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _selectedCard != null ? _processPayment : null,
          child: Center(
            child: Text(
              _selectedCard != null ? 'Confirm Payment' : 'Select a Card First',
              style: GoogleFonts.outfit(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper Methods
  String _getCardBrandIcon(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return 'V';
      case 'mastercard':
        return 'M';
      case 'amex':
        return 'A';
      case 'discover':
        return 'D';
      case 'diners':
        return 'D';
      case 'jcb':
        return 'J';
      default:
        return 'C';
    }
  }

  String _getCardBrandName(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'Mastercard';
      case 'amex':
        return 'American Express';
      case 'discover':
        return 'Discover';
      case 'diners':
        return 'Diners Club';
      case 'jcb':
        return 'JCB';
      default:
        return 'Card';
    }
  }

  Color _getCardBrandColor(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return const Color(0xFF1A1F71);
      case 'mastercard':
        return const Color(0xFFEB001B);
      case 'amex':
        return const Color(0xFF006FCF);
      case 'discover':
        return const Color(0xFFFF6000);
      case 'diners':
        return const Color(0xFF0079BE);
      case 'jcb':
        return const Color(0xFFD70027);
      default:
        return const Color(0xFF4DD0E1);
    }
  }

  // Métodos para validación y formateo de tarjeta
  String _detectCardBrand(String cardNumber) {
    // Remover espacios y caracteres no numéricos
    final cleanNumber = cardNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanNumber.isEmpty) {
      _maxCardLength = 19;
      return '';
    }
    
    // Visa: empieza con 4
    if (cleanNumber.startsWith('4')) {
      _maxCardLength = 19; // 16 dígitos + 3 guiones
      return 'visa';
    }
    
    // Mastercard: empieza con 5 o 2
    if (cleanNumber.startsWith('5') || 
        (cleanNumber.startsWith('2') && cleanNumber.length >= 2 && 
         int.parse(cleanNumber.substring(1, 2)) >= 2 && 
         int.parse(cleanNumber.substring(1, 2)) <= 7)) {
      _maxCardLength = 19; // 16 dígitos + 3 guiones
      return 'mastercard';
    }
    
    // American Express: empieza con 34 o 37
    if (cleanNumber.startsWith('34') || cleanNumber.startsWith('37')) {
      _maxCardLength = 17; // 15 dígitos + 2 guiones
      return 'amex';
    }
    
    // Discover: empieza con 6011, 65, o 644-649
    if (cleanNumber.startsWith('6011') || 
        cleanNumber.startsWith('65') ||
        (cleanNumber.length >= 3 && 
         int.parse(cleanNumber.substring(0, 3)) >= 644 && 
         int.parse(cleanNumber.substring(0, 3)) <= 649)) {
      _maxCardLength = 19; // 16 dígitos + 3 guiones
      return 'discover';
    }
    
    // Diners Club: empieza con 30, 36, o 38
    if (cleanNumber.startsWith('30') || 
        cleanNumber.startsWith('36') || 
        cleanNumber.startsWith('38')) {
      _maxCardLength = 17; // 14 dígitos + 2 guiones
      return 'diners';
    }
    
    // JCB: empieza con 35
    if (cleanNumber.startsWith('35')) {
      _maxCardLength = 19; // 16 dígitos + 3 guiones
      return 'jcb';
    }
    
    // Por defecto
    _maxCardLength = 19;
    return '';
  }

  String _formatCardNumber(String input) {
    // Remover todos los caracteres no numéricos
    final cleanNumber = input.replaceAll(RegExp(r'[^\d]'), '');
    
    // Detectar marca de tarjeta
    final brand = _detectCardBrand(cleanNumber);
    if (brand != _detectedCardBrand) {
      setState(() {
        _detectedCardBrand = brand;
      });
    }
    
    // Limitar longitud según la marca
    final maxDigits = _maxCardLength == 17 ? 15 : 16;
    final limitedNumber = cleanNumber.length > maxDigits 
        ? cleanNumber.substring(0, maxDigits) 
        : cleanNumber;
    
    // Formatear con guiones (-) de 4 en 4 según la marca
    if (brand == 'amex') {
      // American Express: XXXX-XXXXXX-XXXXX
      if (limitedNumber.length <= 4) {
        return limitedNumber;
      } else if (limitedNumber.length <= 10) {
        return '${limitedNumber.substring(0, 4)}-${limitedNumber.substring(4)}';
      } else {
        return '${limitedNumber.substring(0, 4)}-${limitedNumber.substring(4, 10)}-${limitedNumber.substring(10)}';
      }
    } else if (brand == 'diners') {
      // Diners Club: XXXX-XXXXXX-XXXX
      if (limitedNumber.length <= 4) {
        return limitedNumber;
      } else if (limitedNumber.length <= 10) {
        return '${limitedNumber.substring(0, 4)}-${limitedNumber.substring(4)}';
      } else {
        return '${limitedNumber.substring(0, 4)}-${limitedNumber.substring(4, 10)}-${limitedNumber.substring(10)}';
      }
    } else {
      // Visa, Mastercard, Discover, JCB: XXXX-XXXX-XXXX-XXXX (máximo 4 grupos de 4)
      if (limitedNumber.length <= 4) {
        return limitedNumber;
      } else if (limitedNumber.length <= 8) {
        return '${limitedNumber.substring(0, 4)}-${limitedNumber.substring(4)}';
      } else if (limitedNumber.length <= 12) {
        return '${limitedNumber.substring(0, 4)}-${limitedNumber.substring(4, 8)}-${limitedNumber.substring(8)}';
      } else {
        return '${limitedNumber.substring(0, 4)}-${limitedNumber.substring(4, 8)}-${limitedNumber.substring(8, 12)}-${limitedNumber.substring(12)}';
      }
    }
  }


  String _formatCVV(String input) {
    // Remover caracteres no numéricos
    final cleanInput = input.replaceAll(RegExp(r'[^\d]'), '');
    
    // Limitar longitud según la marca de tarjeta
    final maxLength = _detectedCardBrand == 'amex' ? 4 : 3;
    return cleanInput.length > maxLength ? cleanInput.substring(0, maxLength) : cleanInput;
  }

  void _selectCard(Map<String, dynamic> card) {
    print('🔍 DEBUG: Selected card: ${card['id']}');
    setState(() {
      _selectedCard = card;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Card selected: ****${card['last4']}',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteCard(Map<String, dynamic> card) async {
    // Mostrar diálogo de confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text(
          'Delete Card',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this card ending in ${card['last4']}?',
          style: GoogleFonts.outfit(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: GoogleFonts.outfit(
                color: const Color(0xFFDC2626),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Eliminar tarjeta del array en Supabase
      final updatedCards = List<Map<String, dynamic>>.from(_savedCards);
      updatedCards.removeWhere((c) => c['id'] == card['id']);

      await Supabase.instance.client
          .from('profiles')
          .update({
            'saved_cards': updatedCards.map((c) => jsonEncode(c)).toList(),
          })
          .eq('id', user.id);

      setState(() {
        _savedCards = updatedCards;
        if (_selectedCard?['id'] == card['id']) {
          _selectedCard = null;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Card deleted successfully',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Error deleting card: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error deleting card. Please try again.',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildAddNewCardButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isAddingCard = true;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF4DD0E1).withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF4DD0E1),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_card,
              color: Color(0xFF4DD0E1),
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Add New Card',
              style: GoogleFonts.outfit(
                color: const Color(0xFF4DD0E1),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addNewCard() async {
    final cardholderName = _model.cardholderNameController?.text.trim() ?? '';
    
    print('🔍 DEBUG: Cardholder Name: "$cardholderName"');
    
    if (cardholderName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter cardholder name',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSavingCard = true;
    });

    try {
      // Obtener usuario actual
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // 1. ✅ CREAR PAYMENTMETHOD USANDO EL CardField DEL SDK (SEGURO)
      print('🔍 DEBUG: Creando PaymentMethod con CardField...');
      final paymentMethodData = await StripeService.createPaymentMethodFromCardField(
        cardholderName: cardholderName,
      );
      
      final paymentMethodId = paymentMethodData['id'] as String;
      print('✅ PaymentMethod creado: $paymentMethodId');
      
      // ✅ LA TARJETA YA ESTÁ VALIDADA POR STRIPE AL CREAR EL PAYMENTMETHOD
      print('✅ Tarjeta validada automáticamente por Stripe al crear PaymentMethod');

      // 2. Crear Customer en Stripe si no existe
      String? stripeCustomerId;
      try {
        // Obtener el email del usuario de Supabase
        final profileResponse = await Supabase.instance.client
            .from('profiles')
            .select('stripe_customer_id, email')
            .eq('id', user.id)
            .single();
        
        stripeCustomerId = profileResponse['stripe_customer_id'];
        
        // Si no tiene customer ID, crear uno nuevo
        if (stripeCustomerId == null || stripeCustomerId.isEmpty) {
          print('🔍 DEBUG: Creando Customer en Stripe...');
          stripeCustomerId = await StripeService.createCustomer(
            email: profileResponse['email'] ?? user.email ?? 'user@landgotravel.com',
            name: cardholderName,
          );
          
          // Guardar el customer ID en Supabase
          await Supabase.instance.client
              .from('profiles')
              .update({'stripe_customer_id': stripeCustomerId})
              .eq('id', user.id);
          
          print('🔍 DEBUG: Customer creado: $stripeCustomerId');
        }
      } catch (e) {
        print('🔍 DEBUG: Error obteniendo/creando customer: $e');
        // Crear customer sin datos del perfil
        stripeCustomerId = await StripeService.createCustomer(
          email: user.email ?? 'user@landgotravel.com',
          name: cardholderName,
        );
      }

      // 3. ✅ Asociar PaymentMethod al Customer (via Edge Function)
      print('🔍 DEBUG: Asociando PaymentMethod al Customer...');
      await StripeService.attachPaymentMethodToCustomer(
        customerId: stripeCustomerId!,
        paymentMethodId: paymentMethodId,
      );

      // 4. ✅ Crear objeto de tarjeta con datos reales del PaymentMethod
      final cardData = paymentMethodData['card'] as Map<String, dynamic>?;
      final last4 = (cardData?['last4'] as String?) ?? 'XXXX';
      final brand = (cardData?['brand'] as String?) ?? 'unknown';
      final expMonth = (cardData?['exp_month'])?.toString().padLeft(2, '0') ?? 'XX';
      final expYear = (cardData?['exp_year'])?.toString() ?? 'XX';
      final newCard = {
        'id': 'card_${DateTime.now().millisecondsSinceEpoch}',
        'stripe_payment_method_id': paymentMethodId, // ID REAL de Stripe
        'stripe_customer_id': stripeCustomerId,
        'last4': last4,
        'brand': brand,
        'exp_month': expMonth,
        'exp_year': expYear,
        'cardholder_name': cardholderName,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      print('🔍 DEBUG: Tarjeta creada con PaymentMethod real: ${newCard['stripe_payment_method_id']}');

      // Obtener tarjetas existentes
      final response = await Supabase.instance.client
          .from('profiles')
          .select('saved_cards')
          .eq('id', user.id)
          .single();

      final existingCards = response['saved_cards'] as List<dynamic>? ?? [];
      
      // Agregar nueva tarjeta
      final updatedCards = [...existingCards, newCard];
      
      // Actualizar en Supabase
      await Supabase.instance.client
          .from('profiles')
          .update({'saved_cards': updatedCards})
          .eq('id', user.id);

      if (mounted) {
        setState(() {
          _isSavingCard = false;
          _isAddingCard = false; // Cerrar el formulario
          _savedCards.add(newCard);
          
          // Limpiar campos
          _model.cardNumberController?.clear();
          _model.expiryController?.clear();
          _model.cvvController?.clear();
          _model.cardholderNameController?.clear();
          _detectedCardBrand = '';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Card added successfully',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('🔍 DEBUG: Error adding card: $e');
      print('🔍 DEBUG: Error type: ${e.runtimeType}');
      print('🔍 DEBUG: Error details: ${e.toString()}');
      
      if (mounted) {
        setState(() {
          _isSavingCard = false;
        });
        
        // Mostrar error más específico
        String errorMessage = 'Error adding card. Please try again.';
        if (e.toString().contains('Failed to create payment method')) {
          errorMessage = 'Invalid card details. Please check your card information.';
        } else if (e.toString().contains('column "saved_cards" does not exist')) {
          errorMessage = 'Database column missing. Please contact support.';
        } else if (e.toString().contains('relation "profiles" does not exist')) {
          errorMessage = 'Database table missing. Please contact support.';
        } else if (e.toString().contains('permission denied')) {
          errorMessage = 'Permission denied. Please check your account.';
        } else if (e.toString().contains('stripe_customer_id')) {
          errorMessage = 'Database error. Please contact support.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _processPayment() {
    print('🔍 DEBUG: Processing payment');
    print('🔍 DEBUG: Amount: $_amount');
    print('🔍 DEBUG: Payment method: $_selectedPaymentMethod');
    print('🔍 DEBUG: Selected card: ${_selectedCard?['id']}');
    
    // Mostrar modal de procesamiento
    _showPaymentProcessingModal();
  }

  void _showPaymentProcessingModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _PaymentProcessingModal(
          amount: _amount,
          paymentMethod: _selectedPaymentMethod,
          selectedCard: _selectedCard!,
        );
      },
    );
  }
}

// TextInputFormatter personalizado para números de tarjeta
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remover todos los caracteres no numéricos
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Limitar a 16 dígitos
    final limitedText = text.length > 16 ? text.substring(0, 16) : text;
    
    // Formatear con guiones de 4 en 4
    String formatted = '';
    for (int i = 0; i < limitedText.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += '-';
      }
      formatted += limitedText[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// TextInputFormatter personalizado para fecha de expiración
class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remover todos los caracteres no numéricos
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Limitar a 4 dígitos
    final limitedText = text.length > 4 ? text.substring(0, 4) : text;
    
    // Formatear como MM/YY
    String formatted = '';
    for (int i = 0; i < limitedText.length; i++) {
      if (i == 2) {
        formatted += '/';
      }
      formatted += limitedText[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Modal de procesamiento de pago
class _PaymentProcessingModal extends StatefulWidget {
  final String amount;
  final String paymentMethod;
  final Map<String, dynamic> selectedCard;

  const _PaymentProcessingModal({
    required this.amount,
    required this.paymentMethod,
    required this.selectedCard,
  });

  @override
  State<_PaymentProcessingModal> createState() => _PaymentProcessingModalState();
}

class _PaymentProcessingModalState extends State<_PaymentProcessingModal> {
  bool _isProcessing = true;
  bool _paymentSuccess = false;
  String _errorMessage = '';
  String _paymentIntentId = 'N/A';
  String _chargeId = 'N/A';

  @override
  void initState() {
    super.initState();
    _processPayment();
  }

  void _processPayment() async {
    // Procesar pago real con Stripe
    try {
      print('🔍 DEBUG: Iniciando procesamiento de pago...');
      print('🔍 DEBUG: Amount: ${widget.amount}');
      print('🔍 DEBUG: Selected Card: ${widget.selectedCard}');
      
      // Obtener el PaymentMethod ID de la tarjeta seleccionada (estructura de Stripe)
      final paymentMethodId = widget.selectedCard['id'] as String?;
      
      print('🔍 DEBUG: Payment Method ID: $paymentMethodId');
      
      if (paymentMethodId == null || paymentMethodId.isEmpty) {
        throw Exception('No Payment Method ID found. Please add your card again.');
      }
      
      // Obtener el Customer ID del perfil del usuario
      final currentUser = SupaFlow.client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }
      
      final profileResponse = await SupaFlow.client
          .from('profiles')
          .select('stripe_customer_id')
          .eq('id', currentUser.id)
          .maybeSingle();
      
      final stripeCustomerId = profileResponse?['stripe_customer_id'];
      
      print('🔍 DEBUG: Stripe Customer ID: $stripeCustomerId');
      
      if (stripeCustomerId == null || stripeCustomerId.isEmpty) {
        throw Exception('No Stripe Customer ID found. Please add your card again.');
      }
      
      // Procesar el pago con datos reales
      final result = await StripeService.processPayment(
        amount: double.parse(widget.amount),
        currency: 'usd',
        customerId: stripeCustomerId,
        paymentMethodId: paymentMethodId,
      );
      
      print('🔍 DEBUG: Payment result: $result');
      
      final success = result['success'] as bool;
      
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _paymentSuccess = success;
          if (!success) {
            _errorMessage = result['error'] ?? 'Payment failed. Please try again.';
          } else {
            // Guardar los datos de Stripe para la pantalla de éxito
            _paymentIntentId = result['paymentIntentId'] ?? 'N/A';
            _chargeId = result['chargeId'] ?? 'N/A';
          }
        });
        
        // ❌ NO actualizar el saldo aquí - PaymentSuccessPage ya lo hace
        // Evitar duplicación de balance
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _paymentSuccess = false;
          _errorMessage = 'Payment error: $e';
        });
      }
    }
    
    // Navegar después de 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      
      // Cerrar modal de procesamiento
      Navigator.of(context, rootNavigator: true).pop();
      
      if (_paymentSuccess) {
        // Si el pago fue exitoso, navegar a la página de pago exitoso con todos los datos
        final user = Supabase.instance.client.auth.currentUser;
        final customerName = user?.email?.split('@')[0] ?? 'Customer';
        final cardBrand = widget.selectedCard['brand'] ?? 'Card';
        final cardLast4 = widget.selectedCard['last4'] ?? '****';
        final cardExpiry = widget.selectedCard['exp_month'] != null && widget.selectedCard['exp_year'] != null
            ? '${widget.selectedCard['exp_month']}/${widget.selectedCard['exp_year']}'
            : 'N/A';
        
        // Navegar a Payment Success con todos los datos
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessPagWidget(),
            settings: RouteSettings(
              arguments: {
                'paymentIntentId': _paymentIntentId,
                'chargeId': _chargeId,
                'customerName': customerName,
                'cardBrand': cardBrand,
                'cardLast4': cardLast4,
                'cardExpiry': cardExpiry,
                'amount': widget.amount,
                'currency': 'USD',
              },
            ),
          ),
        );
      } else {
        // Si el pago falló, navegar a la página de error
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentFailedPagWidget(),
            settings: RouteSettings(
              arguments: {
                'errorMessage': _errorMessage,
                'amount': widget.amount,
              },
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C), // GRIS OSCURO LANDGO
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isProcessing) ...[
              // Icono de carga
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF4DD0E1).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DD0E1)),
                    strokeWidth: 3,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Processing Payment',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait while we process your payment...',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ] else if (_paymentSuccess) ...[
              // Icono de éxito
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle,
                    color: Color(0xFF4CAF50),
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Payment Successful!',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your payment has been processed successfully.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ] else ...[
              // Icono de error
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.error,
                    color: Color(0xFFDC2626),
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Payment Failed',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
