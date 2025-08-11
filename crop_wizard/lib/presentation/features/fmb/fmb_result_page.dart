// // lib/presentation/features/fmb_result_page.dart
// import 'package:crop_wizard/domain/entities/fmb_result.dart';
// import 'package:crop_wizard/presentation/providers/fmb_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:provider/provider.dart';

// import '../home/home_page.dart';

// class FmbResultPage extends StatefulWidget {
//   const FmbResultPage({super.key});

//   @override
//   State<FmbResultPage> createState() => _FmbResultPageState();
// }

// class _FmbResultPageState extends State<FmbResultPage> {
//   final MapController _mapController = MapController();
//   bool _showFilters = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadData();
//     });
//   }

//   void _loadData() {
//     const url =
//         'https://main.d35889sospji4x.amplifyapp.com/sipcot/data/villages/site_1_kangeyam/fmb.geojson';
//     context.read<FmbProvider>().loadFmbData(url);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('FMB Map Viewer'),
//         backgroundColor: Colors.green[700],
//         foregroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon:
//                 Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
//             onPressed: () {
//               setState(() {
//                 _showFilters = !_showFilters;
//               });
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () {
//               context.read<FmbProvider>().refreshData();
//             },
//           ),
//         ],
//       ),
//       body: Consumer<FmbProvider>(
//         builder: (context, provider, child) {
//           if (provider.isLoading) {
//             return Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [Colors.green[50]!, Colors.white],
//                 ),
//               ),
//               child: const Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
//                     ),
//                     SizedBox(height: 24),
//                     Text(
//                       'Loading FMB data...',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       'Please wait while we fetch the land survey data',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }

//           if (provider.error != null) {
//             return Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [Colors.red[50]!, Colors.white],
//                 ),
//               ),
//               child: Center(
//                 child: Padding(
//                   padding: const EdgeInsets.all(24.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(24),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(16),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.1),
//                               blurRadius: 20,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           children: [
//                             Icon(
//                               Icons.error_outline,
//                               size: 64,
//                               color: Colors.red[400],
//                             ),
//                             const SizedBox(height: 16),
//                             const Text(
//                               'Unable to Load Data',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 12),
//                             Container(
//                               padding: const EdgeInsets.all(12),
//                               decoration: BoxDecoration(
//                                 color: Colors.red[50],
//                                 borderRadius: BorderRadius.circular(8),
//                                 border: Border.all(color: Colors.red[200]!),
//                               ),
//                               child: Text(
//                                 provider.error!,
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   color: Colors.red[700],
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 24),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                               children: [
//                                 OutlinedButton.icon(
//                                   onPressed: () => Navigator.pop(context),
//                                   icon: const Icon(Icons.arrow_back),
//                                   label: const Text('Go Back'),
//                                 ),
//                                 ElevatedButton.icon(
//                                   onPressed: _loadData,
//                                   icon: const Icon(Icons.refresh),
//                                   label: const Text('Retry'),
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.green[700],
//                                     foregroundColor: Colors.white,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }

//           return Column(
//             children: [
//               if (_showFilters) _buildFilterSection(provider),
//               _buildMapInfoBar(provider),
//               Expanded(
//                 child: _buildMap(provider),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildFilterSection(FmbProvider provider) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.tune, color: Colors.green[700], size: 20),
//               const SizedBox(width: 8),
//               const Text(
//                 'Filter Options',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               const Spacer(),
//               TextButton.icon(
//                 onPressed: provider.clearFilters,
//                 icon: const Icon(Icons.clear_all, size: 16),
//                 label: const Text('Clear All'),
//                 style: TextButton.styleFrom(
//                   foregroundColor: Colors.grey[600],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: [
//                 _buildDropdownCard(
//                   'Kharif Crop',
//                   provider.selectedKharifCrop ?? 'All',
//                   provider.availableKharifCrops,
//                   (value) {
//                     provider.setKharifCropFilter(value == 'All' ? null : value);
//                   },
//                   Icons.grass,
//                   Colors.green,
//                 ),
//                 const SizedBox(width: 12),
//                 _buildDropdownCard(
//                   'Rabi Crop',
//                   provider.selectedRabiCrop ?? 'All',
//                   provider.availableRabiCrops,
//                   (value) {
//                     provider.setRabiCropFilter(value == 'All' ? null : value);
//                   },
//                   Icons.eco,
//                   Colors.orange,
//                 ),
//                 const SizedBox(width: 12),
//                 _buildDropdownCard(
//                   'Land Type',
//                   provider.selectedLandType ?? 'All',
//                   provider.availableLandTypes,
//                   (value) =>
//                       provider.setLandTypeFilter(value == 'All' ? null : value),
//                   Icons.terrain,
//                   Colors.brown,
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 12),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             decoration: BoxDecoration(
//               color: Colors.green[50],
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.green[200]!),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.info_outline, size: 16, color: Colors.green[700]),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Showing ${provider.filteredResults.length} of ${provider.fmbResults.length} land parcels',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.green[700],
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDropdownCard(
//     String label,
//     String selectedValue,
//     List<String> options,
//     Function(String?) onChanged,
//     IconData icon,
//     MaterialColor color,
//   ) {
//     return Container(
//       width: 160,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[300]!),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: color[50],
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Icon(icon, size: 16, color: color[700]),
//                 const SizedBox(width: 6),
//                 Expanded(
//                   child: Text(
//                     label,
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: color[700],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             child: DropdownButtonHideUnderline(
//               child: DropdownButton<String>(
//                 value: selectedValue,
//                 isExpanded: true,
//                 isDense: true,
//                 items: options.map((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(
//                       value,
//                       style: const TextStyle(fontSize: 13),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   );
//                 }).toList(),
//                 onChanged: onChanged,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMapInfoBar(FmbProvider provider) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.green[600]!, Colors.green[700]!],
//         ),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.touch_app, color: Colors.white, size: 20),
//           const SizedBox(width: 8),
//           const Expanded(
//             child: Text(
//               'Tap any polygon to view detailed property information',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w500,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Text(
//               '${provider.filteredResults.length} plots',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMap(FmbProvider provider) {
//     if (provider.filteredResults.isEmpty) {
//       return Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.grey[100]!, Colors.white],
//           ),
//         ),
//         child: const Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.map_outlined, size: 80, color: Colors.grey),
//               SizedBox(height: 16),
//               Text(
//                 'No Data Available',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey,
//                 ),
//               ),
//               SizedBox(height: 8),
//               Text(
//                 'No land parcels match the current filter criteria',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     // Calculate map bounds with error handling
//     LatLngBounds? bounds;
//     try {
//       bounds = _calculateBounds(provider.filteredResults);
//     } catch (e) {
//       // Fallback to default location if bounds calculation fails
//       bounds = LatLngBounds(
//         const LatLng(10.95, 77.61),
//         const LatLng(10.96, 77.62),
//       );
//     }

//     return FlutterMap(
//       mapController: _mapController,
//       options: MapOptions(
//         initialCenter: bounds.center,
//         initialZoom: 14,
//         onMapReady: () {
//           if (bounds != null) {
//             _mapController.fitCamera(
//               CameraFit.bounds(
//                 bounds: bounds,
//                 padding: const EdgeInsets.all(20),
//               ),
//             );
//           }
//         },
//       ),
//       children: [
//         TileLayer(
//           urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//           userAgentPackageName: 'com.example.fmb_app',
//           maxZoom: 19,
//         ),
//         PolygonLayer(
//           polygons: _buildPolygons(provider.filteredResults),
//         ),
//         MarkerLayer(
//           markers: _buildMarkers(provider.filteredResults),
//         ),
//       ],
//     );
//   }

//   LatLngBounds _calculateBounds(List<FmbResult> results) {
//     double minLat = double.infinity;
//     double maxLat = -double.infinity;
//     double minLng = double.infinity;
//     double maxLng = -double.infinity;

//     for (final result in results) {
//       try {
//         final coords = _extractCoordinates(result.coordinates);
//         for (final coord in coords) {
//           if (coord.latitude < minLat) minLat = coord.latitude;
//           if (coord.latitude > maxLat) maxLat = coord.latitude;
//           if (coord.longitude < minLng) minLng = coord.longitude;
//           if (coord.longitude > maxLng) maxLng = coord.longitude;
//         }
//       } catch (e) {
//         print('Error processing coordinates for result: $e');
//         continue;
//       }
//     }

//     // Add some padding to bounds
//     const padding = 0.001;
//     return LatLngBounds(
//       LatLng(minLat - padding, minLng - padding),
//       LatLng(maxLat + padding, maxLng + padding),
//     );
//   }

//   List<Polygon> _buildPolygons(List<FmbResult> results) {
//     List<Polygon> polygons = [];

//     for (final result in results) {
//       try {
//         final points = _extractCoordinates(result.coordinates);
//         if (points.isNotEmpty) {
//           polygons.add(
//             Polygon(
//               points: points,
//               color: _getPolygonColor(result).withOpacity(0.4),
//               borderColor: _getPolygonColor(result),
//               borderStrokeWidth: 2,
//               isFilled: true,
//               hitValue: result,
//             ),
//           );
//         }
//       } catch (e) {
//         print('Error creating polygon for survey ${result.surveyNumber}: $e');
//         continue;
//       }
//     }

//     return polygons;
//   }

//   List<Marker> _buildMarkers(List<FmbResult> results) {
//     List<Marker> markers = [];

//     for (final result in results) {
//       try {
//         final points = _extractCoordinates(result.coordinates);
//         if (points.isNotEmpty) {
//           final center = _calculateCenter(points);

//           // Create better formatted display text
//           String displayText = _formatSurveyNumber(
//               result.surveyNumber, result.subdivisionNumber);

//           markers.add(
//             Marker(
//               point: center,
//               child: GestureDetector(
//                 onTap: () => _showPropertyDialog(result),
//                 child: Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     border:
//                         Border.all(color: _getPolygonColor(result), width: 2),
//                     borderRadius: BorderRadius.circular(6),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.3),
//                         blurRadius: 4,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   // child: Text(
//                   //   displayText,
//                   //   style: TextStyle(
//                   //     fontSize: 11,
//                   //     fontWeight: FontWeight.bold,
//                   //     color: _getPolygonColor(result),
//                   //   ),
//                   // ),
//                 ),
//               ),
//             ),
//           );
//         }
//       } catch (e) {
//         print('Error creating marker for survey ${result.surveyNumber}: $e');
//         continue;
//       }
//     }

//     return markers;
//   }

//   // Helper method to format survey number display
//   String _formatSurveyNumber(int? surveyNumber, String? subdivisionNumber) {
//     String surveyPart = 'N/A';
//     String subdivisionPart = '0';

//     // Handle survey number
//     if (surveyNumber != null) {
//       surveyPart = surveyNumber.toString();
//     }

//     // Handle subdivision number - ensure it's properly formatted
//     if (subdivisionNumber != null &&
//         subdivisionNumber.isNotEmpty &&
//         subdivisionNumber != 'null') {
//       subdivisionPart = subdivisionNumber;
//     }

//     return '$surveyPart/$subdivisionPart';
//   }

//   List<LatLng> _extractCoordinates(List<dynamic> coordinates) {
//     List<LatLng> points = [];

//     try {
//       if (coordinates.isNotEmpty && coordinates[0] is List) {
//         List<dynamic> firstRing = coordinates[0];
//         if (firstRing.isNotEmpty && firstRing[0] is List) {
//           firstRing = firstRing[0];
//         }

//         for (final coord in firstRing) {
//           if (coord is List && coord.length >= 2) {
//             final lng = coord[0] is num
//                 ? coord[0].toDouble()
//                 : double.tryParse(coord[0].toString());
//             final lat = coord[1] is num
//                 ? coord[1].toDouble()
//                 : double.tryParse(coord[1].toString());

//             if (lng != null && lat != null) {
//               points.add(LatLng(lat, lng));
//             }
//           }
//         }
//       }
//     } catch (e) {
//       print('Error extracting coordinates: $e');
//     }

//     return points;
//   }

//   LatLng _calculateCenter(List<LatLng> points) {
//     if (points.isEmpty) {
//       return const LatLng(10.958724187008, 77.6164783449398); // Default center
//     }

//     double lat = 0;
//     double lng = 0;

//     for (final point in points) {
//       lat += point.latitude;
//       lng += point.longitude;
//     }

//     return LatLng(lat / points.length, lng / points.length);
//   }

//   Color _getPolygonColor(FmbResult result) {
//     switch (result.tamilnilamLandType?.toLowerCase()) {
//       case 'dry':
//         return Colors.orange;
//       case 'poramboke':
//         return Colors.red;
//       case 'wet':
//         return Colors.blue;
//       case 'garden':
//         return Colors.green;
//       default:
//         return Colors.purple;
//     }
//   }

//   void _showPropertyDialog(FmbResult result) {
//     final properties = result.toDisplayMap();

//     ElevatedButton(
//       onPressed: () {
//         Navigator.of(context).pop(); // Close dialog
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const HomePage()),
//         );
//       },
//       child: const Text('Go to Home'),
//     );
//     // showDialog(
//     //   context: context,
//     //   builder: (BuildContext context) {
//     //     return AlertDialog(
//     //       shape: RoundedRectangleBorder(
//     //         borderRadius: BorderRadius.circular(16),
//     //       ),
//     //       title: Container(
//     //         padding: const EdgeInsets.all(16),
//     //         decoration: BoxDecoration(
//     //           gradient: LinearGradient(
//     //             colors: [Colors.green[600]!, Colors.green[700]!],
//     //           ),
//     //           borderRadius: const BorderRadius.only(
//     //             topLeft: Radius.circular(16),
//     //             topRight: Radius.circular(16),
//     //           ),
//     //         ),
//     //         child: Row(
//     //           children: [
//     //             const Icon(Icons.location_on, color: Colors.white, size: 24),
//     //             const SizedBox(width: 12),
//     //             Expanded(
//     //               child: Column(
//     //                 crossAxisAlignment: CrossAxisAlignment.start,
//     //                 children: [
//     //                   const Text(
//     //                     'Land Parcel Details',
//     //                     style: TextStyle(
//     //                       fontSize: 18,
//     //                       fontWeight: FontWeight.bold,
//     //                       color: Colors.white,
//     //                     ),
//     //                   ),
//     //                   Text(
//     //                     'Survey ${result.surveyNumber}/${result.subdivisionNumber}',
//     //                     style: const TextStyle(
//     //                       fontSize: 14,
//     //                       color: Colors.white,
//     //                       fontWeight: FontWeight.w400,
//     //                     ),
//     //                   ),
//     //                 ],
//     //               ),
//     //             ),
//     //           ],
//     //         ),
//     //       ),
//     //       titlePadding: EdgeInsets.zero,
//     //       contentPadding: const EdgeInsets.all(24),
//     //       content: SizedBox(
//     //         width: double.maxFinite,
//     //         child: SingleChildScrollView(
//     //           child: Column(
//     //             crossAxisAlignment: CrossAxisAlignment.start,
//     //             mainAxisSize: MainAxisSize.min,
//     //             children: [
//     //               _buildInfoSection(
//     //                   '📍 Basic Information',
//     //                   {
//     //                     'KIDE': properties['KIDE'],
//     //                     'Area': properties['Area'],
//     //                     'Survey Number': properties['Survey Number'],
//     //                     'Subdivision Number': properties['Subdivision Number'],
//     //                     'Unique ID 1': properties['Unique ID 1'],
//     //                     'Unique ID 2': properties['Unique ID 2'],
//     //                   },
//     //                   Colors.blue),
//     //               const SizedBox(height: 20),
//     //               _buildInfoSection(
//     //                   '🏞️ Land Details',
//     //                   {
//     //                     'Land Type': properties['Land Type'],
//     //                     'Land Classification':
//     //                         properties['Land Classification'],
//     //                     'Guideline Value': properties['Guideline Value'],
//     //                     'Extent (Ares)': properties['Extent (Ares)'],
//     //                   },
//     //                   Colors.green),
//     //               const SizedBox(height: 20),
//     //               _buildInfoSection(
//     //                   '👤 Owner Information',
//     //                   {
//     //                     'Patta Number': properties['Patta Number'],
//     //                     'Government Priority':
//     //                         properties['Government Priority'],
//     //                     'Owner Details': properties['Owner Details'],
//     //                   },
//     //                   Colors.orange),
//     //               const SizedBox(height: 20),
//     //               _buildInfoSection(
//     //                   '🌾 Crop Information',
//     //                   {
//     //                     'Kharif Crop': properties['Kharif Crop Name'],
//     //                     'Kharif Area': properties['Kharif Area'],
//     //                     'Rabi Crop': properties['Rabi Crop Name'],
//     //                     'Rabi Area': properties['Rabi Area'],
//     //                   },
//     //                   Colors.brown),
//     //             ],
//     //           ),
//     //         ),
//     //       ),
//     //       actions: [
//     //         TextButton(
//     //           onPressed: () => Navigator.of(context).pop(),
//     //           style: TextButton.styleFrom(
//     //             foregroundColor: Colors.green[700],
//     //             padding:
//     //                 const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//     //           ),
//     //           child: const Text(
//     //             'Close',
//     //             style: TextStyle(fontWeight: FontWeight.w600),
//     //           ),
//     //         ),
//     //       ],
//     //     );
//     //   },
//     // );
//   }

//   Widget _buildInfoSection(
//       String title, Map<String, String> data, MaterialColor color) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: color[700],
//           ),
//         ),
//         const SizedBox(height: 12),
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: color[50],
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: color[200]!),
//           ),
//           child: Column(
//             children: data.entries.map((entry) {
//               return Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 4),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(
//                       width: 120,
//                       child: Text(
//                         '${entry.key}:',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w600,
//                           fontSize: 13,
//                           color: color[800],
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: Text(
//                         entry.value,
//                         style: const TextStyle(
//                           fontSize: 13,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       ],
//     );
//   }
// }

// lib/presentation/features/fmb_result_page.dart
import 'package:crop_wizard/domain/entities/fmb_result.dart';
import 'package:crop_wizard/presentation/providers/fmb_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../home/home_page.dart';

class FmbResultPage extends StatefulWidget {
  const FmbResultPage({super.key});

  @override
  State<FmbResultPage> createState() => _FmbResultPageState();
}

class _FmbResultPageState extends State<FmbResultPage> {
  final MapController _mapController = MapController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    const url =
        'https://main.d35889sospji4x.amplifyapp.com/sipcot/data/villages/site_1_kangeyam/fmb.geojson';
    context.read<FmbProvider>().loadFmbData(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FMB Map Viewer'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon:
                Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<FmbProvider>().refreshData();
            },
          ),
        ],
      ),
      body: Consumer<FmbProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.green[50]!, Colors.white],
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Loading FMB data...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please wait while we fetch the land survey data',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.error != null) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.red[50]!, Colors.white],
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[400],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Unable to Load Data',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red[200]!),
                              ),
                              child: Text(
                                provider.error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.arrow_back),
                                  label: const Text('Go Back'),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _loadData,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Retry'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[700],
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Column(
            children: [
              if (_showFilters) _buildFilterSection(provider),
              _buildMapInfoBar(provider),
              Expanded(
                child: _buildMap(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(FmbProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune, color: Colors.green[700], size: 20),
              const SizedBox(width: 8),
              const Text(
                'Filter Options',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: provider.clearFilters,
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('Clear All'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildDropdownCard(
                  'Kharif Crop',
                  provider.selectedKharifCrop ?? 'All',
                  provider.availableKharifCrops,
                  (value) {
                    provider.setKharifCropFilter(value == 'All' ? null : value);
                  },
                  Icons.grass,
                  Colors.green,
                ),
                const SizedBox(width: 12),
                _buildDropdownCard(
                  'Rabi Crop',
                  provider.selectedRabiCrop ?? 'All',
                  provider.availableRabiCrops,
                  (value) {
                    provider.setRabiCropFilter(value == 'All' ? null : value);
                  },
                  Icons.eco,
                  Colors.orange,
                ),
                const SizedBox(width: 12),
                _buildDropdownCard(
                  'Land Type',
                  provider.selectedLandType ?? 'All',
                  provider.availableLandTypes,
                  (value) =>
                      provider.setLandTypeFilter(value == 'All' ? null : value),
                  Icons.terrain,
                  Colors.brown,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  'Showing ${provider.filteredResults.length} of ${provider.fmbResults.length} land parcels',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownCard(
    String label,
    String selectedValue,
    List<String> options,
    Function(String?) onChanged,
    IconData icon,
    MaterialColor color,
  ) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: color[700]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedValue,
                isExpanded: true,
                isDense: true,
                items: options.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapInfoBar(FmbProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[600]!, Colors.green[700]!],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.touch_app, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Tap any polygon to view detailed property information',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${provider.filteredResults.length} plots',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(FmbProvider provider) {
    if (provider.filteredResults.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[100]!, Colors.white],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No Data Available',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'No land parcels match the current filter criteria',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Calculate map bounds with error handling
    LatLngBounds? bounds;
    try {
      bounds = _calculateBounds(provider.filteredResults);
    } catch (e) {
      // Fallback to default location if bounds calculation fails
      bounds = LatLngBounds(
        const LatLng(10.95, 77.61),
        const LatLng(10.96, 77.62),
      );
    }

    return GestureDetector(
      onTapDown: (details) => _handleMapTap(details.localPosition, provider),
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: bounds.center,
          initialZoom: 14,
          onMapReady: () {
            if (bounds != null) {
              _mapController.fitCamera(
                CameraFit.bounds(
                  bounds: bounds,
                  padding: const EdgeInsets.all(20),
                ),
              );
            }
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.fmb_app',
            maxZoom: 19,
          ),
          PolygonLayer(
            polygons: _buildPolygons(provider.filteredResults),
          ),
        ],
      ),
    );
  }

  LatLngBounds _calculateBounds(List<FmbResult> results) {
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (final result in results) {
      try {
        final coords = _extractCoordinates(result.coordinates);
        for (final coord in coords) {
          if (coord.latitude < minLat) minLat = coord.latitude;
          if (coord.latitude > maxLat) maxLat = coord.latitude;
          if (coord.longitude < minLng) minLng = coord.longitude;
          if (coord.longitude > maxLng) maxLng = coord.longitude;
        }
      } catch (e) {
        print('Error processing coordinates for result: $e');
        continue;
      }
    }

    // Add some padding to bounds
    const padding = 0.001;
    return LatLngBounds(
      LatLng(minLat - padding, minLng - padding),
      LatLng(maxLat + padding, maxLng + padding),
    );
  }

  List<Polygon> _buildPolygons(List<FmbResult> results) {
    List<Polygon> polygons = [];

    for (final result in results) {
      try {
        final points = _extractCoordinates(result.coordinates);
        if (points.isNotEmpty) {
          polygons.add(
            Polygon(
              points: points,
              color: _getPolygonColor(result).withOpacity(0.4),
              borderColor: _getPolygonColor(result),
              borderStrokeWidth: 2,
              isFilled: true,
              hitValue:
                  result, // This is the key - store the FmbResult as hitValue
            ),
          );
        }
      } catch (e) {
        print('Error creating polygon for survey ${result.surveyNumber}: $e');
        continue;
      }
    }

    return polygons;
  }

  List<LatLng> _extractCoordinates(List<dynamic> coordinates) {
    List<LatLng> points = [];

    try {
      if (coordinates.isNotEmpty && coordinates[0] is List) {
        List<dynamic> firstRing = coordinates[0];
        if (firstRing.isNotEmpty && firstRing[0] is List) {
          firstRing = firstRing[0];
        }

        for (final coord in firstRing) {
          if (coord is List && coord.length >= 2) {
            final lng = coord[0] is num
                ? coord[0].toDouble()
                : double.tryParse(coord[0].toString());
            final lat = coord[1] is num
                ? coord[1].toDouble()
                : double.tryParse(coord[1].toString());

            if (lng != null && lat != null) {
              points.add(LatLng(lat, lng));
            }
          }
        }
      }
    } catch (e) {
      print('Error extracting coordinates: $e');
    }

    return points;
  }

  LatLng _calculateCenter(List<LatLng> points) {
    if (points.isEmpty) {
      return const LatLng(10.958724187008, 77.6164783449398); // Default center
    }

    double lat = 0;
    double lng = 0;

    for (final point in points) {
      lat += point.latitude;
      lng += point.longitude;
    }

    return LatLng(lat / points.length, lng / points.length);
  }

  void _handleMapTap(Offset localPosition, FmbProvider provider) {
    // Convert screen coordinates to lat/lng
    final camera = _mapController.camera;
    final point = camera.offsetToCrs(localPosition);
    final tappedLatLng = LatLng(point.latitude, point.longitude);

    // Find which polygon was tapped
    for (final result in provider.filteredResults) {
      try {
        final polygonPoints = _extractCoordinates(result.coordinates);
        if (_isPointInPolygon(tappedLatLng, polygonPoints)) {
          _showPropertyDialog(result);
          break; // Show dialog for first matching polygon
        }
      } catch (e) {
        print(
            'Error checking polygon hit for survey ${result.surveyNumber}: $e');
        continue;
      }
    }
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.length < 3) return false;

    bool inside = false;
    int j = polygon.length - 1;

    for (int i = 0; i < polygon.length; i++) {
      final xi = polygon[i].longitude;
      final yi = polygon[i].latitude;
      final xj = polygon[j].longitude;
      final yj = polygon[j].latitude;

      if (((yi > point.latitude) != (yj > point.latitude)) &&
          (point.longitude <
              (xj - xi) * (point.latitude - yi) / (yj - yi) + xi)) {
        inside = !inside;
      }
      j = i;
    }

    return inside;
  }

  Color _getPolygonColor(FmbResult result) {
    switch (result.tamilnilamLandType?.toLowerCase()) {
      case 'dry':
        return Colors.orange;
      case 'poramboke':
        return Colors.red;
      case 'wet':
        return Colors.blue;
      case 'garden':
        return Colors.green;
      default:
        return Colors.purple;
    }
  }

  void _showPropertyDialog(FmbResult result) {
    final properties = result.toDisplayMap();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[600]!, Colors.green[700]!],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Land Parcel Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Survey ${result.surveyNumber}/${result.subdivisionNumber}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          titlePadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.all(24),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInfoSection(
                      '📍 Basic Information',
                      {
                        'KIDE': properties['KIDE'],
                        'Area': properties['Area'],
                        'Survey Number': properties['Survey Number'],
                        'Subdivision Number': properties['Subdivision Number'],
                        'Unique ID 1': properties['Unique ID 1'],
                        'Unique ID 2': properties['Unique ID 2'],
                      },
                      Colors.blue),
                  const SizedBox(height: 20),
                  _buildInfoSection(
                      '🏞️ Land Details',
                      {
                        'Land Type': properties['Land Type'],
                        'Land Classification':
                            properties['Land Classification'],
                        'Guideline Value': properties['Guideline Value'],
                        'Extent (Ares)': properties['Extent (Ares)'],
                      },
                      Colors.green),
                  const SizedBox(height: 20),
                  _buildInfoSection(
                      '👤 Owner Information',
                      {
                        'Patta Number': properties['Patta Number'],
                        'Government Priority':
                            properties['Government Priority'],
                        'Owner Details': properties['Owner Details'],
                      },
                      Colors.orange),
                  const SizedBox(height: 20),
                  _buildInfoSection(
                      '🌾 Crop Information',
                      {
                        'Kharif Crop': properties['Kharif Crop Name'],
                        'Kharif Area': properties['Kharif Area'],
                        'Rabi Crop': properties['Rabi Crop Name'],
                        'Rabi Area': properties['Rabi Area'],
                      },
                      Colors.brown),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.green[700],
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Close',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoSection(
      String title, Map<String, String> data, MaterialColor color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color[700],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color[200]!),
          ),
          child: Column(
            children: data.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        '${entry.key}:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: color[800],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
