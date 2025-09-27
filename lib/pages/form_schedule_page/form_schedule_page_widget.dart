import '/flutter_flow/flutter_flow_util.dart';
import '/auth/supabase_auth/auth_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'form_schedule_page_model.dart';
export 'form_schedule_page_model.dart';

class FormSchedulePageWidget extends StatefulWidget {
  const FormSchedulePageWidget({super.key});

  static String routeName = 'FormSchedulePage';
  static String routePath = '/formSchedulePage';

  @override
  State<FormSchedulePageWidget> createState() => _FormSchedulePageWidgetState();
}

class _FormSchedulePageWidgetState extends State<FormSchedulePageWidget> {
  late FormSchedulePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FormSchedulePageModel());
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
              'Form schedule',
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Imagen del destino
              _buildDestinationImage(),
              
              // Información del destino
              _buildDestinationInfo(),
              
              // Formulario
              _buildScheduleForm(),
              
              SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationImage() {
    return Container(
      width: double.infinity,
      height: 250.0,
      margin: EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 0.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.network(
          'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=250&fit=crop',
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
    );
  }

  Widget _buildDestinationInfo() {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Azure wave island escape',
            style: GoogleFonts.inter(
              color: Color(0xFFFFFFFF),
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Color(0xFFFFFFFF),
                size: 16.0,
              ),
              SizedBox(width: 4.0),
              Text(
                'Bali, Indonesia',
                style: GoogleFonts.inter(
                  color: Color(0xFFFFFFFF),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(width: 16.0),
              Icon(
                Icons.star,
                color: Color(0xFFFFD700),
                size: 16.0,
              ),
              SizedBox(width: 4.0),
              Text(
                '4.2',
                style: GoogleFonts.inter(
                  color: Color(0xFFFFFFFF),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleForm() {
    return Container(
      width: double.infinity,
      margin: EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 0.0),
      decoration: BoxDecoration(
        color: Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16.0, 20.0, 16.0, 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Schedule your visit',
              style: GoogleFonts.inter(
                color: Color(0xFFFFFFFF),
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            
            // Campo de fecha
            _buildFormField(
              label: 'Date of visit',
              controller: _model.textController1,
              hintText: 'Select date',
              suffixIcon: Icons.calendar_today,
            ),
            SizedBox(height: 16.0),
            
            // Campo de número de personas
            _buildPeopleCounter(),
            SizedBox(height: 16.0),
            
            // Campo de mensaje
            _buildFormField(
              label: 'Message',
              controller: _model.textController3,
              hintText: 'Message',
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    IconData? suffixIcon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Color(0xFFFFFFFF),
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.0),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: Color(0xFF404040),
              width: 1.0,
            ),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: GoogleFonts.inter(
              color: Color(0xFFFFFFFF),
              fontSize: 16.0,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.inter(
                color: Color(0xFF888888),
                fontSize: 16.0,
              ),
              suffixIcon: suffixIcon != null
                  ? Icon(
                      suffixIcon,
                      color: Color(0xFFFFFFFF),
                      size: 20.0,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeopleCounter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Number of people',
          style: GoogleFonts.inter(
            color: Color(0xFFFFFFFF),
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.0),
        Container(
          height: 56.0,
          decoration: BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: Color(0xFF404040),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              // Botón menos
              Expanded(
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      if (_model.peopleCount > 1) {
                        _model.peopleCount--;
                      }
                    });
                  },
                  icon: Icon(
                    Icons.remove,
                    color: Color(0xFFFFFFFF),
                    size: 20.0,
                  ),
                ),
              ),
              
              // Contador
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    _model.peopleCount.toString(),
                    style: GoogleFonts.inter(
                      color: Color(0xFFFFFFFF),
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              
              // Botón más
              Expanded(
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _model.peopleCount++;
                    });
                  },
                  icon: Icon(
                    Icons.add,
                    color: Color(0xFFFFFFFF),
                    size: 20.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
