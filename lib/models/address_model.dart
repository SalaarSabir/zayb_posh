class AddressModel {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String postalCode;
  final bool isDefault;
  final DateTime createdAt;

  AddressModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.postalCode,
    this.isDefault = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      postalCode: map['postalCode'] ?? '',
      isDefault: map['isDefault'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  AddressModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get fullAddress => '$address, $city, $state - $postalCode';

  @override
  String toString() {
    return 'AddressModel(id: $id, name: $name, address: $fullAddress)';
  }
}