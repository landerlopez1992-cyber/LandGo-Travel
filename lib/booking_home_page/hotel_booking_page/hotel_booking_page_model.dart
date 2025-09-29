import '/flutter_flow/flutter_flow_util.dart';
import 'hotel_booking_page_widget.dart' show HotelBookingPageWidget;
import 'package:flutter/material.dart';

class HotelBookingPageModel
    extends FlutterFlowModel<HotelBookingPageWidget> {
  /// State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();

  FocusNode? destinationFocusNode;
  TextEditingController? destinationController;
  String? Function(BuildContext, String?)? destinationValidator;

  FocusNode? hotelFocusNode;
  TextEditingController? hotelController;
  String? Function(BuildContext, String?)? hotelValidator;

  FocusNode? roomsFocusNode;
  TextEditingController? roomsController;
  String? Function(BuildContext, String?)? roomsValidator;

  FocusNode? guestsFocusNode;
  TextEditingController? guestsController;
  String? Function(BuildContext, String?)? guestsValidator;

  FocusNode? notesFocusNode;
  TextEditingController? notesController;
  String? Function(BuildContext, String?)? notesValidator;

  DateTime? checkInDate;
  DateTime? checkOutDate;

  bool includeBreakfast = false;
  bool onlyRefundable = false;

  @override
  void initState(BuildContext context) {
    roomsController ??= TextEditingController(text: '1');
    guestsController ??= TextEditingController(text: '2');
  }

  @override
  void dispose() {
    destinationFocusNode?.dispose();
    destinationController?.dispose();

    hotelFocusNode?.dispose();
    hotelController?.dispose();

    roomsFocusNode?.dispose();
    roomsController?.dispose();

    guestsFocusNode?.dispose();
    guestsController?.dispose();

    notesFocusNode?.dispose();
    notesController?.dispose();
  }
}
