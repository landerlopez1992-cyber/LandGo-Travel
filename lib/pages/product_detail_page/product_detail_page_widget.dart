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
        image: DecorationImage(
          image: AssetImage('assets/images/94706-maldivas-portada-.jpeg'),
          fit: BoxFit.cover,
        ),
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
        height: MediaQuery.of(context).size.height * 0.5,
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
              // Ubicación y calificación
              _buildLocationAndRating(),
              SizedBox(height: 16),
              
              // Título del viaje
              _buildTripTitle(),
              SizedBox(height: 8),
              
              // Precio
              _buildPrice(),
              SizedBox(height: 24),
              
              // About this trip
              _buildAboutSection(),
              SizedBox(height: 24),
              
              // Gallery
              _buildGallerySection(),
              SizedBox(height: 100), // Espacio para el botón flotante
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationAndRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Ubicación
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
        // Calificación
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
    );
  }

  Widget _buildTripTitle() {
    return Text(
      'Azure wave island escape',
      style: GoogleFonts.outfit(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPrice() {
    return RichText(
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
        SizedBox(height: 12),
        Text(
          '"Azure wave island escape" likely refers to a vacation experience, potentially at a specific location known for its azure-colored waters and island setting. This could be a resort, hotel, or travel package that offers guests the opportunity to experience a tropical island getaway with pristine blue waters...',
          style: GoogleFonts.outfit(
            color: Colors.grey[300],
            fontSize: 14,
            height: 1.5,
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
            _buildGalleryImage('assets/images/istockphoto-475903022-612x612.jpg'),
            SizedBox(width: 12),
            _buildGalleryImage('assets/images/94706-maldivas-portada-.jpeg'),
            SizedBox(width: 12),
            _buildGalleryImage('assets/images/soneva-jani-resort-1506453329.jpg'),
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
          image: AssetImage(imagePath),
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
