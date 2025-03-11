import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherAPI {
  // Define the API key and base URL
  static const String _apiKey = '672423a2cbba8103c7214eb92e386f5c';
  static const String _baseUrl = 'api.openweathermap.org';

  Future<Map<String, dynamic>> getCityWeather(String city) async {
    try {
      // Construct the URL with query parameters
      var url = Uri.https(
        _baseUrl,
        '/data/2.5/weather',
        {
          'q': city,
          'units': 'metric', // Metric units for temperature (°C)
          'appid': _apiKey,  // Your OpenWeatherMap API key
        },
      );

      // Send the GET request
      var response = await http.get(url);

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Parse the JSON response body
        return jsonDecode(response.body);
      } else {
        // Handle errors, such as city not found or invalid API key
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      // Catch and handle any exceptions (e.g., network errors)
      throw Exception('Error fetching weather data: $e');
    }
  }
}
