import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = '2356b0f9ddf334980776eddb1b5d26ca'; // Replace with your API key
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Map<String, dynamic>> getWeather(String cityName) async {
    final response = await http.get(Uri.parse(
        '$baseUrl?q=$cityName&appid=$apiKey&units=metric&lang=en'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
