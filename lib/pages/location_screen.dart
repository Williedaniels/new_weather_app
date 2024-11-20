import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _searchHistory = [];
  latlong.LatLng? _currentLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context), // Navigate back
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search here',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        onSubmitted: _handleSearch, // Trigger search on enter
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Recent search section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Recent search',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Recent searches list
            Column(
              children: _searchHistory
                  .map((history) => _buildRecentSearchItem(history['city'], history['temperature']))
                  .toList(),
            ),

            // Map section
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    options: const MapOptions(
                      initialCenter: latlong.LatLng(-30.5595, 22.9375), // Default to South Africa
                      initialZoom: 4.5,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      const MarkerLayer(
                        markers: [
                          Marker(
                            point: latlong.LatLng(-33.9249, 18.4241), // Cape Town coordinates
                            width: 40.0,
                            height: 40.0,
                            child: Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.my_location),
                        onPressed: _handleCurrentLocation, // Trigger location navigation
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearchItem(String city, String temperature) {
    return GestureDetector(
      onTap: () => _selectFromHistory(city), // Re-select from history
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.access_time,
                color: Colors.white54,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              city,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              temperature,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSearch(String query) {
    // Simulate a search process with fake data
    const Map<String, latlong.LatLng> cities = {
      'Tokyo': latlong.LatLng(35.6895, 139.6917),
      'Nairobi': latlong.LatLng(-1.286389, 36.817223),
      'Miami': latlong.LatLng(25.7617, -80.1918),
    };

    final location = cities[query];
    if (location != null) {
      setState(() {
        _currentLocation = location;
        _searchHistory.add({
          'city': query,
          'temperature': '${(25 + location.latitude % 10).toStringAsFixed(0)}° / ${(15 + location.longitude % 10).toStringAsFixed(0)}°',
        });
      });
    }
  }

  void _handleCurrentLocation() {
    if (_currentLocation != null) {
      Navigator.pop(context, _currentLocation); // Pass selected location to Home
    }
  }

  void _selectFromHistory(String city) {
    _searchHistory.firstWhere((item) => item['city'] == city);
    setState(() {
      _currentLocation = latlong.LatLng(25, 30); // Use history coordinates
    });
  }
}
