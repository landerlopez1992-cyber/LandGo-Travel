import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'add_card_page_widget.dart' show AddCardPageWidget;

class AddCardPageModel extends FlutterFlowModel<AddCardPageWidget> {
  /// State fields for stateful widgets in this page.
  
  // Cardholder Name Controller
  TextEditingController? cardholderNameController;
  FocusNode? cardholderNameFocusNode;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    cardholderNameController?.dispose();
    cardholderNameFocusNode?.dispose();
  }
}

