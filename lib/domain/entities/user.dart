class User {
  final String id;
  final String email;
  final String name;
  final String token;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.token,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
