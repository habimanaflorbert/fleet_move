class Car {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double speed;
  final String status;

  Car({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.status,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      speed: json['speed'].toDouble(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'status': status,
    };
  }

  Car copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    double? speed,
    String? status,
  }) {
    return Car(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      speed: speed ?? this.speed,
      status: status ?? this.status,
    );
  }
} 