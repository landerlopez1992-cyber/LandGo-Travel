import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'hotel_booking_page_model.dart';
export 'hotel_booking_page_model.dart';

class HotelBookingPageWidget extends StatefulWidget {
  const HotelBookingPageWidget({super.key});

  static String routeName = 'HotelBookingPage';
  static String routePath = '/hotelBooking';

  @override
  State<HotelBookingPageWidget> createState() => _HotelBookingPageWidgetState();
}

class _HotelBookingPageWidgetState extends State<HotelBookingPageWidget> {
  late HotelBookingPageModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HotelBookingPageModel());
    _model.destinationController ??= TextEditingController();
    _model.destinationFocusNode ??= FocusNode();

    _model.hotelController ??= TextEditingController();
    _model.hotelFocusNode ??= FocusNode();

    _model.roomsFocusNode ??= FocusNode();
    _model.guestsFocusNode ??= FocusNode();

    _model.notesController ??= TextEditingController();
    _model.notesFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _selectHotelDate({required bool isCheckIn}) async {
    final initial = isCheckIn
        ? (_model.checkInDate ?? DateTime.now().add(const Duration(days: 1)))
        : (_model.checkOutDate ??
            (_model.checkInDate ?? DateTime.now().add(const Duration(days: 1)))
                .add(const Duration(days: 1)));

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF37474F),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1F2937),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        if (isCheckIn) {
          _model.checkInDate = date;
          if (_model.checkOutDate != null && date.isAfter(_model.checkOutDate!)) {
            _model.checkOutDate = date.add(const Duration(days: 1));
          }
        } else {
          _model.checkOutDate = date;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4c669f), Color(0xFF3b5998), Color(0xFF192f6a)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                      child: Form(
                        key: _model.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDestinationCard(),
                            const SizedBox(height: 16),
                            _buildDatesCard(),
                            const SizedBox(height: 16),
                            _buildRoomsGuestsCard(),
                            const SizedBox(height: 16),
                            _buildPreferencesCard(),
                            const SizedBox(height: 16),
                            _buildNotesCard(),
                            const SizedBox(height: 24),
                            FFButtonWidget(
                              onPressed: () {
                                if (!(_model.formKey.currentState?.validate() ?? false)) {
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Búsqueda de hoteles en desarrollo'),
                                    backgroundColor: Color(0xFF4CAF50),
                                  ),
                                );
                              },
                              text: 'Buscar hoteles',
                              icon: const Icon(Icons.hotel, size: 20),
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 56,
                                color: const Color(0xFFFF9800),
                                textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                                      fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                                      color: Colors.white,
                                      letterSpacing: 0,
                                    ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      width: double.infinity,
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0x33FFFFFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  onPressed: () => context.safePop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Reserva de hotel',
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                      fontFamily: FlutterFlowTheme.of(context).headlineMediumFamily,
                      color: Colors.white,
                      letterSpacing: 0,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Encuentra hoteles con tarifas exclusivas de LandGo y descuentos con puntos.',
            style: FlutterFlowTheme.of(context).bodyLarge.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyLargeFamily,
                  color: const Color(0xE6FFFFFF),
                  letterSpacing: 0,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _model.destinationController!,
            focusNode: _model.destinationFocusNode!,
            label: 'Destino',
            hint: 'Ciudad o zona',
            icon: Icons.location_city,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ingresa el destino del hotel';
              }
              return null;
            },
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          _buildTextField(
            controller: _model.hotelController!,
            focusNode: _model.hotelFocusNode!,
            label: 'Nombre del hotel (opcional)',
            hint: 'Ej. The Langham, Hyatt Place',
            icon: Icons.hotel_class,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  color: const Color(0xFF6B7280),
                  letterSpacing: 0,
                ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            validator: validator,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF37474F)),
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF37474F), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
              ),
            ),
            style: const TextStyle(color: Color(0xFF1F2937)),
          ),
        ],
      ),
    );
  }

  Widget _buildDatesCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _buildDateTile(
            label: 'Check-in',
            value: _model.checkInDate != null
                ? dateTimeFormat('d MMM y', _model.checkInDate)
                : 'Selecciona fecha de llegada',
            onTap: () => _selectHotelDate(isCheckIn: true),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          _buildDateTile(
            label: 'Check-out',
            value: _model.checkOutDate != null
                ? dateTimeFormat('d MMM y', _model.checkOutDate)
                : 'Selecciona fecha de salida',
            onTap: () => _selectHotelDate(isCheckIn: false),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTile({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: const Icon(Icons.calendar_month, color: Color(0xFF37474F)),
      title: Text(
        label,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
              color: const Color(0xFF6B7280),
              letterSpacing: 0,
            ),
      ),
      subtitle: Text(
        value,
        style: FlutterFlowTheme.of(context).titleMedium.override(
              fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
              color: const Color(0xFF1F2937),
              letterSpacing: 0,
            ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF6B7280)),
      onTap: onTap,
    );
  }

  Widget _buildRoomsGuestsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _model.roomsController,
                  focusNode: _model.roomsFocusNode,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Habitaciones',
                    hintText: '1',
                    prefixIcon: const Icon(Icons.meeting_room,
                        color: Color(0xFF37474F)),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF37474F), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Indica cuántas habitaciones necesitas';
                    }
                    final rooms = int.tryParse(value);
                    if (rooms == null || rooms <= 0) {
                      return 'Ingresa un número válido';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _model.guestsController,
                  focusNode: _model.guestsFocusNode,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Huéspedes',
                    hintText: '2',
                    prefixIcon: const Icon(Icons.people, color: Color(0xFF37474F)),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF37474F), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Indica cuántos huéspedes viajan';
                    }
                    final guests = int.tryParse(value);
                    if (guests == null || guests <= 0) {
                      return 'Ingresa un número válido';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferencias',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                  color: const Color(0xFF1F2937),
                  letterSpacing: 0,
                ),
          ),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            value: _model.includeBreakfast,
            onChanged: (value) => setState(() => _model.includeBreakfast = value),
            title: const Text('Incluir desayuno'),
            subtitle:
                const Text('Filtrar hoteles con desayuno incluido en la tarifa'),
            activeColor: const Color(0xFF4CAF50),
          ),
          SwitchListTile.adaptive(
            value: _model.onlyRefundable,
            onChanged: (value) => setState(() => _model.onlyRefundable = value),
            title: const Text('Solo tarifas reembolsables'),
            subtitle: const Text('Mostrar únicamente opciones con cancelación'),
            activeColor: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notas o solicitudes especiales',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                  color: const Color(0xFF1F2937),
                  letterSpacing: 0,
                ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _model.notesController,
            focusNode: _model.notesFocusNode,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  'Ej. habitación con vista, pisos altos, acceso para silla de ruedas, etc.',
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF37474F), width: 2),
              ),
            ),
            style: const TextStyle(color: Color(0xFF1F2937)),
          ),
        ],
      ),
    );
  }
}
