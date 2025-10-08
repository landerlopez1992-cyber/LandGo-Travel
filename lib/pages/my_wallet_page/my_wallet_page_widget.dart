import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/back_button_widget.dart';
import '/pages/review_summary_page/review_summary_page_widget.dart';
import 'my_wallet_page_model.dart';
export 'my_wallet_page_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyWalletPageWidget extends StatefulWidget {
  const MyWalletPageWidget({super.key});

  static const String routeName = 'MyWalletPage';
  static const String routePath = '/myWalletPage';

  @override
  State<MyWalletPageWidget> createState() => _MyWalletPageWidgetState();
}

class _MyWalletPageWidgetState extends State<MyWalletPageWidget> {
  late MyWalletPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Balance actual del usuario
  double _currentBalance = 0.0;
  bool _isLoadingBalance = true;
  
  // Estadísticas del wallet
  double _totalEarned = 0.0;
  double _totalSaved = 0.0;
  int _transactionCount = 0;
  List<Map<String, dynamic>> _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MyWalletPageModel());
    // Cargar balance inicial
    _loadWalletBalance();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }
  
  /// Método público para refrescar el balance cuando sea necesario
  Future<void> refreshBalance() async {
    if (mounted) {
      await _loadWalletBalance();
    }
  }
  
  /// ✅ CARGAR SALDO Y ESTADÍSTICAS DESDE SUPABASE
  Future<void> _loadWalletBalance() async {
    try {
      if (mounted) {
        setState(() {
          _isLoadingBalance = true;
        });
      }
      
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        if (mounted) {
          setState(() {
            _currentBalance = 0.0;
            _totalEarned = 0.0;
            _totalSaved = 0.0;
            _transactionCount = 0;
            _recentTransactions = [];
            _isLoadingBalance = false;
          });
        }
        return;
      }
      
      print('🔍 DEBUG: Loading wallet data for user: ${user.id}');
      
      // 1. Obtener balance del wallet
      final profileResponse = await Supabase.instance.client
          .from('profiles')
          .select('cashback_balance')
          .eq('id', user.id)
          .single();
      
      final balance = (profileResponse['cashback_balance'] as num?)?.toDouble() ?? 0.0;
      print('✅ Balance loaded: \$${balance.toStringAsFixed(2)}');
      
      // 2. Calcular Total Enviado y Recibido (últimos 30 días)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      // Total Enviado: Buscar donde user_id = current_user, amount < 0, transfer_out
      final sentTransactions = await Supabase.instance.client
          .from('payments')
          .select('amount')
          .eq('user_id', user.id)
          .eq('payment_method', 'wallet')
          .eq('related_type', 'transfer_out')
          .lt('amount', 0)
          .gte('created_at', thirtyDaysAgo.toIso8601String());
      
      double totalSent = 0.0;
      for (var tx in sentTransactions) {
        final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
        totalSent += amount.abs();
      }
      
      // Total Recibido: Buscar donde related_id = current_user (soy el receptor)
      // Estas transacciones tienen user_id = emisor, pero related_id = yo
      final receivedTransactions = await Supabase.instance.client
          .from('payments')
          .select('amount')
          .eq('related_id', user.id)
          .eq('payment_method', 'wallet')
          .eq('related_type', 'transfer_out') // La transacción es transfer_out del emisor
          .lt('amount', 0) // El monto es negativo para el emisor
          .gte('created_at', thirtyDaysAgo.toIso8601String());
      
      double totalReceived = 0.0;
      for (var tx in receivedTransactions) {
        final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
        totalReceived += amount.abs(); // Convertir a positivo
      }
      
      print('✅ Total Enviado (30 días): \$${totalSent.toStringAsFixed(2)}');
      print('✅ Total Recibido (30 días): \$${totalReceived.toStringAsFixed(2)}');
      
      // 4. Obtener conteo de transacciones (solo del usuario actual)
      final countResponse = await Supabase.instance.client
          .from('payments')
          .select('id')
          .eq('user_id', user.id); // SOLO transacciones donde el usuario es el user_id
      
      int transactionCount = 0;
      transactionCount = countResponse.length;
      print('✅ Transaction Count: $transactionCount');
      
      // 5. Obtener últimas transacciones (máximo 10) pertenecientes al usuario actual
      final recentTransactionsResponse = await Supabase.instance.client
          .from('payments')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(10);
      
      List<Map<String, dynamic>> recentTransactions = List<Map<String, dynamic>>.from(recentTransactionsResponse);
      
      // DEBUG: Mostrar detalles de cada transacción
      print('🔍 DEBUG TRANSACTIONS:');
      for (var tx in recentTransactions) {
        print('  - Amount: ${tx['amount']}, Type: ${tx['related_type']}, PaymentMethod: ${tx['payment_method']}, User: ${tx['user_id']}, Related: ${tx['related_id']}');
      }
      print('✅ Recent Transactions: ${recentTransactions.length}');
      
      if (mounted) {
        setState(() {
          _currentBalance = balance;
          _totalEarned = totalSent; // Ahora es Total Enviado
          _totalSaved = totalReceived; // Ahora es Total Recibido
          _transactionCount = transactionCount;
          _recentTransactions = recentTransactions;
          _isLoadingBalance = false;
        });
      }
      
    } catch (e) {
      print('❌ Error loading wallet data: $e');
      if (mounted) {
        setState(() {
          _currentBalance = 0.0;
          _totalEarned = 0.0;
          _totalSaved = 0.0;
          _transactionCount = 0;
          _recentTransactions = [];
          _isLoadingBalance = false;
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
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        // Cuando se hace pop (regreso), no hacer nada especial
        // Solo dejar que la navegación funcione normalmente
      },
      child: GestureDetector(
        onTap: () => _model.unfocusNode.canRequestFocus
            ? FocusScope.of(context).requestFocus(_model.unfocusNode)
            : FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: const Color(0xFF000000), // FONDO NEGRO LANDGO
          extendBodyBehindAppBar: false,
          extendBody: false,
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
                              context.pop();
                            } else {
                              context.goNamedAuth('MainPage', context.mounted);
                            }
                          },
                        ),
                        const Spacer(),
                      ],
                    ),
                  
                  const SizedBox(height: 10),
                  
                  // Título "My Wallet" centrado
                  Center(
                    child: Text(
                      'My Wallet',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Current Balance Card
                  _buildCurrentBalanceCard(),
                  
                  const SizedBox(height: 20),
                  
                  // Action Buttons
                  _buildActionButtons(),
                  
                  const SizedBox(height: 20),
                  
                  // Stats Cards
                  _buildStatsCards(),
                  
                  const SizedBox(height: 30),
                  
                  // Recent Transactions Section
                  _buildRecentTransactionsSection(),
                  
                  const SizedBox(height: 100), // ESPACIO PARA BOTTOM NAV
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildCurrentBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C), // GRIS OSCURO LANDGO
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Balance',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4DD0E1), // TURQUESA LANDGO
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Active',
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _isLoadingBalance
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DD0E1)),
              )
            : Text(
                '\$${_currentBalance.toStringAsFixed(2)}',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF4DD0E1), // TURQUESA LANDGO
              borderRadius: BorderRadius.circular(16),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  _showAddMoneyModal();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_circle_outline,
                      color: Colors.black,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add Money',
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white,
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  await context.pushNamed('TransferMoneyPage');
                  // NO recargar automáticamente - solo recargar si es necesario
                  // El balance se actualizará cuando el usuario regrese de una transferencia exitosa
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.swap_horiz,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Transfer',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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

  Widget _buildStatsCards() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C), // GRIS OSCURO LANDGO
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard(
            '\$${_totalEarned.abs().toStringAsFixed(2)}',
            'Total Enviado',
            Icons.arrow_upward,
            const Color(0xFFDC2626), // ROJO para enviado
          ),
          _buildStatCard(
            '\$${_totalSaved.toStringAsFixed(2)}',
            'Total Recibido',
            Icons.arrow_downward,
            const Color(0xFF4CAF50), // VERDE para recibido
          ),
          _buildStatCard(
            '$_transactionCount',
            'Transactions',
            Icons.receipt_long,
            Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color iconColor) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: () async {
                print('🔍 DEBUG: Navegando a AllTransactionsPage...');
                try {
                  await context.pushNamed('AllTransactionsPage');
                  print('✅ DEBUG: Navegación exitosa a AllTransactionsPage');
                } catch (e) {
                  print('❌ DEBUG: Error navegando a AllTransactionsPage: $e');
                }
              },
              child: Text(
                'View All',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF4DD0E1), // TURQUESA LANDGO
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Mostrar transacciones reales o mensaje vacío
        _recentTransactions.isEmpty
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C), // GRIS OSCURO LANDGO
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.receipt_long,
                    color: Colors.white70,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start booking to earn cashback!',
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Column(
              children: _recentTransactions.map((tx) => GestureDetector(
                onTap: () {
                  // Navegar a detalles de transacción
                  context.go(
                    '/transactionDetailPage',
                    extra: {'transaction': tx},
                  );
                },
                child: _buildTransactionItem(tx),
              )).toList(),
            ),
      ],
    );
  }
  
  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
    final paymentMethod = (tx['payment_method'] ?? '').toString().toLowerCase();
    
    // Determinar si es envío, recepción o pago con Stripe
    bool isSent = amount < 0; // débito (envío)
    bool isReceived = amount > 0; // crédito (recepción)
    bool isStripePayment = paymentMethod.contains('stripe') || paymentMethod.contains('card');
    
    // Determinar el tipo de transacción
    String transactionType;
    IconData typeIcon;
    Color typeColor;
    
    if (isStripePayment) {
      transactionType = 'Pago con Tarjeta';
      typeIcon = Icons.credit_card;
      typeColor = const Color(0xFF4DD0E1); // Turquesa
    } else if (isSent) {
      transactionType = 'Enviado';
      typeIcon = Icons.arrow_upward;
      typeColor = const Color(0xFFDC2626); // Rojo
    } else if (isReceived) {
      transactionType = 'Recibido';
      typeIcon = Icons.arrow_downward;
      typeColor = const Color(0xFF4CAF50); // Verde
    } else {
      transactionType = 'Transacción';
      typeIcon = Icons.receipt_long;
      typeColor = Colors.white;
    }
    
    // Obtener datos de la transacción
    final status = (tx['status'] ?? 'completed').toString().toLowerCase();
    final createdAt = tx['created_at']?.toString() ?? '';
    
    // Determinar icono y color según estado
    IconData statusIcon;
    Color statusColor;
    
    if (status.contains('failed') || status.contains('denied')) {
      statusIcon = Icons.cancel;
      statusColor = const Color(0xFFDC2626); // Rojo
    } else if (status.contains('pending')) {
      statusIcon = Icons.access_time;
      statusColor = const Color(0xFFFF9800); // Naranja
    } else {
      statusIcon = Icons.check_circle;
      statusColor = const Color(0xFF4CAF50); // Verde
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C), // GRIS OSCURO LANDGO
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Icono de tipo de transacción
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              typeIcon,
              color: typeColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          
          // Información de la transacción
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transactionType,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _formatTransactionDate(createdAt),
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      statusIcon,
                      color: statusColor,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Monto con color
          Text(
            '${isSent ? '-' : '+'}\$${amount.abs().toStringAsFixed(2)}',
            style: GoogleFonts.outfit(
              color: isSent 
                ? const Color(0xFFDC2626) // Rojo para enviado
                : isStripePayment 
                  ? const Color(0xFF4DD0E1) // Turquesa para tarjeta
                  : const Color(0xFF4CAF50), // Verde para recibido
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatTransactionDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Unknown date';
    try {
      final date = DateTime.parse(dateString);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year} • ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown date';
    }
  }


  void _showAddMoneyModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _AddMoneyModalContent(),
    );
  }
}

