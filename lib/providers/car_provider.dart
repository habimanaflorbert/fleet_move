import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/car.dart';
import '../services/car_service.dart';

class CarProvider with ChangeNotifier {
  final CarService _carService = CarService();
  List<Car> _cars = [];
  Car? _selectedCar;
  String? _searchQuery;
  String? _statusFilter;
  bool _isLoading = false;
  String? _error;
  Timer? _updateTimer;
  static const String _carsKey = 'cached_cars';
  static const Duration _updateInterval = Duration(seconds: 5);

  // Getters
  List<Car> get cars => _cars;
  Car? get selectedCar => _selectedCar;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery ?? '';
  String get statusFilter => _statusFilter ?? 'All';

  CarProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadCachedCars();
    _startPeriodicUpdates();
  }

  Future<void> _loadCachedCars() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_carsKey);
      
      if (cachedData != null) {
        final List<dynamic> decodedData = json.decode(cachedData);
        _cars = decodedData.map((json) => Car.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cached cars: $e');
      // Don't set error here as this is just a cache load
    }
  }

  Future<void> _saveCarsToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final carsJson = json.encode(_cars.map((car) => car.toJson()).toList());
      await prefs.setString(_carsKey, carsJson);
    } catch (e) {
      debugPrint('Error saving cars to cache: $e');
      // Don't set error here as this is just a cache save
    }
  }

  void _startPeriodicUpdates() {
    // Initial fetch
    fetchCars();
    
    // Update periodically
    _updateTimer = Timer.periodic(_updateInterval, (timer) {
      fetchCars();
    });
  }

  List<Car> get filteredCars {
    debugPrint('Filtering cars. Total: ${_cars.length}');
    debugPrint('Search query: $_searchQuery');
    debugPrint('Status filter: $_statusFilter');
    
    final filtered = _cars.where((car) {
      final matchesSearch = _searchQuery == null ||
          _searchQuery!.isEmpty ||
          car.name.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
          car.id.toLowerCase().contains(_searchQuery!.toLowerCase());
      
      debugPrint('Car: ${car.name} (ID: ${car.id}), Search match: $matchesSearch');
      
      final matchesStatus = _statusFilter == null ||
          _statusFilter!.isEmpty ||
          _statusFilter == 'All' ||
          (_statusFilter == 'Moving' && car.status.toLowerCase() == 'moving') ||
          (_statusFilter == 'Parking' && car.status.toLowerCase() == 'parking');
      
      debugPrint('Car: ${car.name}, Status: ${car.status}, Status match: $matchesStatus');
      
      return matchesSearch && matchesStatus;
    }).toList();
    
    debugPrint('Filtered cars: ${filtered.length}');
    return filtered;
  }

  Future<void> fetchCars() async {
    if (_isLoading) return; // Prevent multiple simultaneous requests

    try {
      _setLoading(true);
      _error = null;

      final cars = await _carService.fetchCars();
      debugPrint('Fetched ${cars.length} cars');
      
      _cars = cars;
      await _saveCarsToCache();
    } catch (e) {
      debugPrint('Error fetching cars: $e');
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void selectCar(Car car) {
    _selectedCar = car;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    debugPrint('Setting search query: $query');
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    // Only allow 'All', 'Moving', or 'Parking' as status filters
    if (status == null || status.isEmpty || 
        status == 'All' || status == 'Moving' || status == 'Parking') {
      _statusFilter = status;
      notifyListeners();
    }
  }

  void clearFilters() {
    _searchQuery = null;
    _statusFilter = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
} 