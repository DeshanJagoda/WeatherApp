import 'package:flutter/material.dart';
import 'package:weather/model/weather_model.dart';
import 'package:intl/intl.dart';
import 'package:weather/pages/wether_deatils.dart';
import 'package:weather/services/weater_api.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final List<String> cities = ['Colombo', 'Galle', 'Kandy', 'Jaffna'];
  final TextEditingController searchController = TextEditingController();
  List<String> filteredCities = [];
  WeatherModel? weather;
  bool isLoading = false;
  bool isSearching = false;
  late AnimationController _animationController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    filteredCities = cities;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    _animationController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _filterCities(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        filteredCities = cities
            .where((city) => city.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    });
  }

  void _fetchWeather(String cityName) async {
    setState(() {
      isLoading = true;
    });
    try {
      Map<String, dynamic> data = await WeatherAPI().getCityWeather(cityName);
      setState(() {
        weather = WeatherModel.fromJson(data);
        _animationController.forward(from: 0); // Start animation
      });
    } catch (e) {
      setState(() {
        weather = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to fetch weather data. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _toggleSearchMode() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        searchController.clear();
        _filterCities('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isSearching
              ? TextField(
                  key: const ValueKey("searchField"),
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search city name',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: _filterCities,
                )
              : const Text(
                  'Weather App',
                  key: ValueKey("appBarTitle"),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: _toggleSearchMode,
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF447BFF), Color(0xFF6A11CB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            AnimatedOpacity(
              opacity: weather == null ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Text(
                'Select a city to view the weather',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0D47A1),
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filteredCities.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: CityButton(
                      cityName: filteredCities[index],
                      onPressed: (cityName) => _fetchWeather(cityName),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  if (weather != null) {
                    _fetchWeather(weather!.city);
                  }
                },
                child: SingleChildScrollView(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : weather == null
                            ? Center(
                                child: Text(
                                  'No city selected yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF757575),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              )
                            : ScaleTransition(
                                scale: CurvedAnimation(
                                  parent: _animationController,
                                  curve: Curves.easeInOut,
                                ),
                                child: WeatherDetailsCard(weather: weather!),
                              ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Create a separate controller for the dialog
          TextEditingController dialogController = TextEditingController();

          // Show the dialog
          final newCity = await showDialog<String>(
            context: context,
            builder: (context) {
              // Create a FocusNode for the TextField
              FocusNode textFieldFocusNode = FocusNode();

              // Request focus after the dialog is built
              WidgetsBinding.instance.addPostFrameCallback((_) {
                textFieldFocusNode.requestFocus();
              });

              return AlertDialog(
                title: const Text('Add City'),
                content: TextField(
                  controller: dialogController,
                  focusNode: textFieldFocusNode, // Assign the FocusNode
                  decoration: const InputDecoration(
                    hintText: 'Enter city name',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      // Close the dialog without adding a city
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      // Get the input and validate it
                      final input = dialogController.text.trim();
                      if (input.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('City name cannot be empty.'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      } else {
                        // Close the dialog and return the input
                        Navigator.pop(context, input);
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );

          // If a valid city name was provided, process it
          if (newCity != null && newCity.isNotEmpty) {
            if (!cities.contains(newCity)) {
              setState(() {
                cities.add(newCity); // Add the city to the list
                _filterCities(
                    searchController.text); // Update the filtered list
              });
            } else {
              // Notify the user if the city already exists
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('City already exists.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          }
        },
        backgroundColor: const Color(0xFF1565C0),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CityButton extends StatelessWidget {
  final String cityName;
  final Function(String) onPressed;

  const CityButton({
    super.key,
    required this.cityName,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onPressed(cityName),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1565C0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 4,
      ),
      child: Text(
        cityName,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}

class WeatherDetailsCard extends StatelessWidget {
  final WeatherModel weather;

  const WeatherDetailsCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final String formattedSunrise = DateFormat('h:mm a')
        .format(DateTime.fromMillisecondsSinceEpoch(weather.sunrise * 1000));
    final DateTime formattedLastUpdate = weather.lastUpdate;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    weather.city,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0D47A1),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Image.network(
                    'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    weather.weatherStatus,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1976D2),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weather.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color(0xFF757575),
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Divider(height: 32, thickness: 1, color: Color(0xFFBDBDBD)),
            WeatherDetailRow(
              label: 'Temperature',
              value: '${weather.temperature.toStringAsFixed(1)} °C',
              icon: Icons.thermostat_outlined,
            ),
            WeatherDetailRow(
              label: 'Humidity',
              value: '${weather.humidity.toStringAsFixed(1)}%',
              icon: Icons.water_drop,
            ),
            WeatherDetailRow(
              label: 'Wind Speed',
              value: '${weather.windSpeed.toStringAsFixed(1)} m/s',
              icon: Icons.air,
            ),
            WeatherDetailRow(
              label: 'Pressure',
              value: '${weather.pressure.toStringAsFixed(1)} hPa',
              icon: Icons.speed,
            ),
            WeatherDetailRow(
              label: 'Wind Direction',
              value: '${weather.windDirection}°',
              icon: Icons.explore_outlined,
            ),
            WeatherDetailRow(
              label: 'Sunrise',
              value: formattedSunrise,
              icon: Icons.wb_sunny_outlined,
            ),
            WeatherDetailRow(
              label: 'Last Update',
              value: formattedLastUpdate.toLocal().toIso8601String(),
              icon: Icons.update,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeatherDetails(weather: weather),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const WeatherDetailRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF1976D2),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF0D47A1),
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1976D2),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}