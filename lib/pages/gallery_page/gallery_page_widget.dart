import '/flutter_flow/flutter_flow_util.dart';
import '/auth/supabase_auth/auth_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'gallery_page_model.dart';
export 'gallery_page_model.dart';

class GalleryPageWidget extends StatefulWidget {
  const GalleryPageWidget({super.key});

  static String routeName = 'GalleryPage';
  static String routePath = '/galleryPage';

  @override
  State<GalleryPageWidget> createState() => _GalleryPageWidgetState();
}

class _GalleryPageWidgetState extends State<GalleryPageWidget> {
  late GalleryPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GalleryPageModel());
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
              'Gallery',
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
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.0,
            ),
            itemCount: 6, // 6 imágenes en total
            itemBuilder: (context, index) {
              return _buildGalleryItem(index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryItem(int index) {
    List<Map<String, dynamic>> galleryItems = [
      {
        'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=400&fit=crop',
        'title': 'Mountain View',
        'description': 'Beautiful mountain landscape',
      },
      {
        'image': 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=400&fit=crop',
        'title': 'Tropical Resort',
        'description': 'Paradise beach resort',
      },
      {
        'image': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400&h=400&fit=crop',
        'title': 'Ocean Sunset',
        'description': 'Stunning ocean sunset',
      },
    ];

    // Rotar las imágenes para mostrar más variedad
    final item = galleryItems[index % galleryItems.length];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Stack(
          children: [
            // Imagen de fondo
            Positioned.fill(
              child: Image.network(
                item['image'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Color(0xFF2C2C2C),
                    child: Icon(
                      Icons.image,
                      color: Color(0xFF666666),
                      size: 48.0,
                    ),
                  );
                },
              ),
            ),
            
            // Gradiente oscuro en la parte inferior
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80.0,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
            
            // Información de la imagen
            Positioned(
              bottom: 12.0,
              left: 12.0,
              right: 12.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: GoogleFonts.inter(
                      color: Color(0xFFFFFFFF),
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.0),
                  Text(
                    item['description'],
                    style: GoogleFonts.inter(
                      color: Color(0xFFAAAAAA),
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Botón de favorito
            Positioned(
              top: 12.0,
              right: 12.0,
              child: Container(
                width: 32.0,
                height: 32.0,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: IconButton(
                  onPressed: () {
                    // TODO: Implementar favoritos
                  },
                  icon: Icon(
                    Icons.favorite_border,
                    color: Color(0xFFFFFFFF),
                    size: 16.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
