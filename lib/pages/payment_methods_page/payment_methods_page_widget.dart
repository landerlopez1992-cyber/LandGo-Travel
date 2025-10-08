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
  
  // Variables para billing address
  bool _isLoadingBillingAddress = false;
  Map<String, dynamic>? _billingAddress;
  bool _isEditingBillingAddress = false;
  bool _hasBillingAddressChanges = false;
  
  // Controllers para el formulario de billing address
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _line1Controller = TextEditingController();
  final TextEditingController _line2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PaymentMethodsPageModel());
    _loadPaymentMethods();
    _loadBillingAddress();
    _setupBillingAddressListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  void _setupBillingAddressListeners() {
    _nameController.addListener(_checkForBillingAddressChanges);
    _line1Controller.addListener(_checkForBillingAddressChanges);
    _line2Controller.addListener(_checkForBillingAddressChanges);
    _cityController.addListener(_checkForBillingAddressChanges);
    _stateController.addListener(_checkForBillingAddressChanges);
    _postalCodeController.addListener(_checkForBillingAddressChanges);
    _countryController.addListener(_checkForBillingAddressChanges);
  }

  @override
  void dispose() {
    _model.dispose();
    _nameController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
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

  // Cargar billing address del usuario
  Future<void> _loadBillingAddress() async {
    try {
      setState(() {
        _isLoadingBillingAddress = true;
      });

      final currentUser = SupaFlow.client.auth.currentUser;
      if (currentUser == null) {
        print('❌ No user logged in');
        setState(() {
          _isLoadingBillingAddress = false;
        });
        return;
      }

      print('🔍 Loading billing address for user: ${currentUser.id}');

      final response = await SupaFlow.client
          .from('profiles')
          .select('billing_address')
          .eq('id', currentUser.id)
          .maybeSingle();

      print('🔍 Billing address response: $response');

      final billingAddressData = response?['billing_address'] as Map<String, dynamic>?;
      
      if (mounted) {
        setState(() {
          _billingAddress = billingAddressData;
          _isLoadingBillingAddress = false;
        });
      }

      print('✅ Billing address loaded: $_billingAddress');
    } catch (e) {
      print('❌ Error loading billing address: $e');
      if (mounted) {
        setState(() {
          _billingAddress = null;
          _isLoadingBillingAddress = false;
        });
      }
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

  // ============================================================================
  // MÉTODOS PARA BILLING ADDRESS
  // ============================================================================

  // Guardar billing address
  Future<void> _saveBillingAddress() async {
    try {
      // Validar campos requeridos
      if (_nameController.text.trim().isEmpty) {
        _showErrorModal('Name is required');
        return;
      }
      if (_line1Controller.text.trim().isEmpty) {
        _showErrorModal('Address line 1 is required');
        return;
      }
      if (_cityController.text.trim().isEmpty) {
        _showErrorModal('City is required');
        return;
      }
      if (_stateController.text.trim().isEmpty) {
        _showErrorModal('State is required');
        return;
      }
      if (_postalCodeController.text.trim().isEmpty) {
        _showErrorModal('Postal code is required');
        return;
      }
      if (_countryController.text.trim().isEmpty) {
        _showErrorModal('Country is required');
        return;
      }

      // Mostrar loading
      _showLoadingModal('Saving billing address...');

      final currentUser = SupaFlow.client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Crear objeto de billing address
      final billingAddressData = {
        'name': _nameController.text.trim(),
        'line1': _line1Controller.text.trim(),
        'line2': _line2Controller.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'postal_code': _postalCodeController.text.trim(),
        'country': _countryController.text.trim(),
      };

      print('🔍 Saving billing address: $billingAddressData');

      // Guardar en Supabase
      await SupaFlow.client
          .from('profiles')
          .update({'billing_address': billingAddressData})
          .eq('id', currentUser.id);

      // Cerrar loading
      if (mounted) Navigator.of(context).pop();

      // Actualizar estado
      setState(() {
        _billingAddress = billingAddressData;
        _isEditingBillingAddress = false;
      });

      // Limpiar formulario
      _clearFormFields();

      // Mostrar éxito
      _showSuccessModal('Billing address saved successfully!');

      print('✅ Billing address saved successfully');
    } catch (e) {
      // Cerrar loading
      if (mounted) Navigator.of(context).pop();

      // Mostrar error
      _showErrorModal('Error saving billing address: ${e.toString()}');
      print('❌ Error saving billing address: $e');
    }
  }

  // Limpiar campos del formulario
  void _clearFormFields() {
    _nameController.clear();
    _line1Controller.clear();
    _line2Controller.clear();
    _cityController.clear();
    _stateController.clear();
    _postalCodeController.clear();
    _countryController.clear();
    _hasBillingAddressChanges = false;
  }

  void _checkForBillingAddressChanges() {
    if (_billingAddress == null) {
      _hasBillingAddressChanges = _nameController.text.isNotEmpty ||
          _line1Controller.text.isNotEmpty ||
          _line2Controller.text.isNotEmpty ||
          _cityController.text.isNotEmpty ||
          _stateController.text.isNotEmpty ||
          _postalCodeController.text.isNotEmpty ||
          _countryController.text.isNotEmpty;
    } else {
      _hasBillingAddressChanges = 
          _nameController.text != (_billingAddress!['name'] ?? '') ||
          _line1Controller.text != (_billingAddress!['line1'] ?? '') ||
          _line2Controller.text != (_billingAddress!['line2'] ?? '') ||
          _cityController.text != (_billingAddress!['city'] ?? '') ||
          _stateController.text != (_billingAddress!['state'] ?? '') ||
          _postalCodeController.text != (_billingAddress!['postal_code'] ?? '') ||
          _countryController.text != (_billingAddress!['country'] ?? '');
    }
    
    setState(() {});
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
                          : SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildCardsList(),
                                  _buildBillingAddressSection(),
                                ],
                              ),
                            ),
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
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4DD0E1), Color(0xFF26C6DA)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4DD0E1).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _addNewCard,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add_card_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Add Your First Card',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
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
      mainAxisSize: MainAxisSize.min,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _paymentMethods.length,
          itemBuilder: (context, index) {
            final card = _paymentMethods[index];
            return _buildCardItem(card);
          },
        ),
        // Botón Premium - Diseño V2
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4DD0E1), Color(0xFF26C6DA)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4DD0E1).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _addNewCard,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_card_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Add New Card',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
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

  // ============================================================================
  // WIDGETS PARA BILLING ADDRESS
  // ============================================================================

  Widget _buildBillingAddressSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF37474F).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF4DD0E1).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Color(0xFF4DD0E1),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Billing Address',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Address used for all payment methods',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Contenido según el estado
          if (_isEditingBillingAddress)
            _buildBillingAddressForm()
          else if (_billingAddress == null || _billingAddress!.isEmpty)
            _buildEmptyBillingAddress()
          else
            _buildBillingAddressDisplay(),
        ],
      ),
    );
  }

  Widget _buildEmptyBillingAddress() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF37474F).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF37474F).withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.location_off,
                color: Colors.white54,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                'No billing address saved',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your billing address to use with payment methods',
                style: GoogleFonts.outfit(
                  color: Colors.white54,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _isEditingBillingAddress = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4DD0E1),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_location,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Add Billing Address',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBillingAddressDisplay() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF37474F).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF4DD0E1).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAddressLine('Name', _billingAddress!['name'] ?? ''),
              const SizedBox(height: 12),
              _buildAddressLine('Address', _billingAddress!['line1'] ?? ''),
              if (_billingAddress!['line2'] != null && _billingAddress!['line2'].toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildAddressLine('', _billingAddress!['line2']),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildAddressLine('City', _billingAddress!['city'] ?? ''),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildAddressLine('State', _billingAddress!['state'] ?? ''),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildAddressLine('Postal Code', _billingAddress!['postal_code'] ?? ''),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildAddressLine('Country', _billingAddress!['country'] ?? ''),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    // Pre-llenar formulario con datos existentes
                    _nameController.text = _billingAddress!['name'] ?? '';
                    _line1Controller.text = _billingAddress!['line1'] ?? '';
                    _line2Controller.text = _billingAddress!['line2'] ?? '';
                    _cityController.text = _billingAddress!['city'] ?? '';
                    _stateController.text = _billingAddress!['state'] ?? '';
                    _postalCodeController.text = _billingAddress!['postal_code'] ?? '';
                    _countryController.text = _billingAddress!['country'] ?? '';
                    
                    setState(() {
                      _isEditingBillingAddress = true;
                      _hasBillingAddressChanges = false; // Inicialmente no hay cambios
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: const Color(0xFF4DD0E1).withValues(alpha: 0.5),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Edit',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF4DD0E1),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            if (_hasBillingAddressChanges) ...[
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveBillingAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4DD0E1),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Save',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildAddressLine(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBillingAddressForm() {
    return Column(
      children: [
        _buildFormField(
          controller: _nameController,
          label: 'Full Name',
          icon: Icons.person,
          isRequired: true,
        ),
        const SizedBox(height: 16),
        _buildFormField(
          controller: _line1Controller,
          label: 'Address Line 1',
          icon: Icons.home,
          isRequired: true,
        ),
        const SizedBox(height: 16),
        _buildFormField(
          controller: _line2Controller,
          label: 'Address Line 2 (Optional)',
          icon: Icons.home_work,
          isRequired: false,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildFormField(
                controller: _cityController,
                label: 'City',
                icon: Icons.location_city,
                isRequired: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFormField(
                controller: _stateController,
                label: 'State',
                icon: Icons.map,
                isRequired: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildFormField(
                controller: _postalCodeController,
                label: 'Postal Code',
                icon: Icons.local_post_office,
                isRequired: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFormField(
                controller: _countryController,
                label: 'Country',
                icon: Icons.public,
                isRequired: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isEditingBillingAddress = false;
                    });
                    _clearFormFields();
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveBillingAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4DD0E1),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Save Address',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isRequired,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF4DD0E1),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFDC2626),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF37474F).withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFF37474F).withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFF37474F).withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF4DD0E1),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

