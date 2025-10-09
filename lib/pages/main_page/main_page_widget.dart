import '/flutter_flow/flutter_flow_util.dart';
import '/backend/supabase/supabase.dart';
import 'package:flutter/material.dart';
import 'main_page_model.dart';
export 'main_page_model.dart';

/// Modern travel app home screen with dark theme and vibrant accents
/// 
/// Features:
/// - Header with personalized greeting and profile picture
/// - Search bar for destinations
/// - Category filters (Adventure, Beach, Food & drink, Train)
/// - Recently viewed trips section
/// - Popular trips with filter tabs
/// - Top destinations showcase
/// - Modern bottom navigation
class MainPageWidget extends StatefulWidget {
  const MainPageWidget({super.key});

  static String routeName = 'MainPage';
  static String routePath = '/mainPage';

  @override
  State<MainPageWidget> createState() => _MainPageWidgetState();
}

class _MainPageWidgetState extends State<MainPageWidget> {
  late MainPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Variables para datos del usuario
  String _userName = 'User Name';
  String? _userAvatarUrl;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainPageModel());
    _loadUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  // Método para cargar datos del usuario desde Supabase
  Future<void> _loadUserData() async {
    try {
      final currentUser = SupaFlow.client.auth.currentUser;
      if (currentUser != null) {
        print('Current user ID: ${currentUser.id}');
        print('Current user email: ${currentUser.email}');
        
        // Primero verificar si existe el perfil
        final existingProfile = await SupaFlow.client
            .from('profiles')
            .select('id, full_name, email, avatar_url')
            .eq('id', currentUser.id)
            .maybeSingle();
            
        print('Existing profile: $existingProfile');
        
        // Si no existe el perfil, crearlo
        if (existingProfile == null) {
          print('Creating new profile for user');
          await SupaFlow.client
              .from('profiles')
              .insert({
                'id': currentUser.id,
                'email': currentUser.email,
                'full_name': 'User Name', // Nombre por defecto
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              });
        }
        
        // Obtener datos del usuario desde la tabla profiles
        final response = await SupaFlow.client
            .from('profiles')
            .select('full_name, email, avatar_url')
            .eq('id', currentUser.id)
            .single();
            
        print('Profile data from Supabase: $response');

        setState(() {
          // Usar full_name si existe y no está vacío, sino usar email como nombre
          final fullName = response['full_name'];
          print('Full name from database: "$fullName"');
          
          if (fullName != null && fullName.isNotEmpty && fullName.trim() != '') {
            _userName = fullName;
            print('Using full_name: $_userName');
          } else {
            // Si no hay full_name, usar el email como nombre
            final email = currentUser.email ?? 'user@example.com';
            _userName = email.split('@')[0]; // Tomar la parte antes del @
            print('Using email part as name: $_userName');
          }
          
          _userAvatarUrl = response['avatar_url'];
          print('Final user name: $_userName');
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      // En caso de error, usar datos del usuario autenticado
      final currentUser = SupaFlow.client.auth.currentUser;
      if (currentUser != null) {
        setState(() {
          _userName = 'User Name';
          // _userEmail = currentUser.email ?? 'user@example.com';
        });
      }
    }
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
        backgroundColor: Colors.black, // COLORES LANDGO TRAVEL - Fondo oscuro
        extendBody: false, // NO EXTENDER DEBAJO DEL BOTTOM NAV
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                // Header Section with greeting and profile
                _buildHeaderSection(),
                
                // Search Bar
                _buildSearchBar(),
                
                // Categories Section
                _buildCategoriesSection(),
                
                // Recently Viewed Section
                _buildRecentlyViewedSection(),
                
                // Popular Trips Section
                _buildPopularTripsSection(),
                
                // Top Destinations Section
                _buildTopDestinationsSection(),
                
                // Existing Grid of Buttons (Book Travel, Membership, Wallet, My Bookings)
                _buildExistingButtonsGrid(),
                
                // Legal Links Section
                _buildLegalLinksSection(),
                
                // Bottom spacing for navigation - AJUSTADO PARA EVITAR OVERFLOW
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        // Modern Bottom Navigation
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  // Header Section with personalized greeting and profile picture
  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
                                    children: [
          // Profile Picture
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF4DD0E1), width: 2),
            ),
            child: ClipOval(
              child: _userAvatarUrl != null && _userAvatarUrl!.isNotEmpty
                  ? Image.network(
                      _userAvatarUrl!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF2C2C2C),
                          child: Center(
                            child: Text(
                              _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: const Color(0xFF2C2C2C),
                      child: Center(
                        child: Text(
                          _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Greeting Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello,',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                                        ),
                                      ),
                Text(
                  '$_userName 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Notifications Icon
          GestureDetector(
            onTap: () {
              print('Notifications bell tapped from MainPage');
              context.pushNamed('NotificationsPage');
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Search Bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Container(
        height: 50,
                          decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
                              children: [
            const SizedBox(width: 16),
            Icon(
              Icons.search,
              color: Colors.white.withOpacity(0.6),
              size: 20,
            ),
            const SizedBox(width: 12),
                                Text(
              'Search here',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Categories Section (Adventure, Beach, Hotels, Flights)
  Widget _buildCategoriesSection() {
    final categories = [
      {'name': 'Adventure', 'icon': Icons.landscape, 'emoji': '🌴'},
      {'name': 'Beach', 'icon': Icons.beach_access, 'emoji': '🏖️'},
      {'name': 'Hotels', 'icon': Icons.hotel, 'emoji': '🏨'},
      {'name': 'Flights', 'icon': Icons.flight, 'emoji': '✈️'},
    ];

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // CENTRADO PERFECTO
        children: categories.map((category) {
          return Container(
            width: 80,
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      category['emoji'] as String,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category['name'] as String,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Recently Viewed Section
  Widget _buildRecentlyViewedSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
                                          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
          Text(
            'Recently viewed',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
                                              GestureDetector(
            onTap: () {
              print('Recently viewed card tapped: Azure wave island');
              context.pushNamed('ProductDetailPage');
            },
            child: Container(
            height: 120,
                                                decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Trip Image
                Container(
                  width: 120,
                  height: 120,
                                        decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1571896349842-33c89424de2d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTM5MzA2ODh8&ixlib=rb-4.1.0&q=80&w=1080'),
                      fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                Expanded(
                                        child: Padding(
                    padding: const EdgeInsets.all(16.0),
                                          child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                          'Azure wave island',
                          style: TextStyle(
                                                    color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.grey[400], size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Bali, Indonesia | ⭐ 4.2',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                                              Text(
                              '2 Person',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '\$45',
                              style: TextStyle(
                                color: const Color(0xFF4DD0E1),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                                                  child: Icon(
                    Icons.favorite_border,
                                          color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            ),
          ),
        ],
      ),
    );
  }

  // Popular Trips Section
  Widget _buildPopularTripsSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
                                          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                                              Text(
                'Popular trip',
                style: TextStyle(
                                                    color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                'View all',
                style: TextStyle(
                  color: const Color(0xFF4DD0E1),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Filter tabs
          Container(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterTab('All', true),
                _buildFilterTab('Adventure', false),
                _buildFilterTab('Beach', false),
                _buildFilterTab('Food &', false),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Trip cards
          Container(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildTripCard('Azure wave island', 'Bali, Indonesia', '4.2', '\$45', 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTM5MzA2ODh8&ixlib=rb-4.1.0&q=80&w=1080'),
                _buildTripCard('Everest base', 'Nepal', '4.2', '\$120', 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTM5MzA0ODV8&ixlib=rb-4.1.0&q=80&w=1080'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Top Destinations Section
  Widget _buildTopDestinationsSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
                                          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top destinations',
                style: TextStyle(
                                          color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                'View all',
                style: TextStyle(
                  color: const Color(0xFF4DD0E1),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Large destination card
                                              Container(
            height: 200,
                                                decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1506905925346-21bda4d32df4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTM5MzA0ODV8&ixlib=rb-4.1.0&q=80&w=1080'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                // Rating overlay
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                                              Text(
                          '4.2',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Heart icon
                Positioned(
                  top: 16,
                  right: 16,
                                      child: Container(
                    padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_border,
                                          color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                
                // Bottom info overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                                      colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                                          child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                          'Paris in a weekend',
                          style: TextStyle(
                                                          color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: const Color(0xFF4DD0E1), size: 16),
                            const SizedBox(width: 4),
                                              Text(
                              'Bali',
                              style: TextStyle(
                                                          color: Colors.white,
                                fontSize: 14,
                                                  ),
                                                ),
                            Container(
                              width: 1,
                              height: 16,
                                                  color: Colors.white,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                                              ),
                            Icon(Icons.person, color: const Color(0xFF4DD0E1), size: 16),
                            const SizedBox(width: 4),
                                              Text(
                              '2 Person',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '\$86',
                              style: TextStyle(
                                color: const Color(0xFF4DD0E1),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                
                // Floating action button
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    width: 48,
                    height: 48,
                                  decoration: BoxDecoration(
                      color: const Color(0xFF4DD0E1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.arrow_upward,
                      color: Colors.black,
                      size: 20,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Existing Grid of Buttons (Book Travel, Membership, Wallet, My Bookings)
  Widget _buildExistingButtonsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 400, // Máximo ancho para centrar en pantallas grandes
              ),
              child: GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildActionCard('Book Travel', Icons.flight_takeoff_rounded, const Color(0xFF4DD0E1), () {
                    context.pushNamed('BookingPage'); // CONECTAR A BOOKING PAGE
                  }),
                  _buildActionCard('Travel Feed', Icons.travel_explore_rounded, const Color(0xFF4DD0E1), () {
                    context.pushNamed('TravelFeedPage'); // CONECTAR A TRAVEL FEED
                  }),
                  _buildActionCard('Wallet', Icons.account_balance_wallet_rounded, const Color(0xFF4DD0E1), () {
                    context.pushNamed('MyWalletPage'); // CONECTAR A MY WALLET
                  }),
                  _buildActionCard('Memberships', Icons.card_membership_rounded, const Color(0xFF4DD0E1), () {
                    context.pushNamed('MembershipsPage'); // CONECTAR A MEMBERSHIPS
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  // Modern Bottom Navigation - EXACTAMENTE COMO MY PROFILE
  Widget _buildBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2C2C2C), // FONDO GRIS OSCURO COMO EN CAPTURA
        border: Border(
          top: BorderSide(
            color: Color(0xFF333333), // BORDE SUTIL GRIS
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        bottom: true, // RESPETA EL SAFE AREA DEL SISTEMA
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // PADDING BALANCEADO
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  // Stay on current page (Home)
                },
                child: _buildNavItem(Icons.home, 'Home', true), // HOME ACTIVO
              ),
              GestureDetector(
                onTap: () {
                  print('Discover button tapped from MainPage');
                  context.pushNamed('DiscoverPage');
                },
                child: _buildNavItem(Icons.explore, 'Discover', false),
              ),
              GestureDetector(
                onTap: () {
                  print('My trip button tapped from MainPage');
                  context.pushNamed('MyTripPage');
                },
                child: _buildNavItem(Icons.card_travel, 'My trip', false),
              ),
              GestureDetector(
                onTap: () {
                  print('My favorites button tapped from MainPage');
                  context.pushNamed('MyFavoritesPage');
                },
                child: _buildNavItem(Icons.favorite_border, 'My favorites', false),
              ),
              GestureDetector(
                onTap: () {
                  context.pushNamed('ProfilePage'); // CONECTAR A PROFILE (PANTALLA INTERMEDIA)
                },
                child: _buildNavItem(Icons.person, 'Profile', false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
  Widget _buildFilterTab(String text, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4DD0E1) : Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? Colors.black : Colors.white,
          fontSize: 14,
                                        fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTripCard(String title, String location, String rating, String price, String imageUrl) {
    return GestureDetector(
      onTap: () {
        print('Trip card tapped: $title');
        context.pushNamed('ProductDetailPage');
      },
      child: Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
                              children: [
          // Gradient overlay for text readability
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
          ),
          
          // Content
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
                              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 12),
                    const SizedBox(width: 4),
                                  Text(
                      rating,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Heart icon
          Positioned(
            top: 12,
            right: 12,
            child: Icon(
              Icons.favorite_border,
              color: Colors.white,
              size: 16,
                              ),
                            ),
                          ],
                        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
                              child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
                                children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                icon,
                color: Colors.black,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
                                  Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                                            fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
    );
  }

  // Legal Links Section
  Widget _buildLegalLinksSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        children: [
          // Divider
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.1),
            margin: const EdgeInsets.only(bottom: 20),
          ),
          
          // Legal Links Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegalLink('Privacy Policy', () {
                context.pushNamed('PrivacyPolicyPage');
              }),
              Container(
                width: 1,
                height: 16,
                color: Colors.white.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              _buildLegalLink('Terms & Conditions', () {
                context.pushNamed('TermsConditionsPage');
              }),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Copyright
          Text(
            '© 2024 LandGo Travel. All rights reserved.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Development Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4DD0E1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4DD0E1).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              'Platform in Active Development',
              style: TextStyle(
                color: const Color(0xFF4DD0E1),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalLink(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: const Color(0xFF4DD0E1),
          fontSize: 13,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
          decorationColor: const Color(0xFF4DD0E1).withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40, // TAMAÑO EXACTO BASADO EN CAPTURA MY PROFILE
          height: 40, // TAMAÑO EXACTO BASADO EN CAPTURA MY PROFILE
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF4DD0E1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8), // BORDES COMO EN CAPTURA
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.black : Colors.white, // COLORES CORRECTOS
            size: 22, // TAMAÑO EXACTO BASADO EN CAPTURA
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF4DD0E1) : Colors.white, // COLORES CORRECTOS
            fontSize: 11, // TAMAÑO EXACTO BASADO EN CAPTURA
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

}
