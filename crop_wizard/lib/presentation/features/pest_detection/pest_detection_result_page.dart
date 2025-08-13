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

  Future<void> _pickImageAndRetry(
      BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final newImageFile = File(pickedFile.path);
      // ignore: use_build_context_synchronously
      Provider.of<PestDetectionProvider>(context, listen: false)
          .detect(newImageFile);
    } else {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.noImageSelected)),
      );
    }
  }

  void _showRetryImageSourceActionSheet(BuildContext context) {
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
                  _pickImageAndRetry(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(appLocalizations.uploadFromGallery),
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
      final provider =
          Provider.of<PestDetectionProvider>(context, listen: false);
      if (provider.state == PestDetectionState.initial &&
          imageFile != null &&
          provider.currentImage == null) {
        if (provider.currentImage?.path != imageFile!.path) {
          provider.detect(imageFile!);
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appLocalizations.pestDetectionResultPageTitle,
          style: const TextStyle(
            fontSize: 18.0,
          ),
        ),
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
        ],
      ),
      body: Consumer<PestDetectionProvider>(
        builder: (context, provider, child) {
          final displayImage = provider.currentImage ?? imageFile;
          final theme = Theme.of(context);

          if (provider.state == PestDetectionState.loading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    appLocalizations.detectingPest,
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          if (provider.state == PestDetectionState.error) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (displayImage != null)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      clipBehavior: Clip.antiAlias,
                      child: Image.file(displayImage,
                          fit: BoxFit.cover, height: 250),
                    ),
                  const SizedBox(height: 24),
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    appLocalizations.errorOccurred,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.errorMessage ??
                        'An unknown error occurred. Please try again later.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: Text(appLocalizations.retry),
                    onPressed: () => _showRetryImageSourceActionSheet(context),
                  ),
                ],
              ),
            );
          }

          if (provider.state == PestDetectionState.success &&
              provider.result != null) {
            final result = provider.result!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Image card with rounded corners
                  if (displayImage != null)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      clipBehavior: Clip.antiAlias,
                      child: Image.file(displayImage,
                          fit: BoxFit.cover, height: 250),
                    ),
                  const SizedBox(height: 24),
                  // New header for the results section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bug_report,
                          size: 40, color: Colors.green),
                      const SizedBox(width: 12),
                      Text(
                        'Pest Detection Results',
                        style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Re-designed result card
                  _buildPestResultCard(
                    context,
                    appLocalizations,
                    result.message.diseaseName,
                    result.message.confidenceScore,
                    result.message.nextSteps,
                  ),
                  const SizedBox(height: 30),
                  // Button text changed to "Another Pest Detection"
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Another Pest Detection'),
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
                  Text(appLocalizations.noImageSelected,
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: Text(appLocalizations.uploadFromGallery),
                    onPressed: () => _showRetryImageSourceActionSheet(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPestResultCard(
      BuildContext context,
      AppLocalizations appLocalizations,
      String diseaseName,
      String confidenceScore,
      String nextSteps) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              diseaseName,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red[800],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 16),
            // Confidence score
            _buildResultRow(
              context,
              appLocalizations.confidenceScore,
              confidenceScore,
            ),
            // Next steps
            _buildResultRow(
              context,
              appLocalizations.nextSteps,
              nextSteps,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(BuildContext context, String label, String value,
      {bool isLast = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
