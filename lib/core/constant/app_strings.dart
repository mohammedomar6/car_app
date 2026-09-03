import 'package:car_app/core/utils/secure_storage.dart';
import 'package:easy_localization/easy_localization.dart';

class AppStrings {
  // splash
  static String logoText = 'VELOCITY';

  // onboarding data
  static String get titleO1 => 'app_title_o1'.tr();

  static String get titleO2 => 'app_title_o2'.tr();

  static String get titleO3 => 'app_title_o3'.tr();

  static String get disO1 => 'app_description_o1'.tr();

  static String get disO2 => 'app_description_o2'.tr();

  static String get disO3 => 'app_description_o3'.tr();

  // onboarding
  static String get next => 'app_next'.tr();

  static String get back => 'app_back'.tr();

  static String get skip => 'app_skip'.tr();

  static String get start => 'app_start'.tr();

  // auth _ login
  static String get welcome => 'app_welcome'.tr();
  static String get haveAccount => 'app_no_account'.tr();
  static String get createAccount => 'app_create_account'.tr();
  static String get signIn => 'app_sign_in'.tr();
  static String get password => 'app_password'.tr();
  static String get email => 'app_email'.tr();
  static String hint = 'example@velocity.com';
  static String obscure = "********";
  static String get create => 'app_create'.tr();
  static String get account => 'app_account_upper'.tr();
  static String get account2 => 'app_account'.tr();
  static String get fullName => 'app_full_name'.tr();
  static String get phoneNumber => 'app_phone_number'.tr();
  static String hintName = "JOHN DOE";
  static String hintPhoneNumber = "09xxxxxxxx";
  static String get alreadyHaveAccount => 'app_have_account'.tr();
  static String get home => 'app_home'.tr();
  static String get search => 'app_search'.tr();
  static String get favorites => 'app_favorites'.tr();

  static String get profile => 'app_profile'.tr();
  static String get textFieldSearch => 'app_search_hint'.tr();
  static String get sellCar => 'app_sell_car'.tr();
  static String get rentCar => 'app_rent_car'.tr();
  static String get finance => 'app_finance'.tr();
  static String get concierge => 'app_concierge'.tr();
  static String get featureCars => 'app_featured_cars'.tr();
  static String get viewAll => 'app_view_all'.tr();
  static String get brands => 'app_browse_brands'.tr();
  static String get subtitleBrand => 'app_brands_subtitle'.tr();
  static String get garage => 'app_my_garage'.tr();
  static String get list => 'app_my_listings'.tr();
  static String get history => 'app_order_history'.tr();
  static String get transactions => 'app_contracts_payments'.tr();
  static String get security => 'app_security'.tr();
  static String get support => 'app_support'.tr();
  static String get logOut => 'app_logout'.tr();
  static String get carsInGarage => 'app_cars_in_garage'.tr();
  static String get activeListing => 'app_active_listings'.tr();
  static String baseUrl = "http://192.168.100.243:5222/api/";
  static Map<String, String> headerApi = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer ${SecureStorageService.getToken()}',
  };
  static String get speed => 'app_top_speed'.tr();
  static String get km => 'app_acceleration'.tr();
  static String get horsepower => 'app_horsepower'.tr();
  static String get engine => 'app_engine'.tr();
  static String get description => 'app_description'.tr();
  static String get technical => 'app_technical_specs'.tr();
  static String get fuelType => 'app_fuel_type'.tr();
  static String get color => 'app_exterior_color'.tr();
  static String get driveType => 'app_drive_type'.tr();
  static String get spareType => 'app_spare_type'.tr();
  static String get privacy => 'app_security_privacy'.tr();
  static String get name => 'app_name'.tr();
  static String get location => 'app_location'.tr();
  static String get phone => 'app_phone'.tr();
  static String get privacySecurity => 'app_security_privacy'.tr();
  static String get aboutAccount => 'app_about_account'.tr();
  static String get editProfile => 'app_edit_profile'.tr();
  static String get changePassword => 'app_change_password'.tr();
  static String get danger => 'app_danger_zone'.tr();
  static String get delete => 'app_delete_account'.tr();

  static Future<Map<String, String>> getHeaderApi() async {
    final token = await SecureStorageService.getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<String?> getRole() async {
    final role = await SecureStorageService.getRole();
    return role;

  }
 static String imageBaseUrl = "http://192.168.100.243:5222";
}
