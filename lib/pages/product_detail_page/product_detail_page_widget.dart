import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'product_detail_page_model.dart';
export 'product_detail_page_model.dart';

class ProductDetailPageWidget extends StatefulWidget {
  const ProductDetailPageWidget({super.key});

  static String routeName = 'ProductDetailPage';
  static String routePath = '/productDetailPage';

  @override
  State<ProductDetailPageWidget> createState() => _ProductDetailPageWidgetState();
}

class _ProductDetailPageWidgetState extends State<ProductDetailPageWidget> {
  late ProductDetailPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProductDetailPageModel());

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
        body: Stack(
          children: [
            // Imagen de fondo principal
            _buildHeroImage(),
            
            // Botones superiores
            _buildTopButtons(),
            
            // Contenido principal
            _buildMainContent(),
            
            // Botón flotante Book now
            _buildFloatingButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4DD0E1), // Turquesa LandGo
            Color(0xFF37474F), // Gris azulado LandGo
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=600&fit=crop'),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    print('Error loading image: $exception');
                  },
                ),
              ),
            ),
          ),
          // Dark overlay for text readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
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
          ),
          // Trip information overlay
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location and rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Bali, Indonesia',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.yellow,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '4.2',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // Trip title
                Text(
                  'Azure wave island escape',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                // Price
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'From ',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: '\$45',
                        style: GoogleFonts.outfit(
                          color: Color(0xFF4DD0E1),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: '/per person',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopButtons() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón de regreso
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          // Botón de favoritos
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.favorite_border,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                // TODO: Add to favorites
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.35,
        decoration: BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // About this trip
              _buildAboutSection(),
              SizedBox(height: 18),
              
              // Gallery
              _buildGallerySection(),
              SizedBox(height: 100), // Espacio para el botón flotante
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About this trip',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Experience the ultimate tropical getaway with pristine azure waters and stunning island views. Perfect for couples and families seeking relaxation and adventure.',
          style: GoogleFonts.outfit(
            color: Colors.grey[300],
            fontSize: 14,
            height: 1.4,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Read more',
          style: GoogleFonts.outfit(
            color: Color(0xFF4DD0E1),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildGallerySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Gallery',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'View all',
              style: GoogleFonts.outfit(
                color: Color(0xFF4DD0E1),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            _buildGalleryImage('https://images.unsplash.com/photo-1571896349842-33c89424de2d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTM5MzA2ODh8&ixlib=rb-4.1.0&q=80&w=1080'),
            SizedBox(width: 12),
            _buildGalleryImage('https://images.unsplash.com/photo-1506905925346-21bda4d32df4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTM5MzA0ODV8&ixlib=rb-4.1.0&q=80&w=1080'),
            SizedBox(width: 12),
            _buildGalleryImage('https://images.unsplash.com/photo-1544551763-46a013bb70d5?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTM5MzA0ODV8&ixlib=rb-4.1.0&q=80&w=1080'),
          ],
        ),
      ],
    );
  }

  Widget _buildGalleryImage(String imagePath) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }


  Widget _buildFloatingButton() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: Color(0xFF4DD0E1),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: () {
              // TODO: Navigate to booking
              print('Book now tapped');
            },
            child: Center(
              child: Text(
                'Book now',
                style: GoogleFonts.outfit(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
