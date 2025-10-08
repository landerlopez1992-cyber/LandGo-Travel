import '/flutter_flow/flutter_flow_util.dart';
import 'payment_methods_page_widget.dart' show PaymentMethodsPageWidget;
import 'package:flutter/material.dart';

class PaymentMethodsPageModel extends FlutterFlowModel<PaymentMethodsPageWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}

