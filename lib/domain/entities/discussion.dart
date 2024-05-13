import 'package:json_annotation/json_annotation.dart';

part 'discussion.g.dart';

@JsonSerializable()
class Discussion {
  final String identifier;
  final String markdown;

  Discussion({
    required this.identifier,
    required this.markdown,
  });

  static Discussion fromJson(final Map<String, dynamic> json) => _$DiscussionFromJson(json);

  Map<String, dynamic> toJson() => _$DiscussionToJson(this);
}
