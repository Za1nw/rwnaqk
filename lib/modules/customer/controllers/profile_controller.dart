import 'package:get/get.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_service.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

/// Controller for the profile screen.
///
/// Keeps the screen focused on reactive profile data, VIP perks,
/// and smooth navigation.
class ProfileController extends GetxController {
  ProfileController(this._service);

  final ProfileService _service;

  String get name => _service.profileName();
  String get phone => _service.profilePhone();
  String get avatarPath => _service.profileAvatarPath();
  String get avatarUrl => _service.profileAvatarUrl();

  String get membershipTier => _service.membershipTier();
  String get membershipBadge => _service.membershipBadge();
  String get membershipPerk => _service.membershipPerk();

  List<ProfileStatsItem> get stats => _service.stats();
  List<ProfileInfoItem> get infoItems => _service.infoItems();

  void openEditProfile() {
    Get.toNamed(AppRoutes.editProfile);
  }
}
