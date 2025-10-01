import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/back_button_widget.dart';
import '/backend/supabase/supabase.dart';
import '/pages/transfer_success_page/transfer_success_page_widget.dart';
import 'transfer_money_page_model.dart';
export 'transfer_money_page_model.dart';

class TransferMoneyPageWidget extends StatefulWidget {
  const TransferMoneyPageWidget({super.key});

  static const String routeName = 'TransferMoneyPage';
  static const String routePath = '/transferMoneyPage';

  @override
  State<TransferMoneyPageWidget> createState() => _TransferMoneyPageWidgetState();
}

class _TransferMoneyPageWidgetState extends State<TransferMoneyPageWidget> {
  late TransferMoneyPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TransferMoneyPageModel());
    
    // Escuchar cambios en el campo de búsqueda
    _model.searchController.addListener(_onSearchChanged);
    
    // Escuchar cambios en el campo de monto para actualizar el botón
    _model.amountController.addListener(() {
      setState(() {}); // Actualizar UI cuando cambie el monto
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Función para buscar usuarios en tiempo real
  void _onSearchChanged() async {
    final query = _model.searchController.text.trim();
    
    if (query.isEmpty) {
      setState(() {
        _model.searchResults = [];
        _model.isSearching = false;
      });
      return;
    }

    setState(() {
      _model.isSearching = true;
    });

    try {
      // Buscar en la tabla profiles por nombre completo, email o teléfono
      final response = await SupaFlow.client
          .from('profiles')
          .select('id, full_name, email, phone, avatar_url')
          .or('full_name.ilike.%$query%,email.ilike.%$query%,phone.ilike.%$query%')
          .limit(10);

      setState(() {
        _model.searchResults = List<Map<String, dynamic>>.from(response);
        _model.isSearching = false;
      });
    } catch (e) {
      print('Error searching users: $e');
      setState(() {
        _model.searchResults = [];
        _model.isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFF000000), // FONDO NEGRO LANDGO
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
                        onPressed: () => context.pop(),
                      ),
                      const Spacer(),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Título "Transfer Money" centrado
                  Center(
                    child: Text(
                      'Transfer Money',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Search Section
                  _buildSearchSection(),
                  
                  const SizedBox(height: 20),
                  
                  // Search Results
                  if (_model.isSearching) _buildLoadingIndicator(),
                  if (!_model.isSearching && _model.searchResults.isNotEmpty)
                    _buildSearchResults(),
                  if (!_model.isSearching && _model.searchResults.isEmpty && _model.searchController.text.isNotEmpty)
                    _buildNoResults(),
                  
                  // Selected User Card
                  if (_model.selectedUser != null) ...[
                    const SizedBox(height: 30),
                    _buildSelectedUserCard(),
                    
                    const SizedBox(height: 30),
                    
                    // Amount Input
                    _buildAmountInput(),
                    
                    const SizedBox(height: 30),
                    
                    // Transfer Button
                    _buildTransferButton(),
                  ],
                  
                  const SizedBox(height: 100), // ESPACIO PARA BOTTOM NAV
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C), // GRIS OSCURO LANDGO
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Recipient',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _model.searchController,
              focusNode: _model.searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Name, email or phone...',
                hintStyle: GoogleFonts.outfit(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF4DD0E1), // TURQUESA LANDGO
                  size: 24,
                ),
                suffixIcon: _model.searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () {
                          _model.searchController.clear();
                          setState(() {
                            _model.searchResults = [];
                            _model.selectedUser = null;
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              style: GoogleFonts.outfit(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Enter name, email or phone number to find users',
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DD0E1)), // TURQUESA
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: _model.searchResults.map((user) {
          return _buildUserResultItem(user);
        }).toList(),
      ),
    );
  }

  Widget _buildUserResultItem(Map<String, dynamic> user) {
    final fullName = user['full_name'] ?? '';
    final email = user['email'] ?? '';
    final phone = user['phone'] ?? '';
    final profilePicture = user['avatar_url'];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _model.selectedUser = user;
            _model.searchController.clear();
            _model.searchResults = [];
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Profile Picture
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF4DD0E1), // TURQUESA LANDGO
                  shape: BoxShape.circle,
                  image: profilePicture != null
                      ? DecorationImage(
                          image: NetworkImage(profilePicture),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: profilePicture == null
                    ? Center(
                        child: Text(
                          fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        phone,
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF4DD0E1), // TURQUESA
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.person_search,
            color: Colors.white70,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedUserCard() {
    if (_model.selectedUser == null) return const SizedBox.shrink();

    final user = _model.selectedUser!;
    final fullName = user['full_name'] ?? '';
    final email = user['email'] ?? '';
    final phone = user['phone'] ?? '';
    final profilePicture = user['avatar_url'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4DD0E1), // TURQUESA LANDGO
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transfer to',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _model.selectedUser = null;
                    _model.amountController.clear();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Profile Picture
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF4DD0E1), // TURQUESA LANDGO
              shape: BoxShape.circle,
              image: profilePicture != null
                  ? DecorationImage(
                      image: NetworkImage(profilePicture),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: profilePicture == null
                ? Center(
                    child: Text(
                      fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            fullName,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            email,
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          if (phone.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              phone,
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amount',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _model.amountController,
              focusNode: _model.amountFocusNode,
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: GoogleFonts.outfit(
                  color: Colors.grey,
                  fontSize: 24,
                ),
                prefixText: '\$ ',
                prefixStyle: GoogleFonts.outfit(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              style: GoogleFonts.outfit(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferButton() {
    final amountText = _model.amountController.text;
    final amount = double.tryParse(amountText) ?? 0;
    final isValid = amount > 0 && _model.selectedUser != null;
    
    // Debug logs
    print('🔍 Transfer Button Debug:');
    print('  Amount text: "$amountText"');
    print('  Amount parsed: $amount');
    print('  Selected user: ${_model.selectedUser != null}');
    print('  Is valid: $isValid');

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: isValid ? const Color(0xFF4DD0E1) : Colors.grey, // TURQUESA LANDGO
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isValid ? _processTransfer : null,
          child: Center(
            child: Text(
              'Transfer Money',
              style: GoogleFonts.outfit(
                color: isValid ? Colors.black : Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _processTransfer() {
    _showTransferLoadingModal();
  }

  // Modal de loading para transferencia
  void _showTransferLoadingModal() {
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono de loading moderno con gradiente
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF4DD0E1), // Turquesa
                        const Color(0xFF26C6DA), // Turquesa más oscuro
                        const Color(0xFF00BCD4), // Cyan
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4DD0E1).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Círculo exterior animado
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF4DD0E1).withOpacity(0.3),
                            width: 3,
                          ),
                        ),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF4DD0E1).withOpacity(0.7),
                          ),
                        ),
                      ),
                      // Círculo interior con gradiente
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF4DD0E1),
                              const Color(0xFF26C6DA),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Texto de loading
                Text(
                  'Processing Transfer...',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF2C2C2C),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Please wait while we process your transfer',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF666666),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Ejecutar transferencia después de mostrar el modal
    _performTransfer();
  }

  // Función para realizar la transferencia
  Future<void> _performTransfer() async {
    try {
      // Iniciar cronómetro para mínimo 3 segundos
      final stopwatch = Stopwatch()..start();

      // Generar número de confirmación automático
      final confirmationNumber = _generateConfirmationNumber();
      final currentTime = DateTime.now();
      final recipientName = _model.selectedUser?['full_name'] ?? 'Unknown';
      final transferAmount = _model.amountController.text;
      final amount = double.parse(transferAmount);

      // Obtener usuario actual
      final currentUser = SupaFlow.client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener ID del receptor
      final recipientId = _model.selectedUser?['id'];
      if (recipientId == null) {
        throw Exception('ID del receptor no válido');
      }

      // Realizar transferencia real en Supabase
      await _executeTransfer(
        senderId: currentUser.id,
        recipientId: recipientId,
        amount: amount,
        confirmationNumber: confirmationNumber,
        senderName: currentUser.userMetadata?['full_name'] ?? 'Unknown',
      );

      // Asegurar mínimo 3 segundos de loading
      final elapsed = stopwatch.elapsedMilliseconds;
      if (elapsed < 3000) {
        await Future.delayed(Duration(milliseconds: 3000 - elapsed));
      }

      if (mounted) {
        // Cerrar modal de loading
        Navigator.of(context).pop();
        
        // Navegar a pantalla de éxito
        _showTransferSuccessScreen(
          confirmationNumber: confirmationNumber,
          recipientName: recipientName,
          transferAmount: transferAmount,
          transferTime: currentTime,
        );
      }
    } catch (e) {
      print('❌ Error en transferencia: $e');
      if (mounted) {
        // Cerrar modal de loading
        Navigator.of(context).pop();
        
        // Mostrar error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing transfer: ${e.toString()}'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  // Función para ejecutar la transferencia en Supabase
  Future<Map<String, dynamic>> _executeTransfer({
    required String senderId,
    required String recipientId,
    required double amount,
    required String confirmationNumber,
    required String senderName,
  }) async {
    try {
      print('🔄 Iniciando transferencia:');
      print('  Sender: $senderId');
      print('  Recipient: $recipientId');
      print('  Amount: \$${amount.toStringAsFixed(2)}');
      print('  Confirmation: $confirmationNumber');

      // 1. Verificar que el emisor tiene suficiente balance
      print('📊 Paso 1: Verificando balance del emisor...');
      final senderProfile = await SupaFlow.client
          .from('profiles')
          .select('cashback_balance, full_name')
          .eq('id', senderId)
          .single();

      final currentBalance = (senderProfile['cashback_balance'] as num?)?.toDouble() ?? 0.0;
      print('💰 Balance actual del emisor: \$${currentBalance.toStringAsFixed(2)}');

      if (currentBalance < amount) {
        throw Exception('Fondos insuficientes. Balance disponible: \$${currentBalance.toStringAsFixed(2)}');
      }

      // 2. Obtener balance del receptor
      print('📊 Paso 2: Obteniendo balance del receptor...');
      final recipientProfile = await SupaFlow.client
          .from('profiles')
          .select('cashback_balance, full_name')
          .eq('id', recipientId)
          .single();

      final recipientBalance = (recipientProfile['cashback_balance'] as num?)?.toDouble() ?? 0.0;
      final recipientName = recipientProfile['full_name'] ?? 'Unknown';
      print('💰 Balance actual del receptor: \$${recipientBalance.toStringAsFixed(2)}');
      print('👤 Nombre del receptor: $recipientName');

      // 3. Calcular nuevos balances
      final newSenderBalance = currentBalance - amount;
      final newRecipientBalance = recipientBalance + amount;

      print('💸 Nuevos balances calculados:');
      print('  Emisor: \$${currentBalance.toStringAsFixed(2)} → \$${newSenderBalance.toStringAsFixed(2)}');
      print('  Receptor: \$${recipientBalance.toStringAsFixed(2)} → \$${newRecipientBalance.toStringAsFixed(2)}');

      // 4. Actualizar balance del emisor (DEBITAR)
      print('📊 Paso 3: Debitando del emisor...');
      final senderUpdateResponse = await SupaFlow.client
          .from('profiles')
          .update({'cashback_balance': newSenderBalance})
          .eq('id', senderId)
          .select();

      print('✅ Balance del emisor actualizado');
      print('   Respuesta: $senderUpdateResponse');

      // 5. Actualizar balance del receptor (ACREDITAR)
      print('📊 Paso 4: Acreditando al receptor...');
      final recipientUpdateResponse = await SupaFlow.client
          .from('profiles')
          .update({'cashback_balance': newRecipientBalance})
          .eq('id', recipientId)
          .select();

      print('✅ Balance del receptor actualizado');
      print('   Respuesta: $recipientUpdateResponse');

      // 6. Crear transacción para el emisor (DEBITO)
      print('📊 Paso 5: Creando transacción del emisor...');
      try {
        final senderTransaction = await SupaFlow.client
            .from('payments')
            .insert({
              'user_id': senderId,
              'amount': -amount, // Negativo para débito
              'currency': 'USD',
              'status': 'completed',
              'payment_method': 'wallet', // Valor permitido por constraint
              'transaction_id': confirmationNumber,
              'description': 'Transfer to $recipientName',
              'related_type': 'transfer_out',
              'related_id': recipientId,
            })
            .select();
        print('✅ Transacción del emisor creada');
        print('   Respuesta: $senderTransaction');
      } catch (e) {
        // No bloquear la transferencia por un problema de logging en payments
        print('⚠️ No se pudo registrar transacción del emisor en payments: $e');
      }

      // 7. Crear transacción para el receptor (CREDITO)
      print('📊 Paso 6: Creando transacción del receptor...');
      try {
        final recipientTransaction = await SupaFlow.client
            .from('payments')
            .insert({
              'user_id': recipientId,
              'amount': amount, // Positivo para crédito
              'currency': 'USD',
              'status': 'completed',
              'payment_method': 'wallet', // Valor permitido por constraint
              'transaction_id': confirmationNumber,
              'description': 'Transfer from $senderName',
              'related_type': 'transfer_in',
              'related_id': senderId,
            })
            .select();
        print('✅ Transacción del receptor creada');
        print('   Respuesta: $recipientTransaction');
      } catch (e) {
        // No bloquear la transferencia por un problema de logging en payments
        print('⚠️ No se pudo registrar transacción del receptor en payments: $e');
      }

      print('🎉 Transferencia completada exitosamente!');
      print('   Emisor: \$${newSenderBalance.toStringAsFixed(2)}');
      print('   Receptor: \$${newRecipientBalance.toStringAsFixed(2)}');

      return {
        'success': true,
        'confirmation_number': confirmationNumber,
        'sender_balance': newSenderBalance,
        'recipient_balance': newRecipientBalance,
      };
    } catch (e, stackTrace) {
      print('❌ ERROR EN TRANSFERENCIA:');
      print('   Error: $e');
      print('   Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Generar número de confirmación automático
  String _generateConfirmationNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString().substring(8);
    final random = (now.microsecond % 1000).toString().padLeft(3, '0');
    return 'TRF${timestamp}${random}';
  }

  // Mostrar pantalla de transferencia exitosa
  void _showTransferSuccessScreen({
    required String confirmationNumber,
    required String recipientName,
    required String transferAmount,
    required DateTime transferTime,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TransferSuccessPageWidget(
          confirmationNumber: confirmationNumber,
          recipientName: recipientName,
          transferAmount: transferAmount,
          transferTime: transferTime,
        ),
      ),
    );
  }
}
