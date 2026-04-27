import 'package:equatable/equatable.dart';

/// Authenticated user context (backed by JWT + profile fields as the API grows).
final class AppUser extends Equatable {
  const AppUser({
    required this.email,
    this.id,
  });

  final String email;
  final String? id;

  @override
  List<Object?> get props => [email, id];
}
