import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/car_provider.dart';
import '../models/car.dart';
import 'car_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';
  
  // Default center location (Kigali, Rwanda)
  static const LatLng _defaultCenter = LatLng(-1.94995, 30.05885);

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CarProvider>().fetchCars();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String value) {
    debugPrint('Search TextField changed: $value');
    context.read<CarProvider>().setSearchQuery(value);
  }

  void _handleStatusFilter(String status) {
    setState(() {
      _selectedStatus = status;
    });
    context.read<CarProvider>().setStatusFilter(
          status == 'All' ? null : status,
        );
  }

  void _handleRefresh() {
    context.read<CarProvider>().fetchCars();
  }

  void _handleCarTap(BuildContext context, Car car) {
    showDialog(
      context: context,
      builder: (context) => _buildCarDetailsDialog(context, car),
    );
  }

  Widget _buildCarDetailsDialog(BuildContext context, Car car) {
    return AlertDialog(
      title: Text('Car Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ID: ${car.id}'),
          const SizedBox(height: 8),
          Text('Name: ${car.name}'),
          const SizedBox(height: 8),
          Text('Status: ${car.status}'),
          const SizedBox(height: 8),
          Text('Speed: ${car.speed} km/h'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CarDetailsScreen(car: car),
              ),
            );
          },
          child: const Text('Track This Car'),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name or ID...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              context.read<CarProvider>().setSearchQuery('');
            },
          ),
        ),
        onChanged: _handleSearch,
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          _buildFilterChip('All'),
          _buildFilterChip('Moving'),
          _buildFilterChip('Parking'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(status),
        selected: _selectedStatus == status,
        onSelected: (selected) => _handleStatusFilter(status),
      ),
    );
  }

  Widget _buildMap(List<Car> cars) {
    final center = cars.isNotEmpty
        ? LatLng(cars.first.latitude, cars.first.longitude)
        : _defaultCenter;

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 13.5,
                minZoom: 4,
                maxZoom: 18,
                onMapReady: () {
                  debugPrint('Map is ready');
                  _mapController.move(center, 13.5);
                },
              ),
              children: [
                _buildTileLayer(),
                if (cars.isNotEmpty) _buildMarkerLayer(cars),
              ],
            ),
          ),
        ),
        _buildZoomControls(),
      ],
    );
  }

  Widget _buildTileLayer() {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.example.fleet_monitor',
      tileProvider: NetworkTileProvider(),
      keepBuffer: 5,
      maxZoom: 18,
      minZoom: 4,
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildMarkerLayer(List<Car> cars) {
    return MarkerLayer(
      markers: cars.map((car) {
        return Marker(
          point: LatLng(car.latitude, car.longitude),
          width: 80,
          height: 80,
          child: GestureDetector(
            onTap: () => _handleCarTap(context, car),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.directions_car,
                  color: _getStatusColor(car.status),
                  size: 40,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    car.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildZoomControls() {
    return Positioned(
      right: 16,
      bottom: 16,
      child: Column(
        children: [
          FloatingActionButton.small(
            heroTag: 'zoomIn',
            onPressed: () {
              final currentZoom = _mapController.zoom;
              _mapController.move(_mapController.center, currentZoom + 1);
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'zoomOut',
            onPressed: () {
              final currentZoom = _mapController.zoom;
              _mapController.move(_mapController.center, currentZoom - 1);
            },
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fleet Monitor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildFilterChips(),
            Expanded(
              child: Consumer<CarProvider>(
                builder: (context, carProvider, child) {
                  if (carProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (carProvider.error != null) {
                    return _buildErrorWidget(
                      carProvider.error!,
                      carProvider.fetchCars,
                    );
                  }

                  final cars = carProvider.filteredCars;
                  debugPrint('Number of cars: ${cars.length}');
                  for (var car in cars) {
                    debugPrint('Car: ${car.name} at ${car.latitude}, ${car.longitude}');
                  }

                  return _buildMap(cars);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 