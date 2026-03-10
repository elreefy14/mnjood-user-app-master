import 'package:mnjood/features/location/domain/models/zone_response_model.dart';

class AddressModel {
  int? id;
  String? addressType;
  String? contactPersonNumber;
  String? address;
  String? latitude;
  String? longitude;
  int? zoneId;
  List<int>? zoneIds;
  String? method;
  String? contactPersonName;
  String? road;
  String? house;
  String? floor;
  List<ZoneData>? zoneData;
  String? email;

  AddressModel({
    this.id,
    this.addressType,
    this.contactPersonNumber,
    this.address,
    this.latitude,
    this.longitude,
    this.zoneId,
    this.zoneIds,
    this.method,
    this.contactPersonName,
    this.road,
    this.house,
    this.floor,
    this.zoneData,
    this.email,
  });

  AddressModel.fromJson(Map<String, dynamic> json) {
    // Parse id safely - can be int or String
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    addressType = json['address_type'];
    contactPersonNumber = json['contact_person_number'];
    address = json['address'];
    // Parse latitude/longitude as String
    latitude = json['latitude']?.toString();
    longitude = json['longitude']?.toString();
    // Parse zoneId safely - can be int or String
    zoneId = json['zone_id'] is int ? json['zone_id'] : int.tryParse(json['zone_id']?.toString() ?? '');
    // Parse zoneIds safely - handle mixed types in List
    if (json['zone_ids'] != null && json['zone_ids'] is List) {
      zoneIds = (json['zone_ids'] as List).map((e) => e is int ? e : (int.tryParse(e.toString()) ?? 0)).toList();
    }
    method = json['_method'];
    contactPersonName = json['contact_person_name'];
    floor = json['floor'];
    road = json['road'];
    house = json['house'];
    if (json['zone_data'] != null) {
      zoneData = [];
      json['zone_data'].forEach((v) {
        zoneData!.add(ZoneData.fromJson(v));
      });
    }
    if(json['contact_person_email'] != null) {
      email = json['contact_person_email'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['address_type'] = addressType;
    data['contact_person_number'] = contactPersonNumber;
    data['address'] = address;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['zone_id'] = zoneId;
    data['zone_ids'] = zoneIds;
    data['_method'] = method;
    data['contact_person_name'] = contactPersonName;
    data['road'] = road;
    data['house'] = house;
    data['floor'] = floor;
    if (zoneData != null) {
      data['zone_data'] = zoneData!.map((v) => v.toJson()).toList();
    }
    if(email != null) {
      data['contact_person_email'] = email;
    }
    return data;
  }
}
