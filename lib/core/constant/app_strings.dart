import 'package:car_app/core/utils/secure_storage.dart';

class AppStrings {
  // splash
  static String logoText = 'VELOCITY';

  // onboarding data
  static String titleO1 = 'Drive Your Next Deal with Velocity';

  static String titleO2 = 'Find Cars That Move You';

  static String titleO3 = 'Modern Cars. Smart Choices';

  static String disO1 =
      'buy, and sell cars easily from one place. Explore top dealerships near you.';

  static String disO2 =
      'Browse the latest cars, compare prices, and connect with trusted dealerships instantly.';

  static String disO3 =
      'Your all-in-one marketplace for buying, selling, and exploring the best cars with confidence.';

  // onboarding
  static String next = 'Next';

  static String back = 'Back';

  static String skip = 'Skip';

  static String start = 'Let’s Start';
  // auth _ login
static String welcome='Welcome Back';
static String haveAccount="Don't have an account?";
static String createAccount="Create Account";
static String signIn="SIGN IN";
static String password = "PASSWORD";
static String email = "EMAIL ADDRESS";
static String  hint ='example@velocity.com';
static String obscure ="********";
static String create ="CREATE ";
static String account ="ACCOUNT";
static String account2 ="Account";
static String fullName ="FULL NAME";
static String phoneNumber ="PHONE NUMBER";
static String hintName ="JOHN DOE";
static String hintPhoneNumber ="09xxxxxxxx";
static String alreadyHaveAccount ="Already have an account? ";
static String home ="Home";
static String search ='Search';
static String favorites ="Favorites" ;
static String profile ="Profile";
static String textFieldSearch ="Search for your next supercar...";
static String sellCar ="Sell Car";
static String rentCar ="Rent Car";
static String finance ="Finance";
static String concierge ="Concierge";
static String featureCars ="Featured Supercars";
static String viewAll  ="View All";
static String brands  ="Browse Brands";
static String subtitleBrand  ="Discover excellence through our curated selection of high-performance automotive legends";
static String garage="My Garage";
static String list="My Listings";
static String history="Order History";
static String security="Security";
static String support="Concierge Support";
static String logOut="Logout";
static String carsInGarage="Cars in Garage";
static String activeListing="Active Listings";
static String baseUrl="http://192.168.100.8:5222/api/";
static Map<String,String> headerApi={
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'Bearer ${SecureStorageService.getToken()}',
};
static String speed ="Top Speed";
static String km ="0-100 km/h";
static String horsepower ="Horsepower";
static String engine ="Engine";
static String description ="Description";
static String technical ="Technical Specs";
static String fuelType ="Fuel Type";
static String color ="Exterior Color";
static String driveType ="Drive Type";
static String spareType ="Spare Type";
static String  privacy ="Security & Privacy";
static String  name ="Name";
static String  location ="Location";
static String  phone ="Phone";
static String  privacySecurity ="Security & Privacy";
static String  aboutAccount ="About Account";
static String  editProfile ="Edit Profile";
static String  changePassword ="Change Password";
static String  danger ="DANGER ZONE";
static String  delete ="Delete Account";


}
