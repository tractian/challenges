import 'package:flutter/material.dart';

class Asset {
  final String id;
  final String name;
  final String? parentId;
  final String? locationId;
  final String? sensorType;
  final String status;

  Asset({
    required this.id,
    required this.name,
    this.parentId,
    this.locationId,
    this.sensorType,
    required this.status,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] as String,
      name: json['name'] as String,
      parentId: json['parentId'] as String?,
      locationId: json['locationId'] as String?,
      sensorType: json['sensorType'] as String?,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
      'locationId': locationId,
      'sensorType': sensorType,
      'status': status,
    };
  }

  bool get isComponent => sensorType != null;

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'alert':
        return Colors.red;
      case 'operating':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
