import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/car.dart';
import '../services/car_service.dart';

class CarDetailsScreen extends StatefulWidget {
  final Car car;

  const CarDetailsScreen({super.key, required this.car});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  final MapController _mapController = MapController();
  final CarService _carService = CarService();
  late Car _currentCar;
  Timer? _updateTimer;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _currentCar = widget.car;
    _startPeriodicUpdates();
  }

  void _startPeriodicUpdates() {
    // Update every 5 seconds
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchCarUpdates();
    });
  }

  Future<void> _fetchCarUpdates() async {
    if (_isLoading) return; // Prevent multiple simultaneous requests

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final updatedCar = await _carService.getCarById(_currentCar.id);
      
      if (mounted) {
        setState(() {
          _currentCar = updatedCar;
          _isLoading = false;
        });

        // Update map position if car has moved
        _mapController.move(
          LatLng(_currentCar.latitude, _currentCar.longitude),
          _mapController.zoom,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating car data: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _fetchCarUpdates,
              textColor: Colors.white,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentCar.name),
        actions: [
          IconButton(
            icon: Icon(_isLoading ? Icons.refresh : Icons.refresh),
            onPressed: _isLoading ? null : _fetchCarUpdates,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(_currentCar.latitude, _currentCar.longitude),
                    initialZoom: 15,
                    minZoom: 4,
                    maxZoom: 18,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.fleet_monitor',
                      tileProvider: NetworkTileProvider(),
                      keepBuffer: 5,
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(_currentCar.latitude, _currentCar.longitude),
                          width: 80,
                          height: 80,
                          child: Icon(
                            Icons.directions_car,
                            color: _getStatusColor(_currentCar.status),
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (_isLoading)
                  const Positioned(
                    top: 16,
                    right: 16,
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _fetchCarUpdates,
                          color: Colors.red.shade700,
                        ),
                      ],
                    ),
                  ),
                _buildInfoRow('Status', _currentCar.status),
                const SizedBox(height: 8),
                _buildInfoRow('Speed', '${_currentCar.speed} km/h'),
                const SizedBox(height: 8),
                _buildInfoRow('Location', 
                  '${_currentCar.latitude.toStringAsFixed(6)}, ${_currentCar.longitude.toStringAsFixed(6)}'),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'moving':
        return Colors.green;
      case 'parking':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
} 