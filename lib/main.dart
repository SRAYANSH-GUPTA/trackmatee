// =============================================================
//                      TRACKMATE - MAIN APP (CLEAN BUILD)
// =============================================================
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// =============== SERVICES ===============
import 'package:trackmate_app/services/auth_service.dart';
import 'package:trackmate_app/services/localization_service.dart';
import 'package:trackmate_app/services/stats_api_service.dart';

// =============== CONTROLLERS ===============
import 'package:trackmate_app/controllers/profile_controller.dart';
import 'package:trackmate_app/controllers/language_controller.dart';
import 'package:trackmate_app/controllers/location_controller.dart';
import 'package:trackmate_app/controllers/saved_places_controller.dart';
import 'package:trackmate_app/controllers/stats_controller.dart';

// =============== ONBOARDING ===============
import 'package:trackmate_app/screens/onboarding/splash_screen.dart';
import 'package:trackmate_app/screens/onboarding/welcome_screen.dart';
import 'package:trackmate_app/screens/onboarding/permissions_screen.dart';
import 'package:trackmate_app/screens/onboarding/main_navigation_screen.dart';
import 'package:trackmate_app/screens/onboarding/terms_of_use_screen.dart';

// =============== AUTH ===============
import 'package:trackmate_app/screens/auth/login_screen.dart';
import 'package:trackmate_app/screens/auth/signup_screen.dart';
import 'package:trackmate_app/screens/auth/reset_password_screen.dart';
import 'package:trackmate_app/screens/auth/otp_verification.dart';
import 'package:trackmate_app/screens/auth/otp_verification_reset.dart';
import 'package:trackmate_app/screens/auth/forgot_password_screen.dart';
import 'package:trackmate_app/screens/auth/forgot_otp_screen.dart';

// =============== MAIN SCREENS ===============
import 'package:trackmate_app/screens/discover/discover_screen.dart';
import 'package:trackmate_app/screens/onboarding/home_screen.dart';

// =============== AI CHECKLIST ===============
import 'package:trackmate_app/screens/ai_checklist_screen.dart';

// =============== USER CONTRIBUTION / STATS ===============
import 'package:trackmate_app/screens/my_stats.dart';

// =============================================================
//                           ENTRY POINT
// =============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  try {
    await dotenv.load();
  } catch (e) {
    debugPrint("⚠️ .env not loaded => $e");
  }

  // ====== SERVICES / CONTROLLERS ======
  Get.put(AuthService(), permanent: true);
  Get.put(ProfileController(), permanent: true);
  Get.put(LanguageController(), permanent: true);
  Get.put(LocationController(), permanent: true);
  Get.lazyPut(() => SavedPlacesController());

  // ====== STATS SERVICE (NEW) ======
  Get.lazyPut(() => StatsController());

  runApp(const TrackMateApp());
}

// =============================================================
//                        ROOT APP
// =============================================================

class TrackMateApp extends StatelessWidget {
  const TrackMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "TrackMate",
      debugShowCheckedModeBanner: false,

      translations: LocalizationService(),
      locale: LocalizationService.fallbackLocale,
      fallbackLocale: const Locale('en', 'US'),

      initialRoute: "/",

      theme: ThemeData.dark(useMaterial3: true).copyWith(
        primaryColor: const Color(0xFF8B5CF6),
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
      ),

      getPages: [

        /// ======== ONBOARDING ========
        GetPage(name: "/", page: () => const SplashScreen()),
        GetPage(name: "/welcome", page: () => const WelcomeScreen()),
        GetPage(name: "/permissions", page: () => const LocationPermissionScreen()),
        GetPage(name: "/terms", page: () => const TermsOfUseScreen()),
        GetPage(name: "/home", page: () => const MainNavigationScreen()),

        /// ======== AUTH ========
        GetPage(name: "/login", page: () => const LoginScreen()),
        GetPage(name: "/signup", page: () => const SignUpScreen()),
        GetPage(name: "/reset-password", page: () => const ResetPasswordScreen()),
        GetPage(name: "/otp", page: () => const OtpVerificationScreen()),
        GetPage(name: "/otp-reset", page: () => const OtpVerificationResetScreen()),
        GetPage(name: "/forgot-password", page: () => const ForgotPasswordScreen()),
        GetPage(name: "/forgot-otp", page: () => const ForgotOtpVerifyScreen()),

        /// ======== MAIN SCREENS ========
        GetPage(name: "/discover", page: () => const DiscoverScreen()),
        GetPage(name: "/dashboard", page: () => const HomeScreen()),

        /// ======== AI CHECKLIST ========
        GetPage(name: "/ai-checklist", page: () => AiChecklistScreen()),

        /// ======== STATS / CONTRIBUTION ========
        GetPage(name: "/my-stats", page: () => const MyStatsScreen()),
    // Add this temporarily in your main.dart or any screen
    void printToken() {
    final token = GetStorage().read('auth_token'); // or your key
    print('🔑 STORED TOKEN: $token');
    }
      ],
    );
  }
}