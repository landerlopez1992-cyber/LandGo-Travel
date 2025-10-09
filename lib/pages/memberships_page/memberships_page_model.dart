import '/flutter_flow/flutter_flow_util.dart';
import 'memberships_page_widget.dart' show MembershipsPageWidget;
import 'package:flutter/material.dart';

class MembershipsPageModel extends FlutterFlowModel<MembershipsPageWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}

