import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class BookingsRecord extends FirestoreRecord {
  BookingsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "user_ref" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "item_id" field.
  String? _itemId;
  String get itemId => _itemId ?? '';
  bool hasItemId() => _itemId != null;

  // "item_title" field.
  String? _itemTitle;
  String get itemTitle => _itemTitle ?? '';
  bool hasItemTitle() => _itemTitle != null;

  // "start_date" field.
  DateTime? _startDate;
  DateTime? get startDate => _startDate;
  bool hasStartDate() => _startDate != null;

  // "end_date" field.
  DateTime? _endDate;
  DateTime? get endDate => _endDate;
  bool hasEndDate() => _endDate != null;

  // "total_price" field.
  double? _totalPrice;
  double get totalPrice => _totalPrice ?? 0.0;
  bool hasTotalPrice() => _totalPrice != null;

  // "payment_status" field.
  String? _paymentStatus;
  String get paymentStatus => _paymentStatus ?? '';
  bool hasPaymentStatus() => _paymentStatus != null;

  // "booking_type" field.
  String? _bookingType;
  String get bookingType => _bookingType ?? '';
  bool hasBookingType() => _bookingType != null;

  // "booking_status" field.
  String? _bookingStatus;
  String get bookingStatus => _bookingStatus ?? '';
  bool hasBookingStatus() => _bookingStatus != null;

  // "payment_method" field.
  String? _paymentMethod;
  String get paymentMethod => _paymentMethod ?? '';
  bool hasPaymentMethod() => _paymentMethod != null;

  // "zelle_upload_url" field.
  String? _zelleUploadUrl;
  String get zelleUploadUrl => _zelleUploadUrl ?? '';
  bool hasZelleUploadUrl() => _zelleUploadUrl != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "notes" field.
  String? _notes;
  String get notes => _notes ?? '';
  bool hasNotes() => _notes != null;

  void _initializeFields() {
    _userRef = snapshotData['user_ref'] as DocumentReference?;
    _itemId = snapshotData['item_id'] as String?;
    _itemTitle = snapshotData['item_title'] as String?;
    _startDate = snapshotData['start_date'] as DateTime?;
    _endDate = snapshotData['end_date'] as DateTime?;
    _totalPrice = castToType<double>(snapshotData['total_price']);
    _paymentStatus = snapshotData['payment_status'] as String?;
    _bookingType = snapshotData['booking_type'] as String?;
    _bookingStatus = snapshotData['booking_status'] as String?;
    _paymentMethod = snapshotData['payment_method'] as String?;
    _zelleUploadUrl = snapshotData['zelle_upload_url'] as String?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _notes = snapshotData['notes'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('bookings');

  static Stream<BookingsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => BookingsRecord.fromSnapshot(s));

  static Future<BookingsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => BookingsRecord.fromSnapshot(s));

  static BookingsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      BookingsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static BookingsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      BookingsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'BookingsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is BookingsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createBookingsRecordData({
  DocumentReference? userRef,
  String? itemId,
  String? itemTitle,
  DateTime? startDate,
  DateTime? endDate,
  double? totalPrice,
  String? paymentStatus,
  String? bookingType,
  String? bookingStatus,
  String? paymentMethod,
  String? zelleUploadUrl,
  DateTime? createdAt,
  String? notes,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user_ref': userRef,
      'item_id': itemId,
      'item_title': itemTitle,
      'start_date': startDate,
      'end_date': endDate,
      'total_price': totalPrice,
      'payment_status': paymentStatus,
      'booking_type': bookingType,
      'booking_status': bookingStatus,
      'payment_method': paymentMethod,
      'zelle_upload_url': zelleUploadUrl,
      'created_at': createdAt,
      'notes': notes,
    }.withoutNulls,
  );

  return firestoreData;
}

class BookingsRecordDocumentEquality implements Equality<BookingsRecord> {
  const BookingsRecordDocumentEquality();

  @override
  bool equals(BookingsRecord? e1, BookingsRecord? e2) {
    return e1?.userRef == e2?.userRef &&
        e1?.itemId == e2?.itemId &&
        e1?.itemTitle == e2?.itemTitle &&
        e1?.startDate == e2?.startDate &&
        e1?.endDate == e2?.endDate &&
        e1?.totalPrice == e2?.totalPrice &&
        e1?.paymentStatus == e2?.paymentStatus &&
        e1?.bookingType == e2?.bookingType &&
        e1?.bookingStatus == e2?.bookingStatus &&
        e1?.paymentMethod == e2?.paymentMethod &&
        e1?.zelleUploadUrl == e2?.zelleUploadUrl &&
        e1?.createdAt == e2?.createdAt &&
        e1?.notes == e2?.notes;
  }

  @override
  int hash(BookingsRecord? e) => const ListEquality().hash([
        e?.userRef,
        e?.itemId,
        e?.itemTitle,
        e?.startDate,
        e?.endDate,
        e?.totalPrice,
        e?.paymentStatus,
        e?.bookingType,
        e?.bookingStatus,
        e?.paymentMethod,
        e?.zelleUploadUrl,
        e?.createdAt,
        e?.notes
      ]);

  @override
  bool isValidKey(Object? o) => o is BookingsRecord;
}
