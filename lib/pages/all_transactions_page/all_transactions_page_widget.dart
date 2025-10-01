import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'all_transactions_page_model.dart';
export 'all_transactions_page_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AllTransactionsPageWidget extends StatefulWidget {
  const AllTransactionsPageWidget({super.key});

  static const String routeName = 'AllTransactionsPage';
  static const String routePath = '/allTransactionsPage';

  @override
  State<AllTransactionsPageWidget> createState() => _AllTransactionsPageWidgetState();
}

class _AllTransactionsPageWidgetState extends State<AllTransactionsPageWidget> {
  late AllTransactionsPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Variables de estado
  List<Map<String, dynamic>> _allTransactions = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    print('🔍 DEBUG: AllTransactionsPage initState() llamado');
    _model = createModel(context, () => AllTransactionsPageModel());
    _loadAllTransactions();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  /// ✅ CARGAR TODAS LAS TRANSACCIONES DESDE SUPABASE
  Future<void> _loadAllTransactions() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = '';
        });
      }
      
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        if (mounted) {
          setState(() {
            _allTransactions = [];
            _isLoading = false;
            _errorMessage = 'No user logged in';
          });
        }
        return;
      }
      
      print('🔍 DEBUG: Loading ALL transactions for user: ${user.id}');
      
      // Obtener únicamente las transacciones del usuario actual (linea de débito o crédito propia)
      final allTransactionsResponse = await Supabase.instance.client
          .from('payments')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      
      List<Map<String, dynamic>> allTransactions = List<Map<String, dynamic>>.from(allTransactionsResponse);
      
      // Ordenar por fecha descendente
      allTransactions.sort((a, b) {
        final dateA = DateTime.parse(a['created_at'] ?? '');
        final dateB = DateTime.parse(b['created_at'] ?? '');
        return dateB.compareTo(dateA);
      });
      
      // Precargar nombres de usuarios para todas las transacciones
      await _preloadUserNames(allTransactions);
      
      // DEBUG: Mostrar detalles de cada transacción
      print('🔍 DEBUG ALL TRANSACTIONS: ${allTransactions.length}');
      for (var tx in allTransactions) {
        print('  - Amount: ${tx['amount']}, Type: ${tx['related_type']}, User: ${tx['user_id']}, Related: ${tx['related_id']}');
      }
      
      if (mounted) {
        setState(() {
          _allTransactions = allTransactions;
          _isLoading = false;
        });
      }
      
    } catch (e) {
      print('❌ Error loading all transactions: $e');
      if (mounted) {
        setState(() {
          _allTransactions = [];
          _isLoading = false;
          _errorMessage = 'Error loading transactions: $e';
        });
      }
    }
  }

  /// Obtener nombre de usuario por ID desde Supabase
  Future<String?> _getUserName(String? userId) async {
    if (userId == null) return null;
    
    // Cache simple para evitar consultas repetidas
    if (_userNameCache.containsKey(userId)) {
      return _userNameCache[userId];
    }
    
    try {
      // Consultar el nombre del usuario desde Supabase
      final response = await Supabase.instance.client
          .from('profiles')
          .select('full_name, first_name, last_name')
          .eq('id', userId)
          .single();
      
      String? userName;
      if (response['full_name'] != null && response['full_name'].toString().isNotEmpty) {
        userName = response['full_name'].toString();
      } else if (response['first_name'] != null && response['last_name'] != null) {
        userName = '${response['first_name']} ${response['last_name']}';
      } else {
        userName = 'Usuario';
      }
      
      // Guardar en cache
      _userNameCache[userId] = userName;
      return userName;
    } catch (e) {
      print('❌ Error obteniendo nombre de usuario $userId: $e');
      return 'Usuario';
    }
  }
  
  // Cache de nombres de usuarios
  final Map<String, String> _userNameCache = {};
  
  /// Obtener nombre de usuario sincrónicamente desde cache
  String _getUserNameSync(String? userId) {
    if (userId == null) return 'Usuario desconocido';
    
    // Usar cache si está disponible
    if (_userNameCache.containsKey(userId)) {
      return _userNameCache[userId]!;
    }
    
    // Si no está en cache, cargar de forma asíncrona
    _loadUserNameAsync(userId);
    return 'Cargando...';
  }
  
  /// Cargar nombre de usuario de forma asíncrona
  Future<void> _loadUserNameAsync(String userId) async {
    try {
      final userName = await _getUserName(userId);
      if (mounted) {
        setState(() {
          // El setState actualizará la UI cuando se obtenga el nombre
        });
      }
    } catch (e) {
      print('❌ Error cargando nombre de usuario $userId: $e');
    }
  }
  
  /// Precargar nombres de usuarios para todas las transacciones
  Future<void> _preloadUserNames(List<Map<String, dynamic>> transactions) async {
    final Set<String> userIds = {};
    
    // Recopilar todos los IDs de usuarios únicos
    for (var tx in transactions) {
      if (tx['user_id'] != null) {
        userIds.add(tx['user_id'].toString());
      }
      if (tx['related_id'] != null) {
        userIds.add(tx['related_id'].toString());
      }
    }
    
    // Cargar nombres de usuarios en paralelo
    final futures = userIds.map((userId) => _getUserName(userId));
    await Future.wait(futures);
    
    print('✅ Precargados ${userIds.length} nombres de usuarios');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFF000000), // FONDO NEGRO LANDGO
        appBar: AppBar(
          backgroundColor: const Color(0xFF000000), // FONDO NEGRO LANDGO
          automaticallyImplyLeading: false,
          leading: null,
          title: null,
          elevation: 0,
          toolbarHeight: 0, // Sin AppBar, usaremos un header personalizado
        ),
        body: SafeArea(
          top: true,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF000000), // NEGRO LANDGO
                  Color(0xFF1A1A1A), // NEGRO SUAVE
                ],
              ),
            ),
            child: Column(
              children: [
                // Header personalizado con botón atrás
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {
                          context.pop();
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'All Transactions',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Contenido principal
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF4DD0E1), // TURQUESA LANDGO
                          ),
                        )
                      : _errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            FFButtonWidget(
                              onPressed: _loadAllTransactions,
                              text: 'Retry',
                              options: FFButtonOptions(
                                height: 40,
                                padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                                iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                color: const Color(0xFF4DD0E1),
                                textStyle: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                elevation: 3,
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _allTransactions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.receipt_long,
                                  color: Colors.white70,
                                  size: 64,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No transactions yet',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start making transactions to see them here!',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadAllTransactions,
                            color: const Color(0xFF4DD0E1),
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _allTransactions.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final tx = _allTransactions[index];
                                return _buildTransactionItem(tx);
                              },
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
  
  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    final user = Supabase.instance.client.auth.currentUser;
    final currentUserId = user?.id;
    
    final description = (tx['description'] ?? '').toString();
    final relatedType = (tx['related_type'] ?? '').toString().toLowerCase();
    final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
    final userId = tx['user_id']?.toString();
    final relatedId = tx['related_id']?.toString();
    final paymentMethod = (tx['payment_method'] ?? '').toString().toLowerCase();
    final status = (tx['status'] ?? 'completed').toString().toLowerCase();
    final createdAt = tx['created_at']?.toString() ?? '';
    
    // Determinar si es envío, recepción o pago con Stripe
    bool isSent = amount < 0; // débito (envío)
    bool isReceived = amount > 0; // crédito (recepción)
    bool isStripePayment = paymentMethod.contains('stripe') || paymentMethod.contains('card');
    
    // Determinar el tipo de transacción y obtener información del usuario
    String transactionType;
    String userInfo;
    IconData typeIcon;
    Color typeColor;
    
    if (isStripePayment) {
      transactionType = 'Pago con Tarjeta';
      userInfo = 'Agregado saldo con tarjeta';
      typeIcon = Icons.credit_card;
      typeColor = const Color(0xFF4DD0E1); // Turquesa
    } else if (isSent) {
      transactionType = 'Enviado';
      // Obtener nombre del receptor
      userInfo = 'Para: ${_getUserNameSync(relatedId)}';
      typeIcon = Icons.arrow_upward;
      typeColor = const Color(0xFFDC2626); // Rojo
    } else if (isReceived) {
      transactionType = 'Recibido';
      // Obtener nombre del emisor
      userInfo = 'De: ${_getUserNameSync(userId)}';
      typeIcon = Icons.arrow_downward;
      typeColor = const Color(0xFF4CAF50); // Verde
    } else {
      transactionType = 'Transacción';
      userInfo = 'Detalles de transacción';
      typeIcon = Icons.receipt_long;
      typeColor = Colors.white;
    }
    
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A), // NEGRO SUAVE LANDGO
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF37474F).withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono de tipo de transacción
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              typeIcon,
              color: typeColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // Información de la transacción
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transactionType,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  userInfo,
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
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
                    const SizedBox(width: 4),
                    Text(
                      status.toUpperCase(),
                      style: GoogleFonts.outfit(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Monto con color
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isSent ? '-' : '+'}\$${amount.abs().toStringAsFixed(2)}',
                style: GoogleFonts.outfit(
                  color: isSent ? const Color(0xFFDC2626) : const Color(0xFF4CAF50),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isSent ? 'Enviado' : 'Recibido',
                style: GoogleFonts.outfit(
                  color: isSent ? const Color(0xFFDC2626) : const Color(0xFF4CAF50),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
}
