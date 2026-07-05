class UpdateMemberProfileRequestDto {
  const UpdateMemberProfileRequestDto({
    required this.name,
    required this.email,
    required this.phone,
  });

  final String name;
  final String email;
  final String phone;

  Map<String, Object?> toJson() {
    return {'name': name, 'email': email, 'phone': phone};
  }
}
