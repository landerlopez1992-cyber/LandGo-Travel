import '/flutter_flow/flutter_flow_util.dart';
import 'my_wallet_page_widget.dart' show MyWalletPageWidget;
import 'package:flutter/material.dart';

class MyWalletPageModel extends FlutterFlowModel<MyWalletPageWidget> {
  /// Unfocus node for form interactions
  FocusNode unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
