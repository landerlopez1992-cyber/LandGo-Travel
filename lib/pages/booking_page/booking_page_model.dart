import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class BookingPageModel extends FlutterFlowModel {
  // State fields
  final unfocusNode = FocusNode();
  
  // Tab selection (0 = Flights, 1 = Hotels)
  int selectedTab = 1; // Por defecto Hotel
  
  // Flight form fields
  TextEditingController? flightOriginController;
  TextEditingController? flightDestinationController;
  DateTime? flightDepartureDate;
  DateTime? flightReturnDate;
  int flightPassengers = 1;
  String flightClass = 'Economy';
  
  // Hotel form fields
  TextEditingController? hotelDestinationController;
  DateTime? hotelCheckInDate;
  DateTime? hotelCheckOutDate;
  int hotelRooms = 1;
  int hotelGuests = 2;
  
  @override
  void initState(BuildContext context) {
    // Initialize controllers
    flightOriginController = TextEditingController();
    flightDestinationController = TextEditingController();
    hotelDestinationController = TextEditingController();
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    flightOriginController?.dispose();
    flightDestinationController?.dispose();
    hotelDestinationController?.dispose();
  }
}
