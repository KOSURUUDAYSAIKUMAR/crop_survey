import 'package:crop_wizard/core/network_server/dio_config.dart';
import 'package:crop_wizard/data/datasources/crop_classification_remote_data_source.dart';
import 'package:crop_wizard/data/datasources/fmb_layer_data_source.dart';
import 'package:crop_wizard/data/datasources/pest_detection_remote_data_source.dart';
import 'package:crop_wizard/data/repositories/crop_classification_repository_impl.dart';
import 'package:crop_wizard/data/repositories/pest_detection_repository_impl.dart';
import 'package:crop_wizard/domain/usecases/classify_crop.dart';
import 'package:crop_wizard/domain/usecases/detect_pest.dart';
import 'package:crop_wizard/presentation/providers/crop_classification_provider.dart';
import 'package:crop_wizard/presentation/providers/fmb_provider.dart';
import 'package:crop_wizard/presentation/providers/locale_provider.dart';
import 'package:crop_wizard/presentation/providers/pest_detection_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:crop_wizard/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart'; // Added for CropClassification

import 'data/repositories/fmb_repository_implementation.dart';
import 'domain/usecases/fmb_data.dart';
import 'presentation/features/home/home_page.dart'; // We'll create this next

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  print('Hive initialized successfully');
  final httpClient = http.Client(); // For services still using http package
  final dioClient = Dio(); // For services using Dio

  // Create FMB Dio with enhanced configuration
  final dioFmb = DioConfig.createDio();

  // Add network debugging
  print('Initializing Crop Wizard with enhanced network configuration...');
  print('FMB Dio configured with:');
  print('- Connect timeout: ${dioFmb.options.connectTimeout}');
  print('- Receive timeout: ${dioFmb.options.receiveTimeout}');
  print('- Send timeout: ${dioFmb.options.sendTimeout}');

  // Crop Classification Dependencies (using Dio)
  final cropClassificationRemoteDataSource =
      CropClassificationRemoteDataSourceImpl(dioClient);
  final cropClassificationRepository = CropClassificationRepositoryImpl(
      remoteDataSource: cropClassificationRemoteDataSource);
  final classifyCropUseCase = ClassifyCrop(cropClassificationRepository);

  // Pest Detection Dependencies (still using http.Client)
  final pestDetectionRemoteDataSource =
      PestDetectionRemoteDataSourceImpl(client: httpClient);
  final pestDetectionRepository = PestDetectionRepositoryImpl(
      remoteDataSource: pestDetectionRemoteDataSource);
  final detectPestUseCase = DetectPest(pestDetectionRepository);

// FMB Dependencies (Using Dio)
  final dataSource = FmbLayerDataSourceImpl(dio: dioFmb);
  final repository = FmbRepositoryImplementation(dataSource: dataSource);
  final fmbDataUseCase = FmbDataUseCase(repository: repository);

  print('All dependencies initialized successfully');

  runApp(MyApp(
    classifyCropUseCase: classifyCropUseCase,
    detectPestUseCase: detectPestUseCase,
    fmbDataUseCase: fmbDataUseCase,
  ));
}

class MyApp extends StatelessWidget {
  final ClassifyCrop classifyCropUseCase;
  final DetectPest detectPestUseCase;
  final FmbDataUseCase fmbDataUseCase;
  const MyApp({
    super.key,
    required this.classifyCropUseCase,
    required this.detectPestUseCase,
    required this.fmbDataUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(
            create: (_) => CropClassificationProvider(classifyCropUseCase)),
        ChangeNotifierProvider(
            create: (_) => PestDetectionProvider(detectPestUseCase)),
        ChangeNotifierProvider(
            create: (_) => FmbProvider(fmbDataUseCase: fmbDataUseCase)),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title:
                'Crop Wizard', // This will be localized later if needed from context
            theme: ThemeData(
              primarySwatch: Colors.green,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white, // For title and icons
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              cardTheme: CardThemeData(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              ),
              progressIndicatorTheme: const ProgressIndicatorThemeData(
                color: Colors.green, // Color for CircularProgressIndicator
              ),
            ),
            locale: provider.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const HomePage(), // We'll create this page next
          );
        },
      ),
    );
  }
}
