import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';

WeatherFactory wf = WeatherFactory("5796abbde9106b7da4febfae8c44c232");

class WeatherService {
  void fetchWeather() {}

  void changeLanguage() {
    wf = WeatherFactory("5796abbde9106b7da4febfae8c44c232",
        language: Language.GERMAN);
  }

  Future<bool> checkGeoLocationPerms() async {
    LocationPermission permissions = await Geolocator.checkPermission();
    if (permissions == LocationPermission.denied) {
      permissions = await Geolocator.requestPermission();
      if (permissions == LocationPermission.denied) {
        return false;
      }
    }
    return true;
  }

  Future<List> getCityName() async {
    if (!await checkGeoLocationPerms()) {
      return [];
    }
    final result = await Geolocator.getCurrentPosition();
    Weather weatherResult =
        await wf.currentWeatherByLocation(result.latitude, result.longitude);
    return [
      weatherResult.temperature?.celsius,
      weatherResult.humidity,
      weatherResult.weatherMain
    ];
  }
}
