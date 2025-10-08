import 'dart:async';
import 'package:crop_survey/layer/distirct_geo_layer.dart';
import 'package:crop_survey/model/district_feature_model.dart';
import 'package:crop_survey/viewmodel/district_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class DistrictView extends StatefulWidget {
  const DistrictView({super.key});

  @override
  State<DistrictView> createState() => _DistrictViewState();
}

class _DistrictViewState extends State<DistrictView> {
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.delayed(Duration.zero);
    if (!mounted) return;

    final viewModel = Provider.of<DistrictVm>(context, listen: false);
    try {
      await viewModel.fetchWFSData();
    } catch (e) {
      debugPrint('Initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crop Survey')),
      body: Consumer<DistrictVm>(
        builder: (context, viewModel, child) {
          if (viewModel.error != null) {
            return Center(child: Text('Error: ${viewModel.error}'));
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: viewModel.mapController,
                options: MapOptions(
                  initialCenter: LatLng(20.5937, 78.9629),
                  initialZoom: 5.0,
                  onMapReady: () {
                    if (mounted) {
                      viewModel.onMapReady();
                    }
                  },
                  onTap: (tapPosition, point) {
                    viewModel.clearSelection();
                  },
                  onSecondaryTap: (tapPos, latLng) {
                    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                      SnackBar(content: Text('Secondary tap at $latLng')),
                    );
                  },
                ),

                children: [
                  TileLayer(
                    urlTemplate:
                        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                    userAgentPackageName: "com.fai.crop_survey",
                  ),

                  if (viewModel.mapReady && viewModel.wfsResponse != null)
                    DistrictGeoJsonLayer(
                      geojson: viewModel.wfsResponse!,
                      onFeatureTap: _onFeatureTap,
                    ),
                ],
              ),
              // if (viewModel.selectedFeature != null)
              //   Positioned(
              //     bottom: 20,
              //     left: 20,
              //     child: _buildFeatureInfoCard(viewModel.selectedFeature!),
              //   ),
              if (viewModel.isLoading)
                const Center(child: CircularProgressIndicator()),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    Provider.of<DistrictVm>(context, listen: false).disposeMapController();
    super.dispose();
  }

  void _onFeatureTap(DistrictFeatureModel feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('District Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('District Name: ${feature.properties.distName}'),
                Text('District Code: ${feature.properties.districtCode}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
