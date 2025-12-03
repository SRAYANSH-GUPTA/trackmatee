import 'package:get/get.dart';
import '../controllers/stats_controller.dart'
import '../services/stats_api_service.dart';
import '../services/auth_service.dart';

class StatsController extends GetxController {
  final StatsApiService _apiService = StatsApiService();

  // Observable variables
  var isLoading = true.obs;
  var dailyScore = Rx<DailyScoreResponse?>(null);
  var calendarStats = Rx<CalendarStatsResponse?>(null);
  var monthlyChart = Rx<MonthlyChartResponse?>(null);
  var selectedMonth = DateTime.now().obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // ⭐ GET TOKEN FROM YOUR EXISTING AUTH SERVICE
    try {
      final authService = Get.find<AuthService>();
      final token = authService.token;

      if (token != null && token.isNotEmpty) {
        _apiService.setAuthToken(token);
        loadAllData();
      } else {
        errorMessage.value = 'Please login to view stats';
        isLoading.value = false;
      }
    } catch (e) {
      print('Error getting auth token: $e');
      errorMessage.value = 'Authentication error. Please login again.';
      isLoading.value = false;
    }
  }

  // Load all data for the stats screen
  Future<void> loadAllData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await Future.wait([
        fetchDailyScore(),
        fetchCalendarStats(),
        fetchMonthlyChart(),
      ]);
    } catch (e) {
      errorMessage.value = 'Failed to load stats: $e';
      print('Error loading stats: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch daily score
  Future<void> fetchDailyScore({String? date}) async {
    try {
      final response = await _apiService.getDailyScore(date: date);
      dailyScore.value = response;
    } catch (e) {
      print('Error fetching daily score: $e');
      rethrow;
    }
  }

  // Fetch calendar stats
  Future<void> fetchCalendarStats() async {
    try {
      final response = await _apiService.getCalendarStats(
        month: selectedMonth.value.month,
        year: selectedMonth.value.year,
      );
      calendarStats.value = response;
    } catch (e) {
      print('Error fetching calendar stats: $e');
      rethrow;
    }
  }

  // Fetch monthly chart data
  Future<void> fetchMonthlyChart() async {
    try {
      final response = await _apiService.getMonthlyChart(
        month: selectedMonth.value.month,
        year: selectedMonth.value.year,
      );
      monthlyChart.value = response;
    } catch (e) {
      print('Error fetching monthly chart: $e');
      rethrow;
    }
  }

  // Change month and refresh data
  void changeMonth(DateTime newMonth) {
    selectedMonth.value = newMonth;
    fetchCalendarStats();
    fetchMonthlyChart();
  }

  void previousMonth() {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month - 1,
    );
    fetchCalendarStats();
    fetchMonthlyChart();
  }

  void nextMonth() {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month + 1,
    );
    fetchCalendarStats();
    fetchMonthlyChart();
  }

  // Pull to refresh
  Future<void> refresh() async {
    await loadAllData();
  }
}