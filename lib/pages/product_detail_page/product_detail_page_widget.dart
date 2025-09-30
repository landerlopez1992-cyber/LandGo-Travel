import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'product_detail_page_model.dart';
export 'product_detail_page_model.dart';

class ProductDetailPageWidget extends StatefulWidget {
  const ProductDetailPageWidget({super.key});

  static String routeName = 'ProductDetailPage';
  static String routePath = '/productDetail';

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
            // Imagen principal de fondo
            _buildHeroImage(),
            
            // Botones superiores
            _buildTopButtons(),
            
            // Contenido principal (curtina)
            _buildMainContent(),
            
            // Botón flotante de reserva
            _buildFloatingButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=1200&fit=crop&q=80'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Información sobre la imagen
              Positioned(
                left: 20,
                right: 20,
                bottom: 200, // Posicionado sobre la curtina
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ubicación
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Color(0xFF4CAF50),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Bali, Indonesia',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    
                    // Rating
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Color(0xFFFFD700),
                          size: 20,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '4.8',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '(124 reviews)',
                          style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    
                    // Título del viaje
                    Text(
                      'Azure Wave Island Escape',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    
                    // Precio
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
                              fontSize: 24,
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
              onPressed: () {},
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
        height: MediaQuery.of(context).size.height * 0.4, // 40% de la pantalla
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle de la curtina
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 20),
              
              // Sección About this trip
              _buildAboutSection(),
              SizedBox(height: 30),
              
              // Sección Gallery
              _buildGallerySection(),
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
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Experience the ultimate tropical getaway at Azure Wave Island Escape. This stunning destination offers pristine beaches, crystal-clear waters, and breathtaking sunsets that will leave you speechless.',
          style: GoogleFonts.outfit(
            color: Color(0xFF6B7280),
            fontSize: 16,
            height: 1.5,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'What\'s included:',
          style: GoogleFonts.outfit(
            color: Color(0xFF1F2937),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        _buildIncludedItem('✓ Airport transfers'),
        _buildIncludedItem('✓ 3 nights accommodation'),
        _buildIncludedItem('✓ Daily breakfast'),
        _buildIncludedItem('✓ Island hopping tour'),
        _buildIncludedItem('✓ Snorkeling equipment'),
      ],
    );
  }

  Widget _buildIncludedItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          color: Color(0xFF6B7280),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildGallerySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gallery',
          style: GoogleFonts.outfit(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                width: 120,
                margin: EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-${1506905925346 + index}?w=300&h=300&fit=crop&q=80'),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingButton() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Color(0xFF4DD0E1),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF4DD0E1).withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () {
              // TODO: Implementar lógica de reserva
              print('Book now pressed');
            },
            child: Center(
              child: Text(
                'Book now',
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
    );
  }
}
