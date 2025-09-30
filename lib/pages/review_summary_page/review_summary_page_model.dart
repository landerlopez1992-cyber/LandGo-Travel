import '/flutter_flow/flutter_flow_util.dart';
import 'review_summary_page_widget.dart' show ReviewSummaryPageWidget;
import 'package:flutter/material.dart';

class ReviewSummaryPageModel extends FlutterFlowModel<ReviewSummaryPageWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
