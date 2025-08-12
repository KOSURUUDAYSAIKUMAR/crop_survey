import 'dart:io';
import 'package:crop_wizard/presentation/providers/crop_classification_provider.dart';
import 'package:crop_wizard/presentation/providers/fmb_provider.dart';
import 'package:crop_wizard/presentation/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crop_wizard/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crop_wizard/domain/entities/crop_classification_result.dart';

class CropClassificationResultPage extends StatefulWidget {
  final File? imageFile;
  final String? selectedPolygonKide;

  const CropClassificationResultPage({
    super.key,
    this.imageFile,
    this.selectedPolygonKide,
  });

  @override
  State<CropClassificationResultPage> createState() =>
      _CropClassificationResultPageState();
}

class _CropClassificationResultPageState
    extends State<CropClassificationResultPage> {
  // All other methods (_pickImageAndRetry, _showRetryImageSourceActionSheet,
  // _capitalizeCropName, _sortResultsByConfidence, _updatePolygonCrop, _buildResultRow)
  // remain the same.

  Future<void> _pickImageAndRetry(
      BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final newImageFile = File(pickedFile.path);
      // ignore: use_build_context_synchronously
      Provider.of<CropClassificationProvider>(context, listen: false)
          .classify(newImageFile);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!
                .noImageSelected)), // Or a more specific message
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

  String _capitalizeCropName(String name) {
    if (name.isEmpty) return name;
    return name.split(' ').map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }

  List<CropClassificationResult> _sortResultsByConfidence(
      List<CropClassificationResult> results) {
    final sorted = List<CropClassificationResult>.from(results);
    sorted.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));
    return sorted;
  }

  Future<void> _updatePolygonCrop(String cropName) async {
    if (widget.selectedPolygonKide == null) return;

    try {
      final fmbProvider = Provider.of<FmbProvider>(context, listen: false);
      await fmbProvider.updateCropForPolygon(
          widget.selectedPolygonKide!, cropName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Polygon updated successfully with crop: $cropName'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update polygon: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildResultRow(BuildContext context, String label, String value,
      {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (!isLast) const SizedBox(height: 8),
          if (!isLast) Divider(color: Colors.grey[300]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);

    // Initial call to classify if imageFile is provided and not already loading/success
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<CropClassificationProvider>(context, listen: false);
      if (provider.state == CropClassificationState.initial &&
          widget.imageFile != null &&
          provider.currentImage == null) {
        if (provider.currentImage?.path != widget.imageFile!.path) {
          provider.classify(widget.imageFile!);
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appLocalizations.cropClassificationResultPageTitle,
          style: const TextStyle(
            fontSize: 14.0,
          ),
          textAlign: TextAlign.center,
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
      body: Consumer<CropClassificationProvider>(
        builder: (context, provider, child) {
          final displayImage = provider.currentImage ?? widget.imageFile;
          final sortedResults = _sortResultsByConfidence(provider.results);

          if (provider.state == CropClassificationState.loading) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(appLocalizations.classifyingCrop,
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ));
          }

          if (provider.state == CropClassificationState.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(appLocalizations.errorOccurred,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(color: Colors.red)),
                      const SizedBox(height: 10),
                      Text(provider.errorMessage ?? 'Unknown error',
                          textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: Text(appLocalizations.retry),
                        onPressed: () =>
                            _showRetryImageSourceActionSheet(context),
                      ),
                    ]),
              ),
            );
          }

          // Case: Image is not a recognized crop
          // Case: Image is not a recognized crop
          if (provider.state == CropClassificationState.success &&
              sortedResults.isNotEmpty &&
              sortedResults.first.crop.toLowerCase() == 'not a crop') {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (displayImage != null)
                    Card(
                      elevation: 2,
                      clipBehavior: Clip.antiAlias,
                      child: Image.file(displayImage,
                          fit: BoxFit.cover, height: 250),
                    ),
                  const SizedBox(height: 20),
                  const Icon(Icons.info_outline, color: Colors.blue, size: 60),
                  const SizedBox(height: 10),
                  Text(
                    'No Crop Identified',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: Colors.blue),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Our system could not detect a recognizable crop in the provided image. Please ensure the image is of a field with a visible crop.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    'The image does not appear to contain a recognized crop. Please try again with a different photo of a crop field.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Possible Reasons"',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildReasonListItem(context,
                      'The photo was taken from an incorrect angle or too far away.'),
                  _buildReasonListItem(context,
                      'The image has poor lighting, is blurry, or out of focus.'),
                  _buildReasonListItem(context,
                      'The crop type is not yet supported by our classification model.'),
                  _buildReasonListItem(context,
                      'The crop is obscured by weeds or other objects.'),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    onPressed: () => _showRetryImageSourceActionSheet(context),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          }
          // Case: Success, a crop was identified
          if (provider.state == CropClassificationState.success &&
              sortedResults.isNotEmpty) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (displayImage != null)
                    Card(
                      elevation: 2,
                      clipBehavior: Clip.antiAlias,
                      child: Image.file(displayImage,
                          fit: BoxFit.cover, height: 250),
                    )
                  else
                    Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: Center(
                        child: Text(
                          appLocalizations.noImageSelected,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  // Major Crop Section (highest confidence)
                  Text(
                    'Major Crop',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (widget.selectedPolygonKide != null)
                    ElevatedButton.icon(
                      onPressed: () => _updatePolygonCrop(
                        _capitalizeCropName(
                          sortedResults.first.crop,
                        ),
                      ),
                      icon: const Icon(Icons.update, size: 16),
                      label: const Text('Update data in fmb'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _capitalizeCropName(
                              sortedResults.first.crop,
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 20,
                                ),
                          ),
                          const SizedBox(height: 8),
                          _buildResultRow(
                            context,
                            'Confidence',
                            '${sortedResults.first.confidenceScore}%',
                          ),
                          _buildResultRow(
                            context,
                            appLocalizations.stageOfGrowth,
                            sortedResults.first.stageOfGrowth,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Additional Crops Section (all except first)
                  if (sortedResults.length > 1) ...[
                    Text(
                      'Additional Crops',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...sortedResults.skip(1).map((result) => Card(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _capitalizeCropName(result.crop),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 20,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                _buildResultRow(
                                  context,
                                  'Confidence',
                                  '${result.confidenceScore}%',
                                ),
                                if (result.stageOfGrowth.isNotEmpty)
                                  _buildResultRow(
                                    context,
                                    appLocalizations.stageOfGrowth,
                                    result.stageOfGrowth,
                                  ),
                              ],
                            ),
                          ),
                        )),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Classify another crop'),
                    onPressed: () => _showRetryImageSourceActionSheet(context),
                  ),
                ],
              ),
            );
          }
          // Initial or other states
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(appLocalizations.noImageSelected,
                      style: Theme.of(context).textTheme.titleMedium),
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

  Widget _buildReasonListItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
