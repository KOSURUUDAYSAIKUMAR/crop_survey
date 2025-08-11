// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Crop Wizard';

  @override
  String get homePageTitle => 'Home';

  @override
  String get cropClassification => 'Crop Classification';

  @override
  String get pestDetection => 'Pest Detection';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get uploadFromGallery => 'Upload from Gallery';

  @override
  String get selectOption => 'Select an Option';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get tamil => 'Tamil';

  @override
  String get cropClassificationResultPageTitle => 'Crop Classification Result';

  @override
  String get cropName => 'Crop Name';

  @override
  String get confidenceScore => 'Confidence Score';

  @override
  String get stageOfGrowth => 'Stage of Growth';

  @override
  String get description => 'Description';

  @override
  String get retry => 'Retry';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get noImageSelected => 'No image selected to display.';

  @override
  String get classifyingCrop => 'Classifying crop...';

  @override
  String get pestDetectionResultPageTitle => 'Pest Detection Result';

  @override
  String get diseaseName => 'Disease/Pest Name';

  @override
  String get nextSteps => 'Next Steps';

  @override
  String get detectingPest => 'Detecting pest...';
}
