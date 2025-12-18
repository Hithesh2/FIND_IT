import 'package:flutter/material.dart';

class Constants {
  Constants._();
  // Default padding for screens
  static const defaultPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 10,
  );
  static const defaultGap = 10.0;
  static const defaultBigGap = 10.0;

  static const appLogo = 'assets/images/app_logo.png';
  static const splashGif = 'assets/animations/loadingicon.gif';

  static const help = 'assets/images/help2.png';
  static const droneGif = 'assets/animations/drone_gif.gif';

  static const String home = 'assets/icons_main/home.png';
  static const String found = 'assets/icons_main/found.png';
  static const String lost = 'assets/icons_main/lost.png';
  static const String view = 'assets/icons_main/viewlist.png';

  static const String logo = 'assets/icons_main/logo.png';
  static const String user = 'assets/icons_main/user.png';
  static const String cover = 'assets/icons_main/homepagecover.jpg';

  //! Shared Preferences key
  static const kSHIsOnboardingPlay = 'kSHIsOnboardingPlay';
  static const kSHIsLocalizationPageLoad = 'kSHIsLocalizationPageLoad';
  static const kSHIsLoginSuccess = 'kSHIsLoginSuccess';
  static const kSHIsTutorialPlay = 'kSHIsTutorialPlay';
  static const kSHUserRole = 'kSHUserRole';
  static const kSHLangCode = 'kSHLangCode';
  static const kSHId = 'kSHId';
  static const kSHToken = 'kSHToken';
  static const kSHName = 'kSHName';
  static const kSHUserType = 'kSHUserType';
  static const kSHNic = 'kSHNic';
  static const kSHMobile = 'kSHMobile';
  static const kSHEmail = 'kSHEmail';
  static const kSHImage = 'kSHImage';
  static const kSHDownloadStatus = 'kSHDownloadStatus';
  static const kSHInitializeStatus = 'kSHInitializeStatus';
}
