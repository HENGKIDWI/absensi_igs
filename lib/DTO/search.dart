// lib/model/search_model.dart

import 'package:igs_absensi/DTO/class.dart';

class SearchResult {
  final List<ClassModel> courses;
  final String? nextCursor;
  final String? prevCursor;
  final bool hasMore;

  const SearchResult({
    required this.courses,
    this.nextCursor,
    this.prevCursor,
    required this.hasMore,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final meta = (json['meta'] as Map<String, dynamic>?) ?? {};

    return SearchResult(
      courses:
          (json['courses'] as List<dynamic>? ?? []) // ← null-safe
              .map((e) => ClassModel.fromJson(e as Map<String, dynamic>))
              .toList(),
      nextCursor: meta['next_cursor'],
      prevCursor: meta['prev_cursor'],
      hasMore: meta['has_more'] ?? false,
    );
  }
}
