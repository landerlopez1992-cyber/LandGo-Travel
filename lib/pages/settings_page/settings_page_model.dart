import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class SettingsPageModel extends FlutterFlowModel {
  // State fields
  final unfocusNode = FocusNode();
  
  // Settings toggles
  bool notificationsEnabled = true;
  bool darkModeEnabled = true;
  bool locationServicesEnabled = true;
  bool biometricEnabled = false;
  
  @override
  void initState(BuildContext context) {
    // Initialize settings
  }

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
