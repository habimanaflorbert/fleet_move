import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/car.dart';

class CarService {
  static const String _baseUrl = 'https://6828a6f66075e87073a48111.mockapi.io/api/v1';

  Future<List<Car>> fetchCars() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/cars'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Car.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load cars: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching cars: $e');
      throw Exception('Failed to connect to the server');
    }
  }

  Future<List<Car>> getCars() async {
    try {
      return await fetchCars();
    } catch (e) {
      debugPrint('Error in getCars: $e');
      return [];
    }
  }

  Future<Car> getCarById(String id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/cars/$id'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Car.fromJson(data);
      } else {
        throw Exception('Failed to load car: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching car: $e');
      throw Exception('Failed to connect to the server');
    }
  }

  // Get cars data in JSON format
  Future<String> getCarsJson() async {
    try {
      final cars = await fetchCars();
      final List<Map<String, dynamic>> carsJson = cars.map((car) => car.toJson()).toList();
      return const JsonEncoder.withIndent('  ').convert(carsJson);
    } catch (e) {
      debugPrint('Error in getCarsJson: $e');
      throw Exception('Failed to get cars data in JSON format');
    }
  }
} 