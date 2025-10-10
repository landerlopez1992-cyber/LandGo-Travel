import '/flutter_flow/flutter_flow_util.dart';
import 'membership_detail_page_widget.dart' show MembershipDetailPageWidget;
import 'package:flutter/material.dart';

class MembershipDetailPageModel extends FlutterFlowModel<MembershipDetailPageWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  
  // ✅ Estado del checkbox de aceptación de términos
  bool termsAccepted = false;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}



