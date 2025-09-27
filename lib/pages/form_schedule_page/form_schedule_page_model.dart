import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'form_schedule_page_widget.dart' show FormSchedulePageWidget;
import 'package:provider/provider.dart';

class FormSchedulePageModel extends FlutterFlowModel<FormSchedulePageWidget> {
  TextEditingController textController1 = TextEditingController();
  TextEditingController textController2 = TextEditingController();
  TextEditingController textController3 = TextEditingController();
  int peopleCount = 1;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textController1.dispose();
    textController2.dispose();
    textController3.dispose();
  }
}
