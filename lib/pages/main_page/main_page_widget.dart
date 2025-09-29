import '/flutter_flow/flutter_flow_util.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/auth/supabase_auth/supabase_user_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainPageModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
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
                
                // Existing Special Offer Banner
                _buildSpecialOfferBanner(),
                
                // Bottom spacing for navigation - AUMENTADO PARA BOTONES ANDROID
                const SizedBox(height: 120),
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
                                              child: Image.network(
                                                'https://images.unsplash.com/photo-1519058082700-08a0b56da9b4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTM5MzA0ODV8&ixlib=rb-4.1.0&q=80&w=1080',
                                                fit: BoxFit.cover,
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
                  '${(currentUser as LandGoTravelSupabaseUser?)?.user?.userMetadata?['full_name'] ?? 'Dev Cooper'} 👋',
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
          Container(
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

  // Categories Section (Adventure, Beach, Food & drink, Train)
  Widget _buildCategoriesSection() {
    final categories = [
      {'name': 'Adventure', 'icon': Icons.landscape, 'emoji': '🌴'},
      {'name': 'Beach', 'icon': Icons.beach_access, 'emoji': '🏖️'},
      {'name': 'Food & drink', 'icon': Icons.restaurant, 'emoji': '🍔🥤'},
      {'name': 'Train', 'icon': Icons.train, 'emoji': '🚆'},
    ];

    return Container(
      height: 120,
      margin: const EdgeInsets.only(top: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 16),
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
                ),
              ],
            ),
          );
        },
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
                                              Container(
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
      padding: const EdgeInsets.all(20.0),
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
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildActionCard('Book Travel', Icons.flight_takeoff_rounded, const Color(0xFF4DD0E1), () {
                // Navigate to booking
              }),
              _buildActionCard('Membership', Icons.military_tech_rounded, const Color(0xFF4DD0E1), () {
                // Navigate to membership
              }),
              _buildActionCard('Wallet', Icons.account_balance_wallet_rounded, const Color(0xFF4DD0E1), () {
                // Navigate to wallet
              }),
              _buildActionCard('My Bookings', Icons.calendar_month_rounded, const Color(0xFF4DD0E1), () {
                // Navigate to bookings
              }),
            ],
          ),
        ],
      ),
    );
  }

  // Existing Special Offer Banner
  Widget _buildSpecialOfferBanner() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF4DD0E1), const Color(0xFF26C6DA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
          padding: const EdgeInsets.all(20.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Special Offer!',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                                              Text(
                                                'Get 20% off your next booking',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                                                  color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Claim Now',
                        style: TextStyle(
                          color: const Color(0xFF4DD0E1),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.local_offer_rounded,
                color: Colors.white,
                size: 48,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
    );
  }

  // Modern Bottom Navigation
  Widget _buildBottomNavigation() {
    return Container(
      height: 100, // AUMENTADO MÁS PARA ESTAR ARRIBA DE BOTONES ANDROID
      decoration: const BoxDecoration(
        color: Color(0xFF000000), // FONDO NEGRO LANDGO TRAVEL
        border: Border(
          top: BorderSide(
            color: Color(0xFF333333), // BORDE SUTIL GRIS
            width: 0.5,
                            ),
                          ),
                        ),
      child: SafeArea(
        bottom: true, // IMPORTANTE: RESPETA EL SAFE AREA DEL SISTEMA
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 20.0), // MÁS PADDING INFERIOR
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
                  // TODO: Navigate to Discover when page exists
                },
                child: _buildNavItem(Icons.explore, 'Discover', false),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Navigate to My trip when page exists
                },
                child: _buildNavItem(Icons.card_travel, 'My trip', false),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Navigate to My favorites when page exists
                },
                child: _buildNavItem(Icons.favorite_border, 'My favorites', false),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Navigate to Profile when page exists
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
    return Container(
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

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
                                children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF4DD0E1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.black : Colors.grey[400],
            size: 22,
          ),
        ),
        const SizedBox(height: 4),
                                  Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF4DD0E1) : Colors.grey[400],
            fontSize: 12,
                                            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

}
