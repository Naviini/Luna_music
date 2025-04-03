part of 'track_model.dart';

TrackModel _$TrackModelFromJson(Map<String, dynamic> json) => TrackModel(
      id: json['id'] as String,
      name: json['name'] as String,
      layers: (json['layers'] as List<dynamic>)
          .map((e) => LayerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata:
          TrackMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
      lastModified: TrackModel._fromTimestamp(json['lastModified']),
      createdBy: json['createdBy'] as String,
    );

Map<String, dynamic> _$TrackModelToJson(TrackModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'layers': instance.layers.map((e) => e.toJson()).toList(),
      'metadata': instance.metadata.toJson(),
      'lastModified': TrackModel._toTimestamp(instance.lastModified),
      'createdBy': instance.createdBy,
    };

LayerModel _$LayerModelFromJson(Map<String, dynamic> json) => LayerModel(
      name: json['name'] as String,
      instrument: json['instrument'] as String,
      grid: (json['grid'] as List<dynamic>).map((e) => e as bool).toList(),
      volume: (json['volume'] as num).toDouble(),
      isMuted: json['isMuted'] as bool,
    );

Map<String, dynamic> _$LayerModelToJson(LayerModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'instrument': instance.instrument,
      'grid': instance.grid,
      'volume': instance.volume,
      'isMuted': instance.isMuted,
    };

TrackMetadata _$TrackMetadataFromJson(Map<String, dynamic> json) =>
    TrackMetadata(
      tempo: (json['tempo'] as num).toDouble(),
      key: json['key'] as String,
      scale: json['scale'] as String,
      rhythm: json['rhythm'] as String,
    );

Map<String, dynamic> _$TrackMetadataToJson(TrackMetadata instance) =>
    <String, dynamic>{
      'tempo': instance.tempo,
      'key': instance.key,
      'scale': instance.scale,
      'rhythm': instance.rhythm,
    };
