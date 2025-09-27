import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MaintenanceControlRecord extends FirestoreRecord {
  MaintenanceControlRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "is_maintenance_mode" field.
  bool? _isMaintenanceMode;
  bool get isMaintenanceMode => _isMaintenanceMode ?? false;
  bool hasIsMaintenanceMode() => _isMaintenanceMode != null;

  // "maintenance_message" field.
  String? _maintenanceMessage;
  String get maintenanceMessage => _maintenanceMessage ?? '';
  bool hasMaintenanceMessage() => _maintenanceMessage != null;

  // "force_update" field.
  bool? _forceUpdate;
  bool get forceUpdate => _forceUpdate ?? false;
  bool hasForceUpdate() => _forceUpdate != null;

  // "update_message" field.
  String? _updateMessage;
  String get updateMessage => _updateMessage ?? '';
  bool hasUpdateMessage() => _updateMessage != null;

  // "min_required_version" field.
  String? _minRequiredVersion;
  String get minRequiredVersion => _minRequiredVersion ?? '';
  bool hasMinRequiredVersion() => _minRequiredVersion != null;

  // "platform" field.
  String? _platform;
  String get platform => _platform ?? '';
  bool hasPlatform() => _platform != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  void _initializeFields() {
    _isMaintenanceMode = snapshotData['is_maintenance_mode'] as bool?;
    _maintenanceMessage = snapshotData['maintenance_message'] as String?;
    _forceUpdate = snapshotData['force_update'] as bool?;
    _updateMessage = snapshotData['update_message'] as String?;
    _minRequiredVersion = snapshotData['min_required_version'] as String?;
    _platform = snapshotData['platform'] as String?;
    _createdAt = snapshotData['created_at'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('maintenance_control');

  static Stream<MaintenanceControlRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => MaintenanceControlRecord.fromSnapshot(s));

  static Future<MaintenanceControlRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => MaintenanceControlRecord.fromSnapshot(s));

  static MaintenanceControlRecord fromSnapshot(DocumentSnapshot snapshot) =>
      MaintenanceControlRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static MaintenanceControlRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      MaintenanceControlRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'MaintenanceControlRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is MaintenanceControlRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createMaintenanceControlRecordData({
  bool? isMaintenanceMode,
  String? maintenanceMessage,
  bool? forceUpdate,
  String? updateMessage,
  String? minRequiredVersion,
  String? platform,
  DateTime? createdAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'is_maintenance_mode': isMaintenanceMode,
      'maintenance_message': maintenanceMessage,
      'force_update': forceUpdate,
      'update_message': updateMessage,
      'min_required_version': minRequiredVersion,
      'platform': platform,
      'created_at': createdAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class MaintenanceControlRecordDocumentEquality
    implements Equality<MaintenanceControlRecord> {
  const MaintenanceControlRecordDocumentEquality();

  @override
  bool equals(MaintenanceControlRecord? e1, MaintenanceControlRecord? e2) {
    return e1?.isMaintenanceMode == e2?.isMaintenanceMode &&
        e1?.maintenanceMessage == e2?.maintenanceMessage &&
        e1?.forceUpdate == e2?.forceUpdate &&
        e1?.updateMessage == e2?.updateMessage &&
        e1?.minRequiredVersion == e2?.minRequiredVersion &&
        e1?.platform == e2?.platform &&
        e1?.createdAt == e2?.createdAt;
  }

  @override
  int hash(MaintenanceControlRecord? e) => const ListEquality().hash([
        e?.isMaintenanceMode,
        e?.maintenanceMessage,
        e?.forceUpdate,
        e?.updateMessage,
        e?.minRequiredVersion,
        e?.platform,
        e?.createdAt
      ]);

  @override
  bool isValidKey(Object? o) => o is MaintenanceControlRecord;
}
