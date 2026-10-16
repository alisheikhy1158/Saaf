import 'package:saaf/core/error/result.dart';

/// Opens the phone's share sheet. Only text is ever shared, never photos or
/// anything from the user's profile (PRV-2).
abstract interface class ShareService {
  Future<Result<void>> shareText(String text);
}
