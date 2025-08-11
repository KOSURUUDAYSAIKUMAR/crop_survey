import 'dart:io';
import 'package:crop_wizard/presentation/providers/locale_provider.dart';
import 'package:crop_wizard/presentation/providers/pest_detection_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crop_wizard/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

class PestDetectionResultPage extends StatelessWidget {
  final File? imageFile; // Image passed from HomePage

  const PestDetectionResultPage({super.key, this.imageFile});

  Future<void> _pickImageAndRetry(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final newImageFile = File(pickedFile.path);
      // ignore: use_build_context_synchronously
      Provider.of<PestDetectionProvider>(context, listen: false).detect(newImageFile);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.noImageSelected)),
      );
    }
  }

  void _showRetryImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text(AppLocalizations.of(context)!.takePhoto),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImageAndRetry(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(AppLocalizations.of(context)!.uploadFromGallery),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImageAndRetry(context, ImageSource.gallery);
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
    final appLocalizations = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PestDetectionProvider>(context, listen: false);
      if (provider.state == PestDetectionState.initial && imageFile != null && provider.currentImage == null) {
        if(provider.currentImage?.path != imageFile!.path ){
            provider.detect(imageFile!);
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.pestDetectionResultPageTitle),
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
                  child: Text(LocaleProvider.getLanguageName(locale.languageCode)),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Consumer<PestDetectionProvider>(
        builder: (context, provider, child) {
          final displayImage = provider.currentImage ?? imageFile;

          if (provider.state == PestDetectionState.loading) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(appLocalizations.detectingPest, style: Theme.of(context).textTheme.titleMedium),
              ],
            ));
          }

          if (provider.state == PestDetectionState.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(appLocalizations.errorOccurred, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.red)),
                  const SizedBox(height: 10),
                  Text(provider.errorMessage ?? 'Unknown error', textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: Text(appLocalizations.retry),
                    onPressed: () => _showRetryImageSourceActionSheet(context),
                  ),
                ]),
              ),
            );
          }

          if (provider.state == PestDetectionState.success && provider.result != null) {
            final result = provider.result!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (displayImage != null)
                    Card(
                      elevation: 2,
                      clipBehavior: Clip.antiAlias,
                      child: Image.file(displayImage, fit: BoxFit.cover, height: 250),
                    )
                  else
                    Container(
                        height: 250,
                        color: Colors.grey[300],
                        child: Center(child: Text(appLocalizations.noImageSelected, textAlign: TextAlign.center))),
                  const SizedBox(height: 20),
                  _buildResultCard(context, appLocalizations, [
                    _buildResultRow(context, appLocalizations.diseaseName, result.message.diseaseName),
                    _buildResultRow(context, appLocalizations.confidenceScore, result.message.confidenceScore),
                    _buildResultRow(context, appLocalizations.nextSteps, result.message.nextSteps, isLast: true),
                    // Optionally display GeoInfo and LayerName if they are useful
                    // _buildResultRow(context, 'Geo Info', result.geoInfo),
                    // _buildResultRow(context, 'Layer Name', result.layerName, isLast: true),
                  ]),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: Text(appLocalizations.retry),
                    onPressed: () => _showRetryImageSourceActionSheet(context),
                  ),
                ],
              ),
            );
          }
          return Center(
             child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(appLocalizations.noImageSelected, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 20),
                   ElevatedButton.icon(
                        icon: const Icon(Icons.upload_file),
                        label: Text(appLocalizations.uploadFromGallery),
                        onPressed: () => _showRetryImageSourceActionSheet(context),
                    ),
                ],
              )
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, AppLocalizations appLocalizations, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildResultRow(BuildContext context, String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          if(!isLast) const SizedBox(height: 8),
          if(!isLast) Divider(color: Colors.grey[300]),
        ],
      ),
    );
  }
} 