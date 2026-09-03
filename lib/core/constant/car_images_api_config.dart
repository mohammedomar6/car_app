class CarImagesApiConfig {
  const CarImagesApiConfig._();

  static const String baseUrl = 'https://carimagesapi.com';

  // CarImagesAPI documents the API key as safe for browser/frontend use.
  // The API secret is intentionally NOT stored in the Flutter app.
  // Override this at build/run time with:
  // --dart-define=CAR_IMAGES_API_KEY=ci_xxx
  static const String apiKey = String.fromEnvironment(
    'CAR_IMAGES_API_KEY',
    defaultValue: 'ci_336e4027a77baa0347c16238d6d8b7b2d73eaaf2eff3cb891df286d0',
  );
}
