import 'package:cloud_firestore/cloud_firestore.dart';

/// Safely convert various Firestore date representations to [DateTime].
///
/// Accepts:
/// - [Timestamp]
/// - ISO-8601 [String] (e.g. "2025-10-18" or "2025-10-18T17:06:43")
/// - integer millisecondsSinceEpoch
/// - [DateTime]
/// Returns null if value is null or cannot be parsed.
DateTime? dateTimeFromFirestore(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is Timestamp) return value.toDate();
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      // Try parsing common formats by removing timezone if present
      try {
        return DateTime.parse(value.replaceAll(RegExp(r"[^0-9T:-]"), ''));
      } catch (_) {
        return null;
      }
    }
  }
  return null;
}
