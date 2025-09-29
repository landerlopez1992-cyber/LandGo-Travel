import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/back_button_widget.dart';
import '/backend/supabase/supabase.dart';
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
    final amount = double.tryParse(_model.amountController.text) ?? 0;
    final isValid = amount > 0 && _model.selectedUser != null;

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
    // TODO: Implementar lógica de transferencia con Supabase
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Transfer functionality coming soon!',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF4DD0E1), // TURQUESA
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
