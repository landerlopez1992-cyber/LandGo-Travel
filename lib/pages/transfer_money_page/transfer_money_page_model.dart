import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_util.dart';

class TransferMoneyPageModel extends FlutterFlowModel {
  // State fields
  FocusNode unfocusNode = FocusNode();
  
  // Search controller
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  
  // Amount controller
  TextEditingController amountController = TextEditingController();
  FocusNode amountFocusNode = FocusNode();
  
  // Selected user
  Map<String, dynamic>? selectedUser;
  
  // Search results
  List<Map<String, dynamic>> searchResults = [];
  
  // Loading state
  bool isSearching = false;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
    searchController.dispose();
    searchFocusNode.dispose();
    amountController.dispose();
    amountFocusNode.dispose();
  }
}
