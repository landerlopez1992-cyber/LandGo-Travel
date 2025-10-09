import '/flutter_flow/flutter_flow_util.dart';
import '/components/back_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'my_referrals_page_model.dart';
export 'my_referrals_page_model.dart';

/// My Referrals Page - Shows all users referred by the current user
///
/// Features:
/// - Total referrals count
/// - Active/subscribed referrals count  
/// - List of referred users with:
///   * Profile picture
///   * Full name
///   * Membership type
///   * Join date
class MyReferralsPageWidget extends StatefulWidget {
  const MyReferralsPageWidget({super.key});

  static String routeName = 'MyReferralsPage';
  static String routePath = '/myReferralsPage';

  @override
  State<MyReferralsPageWidget> createState() => _MyReferralsPageWidgetState();
}

class _MyReferralsPageWidgetState extends State<MyReferralsPageWidget> {
  late MyReferralsPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Variables para datos de referidos
  bool _isLoading = true;
  int _totalReferrals = 0;
  int _activeReferrals = 0;
  List<Map<String, dynamic>> _referredUsers = [];
  String? _referralCode;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MyReferralsPageModel());
    _loadReferralData();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Cargar datos de referidos
  Future<void> _loadReferralData() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      print('🔍 DEBUG: Loading referral data for user: ${user.id}');

      // 1. Obtener el código de referido del usuario actual
      final profileResponse = await Supabase.instance.client
          .from('profiles')
          .select('referral_code')
          .eq('id', user.id)
          .single();

      _referralCode = profileResponse['referral_code'];
      print('🔍 DEBUG: User referral code: $_referralCode');

      // 2. Obtener todos los usuarios que usaron mi código de referido
      // Buscar en profiles donde referred_by = mi referral_code
      final referredUsersResponse = await Supabase.instance.client
          .from('profiles')
          .select('id, full_name, email, avatar_url, membership_type, created_at')
          .eq('referred_by', _referralCode ?? '')
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> allReferredUsers = 
          List<Map<String, dynamic>>.from(referredUsersResponse);

      print('🔍 DEBUG: Found ${allReferredUsers.length} referred users');

      // 3. Contar referidos activos (con membresía activa)
      int activeCount = 0;
      for (var user in allReferredUsers) {
        final membershipType = user['membership_type']?.toString() ?? 'free';
        if (membershipType != 'free' && membershipType.isNotEmpty) {
          activeCount++;
        }
      }

      if (mounted) {
        setState(() {
          _totalReferrals = allReferredUsers.length;
          _activeReferrals = activeCount;
          _referredUsers = allReferredUsers;
          _isLoading = false;
        });
      }

      print('✅ Referral data loaded successfully');
      print('   Total: $_totalReferrals, Active: $_activeReferrals');

    } catch (e) {
      print('❌ Error loading referral data: $e');
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
      backgroundColor: const Color(0xFF000000), // NEGRO COMPLETO LANDGO
      body: SafeArea(
        top: true,
        child: Column(
          children: [
            // Custom Header
            _buildCustomHeader(),
            
            const SizedBox(height: 10),
            
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'My Referrals',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Stats Cards
            if (!_isLoading) _buildStatsSection(),
            
            // Referrals List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4DD0E1), // TURQUESA LANDGO
                      ),
                    )
                  : _referredUsers.isEmpty
                      ? _buildEmptyState()
                      : _buildReferralsList(),
            ),
          ],
        ),
      ),
    );
  }

  // Custom Header
  Widget _buildCustomHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF000000), // NEGRO PURO IGUAL AL FONDO
        // Sin borde - limpio y minimalista
      ),
      child: Row(
        children: [
          // Back Button - ESTÁNDAR COMO PAYMENT METHODS
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
    );
  }

  // Stats Section
  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Referrals',
              _totalReferrals.toString(),
              Icons.people,
              const Color(0xFF4DD0E1), // TURQUESA LANDGO
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Active Members',
              _activeReferrals.toString(),
              Icons.verified_user,
              const Color(0xFF4CAF50), // VERDE ÉXITO
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF000000), // NEGRO PURO IGUAL AL FONDO
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
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

  // Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF4DD0E1).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline,
                color: Color(0xFF4DD0E1), // TURQUESA LANDGO
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Referrals Yet',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Share your referral code with friends and family to start earning rewards!',
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_referralCode != null && _referralCode!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF000000), // NEGRO PURO IGUAL AL FONDO
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4DD0E1).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Your Code: ',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _referralCode!,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF4DD0E1), // TURQUESA LANDGO
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Referrals List
  Widget _buildReferralsList() {
    return RefreshIndicator(
      onRefresh: _loadReferralData,
      color: const Color(0xFF4DD0E1), // TURQUESA LANDGO
      backgroundColor: const Color(0xFF000000), // NEGRO PURO
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: _referredUsers.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final referredUser = _referredUsers[index];
          return _buildReferralItem(referredUser);
        },
      ),
    );
  }

  // Referral Item
  Widget _buildReferralItem(Map<String, dynamic> user) {
    final fullName = user['full_name']?.toString() ?? 'Unknown User';
    final email = user['email']?.toString() ?? '';
    final avatarUrl = user['avatar_url']?.toString();
    final membershipType = user['membership_type']?.toString() ?? 'free';
    final createdAt = user['created_at']?.toString() ?? '';
    
    // Determinar si está activo (tiene membresía pagada)
    final isActive = membershipType != 'free' && membershipType.isNotEmpty;
    
    // Formatear membership type
    String displayMembership = 'Free';
    Color membershipColor = Colors.white54;
    
    if (membershipType.toLowerCase().contains('basic')) {
      displayMembership = 'Basic - \$29/mo';
      membershipColor = const Color(0xFF4DD0E1); // TURQUESA
    } else if (membershipType.toLowerCase().contains('premium')) {
      displayMembership = 'Premium - \$49/mo';
      membershipColor = const Color(0xFF4CAF50); // VERDE
    } else if (membershipType.toLowerCase().contains('vip')) {
      displayMembership = 'VIP - \$79/mo';
      membershipColor = const Color(0xFFFF9800); // NARANJA
    }
    
    // Formatear fecha
    String formattedDate = 'Recently';
    try {
      if (createdAt.isNotEmpty) {
        final date = DateTime.parse(createdAt);
        final now = DateTime.now();
        final difference = now.difference(date);
        
        if (difference.inDays > 30) {
          formattedDate = 'Joined ${(difference.inDays / 30).floor()} months ago';
        } else if (difference.inDays > 0) {
          formattedDate = 'Joined ${difference.inDays} days ago';
        } else if (difference.inHours > 0) {
          formattedDate = 'Joined ${difference.inHours} hours ago';
        } else {
          formattedDate = 'Joined recently';
        }
      }
    } catch (e) {
      print('Error parsing date: $e');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF000000), // NEGRO PURO IGUAL AL FONDO
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF37474F).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive 
                    ? const Color(0xFF4DD0E1) 
                    : Colors.white24,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: avatarUrl != null && avatarUrl.isNotEmpty
                  ? Image.network(
                      avatarUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildAvatarPlaceholder(fullName);
                      },
                    )
                  : _buildAvatarPlaceholder(fullName),
            ),
          ),
          const SizedBox(width: 16),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        fullName,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF4CAF50),
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Active',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF4CAF50),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: GoogleFonts.outfit(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.card_membership,
                      color: membershipColor,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      displayMembership,
                      style: GoogleFonts.outfit(
                        color: membershipColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Colors.white54,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formattedDate,
                      style: GoogleFonts.outfit(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Avatar Placeholder
  Widget _buildAvatarPlaceholder(String name) {
    return Container(
      color: const Color(0xFF37474F), // GRIS AZULADO LANDGO
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

