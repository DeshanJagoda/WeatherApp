import 'package:flutter/material.dart';

class CityButton extends StatelessWidget {
  final String cityName;
  final Function(String) onPressed;
  final Color buttonColor;
  final Color textColor;

  const CityButton({
    required this.cityName,
    required this.onPressed,
    this.buttonColor = Colors.blueAccent, // Default button color
    this.textColor = Colors.white, // Default text color
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor, // Customizable button color
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Padding around the text
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Rounded corners for the button
        ),
        elevation: 5, // Optional elevation for the button's shadow
      ),
      onPressed: () => onPressed(cityName),
      child: Text(
        cityName,
        style: TextStyle(
          color: textColor, // Customizable text color
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
