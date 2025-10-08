import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'support_chat_page_model.dart';
export 'support_chat_page_model.dart';

/// 🤖 Automated Support Chat Page for LandGo Travel
/// 
/// Features:
/// - Intelligent bot with menu options
/// - Automatic user detection
/// - Auto-query bookings, transactions, wallet
/// - Escalate to human agent when needed
class SupportChatPageWidget extends StatefulWidget {
  const SupportChatPageWidget({super.key});

  static String routeName = 'SupportChatPage';
  static String routePath = '/supportChatPage';

  @override
  State<SupportChatPageWidget> createState() => _SupportChatPageWidgetState();
}

class _SupportChatPageWidgetState extends State<SupportChatPageWidget> {
  late SupportChatPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  // Estado del chat
  String? _conversationId;
  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> _currentOptions = [];
  bool _isLoading = true;
  bool _waitingForInput = false;
  String? _waitingForDataType;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SupportChatPageModel());
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    
    _initializeChat();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 🚀 INICIALIZAR CHAT
  Future<void> _initializeChat() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        print('❌ Usuario no autenticado');
        return;
      }

      // Verificar si hay conversación activa
      final existingConversation = await Supabase.instance.client
          .from('support_conversations')
          .select()
          .eq('user_id', user.id)
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (existingConversation != null) {
        // Continuar conversación existente
        _conversationId = existingConversation['id'];
        await _loadMessages();
      } else {
        // Crear nueva conversación
        await _createNewConversation();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error inicializando chat: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 📝 CREAR NUEVA CONVERSACIÓN
  Future<void> _createNewConversation() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Crear conversación
      final conversation = await Supabase.instance.client
          .from('support_conversations')
          .insert({
            'user_id': user.id,
            'status': 'active',
            'is_automated': true,
          })
          .select()
          .single();

      _conversationId = conversation['id'];

      // Mensaje de bienvenida del bot
      await _addBotMessage(
        '👋 Welcome to LandGo Travel Support!\n\nI\'m your virtual assistant. I can help you with bookings, payments, account issues, and more.\n\nHow can I help you today?',
        messageType: 'text',
      );

      // Cargar opciones principales
      await _loadMainMenuOptions();
      await _loadMessages();
    } catch (e) {
      print('❌ Error creando conversación: $e');
    }
  }

  /// 📋 CARGAR OPCIONES DEL MENÚ PRINCIPAL
  Future<void> _loadMainMenuOptions() async {
    try {
      final options = await Supabase.instance.client
          .from('support_bot_options')
          .select()
          .isFilter('parent_option_id', null)
          .eq('is_active', true)
          .order('order_index');

      setState(() {
        _currentOptions = List<Map<String, dynamic>>.from(options);
      });
    } catch (e) {
      print('❌ Error cargando opciones: $e');
    }
  }

  /// 📋 CARGAR SUB-OPCIONES
  Future<void> _loadSubOptions(String parentOptionId) async {
    try {
      final options = await Supabase.instance.client
          .from('support_bot_options')
          .select()
          .eq('parent_option_id', parentOptionId)
          .eq('is_active', true)
          .order('order_index');

      setState(() {
        _currentOptions = List<Map<String, dynamic>>.from(options);
      });
    } catch (e) {
      print('❌ Error cargando sub-opciones: $e');
    }
  }

  /// 💬 CARGAR MENSAJES
  Future<void> _loadMessages() async {
    try {
      if (_conversationId == null) return;

      final messages = await Supabase.instance.client
          .from('support_messages')
          .select()
          .eq('conversation_id', _conversationId!)
          .order('created_at');

      setState(() {
        _messages = List<Map<String, dynamic>>.from(messages);
      });

      _scrollToBottom();
    } catch (e) {
      print('❌ Error cargando mensajes: $e');
    }
  }

  /// 🤖 AGREGAR MENSAJE DEL BOT
  Future<void> _addBotMessage(String text, {String messageType = 'text', Map<String, dynamic>? metadata}) async {
    try {
      if (_conversationId == null) return;

      await Supabase.instance.client
          .from('support_messages')
          .insert({
            'conversation_id': _conversationId,
            'sender_type': 'bot',
            'message_text': text,
            'message_type': messageType,
            'metadata': metadata,
          });

      await _loadMessages();
    } catch (e) {
      print('❌ Error agregando mensaje del bot: $e');
    }
  }

  /// 👤 AGREGAR MENSAJE DEL USUARIO
  Future<void> _addUserMessage(String text) async {
    try {
      if (_conversationId == null) return;

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      await Supabase.instance.client
          .from('support_messages')
          .insert({
            'conversation_id': _conversationId,
            'sender_type': 'user',
            'sender_id': user.id,
            'message_text': text,
            'message_type': 'text',
          });

      await _loadMessages();
    } catch (e) {
      print('❌ Error agregando mensaje del usuario: $e');
    }
  }

  /// 🎯 MANEJAR SELECCIÓN DE OPCIÓN
  Future<void> _handleOptionSelected(Map<String, dynamic> option) async {
    final optionText = option['option_text'] ?? '';
    final optionKey = option['option_key'] ?? '';
    final actionType = option['action_type'];
    final requiresData = option['requires_data'] ?? false;
    final dataType = option['data_type'];

    // Agregar mensaje del usuario con la opción seleccionada
    await _addUserMessage(optionText);

    // Ejecutar acción según el tipo
    if (actionType == 'show_options') {
      // Cargar sub-opciones
      await _loadSubOptions(option['id']);
    } else if (actionType == 'check_booking' && requiresData) {
      // Solicitar booking ID
      await _addBotMessage('Please provide your booking reference number (e.g., LG2024-123456):');
      setState(() {
        _waitingForInput = true;
        _waitingForDataType = dataType;
        _currentOptions = [];
      });
    } else if (actionType == 'check_wallet') {
      // Consultar wallet automáticamente
      await _checkWallet(optionKey);
    } else if (actionType == 'escalate') {
      // Escalar a agente humano
      await _escalateToAgent();
    } else if (actionType == 'resolve') {
      // Resolver con información
      await _provideInformation(optionKey);
    }
  }

  /// 💰 CONSULTAR WALLET
  Future<void> _checkWallet(String optionKey) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      if (optionKey == 'wallet_check_balance') {
        // Obtener saldo
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('wallet_balance')
            .eq('id', user.id)
            .single();

        final balance = profile['wallet_balance'] ?? 0.0;

        await _addBotMessage(
          '💵 Your Current Balance:\n\n\$${balance.toStringAsFixed(2)} USD\n\nIs there anything else I can help you with?'
        );
      } else if (optionKey == 'wallet_transaction_history') {
        // Obtener últimas transacciones
        final transactions = await Supabase.instance.client
            .from('payments')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: false)
            .limit(5);

        String transactionText = '📊 Your Recent Transactions:\n\n';
        
        if (transactions.isEmpty) {
          transactionText += 'No transactions found.';
        } else {
          for (var tx in transactions) {
            final amount = tx['amount'] ?? 0.0;
            final type = tx['type'] ?? 'unknown';
            final date = tx['created_at'];
            transactionText += '• \$${amount.toStringAsFixed(2)} - $type\n  ${_formatDate(date)}\n\n';
          }
        }

        transactionText += 'Need help with any transaction?';
        await _addBotMessage(transactionText);
      }

      await _loadMainMenuOptions();
    } catch (e) {
      print('❌ Error consultando wallet: $e');
      await _addBotMessage('Sorry, I couldn\'t retrieve your wallet information. Please try again or speak to an agent.');
      await _loadMainMenuOptions();
    }
  }

  /// 📋 CONSULTAR BOOKING
  Future<void> _checkBooking(String bookingId) async {
    try {
      // Aquí consultarías tu tabla de bookings
      // Por ahora, mensaje de ejemplo
      await _addBotMessage(
        '✅ I found your booking!\n\n'
        '📋 Booking Details:\n'
        '- Reference: $bookingId\n'
        '- Status: Confirmed\n\n'
        'What would you like to do with this booking?'
      );

      // Mostrar opciones específicas para este booking
      setState(() {
        _currentOptions = [
          {'option_text': '❌ Cancel Booking', 'action_type': 'escalate'},
          {'option_text': '🔄 Modify Booking', 'action_type': 'escalate'},
          {'option_text': '📧 Resend Confirmation', 'action_type': 'resolve'},
          {'option_text': '🏠 Main Menu', 'action_type': 'main_menu'},
        ];
      });
    } catch (e) {
      print('❌ Error consultando booking: $e');
      await _addBotMessage('Sorry, I couldn\'t find a booking with that reference. Please check the number and try again, or speak to an agent.');
      await _loadMainMenuOptions();
    }
  }

  /// 📧 PROVEER INFORMACIÓN
  Future<void> _provideInformation(String optionKey) async {
    String infoText = '';

    if (optionKey == 'wallet_add_funds') {
      infoText = '➕ How to Add Funds to Your Wallet:\n\n'
          '1. Go to "My Wallet" in the app\n'
          '2. Tap "Add Funds"\n'
          '3. Choose your payment method:\n'
          '   • Credit/Debit Card\n'
          '   • Google Pay\n'
          '   • Apple Pay\n'
          '4. Enter the amount\n'
          '5. Confirm payment\n\n'
          'Funds are added instantly! 💳';
    } else if (optionKey == 'account_reset_password') {
      infoText = '🔑 Reset Your Password:\n\n'
          '1. Go to Login screen\n'
          '2. Tap "Forgot Password?"\n'
          '3. Enter your email\n'
          '4. Check your email for reset link\n'
          '5. Click link and create new password\n\n'
          'Need more help?';
    }

    await _addBotMessage(infoText);
    await _loadMainMenuOptions();
  }

  /// 👨‍💼 ESCALAR A AGENTE
  Future<void> _escalateToAgent() async {
    try {
      if (_conversationId == null) return;

      // Actualizar conversación a escalated
      await Supabase.instance.client
          .from('support_conversations')
          .update({
            'status': 'escalated',
            'is_automated': false,
          })
          .eq('id', _conversationId!);

      await _addBotMessage(
        '👨‍💼 Connecting you to a human agent...\n\n'
        'A support representative will be with you shortly. '
        'Average wait time: 2-5 minutes.\n\n'
        'Thank you for your patience!'
      );

      setState(() {
        _currentOptions = [];
      });
    } catch (e) {
      print('❌ Error escalando a agente: $e');
    }
  }

  /// 📤 ENVIAR MENSAJE
  Future<void> _sendMessage() async {
    final text = _model.textController.text.trim();
    if (text.isEmpty) return;

    await _addUserMessage(text);
    _model.textController?.clear();

    // Si estamos esperando input del usuario
    if (_waitingForInput) {
      if (_waitingForDataType == 'booking_id') {
        await _checkBooking(text);
      } else if (_waitingForDataType == 'transaction_id') {
        // Consultar transacción
        await _addBotMessage('Let me check that transaction for you...');
        await Future.delayed(Duration(seconds: 1));
        await _addBotMessage('Transaction found! How can I help you with this?');
        await _loadMainMenuOptions();
      }

      setState(() {
        _waitingForInput = false;
        _waitingForDataType = null;
      });
    }
  }

  /// 📅 FORMATEAR FECHA
  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  /// 📜 SCROLL AL FINAL
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
        backgroundColor: Color(0xFF1A1A1A), // ✅ FONDO NEGRO LANDGO
        appBar: AppBar(
          backgroundColor: Color(0xFF1A1A1A), // ✅ NEGRO
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: EdgeInsets.only(left: 8.0), // ✅ POSICIÓN ESTÁNDAR
            child: FlutterFlowIconButton(
              borderColor: Colors.transparent,
              borderRadius: 12.0,
              borderWidth: 0,
              buttonSize: 40.0,
              fillColor: Color(0xFF2C2C2C), // ✅ GRIS OSCURO
              icon: Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF4DD0E1), // ✅ TURQUESA
                size: 24.0,
              ),
              onPressed: () {
                context.pop();
              },
            ),
          ),
          title: Text(
            'Customer Support',
            style: GoogleFonts.interTight(
              color: Colors.white, // ✅ BLANCO
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // MENSAJES
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF4DD0E1), // ✅ TURQUESA
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isBot = message['sender_type'] == 'bot';
                          final text = message['message_text'] ?? '';
                          final timestamp = _formatDate(message['created_at']);

                          return Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Row(
                              mainAxisAlignment: isBot
                                  ? MainAxisAlignment.start
                                  : MainAxisAlignment.end,
                              children: [
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isBot 
                                        ? Color(0xFF2C2C2C) // ✅ GRIS OSCURO PARA BOT
                                        : Color(0xFF4DD0E1), // ✅ TURQUESA PARA USER
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Color(0xFF4DD0E1), // ✅ BORDE TURQUESA
                                      width: 1,
                                    ),
                                  ),
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: isBot
                                        ? CrossAxisAlignment.start
                                        : CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        text,
                                        style: GoogleFonts.inter(
                                          color: isBot 
                                              ? Colors.white // ✅ BLANCO PARA BOT
                                              : Colors.black, // ✅ NEGRO PARA USER
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        timestamp,
                                        style: GoogleFonts.inter(
                                          color: isBot 
                                              ? Colors.white70 // ✅ BLANCO 70% PARA BOT
                                              : Colors.black54, // ✅ NEGRO 54% PARA USER
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              // OPCIONES (BOTONES)
              if (_currentOptions.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF2C2C2C), // ✅ GRIS OSCURO
                    border: Border(
                      top: BorderSide(color: Color(0xFF4DD0E1)), // ✅ BORDE TURQUESA
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _currentOptions.map((option) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: ElevatedButton(
                          onPressed: () => _handleOptionSelected(option),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4DD0E1), // ✅ TURQUESA
                            foregroundColor: Colors.black, // ✅ NEGRO
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            option['option_text'] ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // INPUT DE MENSAJE
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF2C2C2C), // ✅ GRIS OSCURO
                    border: Border.all(color: Color(0xFF4DD0E1)), // ✅ BORDE TURQUESA
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _model.textController,
                            focusNode: _model.textFieldFocusNode,
                            autofocus: false,
                            textInputAction: TextInputAction.send,
                            onFieldSubmitted: (_) => _sendMessage(),
                            decoration: InputDecoration(
                              hintText: 'Type your message...',
                              hintStyle: GoogleFonts.inter(
                                color: Colors.white54, // ✅ BLANCO 54%
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16),
                            ),
                            style: GoogleFonts.inter(
                              color: Colors.white, // ✅ BLANCO
                            ),
                            maxLines: 3,
                            minLines: 1,
                          ),
                        ),
                        FlutterFlowIconButton(
                          borderRadius: 24.0,
                          buttonSize: 48.0,
                          fillColor: Color(0xFF4DD0E1), // ✅ TURQUESA
                          icon: Icon(
                            Icons.send_rounded,
                            color: Colors.black, // ✅ NEGRO
                            size: 20.0,
                          ),
                          onPressed: _sendMessage,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}