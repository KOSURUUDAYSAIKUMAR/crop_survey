import 'dart:io';
import 'package:crop_wizard/presentation/features/crop_classification/crop_classification_result_page.dart';
import 'package:crop_wizard/presentation/features/pest_detection/pest_detection_result_page.dart';
import 'package:crop_wizard/presentation/providers/crop_classification_provider.dart';
import 'package:crop_wizard/presentation/providers/locale_provider.dart';
import 'package:crop_wizard/presentation/providers/pest_detection_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crop_wizard/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import '../fmb/fmb_result_page.dart'; // For File type
import 'package:crop_wizard/core/constants/app_global.dart';
import 'package:crop_wizard/core/utils/custom_logger.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  final environmentLogger = createLogger(
    FmbResultPage,
    enableDebugLogs: AppGlobals.enableDebugLogs,
  );

  Future<void> _pickImageAndNavigate(
      BuildContext context, ImageSource source, String featureType) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (!context.mounted) {
      return;
    }
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      environmentLogger.i('$featureType - Image selected: ${imageFile.path}');
      final appLocalizations = AppLocalizations.of(context)!;
      if (featureType == appLocalizations.cropClassification) {
        Provider.of<CropClassificationProvider>(context, listen: false)
            .resetState();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CropClassificationResultPage(imageFile: imageFile),
          ),
        );
      } else if (featureType == appLocalizations.pestDetection) {
        Provider.of<PestDetectionProvider>(context, listen: false).resetState();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PestDetectionResultPage(imageFile: imageFile),
          ),
        );
      }
    } else {
      environmentLogger.e('$featureType - No image selected.');
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.homePageTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'View FMB Map',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FmbResultPage(),
                ),
              );
            },
          ),
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
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Welcome to Crop Wizard! 🧙‍♂️',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Select a feature to get started.',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildFeatureCard(
                context,
                title: appLocalizations.cropClassification,
                description: 'Identify the type of crop from a photo.',
                icon: Icons.eco,
                color: Colors.green.shade50,
                iconColor: Colors.green.shade700,
                onTap: () {
                  _showImageSourceActionSheet(
                      context, appLocalizations.cropClassification);
                },
              ),
              const SizedBox(height: 24),
              _buildFeatureCard(
                context,
                title: appLocalizations.pestDetection,
                description: 'Detect pests or diseases affecting your crop.',
                icon: Icons.bug_report,
                color: Colors.orange.shade50,
                iconColor: Colors.orange.shade700,
                onTap: () {
                  _showImageSourceActionSheet(
                      context, appLocalizations.pestDetection);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(icon, size: 36, color: iconColor),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 20, color: iconColor),
            ],
          ),
        ),
      ),
    );
  }
}
