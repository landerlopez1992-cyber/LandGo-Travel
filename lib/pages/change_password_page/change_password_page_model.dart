import '/flutter_flow/flutter_flow_util.dart';
import 'change_password_page_widget.dart' show ChangePasswordPageWidget;
import 'package:flutter/material.dart';

class ChangePasswordPageModel extends FlutterFlowModel<ChangePasswordPageWidget> {
  final unfocusNode = FocusNode();
  
  // Controllers para los campos de contraseña
  FocusNode? currentPasswordFocusNode;
  TextEditingController? currentPasswordController;
  late bool currentPasswordVisibility;
  
  FocusNode? newPasswordFocusNode;
  TextEditingController? newPasswordController;
  late bool newPasswordVisibility;
  
  FocusNode? confirmPasswordFocusNode;
  TextEditingController? confirmPasswordController;
  late bool confirmPasswordVisibility;

  @override
  void initState(BuildContext context) {
    currentPasswordVisibility = false;
    newPasswordVisibility = false;
    confirmPasswordVisibility = false;
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    currentPasswordFocusNode?.dispose();
    currentPasswordController?.dispose();
    newPasswordFocusNode?.dispose();
    newPasswordController?.dispose();
    confirmPasswordFocusNode?.dispose();
    confirmPasswordController?.dispose();
  }
}

