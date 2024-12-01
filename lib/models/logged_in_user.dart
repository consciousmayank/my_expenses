import 'package:expense_manager/ui/common/app_constants.dart';
import 'package:hive/hive.dart';

part 'logged_in_user.g.dart';

@HiveType(typeId: HiveTypeIdLoggedInUser)
class LoggedInUser {
  @HiveField(0)
  final String? displayName;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String id;

  @HiveField(3)
  final String? photoUrl;

  @HiveField(4)
  final String? accessToken;

  LoggedInUser({
    required this.displayName,
    required this.email,
    required this.id,
    this.photoUrl,
    this.accessToken,
  });

  factory LoggedInUser.fromJson(Map<String, dynamic> json) {
    return LoggedInUser(
      displayName: json['displayName'],
      email: json['email'],
      id: json['id'],
      photoUrl: json['photoUrl'],
      accessToken: json['accessToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'email': email,
      'id': id,
      'photoUrl': photoUrl,
      'accessToken': accessToken,
    };
  }
}
