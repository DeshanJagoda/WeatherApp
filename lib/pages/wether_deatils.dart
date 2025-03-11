import 'package:flutter/material.dart';
import 'package:weather/model/weather_model.dart';

class WeatherDetails extends StatefulWidget {
  final WeatherModel weather;

  const WeatherDetails({super.key, required this.weather});

  @override
  State<WeatherDetails> createState() => _WeatherDetailsState();
}

class _WeatherDetailsState extends State<WeatherDetails>
    with SingleTickerProviderStateMixin {
  late bool shouldDisplayWeatherDetails;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool isLoading = false; // Simulate loading state

  @override
  void initState() {
    super.initState();
    shouldDisplayWeatherDetails = widget.weather.temperature > 10;

    // Initialize animation controller for slide effect
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Slide animation from bottom to top
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start the animation on page load
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 41, 64, 231),
                Colors.blue.shade700,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFECEFF1), // Light gray
              Colors.blue.shade50, // Light blue
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          color: Colors.blue.shade700,
          backgroundColor: Colors.white,
          onRefresh: _fetchWeatherData,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth > 600 ? 64 : 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (shouldDisplayWeatherDetails)
                        FadeTransition(
                          opacity: _animationController,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                Hero(
                                  tag: 'weather-${widget.weather.city}',
                                  child: Icon(
                                    _getWeatherIcon(widget.weather.icon),
                                    size: 64,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                WeatherDetailCard(
                                  label: 'City:',
                                  value:
                                      '${widget.weather.city}, ${widget.weather.country}',
                                  icon: Icons.location_city,
                                  isHighlight: true,
                                ),
                                WeatherDetailCard(
                                  label: 'Weather:',
                                  value: widget.weather.weatherStatus,
                                  icon: _getWeatherIcon(widget.weather.icon),
                                ),
                                WeatherDetailCard(
                                  label: 'Description:',
                                  value: widget.weather.description,
                                  icon: Icons.description,
                                ),
                                WeatherDetailCard(
                                  label: 'Temperature:',
                                  value:
                                      '${widget.weather.temperature.toStringAsFixed(1)}°C',
                                  icon: Icons.thermostat,
                                ),
                                WeatherDetailCard(
                                  label: 'Humidity:',
                                  value: '${widget.weather.humidity}%',
                                  icon: Icons.water_drop,
                                ),
                                WeatherDetailCard(
                                  label: 'Wind Speed:',
                                  value: '${widget.weather.windSpeed} m/s',
                                  icon: Icons.air,
                                ),
                                WeatherDetailCard(
                                  label: 'Wind Direction:',
                                  value: '${widget.weather.windDirection}°',
                                  icon: Icons.navigation,
                                ),
                                WeatherDetailCard(
                                  label: 'Pressure:',
                                  value: '${widget.weather.pressure} hPa',
                                  icon: Icons.speed,
                                ),
                                WeatherDetailCard(
                                  label: 'Sunrise:',
                                  value:
                                      _formatTimestamp(widget.weather.sunrise),
                                  icon: Icons.wb_sunny_outlined,
                                ),
                                WeatherDetailCard(
                                  label: 'Last Update:',
                                  value: _formatDateTime(
                                      widget.weather.lastUpdate),
                                  icon: Icons.update,
                                ),
                                WeatherDetailCard(
                                  label: 'Latitude:',
                                  value: '${widget.weather.lat}',
                                  icon: Icons.pin_drop,
                                ),
                                WeatherDetailCard(
                                  label: 'Longitude:',
                                  value: '${widget.weather.lon}',
                                  icon: Icons.pin_drop,
                                ),
                                WeatherDetailCard(
                                  label: 'Timezone Offset:',
                                  value: '${widget.weather.timezone} seconds',
                                  icon: Icons.timer,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              "Weather data does not meet the filtering criteria.",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'Weather data provided by OpenWeatherMap',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  // Fetch weather data (simulated)
  Future<void> _fetchWeatherData() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2)); // Simulate network call
    setState(() => isLoading = false);
  }

  // Get weather icon based on weather status
  IconData _getWeatherIcon(String icon) {
    const weatherIcons = {
      'clear sky': Icons.sunny,
      'clear': Icons.sunny,
      'few clouds': Icons.cloud,
      'clouds': Icons.cloud,
      'light rain': Icons.beach_access,
      'rain': Icons.beach_access,
      'snow': Icons.ac_unit,
      'thunderstorm': Icons.flash_on,
      'storm': Icons.flash_on,
    };
    return weatherIcons[icon.toLowerCase()] ?? Icons.help_outline;
  }

  // Format timestamp to a readable time
  String _formatTimestamp(int timestamp) {
    final date =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).toLocal();
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Format DateTime to a readable string
  String _formatDateTime(DateTime dateTime) {
    final localTime = dateTime.toLocal();
    return '${localTime.day}/${localTime.month}/${localTime.year} ${localTime.hour}:${localTime.minute}';
  }
}

// WeatherDetailCard widget for reusable weather detail cards
class WeatherDetailCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isHighlight;

  const WeatherDetailCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isHighlight ? const Color(0xFFC5CAE9) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.1),
              offset: const Offset(0, 4),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isHighlight ? const Color(0xFF283593) : const Color(0xFF607D8B),
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isHighlight ? const Color(0xFF283593) : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    softWrap: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}