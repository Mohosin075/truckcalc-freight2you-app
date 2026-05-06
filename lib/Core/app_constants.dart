class AppConstants {
  static const String appName = "TruckCalc / Freight2You";
}

enum UserRoles {
  superAdmin,
  admin,
  user,
  organizer;

  String get value {
    switch (this) {
      case UserRoles.superAdmin: return "super_admin";
      case UserRoles.admin: return "admin";
      case UserRoles.user: return "user";
      case UserRoles.organizer: return "organizer";
    }
  }
}

enum UserStatus {
  active,
  inactive,
  deleted;

  String get value => name;
}

enum CalcType {
  load,
  goal,
  cost;

  String get value => name.toUpperCase();
}

enum AuthType {
  resetPassword,
  createAccount;

  String get value => name;
}
