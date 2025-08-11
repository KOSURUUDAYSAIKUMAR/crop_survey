import 'package:crop_wizard/presentation/features/crop_classification/crop_classification_result_page.dart';
import 'package:crop_wizard/presentation/features/pest_detection/pest_detection_result_page.dart';
import 'package:crop_wizard/presentation/providers/crop_classification_provider.dart';
import 'package:crop_wizard/presentation/providers/locale_provider.dart';
import 'package:crop_wizard/presentation/providers/pest_detection_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crop_wizard/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../fmb/fmb_result_page.dart'; // For File type

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageAndNavigate(
      BuildContext context, ImageSource source, String featureType) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      print('$featureType - Image selected: ${imageFile.path}');
      // ignore: use_build_context_synchronously
      final appLocalizations = AppLocalizations.of(context)!;

      if (featureType == appLocalizations.cropClassification) {
        // ignore: use_build_context_synchronously
        Provider.of<CropClassificationProvider>(context, listen: false)
            .resetState();
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CropClassificationResultPage(imageFile: imageFile),
          ),
        );
      } else if (featureType == appLocalizations.pestDetection) {
        // ignore: use_build_context_synchronously
        Provider.of<PestDetectionProvider>(context, listen: false).resetState();
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PestDetectionResultPage(imageFile: imageFile),
          ),
        );
      }
    } else {
      print('$featureType - No image selected.');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.noImageSelected)),
      );
    }
  }

  void _showImageSourceActionSheet(BuildContext context, String featureType) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) {
        final appLocalizations = AppLocalizations.of(context)!;
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text(appLocalizations.takePhoto),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImageAndNavigate(
                      context, ImageSource.camera, featureType);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(appLocalizations.uploadFromGallery),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImageAndNavigate(
                      context, ImageSource.gallery, featureType);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.homePageTitle),
        actions: [
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            tooltip: appLocalizations.language,
            onSelected: (Locale locale) {
              localeProvider.setLocale(locale);
            },
            itemBuilder: (BuildContext context) {
              return AppLocalizations.supportedLocales.map((locale) {
                return PopupMenuItem(
                  value: locale,
                  child:
                      Text(LocaleProvider.getLanguageName(locale.languageCode)),
                );
              }).toList();
            },
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FmbResultPage(),
                ),
              );
            },
            icon: const Icon(Icons.map_outlined),
            label: const Text('View FMB Map'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildFeatureCard(
                  context,
                  title: appLocalizations.cropClassification,
                  icon: Icons.eco,
                  onTap: () {
                    _showImageSourceActionSheet(
                        context, appLocalizations.cropClassification);
                  },
                ),
                // const SizedBox(height: 20), // Commented out SizedBox
                // _buildFeatureCard( // Commented out Pest Detection Card
                //   context,
                //   title: appLocalizations.pestDetection,
                //   icon: Icons.bug_report,
                //   onTap: () {
                //     _showImageSourceActionSheet(context, appLocalizations.pestDetection); // Pass localized string
                //   },
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context,
      {required String title,
      required IconData icon,
      required VoidCallback onTap}) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(icon, size: 50, color: Theme.of(context).primaryColor),
              const SizedBox(height: 15),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
