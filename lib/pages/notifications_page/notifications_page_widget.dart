import '/flutter_flow/flutter_flow_util.dart';
import '/auth/supabase_auth/auth_util.dart';
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
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Color(0xFF000000), // Fondo negro
      appBar: AppBar(
        backgroundColor: Color(0xFF000000),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Botón de retroceso
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xFFFFFFFF),
                  size: 20.0,
                ),
              ),
            ),
            SizedBox(width: 16.0),
            // Título
            Text(
              'Notification',
              style: GoogleFonts.inter(
                color: Color(0xFFFFFFFF),
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        top: true,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 24.0),
          child: ListView(
            children: [
              // Notification 1
              _buildNotificationCard(
                'Booking confirmed',
                'Your trip to Buckingham Palace on 21 May, 2024 is confirmed.',
                '30 seconds ago',
              ),
              SizedBox(height: 16.0),
              
              // Notification 2
              _buildNotificationCard(
                'Upcoming trip reminder',
                'Don\'t forget your Venice Grand Canal Cruise on 15 May, 2024.',
                '2 minutes ago',
              ),
              SizedBox(height: 16.0),
              
              // Notification 3
              _buildNotificationCard(
                'Message from support',
                'We\'ve confirmed the request for 1 wheelchair at Buckingham Palace',
                '5 minutes ago',
              ),
              SizedBox(height: 16.0),
              
              // Notification 4
              _buildNotificationCard(
                'Tip for travelers',
                'Check out our new travel tips for your upcoming trip to Venice.',
                '1 hour ago',
              ),
              SizedBox(height: 16.0),
              
              // Notification 5
              _buildNotificationCard(
                'Booking cancelled',
                'Your booking for Paris trip on 10 May has been cancelled due to weather conditions.',
                '2 hours ago',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(String title, String description, String time) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono de campana
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: Color(0xFF404040),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: Color(0xFFFFFFFF),
                size: 20.0,
              ),
            ),
            SizedBox(width: 16.0),
            
            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: Color(0xFFFFFFFF),
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  
                  // Descripción
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      color: Color(0xFFAAAAAA),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  
                  // Tiempo
                  Text(
                    time,
                    style: GoogleFonts.inter(
                      color: Color(0xFFAAAAAA),
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
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
}
