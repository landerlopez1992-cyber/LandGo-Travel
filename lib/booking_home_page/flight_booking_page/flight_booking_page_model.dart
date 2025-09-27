import '/flutter_flow/flutter_flow_util.dart';
import 'flight_booking_page_widget.dart' show FlightBookingPageWidget;
import 'package:flutter/material.dart';

class FlightBookingPageModel
    extends FlutterFlowModel<FlightBookingPageWidget> {
  /// State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();

  // Text field controllers.
  FocusNode? originFocusNode;
  TextEditingController? originController;
  String? Function(BuildContext, String?)? originControllerValidator;

  FocusNode? destinationFocusNode;
  TextEditingController? destinationController;
  String? Function(BuildContext, String?)? destinationControllerValidator;

  FocusNode? airlineFocusNode;
  TextEditingController? airlineController;
  String? Function(BuildContext, String?)? airlineControllerValidator;

  FocusNode? notesFocusNode;
  TextEditingController? notesController;
  String? Function(BuildContext, String?)? notesControllerValidator;

  DateTime? departureDate;
  DateTime? returnDate;

  bool isRoundTrip = false;
  String cabinClass = 'Economy';

  int adults = 1;
  int seniors = 0;
  int children = 0;
  int infants = 0;

  bool showPassengerSelector = false;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    originFocusNode?.dispose();
    originController?.dispose();

    destinationFocusNode?.dispose();
    destinationController?.dispose();

    airlineFocusNode?.dispose();
    airlineController?.dispose();

    notesFocusNode?.dispose();
    notesController?.dispose();
  }

  /// Additional helper methods are added here.

  int get totalTravelers => adults + seniors + children + infants;

  void resetReturnDateIfNeeded() {
    if (!isRoundTrip) {
      returnDate = null;
    }
  }
}
