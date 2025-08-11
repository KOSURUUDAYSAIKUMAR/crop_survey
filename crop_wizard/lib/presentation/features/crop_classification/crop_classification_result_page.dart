import 'dart:io';
import 'package:crop_wizard/presentation/providers/crop_classification_provider.dart';
import 'package:crop_wizard/presentation/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crop_wizard/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crop_wizard/domain/entities/crop_classification_result.dart';

class CropClassificationResultPage extends StatelessWidget {
  final File? imageFile; // Image passed from HomePage

  const CropClassificationResultPage({super.key, this.imageFile});

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

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final sortedResults = _sortResultsByConfidence(
        Provider.of<CropClassificationProvider>(context).results);
    final localeProvider = Provider.of<LocaleProvider>(context);

    // Initial call to classify if imageFile is provided and not already loading/success
    // This is typically done when the page is first pushed.
    // However, the provider might already be in a loading/success/error state if classify was called before navigating.
    // We only call classify if the state is initial and an image is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<CropClassificationProvider>(context, listen: false);
      if (provider.state == CropClassificationState.initial &&
          imageFile != null &&
          provider.currentImage == null) {
        //Only call if it's a new image or initial state.
        if (provider.currentImage?.path != imageFile!.path) {
          provider.classify(imageFile!);
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.cropClassificationResultPageTitle),
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
          final displayImage = provider.currentImage ??
              imageFile; // Use provider's current image, fallback to initial

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

          if (provider.state == CropClassificationState.success &&
              provider.results.isNotEmpty) {
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
                          child: Text(appLocalizations.noImageSelected,
                              textAlign: TextAlign.center)),
                    ),
                  const SizedBox(height: 20),
                  // Major Crop Section (highest confidence)
                  if (sortedResults.isNotEmpty) ...[
                    Text(
                      'Major Crop',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
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
                              _capitalizeCropName(sortedResults.first.crop),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800, // Extra bold
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 20, // Slightly larger font size
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
                            // _buildResultRow(
                            //   context,
                            //   appLocalizations.description,
                            //   sortedResults.first.description,
                            //   isLast: true,
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ],

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
                                        color: Theme.of(context)
                                            .primaryColor, // Extra bold
                                        fontSize:
                                            20, // Slightly larger font size
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
                                // if (result.description.isNotEmpty)
                                //   _buildResultRow(
                                //     context,
                                //     appLocalizations.description,
                                //     result.description,
                                //     isLast: true,
                                //   ),
                              ],
                            ),
                          ),
                        )),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: Text(appLocalizations.retry),
                    onPressed: () => _showRetryImageSourceActionSheet(context),
                  ),
                ],
              ),
            );
          }
          // Initial or other states (e.g. if no image was ever provided)
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
                      label: Text(appLocalizations
                          .uploadFromGallery), // Or provide a generic "Select Image"
                      onPressed: () =>
                          _showRetryImageSourceActionSheet(context),
                    ),
                  ],
                )),
          );
        },
      ),
    );
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
}
