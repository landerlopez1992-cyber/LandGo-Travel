import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'flight_booking_page_model.dart';
export 'flight_booking_page_model.dart';

class FlightBookingPageWidget extends StatefulWidget {
  const FlightBookingPageWidget({super.key});

  static String routeName = 'FlightBookingPage';
  static String routePath = '/flightBooking';

  @override
  State<FlightBookingPageWidget> createState() =>
      _FlightBookingPageWidgetState();
}

class _FlightBookingPageWidgetState extends State<FlightBookingPageWidget> {
  late FlightBookingPageModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FlightBookingPageModel());
    _model.originController ??= TextEditingController();
    _model.originFocusNode ??= FocusNode();

    _model.destinationController ??= TextEditingController();
    _model.destinationFocusNode ??= FocusNode();

    _model.airlineController ??= TextEditingController();
    _model.airlineFocusNode ??= FocusNode();

    _model.notesController ??= TextEditingController();
    _model.notesFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _selectDate({required bool isDeparture}) async {
    final initialDate = isDeparture
        ? (_model.departureDate ?? getCurrentTimestamp)
        : (_model.returnDate ??
            (_model.departureDate ?? getCurrentTimestamp).add(Duration(days: 1)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
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

    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _model.departureDate = picked;
          if (_model.returnDate != null && picked.isAfter(_model.returnDate!)) {
            _model.returnDate = picked.add(const Duration(days: 1));
          }
        } else {
          _model.returnDate = picked;
        }
      });
    }
  }

  Future<void> _showPassengerSelector() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF8FAFC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, refresh) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPassengerRow(
                    label: 'Adultos',
                    description: '18-64 años',
                    value: _model.adults,
                    onChanged: (value) => refresh(() => _model.adults = value),
                  ),
                  const SizedBox(height: 16),
                  _buildPassengerRow(
                    label: 'Mayores',
                    description: '65+ años',
                    value: _model.seniors,
                    onChanged: (value) => refresh(() => _model.seniors = value),
                  ),
                  const SizedBox(height: 16),
                  _buildPassengerRow(
                    label: 'Niños',
                    description: '3-17 años',
                    value: _model.children,
                    onChanged: (value) => refresh(() => _model.children = value),
                  ),
                  const SizedBox(height: 16),
                  _buildPassengerRow(
                    label: 'Infantes',
                    description: '0-2 años',
                    value: _model.infants,
                    onChanged: (value) => refresh(() => _model.infants = value),
                  ),
                  const SizedBox(height: 24),
                  FFButtonWidget(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {});
                    },
                    text: 'Aplicar',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 48,
                      color: const Color(0xFFFF9800),
                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily: FlutterFlowTheme.of(context)
                                .titleSmallFamily,
                            color: Colors.white,
                            letterSpacing: 0,
                          ),
                      borderSide: const BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPassengerRow({
    required String label,
    required String description,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                    color: const Color(0xFF1F2937),
                    letterSpacing: 0,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                    color: const Color(0xFF6B7280),
                    letterSpacing: 0,
                  ),
            ),
          ],
        ),
        Row(
          children: [
            _roundedIconButton(
              icon: Icons.remove,
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                value.toString(),
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                      color: const Color(0xFF1F2937),
                      letterSpacing: 0,
                    ),
              ),
            ),
            _roundedIconButton(
              icon: Icons.add,
              onPressed: () => onChanged(value + 1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _roundedIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: onPressed == null ? const Color(0xFFE2E8F0) : const Color(0xFFFF9800),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          icon,
          size: 20,
          color: onPressed == null ? const Color(0xFF6B7280) : Colors.white,
        ),
      ),
    );
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
                    width: double.infinity,
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
                            _buildTripTypeSelector(),
                            const SizedBox(height: 16),
                            _buildAirlineTypeSelector(),
                            const SizedBox(height: 16),
                            _buildOriginDestinationCard(),
                            const SizedBox(height: 16),
                            _buildDatesCard(),
                            const SizedBox(height: 16),
                            _buildCabinClassCard(),
                            const SizedBox(height: 16),
                            _buildPassengersCard(),
                            const SizedBox(height: 16),
                            _buildAdditionalInfoCard(),
                            const SizedBox(height: 24),
                            FFButtonWidget(
                              onPressed: () {
                                if (_model.formKey.currentState?.validate() ?? false) {
                                  // TODO: Connect with Duffel search when ready
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Búsqueda de vuelos en desarrollo'),
                                      backgroundColor: const Color(0xFF4CAF50),
                                    ),
                                  );
                                }
                              },
                              text: 'Buscar vuelos',
                              icon: const Icon(Icons.search, size: 20),
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
                'Reserva aérea',
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
            'Encuentra tu vuelo ideal con descuentos de membresía y puntos LandGo.',
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

  Widget _buildTripTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.15), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A4CAF50),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _tripOption(
              label: 'Solo ida',
              icon: Icons.arrow_forward,
              selected: !_model.isRoundTrip,
              onTap: () => setState(() {
                _model.isRoundTrip = false;
                _model.resetReturnDateIfNeeded();
              }),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _tripOption(
              label: 'Ida y vuelta',
              icon: Icons.swap_horiz,
              selected: _model.isRoundTrip,
              onTap: () => setState(() {
                _model.isRoundTrip = true;
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tripOption({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4CAF50) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF4CAF50) : const Color(0xFFE2E8F0),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? Colors.white : const Color(0xFF6B7280)),
            const SizedBox(width: 8),
            Text(
              label,
              style: FlutterFlowTheme.of(context).titleSmall.override(
                    fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                    color: selected ? Colors.white : const Color(0xFF6B7280),
                    letterSpacing: 0,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAirlineTypeSelector() {
    final options = [
      {'label': 'Todas', 'icon': Icons.all_inclusive},
      {'label': 'Comerciales', 'icon': Icons.business},
      {'label': 'Charter', 'icon': Icons.flight_takeoff},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tipo de aerolíneas',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                  color: const Color(0xFF1F2937),
                  letterSpacing: 0,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: options.map((option) {
              final selected = _selectedAirline == option['label'];
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: InkWell(
                    onTap: () => setState(() => _selectedAirline = option['label'] as String),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF37474F)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF37474F)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            option['icon'] as IconData,
                            size: 20,
                            color: selected ? Colors.white : const Color(0xFF6B7280),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            option['label'] as String,
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                  color: selected
                                      ? Colors.white
                                      : const Color(0xFF6B7280),
                                  letterSpacing: 0,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _selectedAirline = 'Todas';

  Widget _buildOriginDestinationCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _model.originController!,
            focusNode: _model.originFocusNode!,
            label: 'Origen',
            hint: 'Aeropuerto o ciudad de salida',
            icon: Icons.flight_takeoff,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Indica el origen del vuelo';
              }
              return null;
            },
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          _buildTextField(
            controller: _model.destinationController!,
            focusNode: _model.destinationFocusNode!,
            label: 'Destino',
            hint: 'Aeropuerto o ciudad de destino',
            icon: Icons.location_on,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Indica el destino del vuelo';
              }
              return null;
            },
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          _buildTextField(
            controller: _model.airlineController!,
            focusNode: _model.airlineFocusNode!,
            label: 'Preferencia de aerolínea (opcional)',
            hint: 'Ej. Copa Airlines, American Airlines',
            icon: Icons.airplanemode_active,
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
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
              ),
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
            label: 'Salida',
            value: _model.departureDate != null
                ? dateTimeFormat('d MMM y', _model.departureDate)
                : 'Selecciona fecha de salida',
            onTap: () => _selectDate(isDeparture: true),
          ),
          if (_model.isRoundTrip)
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
          if (_model.isRoundTrip)
            _buildDateTile(
              label: 'Regreso',
              value: _model.returnDate != null
                  ? dateTimeFormat('d MMM y', _model.returnDate)
                  : 'Selecciona fecha de regreso',
              onTap: () => _selectDate(isDeparture: false),
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
      leading: const Icon(Icons.calendar_today, color: Color(0xFF37474F)),
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

  Widget _buildCabinClassCard() {
    final classes = ['Economy', 'Premium', 'Business', 'First'];
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
            'Clase de cabina',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                  color: const Color(0xFF1F2937),
                  letterSpacing: 0,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: classes.map((className) {
              final selected = _model.cabinClass == className;
              return ChoiceChip(
                label: Text(
                  className,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF37474F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                selected: selected,
                onSelected: (_) => setState(() => _model.cabinClass = className),
                selectedColor: const Color(0xFF37474F),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: selected
                        ? const Color(0xFF37474F)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengersCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: _showPassengerSelector,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0x1A4CAF50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.people, color: Color(0xFF4CAF50)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pasajeros',
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                          color: const Color(0xFF1F2937),
                          letterSpacing: 0,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_model.totalTravelers} viajeros (Adultos ${_model.adults}, Mayores ${_model.seniors}, Niños ${_model.children}, Infantes ${_model.infants})',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                          color: const Color(0xFF6B7280),
                          letterSpacing: 0,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoCard() {
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
            'Notas adicionales',
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
              hintText: 'Preferencias de asientos, asistencia especial, equipaje, etc.',
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