// WIDGET SEPARADO PARA EL MODAL CON SU PROPIO ESTADO
class _AddMoneyModalContent extends StatefulWidget {
  const _AddMoneyModalContent();

  @override
  State<_AddMoneyModalContent> createState() => _AddMoneyModalContentState();
}

class _AddMoneyModalContentState extends State<_AddMoneyModalContent> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Color(0xFF2C2C2C), // GRIS OSCURO LANDGO
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modal Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Money',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Amount Input - MEJORADO
            Center(
              child: Container(
                width: 280,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Label
                    Text(
                      'Enter Amount',
                      style: GoogleFonts.outfit(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Input Field
                    TextField(
                      controller: _amountController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '\$0.00',
                        border: InputBorder.none,
                        hintStyle: GoogleFonts.outfit(
                          fontSize: 32,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w300,
                        ),
                        prefixText: '\$ ',
                        prefixStyle: GoogleFonts.outfit(
                          fontSize: 32,
                          color: const Color(0xFF4DD0E1),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Add Money Button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF4DD0E1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    // Validar que se haya ingresado una cantidad
                    if (_amountController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Please enter an amount',
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

                    // Validar que la cantidad sea válida
                    final amount = double.tryParse(_amountController.text.trim());
                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Please enter a valid amount',
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

                    print('🔍 DEBUG: Amount to send: $amount');
                    print('🔍 DEBUG: Amount as string: ${amount.toString()}');
                    
                    Navigator.pop(context);
                    // Navegar directamente a Review Summary con datos
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewSummaryPageWidget(),
                        settings: RouteSettings(
                          arguments: {
                            'amount': amount.toString(),
                          },
                        ),
                      ),
                    );
                    
                    print('🔍 DEBUG: Navigation completed to ReviewSummaryPage with extra data');
                  },
                  child: Center(
                    child: Text(
                      'Add Money',
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
            
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

}
