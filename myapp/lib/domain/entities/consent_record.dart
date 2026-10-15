import 'package:freezed_annotation/freezed_annotation.dart';

part 'consent_record.freezed.dart';

/// Proof that the user accepted the Terms and Privacy Policy and confirmed they
/// are 16 or older: when, and which version of the documents.
@freezed
abstract class ConsentRecord with _$ConsentRecord {
  const factory ConsentRecord({
    required DateTime acceptedAt,
    required String policyVersion,
  }) = _ConsentRecord;
}
