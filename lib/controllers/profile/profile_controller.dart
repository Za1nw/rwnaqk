import 'package:get/get.dart';
import 'package:rwnaqk/controllers/profile/profile_service.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';

/// Controller for the profile screen.
///
/// Keeps the screen focused on read-only profile data and the primary edit
/// navigation action.
class ProfileController extends GetxController {
  ProfileController(this._service);

  final ProfileService _service;

  String get name => _service.profileName();
  String get phone => _service.profilePhone();
  String get avatarPath => _service.profileAvatarPath();
  String get avatarUrl => _service.profileAvatarUrl();

  List<ProfileStatsItem> get stats => _service.stats();
  List<ProfileInfoItem> get infoItems => _service.infoItems();

  void openEditProfile() {
    Get.toNamed(AppRoutes.editProfile);
  }
}
