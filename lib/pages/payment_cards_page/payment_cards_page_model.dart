import '/flutter_flow/flutter_flow_util.dart';
import 'payment_cards_page_widget.dart' show PaymentCardsPageWidget;
import 'package:flutter/material.dart';

class PaymentCardsPageModel extends FlutterFlowModel<PaymentCardsPageWidget> {
  ///  State field(s) for Card Number TextField widget.
  FocusNode? cardNumberFocusNode;
  TextEditingController? cardNumberController;
  String? Function(BuildContext, String?)? cardNumberControllerValidator;
  
  /// Focus node for unfocusing
  FocusNode unfocusNode = FocusNode();

  ///  State field(s) for Expiry Date TextField widget.
  FocusNode? expiryFocusNode;
  TextEditingController? expiryController;
  String? Function(BuildContext, String?)? expiryControllerValidator;

  ///  State field(s) for CVV TextField widget.
  FocusNode? cvvFocusNode;
  TextEditingController? cvvController;
  String? Function(BuildContext, String?)? cvvControllerValidator;

  ///  State field(s) for Cardholder Name TextField widget.
  FocusNode? cardholderNameFocusNode;
  TextEditingController? cardholderNameController;
  String? Function(BuildContext, String?)? cardholderNameControllerValidator;

  @override
  void initState(BuildContext context) {
    cardNumberController = TextEditingController();
    expiryController = TextEditingController();
    cvvController = TextEditingController();
    cardholderNameController = TextEditingController();
    
    cardNumberControllerValidator = _cardNumberControllerValidator;
    expiryControllerValidator = _expiryControllerValidator;
    cvvControllerValidator = _cvvControllerValidator;
    cardholderNameControllerValidator = _cardholderNameControllerValidator;
  }

  @override
  void dispose() {
    cardNumberFocusNode?.dispose();
    cardNumberController?.dispose();

    expiryFocusNode?.dispose();
    expiryController?.dispose();

    cvvFocusNode?.dispose();
    cvvController?.dispose();

    cardholderNameFocusNode?.dispose();
    cardholderNameController?.dispose();
    
    unfocusNode.dispose();
  }

  /// Additional helper methods are added here.

  String? _cardNumberControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Card number is required';
    }
    if (val.length < 16) {
      return 'Please enter a valid card number';
    }
    return null;
  }

  String? _expiryControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Expiry date is required';
    }
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(val)) {
      return 'Please enter in MM/YY format';
    }
    return null;
  }

  String? _cvvControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'CVV is required';
    }
    if (val.length < 3) {
      return 'Please enter a valid CVV';
    }
    return null;
  }

  String? _cardholderNameControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Cardholder name is required';
    }
    if (val.length < 2) {
      return 'Please enter a valid name';
    }
    return null;
  }
}
