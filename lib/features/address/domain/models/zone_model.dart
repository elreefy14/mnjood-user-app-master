import 'dart:convert';

import 'package:mnjood/features/location/domain/models/zone_response_model.dart';

class ZoneModel {
  List<int>? zoneIds;
  List<ZoneData>? zoneData;

  ZoneModel({this.zoneIds, this.zoneData});

  ZoneModel.fromJson(Map<String, dynamic> json) {
    zoneIds = [];
    if (json['zone_id'] != null) {
      jsonDecode(json['zone_id']).forEach((v) {
        zoneIds!.add(v);
      });
    }
    if (json['zone_data'] != null) {
      zoneData = <ZoneData>[];
      json['zone_data'].forEach((v) {
        zoneData!.add(ZoneData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['zone_id'] = zoneIds;
    if (zoneData != null) {
      data['zone_data'] = zoneData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}