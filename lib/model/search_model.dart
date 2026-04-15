// lib/model/search_result.dart
import 'class_model.dart';

class SearchResult {
  final List<ClassModel> classes;
  final String? nextCursor;
  final String? prevCursor;
  final bool hasMore;

  const SearchResult({
    required this.classes,
    this.nextCursor,
    this.prevCursor,
    required this.hasMore,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>;

    return SearchResult(
      classes: (json['classes'] as List)
          .map((e) => ClassModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: meta['next_cursor'],
      prevCursor: meta['prev_cursor'],
      hasMore: meta['has_more'] ?? false,
    );
  }
}
