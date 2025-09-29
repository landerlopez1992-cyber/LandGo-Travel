import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/back_button_widget.dart';
import 'my_wallet_page_model.dart';
export 'my_wallet_page_model.dart';

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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MyWalletPageModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
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
                        onPressed: () => Navigator.of(context).pop(),
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
          Text(
            '\$0.00',
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
                onTap: () {
                  context.pushNamed('TransferMoneyPage');
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
            '\$0',
            'Total Earned',
            Icons.trending_up,
            const Color(0xFF4DD0E1), // TURQUESA
          ),
          _buildStatCard(
            '\$0',
            'Total Saved',
            Icons.savings,
            const Color(0xFF4DD0E1), // TURQUESA  
          ),
          _buildStatCard(
            '0',
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
            Text(
              'View All',
              style: GoogleFonts.outfit(
                color: const Color(0xFF4DD0E1), // TURQUESA LANDGO
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
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
        ),
      ],
    );
  }


  void _showAddMoneyModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6, // REDUCIDO A 60% PARA SUBIR EL MODAL
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
              
              const SizedBox(height: 20),
              
              // Amount Input
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: '0.00',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontSize: 24,
                      color: Colors.grey,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Payment Methods
              _buildPaymentMethod(
                'Debit/Credit Card',
                'Visa, Mastercard, American Express',
                Icons.credit_card,
                true, // SELECTED
              ),
              
              const SizedBox(height: 16),
              
              _buildPaymentMethod(
                'Apple Pay',
                'Quick and secure payment',
                Icons.apple,
                false,
              ),
              
              const SizedBox(height: 40), // ESPACIO FIJO EN LUGAR DE SPACER
              
              // Add Money Button
              Container(
                width: double.infinity,
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
                      Navigator.pop(context);
                      // TODO: Process payment
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
              
              const SizedBox(height: 10), // REDUCIDO PARA SUBIR EL BOTÓN
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(String title, String subtitle, IconData icon, bool isSelected) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF4DD0E1) : Colors.white,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF4DD0E1) : Colors.white,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            const Icon(
              Icons.check_circle,
              color: Color(0xFF4DD0E1), // TURQUESA CHECK
              size: 24,
            ),
        ],
      ),
    );
  }
}
