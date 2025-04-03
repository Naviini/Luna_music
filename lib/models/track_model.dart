import 'package:json_annotation/json_annotation.dart';

part 'track_model.g.dart';

@JsonSerializable()
class TrackModel {
  final String id;
  final String name;
  final List<LayerModel> layers;
  final TrackMetadata metadata;
  final DateTime lastModified;
  final String createdBy;

  TrackModel({
    required this.id,
    required this.name,
    required this.layers,
    required this.metadata,
    required this.lastModified,
    required this.createdBy,
  });

  // _fromTimestamp converts a timestamp to a DateTime object
  static DateTime _fromTimestamp(dynamic timestamp) {
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    throw Exception('Invalid timestamp format');
  }

  // _toTimestamp converts a DateTime object to a timestamp
  static int _toTimestamp(DateTime date) {
    return date.millisecondsSinceEpoch;
  }

  // From JSON constructor
  factory TrackModel.fromJson(Map<String, dynamic> json) =>
      _$TrackModelFromJson(json);

  // To JSON method
  Map<String, dynamic> toJson() => _$TrackModelToJson(this);
}

@JsonSerializable()
class LayerModel {
  final String name;
  final String instrument;
  final List<bool> grid;
  final double volume;
  final bool isMuted;

  LayerModel({
    required this.name,
    required this.instrument,
    required this.grid,
    required this.volume,
    required this.isMuted,
  });

  // From JSON constructor
  factory LayerModel.fromJson(Map<String, dynamic> json) =>
      _$LayerModelFromJson(json);

  // To JSON method
  Map<String, dynamic> toJson() => _$LayerModelToJson(this);
}

@JsonSerializable()
class TrackMetadata {
  final double tempo;
  final String key;
  final String scale;
  final String rhythm;

  TrackMetadata({
    required this.tempo,
    required this.key,
    required this.scale,
    required this.rhythm,
  });

  // From JSON constructor
  factory TrackMetadata.fromJson(Map<String, dynamic> json) =>
      _$TrackMetadataFromJson(json);

  // To JSON method
  Map<String, dynamic> toJson() => _$TrackMetadataToJson(this);
}