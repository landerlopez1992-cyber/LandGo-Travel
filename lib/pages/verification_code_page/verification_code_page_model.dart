import '/flutter_flow/flutter_flow_util.dart';
import 'verification_code_page_widget.dart' show VerificationCodePageWidget;
import 'package:flutter/material.dart';

class VerificationCodePageModel
    extends FlutterFlowModel<VerificationCodePageWidget> {
  /// State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  
  // 6 individual controllers for each digit
  List<TextEditingController> digitControllers = [];
  List<FocusNode> digitFocusNodes = [];
  
  // Combined code for verification
  String get verificationCode => digitControllers.map((c) => c.text).join('');

  @override
  void initState(BuildContext context) {
    // Initialize 6 controllers and focus nodes
    for (int i = 0; i < 6; i++) {
      digitControllers.add(TextEditingController());
      digitFocusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (var controller in digitControllers) {
      controller.dispose();
    }
    for (var focusNode in digitFocusNodes) {
      focusNode.dispose();
    }
  }
}
