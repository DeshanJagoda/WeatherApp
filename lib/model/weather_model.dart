class WeatherModel {
  final String weatherStatus;
  final String description;
  final String icon;
  final double temperature;
  final double humidity;
  final double windSpeed;
  final double windDirection;
  final double pressure;
  final int sunrise; // Keeping sunrise as an integer (Unix timestamp)
  final DateTime lastUpdate;
  final String city;
  final String country;
  final double lat;
  final double lon;
  final double timezone;
  

  WeatherModel({
    required this.weatherStatus,
    required this.description,
    required this.icon,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.pressure,
    required this.sunrise,
    required this.lastUpdate,
    required this.city,
    required this.country,
    required this.lat,
    required this.lon,
    required this.timezone,
  });

  /// Factory constructor to create an instance of `WeatherModel` from JSON data
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
        weatherStatus: json['weather'][0]['main'] as String,
        description: json['weather'][0]['description'] as String,
        icon: json['weather'][0]['icon'] as String,
        temperature: (json['main']['temp'] as num).toDouble(),
        humidity: (json['main']['humidity'] as num).toDouble(),
        windSpeed: (json['wind']['speed'] as num).toDouble(),
        windDirection: (json['wind']['deg'] as num).toDouble(),
        pressure: (json['main']['pressure'] as num).toDouble(),
        sunrise: json['sys']['sunrise'] as int, // Unix timestamp for sunrise
        lastUpdate: DateTime.fromMillisecondsSinceEpoch(
          (json['dt'] as int) * 1000, // Convert seconds to milliseconds
        ),
        city: json['name'] as String,
        country: json['sys']['country'] as String,
        lat: json['coord']['lat'] as double,
        lon: json['coord']['lon'] as double,
        timezone: json['timezone'] as double);
  }
}
