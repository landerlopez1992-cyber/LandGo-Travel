import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/back_button_widget.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notifications_page_model.dart';
export 'notifications_page_model.dart';

class NotificationsPageWidget extends StatefulWidget {
  const NotificationsPageWidget({super.key});

  static String routeName = 'NotificationsPage';
  static String routePath = '/notificationsPage';

  @override
  State<NotificationsPageWidget> createState() => _NotificationsPageWidgetState();
}

class _NotificationsPageWidgetState extends State<NotificationsPageWidget> {
  late NotificationsPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NotificationsPageModel());

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
        backgroundColor: Color(0xFF000000),
        extendBodyBehindAppBar: false,
        extendBody: false,
        body: SafeArea(
          top: true,
          child: Column(
            children: [
              // Header Section
              _buildHeaderSection(),
              Expanded(
                child: _buildNotificationsList(),
              ),
              _buildBottomNavigation(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
                                  child: Column(
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
          
          // Título "Notification" centrado
          Center(
                                      child: Text(
              'Notification',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 28,
                                                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    final notifications = [
      {
        'title': 'Booking confirmed',
        'description': 'Your trip to Buckingham Palace on 21 May, 2024 is confirmed.',
        'timestamp': '30 seconds ago',
      },
      {
        'title': 'Upcoming trip reminder',
        'description': 'Don\'t forget your Venice Grand Canal Cruise on 15 May, 2024.',
        'timestamp': '30 seconds ago',
      },
      {
        'title': 'Message from support',
        'description': 'We\'ve confirmed the request for 1 wheelchair at Buckingham Palace',
        'timestamp': '30 seconds ago',
      },
      {
        'title': 'Tip for travelers',
        'description': 'Check out the best travel times for London in spring',
        'timestamp': '30 seconds ago',
      },
      {
        'title': 'Booking cancelled',
        'description': 'Your trip to Taj Mahal, India on 10 June, 2024 has been cancelled.',
        'timestamp': '30 seconds ago',
      },
    ];

    return ListView.builder(
                      padding: EdgeInsets.all(16.0),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(
          title: notification['title']!,
          description: notification['description']!,
          timestamp: notification['timestamp']!,
        );
      },
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String description,
    required String timestamp,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
                      padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
        color: Color(0xFF2C2C2C),
                            borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
            width: 40,
            height: 40,
                                  decoration: BoxDecoration(
              color: Color(0xFF424242),
                                    shape: BoxShape.circle,
                                  ),
            child: Icon(
              Icons.notifications,
              color: Colors.grey[300],
              size: 20,
            ),
          ),
          SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                  title,
                  style: GoogleFonts.outfit(
                            color: Colors.white,
                    fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                            ),
                                      ),
                SizedBox(height: 4),
                                      Text(
                  description,
                  style: GoogleFonts.outfit(
                    color: Colors.grey[300],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 8),
                                      Text(
                  timestamp,
                  style: GoogleFonts.outfit(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2C2C2C),
        border: Border(
          top: BorderSide(
            color: Color(0xFF333333),
            width: 0.5,
                            ),
                          ),
                        ),
      child: SafeArea(
        bottom: true,
                          child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
              GestureDetector(
                onTap: () {
                  context.pushNamed('MainPage');
                },
                child: _buildNavItem(Icons.home, 'Home', false),
              ),
              GestureDetector(
                onTap: () {
                  context.pushNamed('DiscoverPage');
                },
                child: _buildNavItem(Icons.explore, 'Discover', false),
              ),
              GestureDetector(
                onTap: () {
                  context.pushNamed('MyTripPage');
                },
                child: _buildNavItem(Icons.card_travel, 'My trip', false),
              ),
              GestureDetector(
                onTap: () {
                  context.pushNamed('MyFavoritesPage');
                },
                child: _buildNavItem(Icons.favorite_border, 'My favorites', false),
              ),
              GestureDetector(
                onTap: () {
                  context.pushNamed('ProfilePage');
                },
                child: _buildNavItem(Icons.person, 'Profile', false),
              ),
            ],
          ),
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
          width: 40,
          height: 40,
                                  decoration: BoxDecoration(
            color: isActive ? const Color(0xFF4DD0E1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.black : Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(height: 4),
                                      Text(
          label,
                                        style: TextStyle(
            color: isActive ? const Color(0xFF4DD0E1) : Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
                ),
              ),
            ],
    );
  }
}
