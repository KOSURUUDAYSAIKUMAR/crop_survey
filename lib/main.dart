import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Repository/district_repository.dart';
import 'view/district_view.dart';
import 'viewmodel/district_vm.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WFS Layer Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      //  home: WFSVectorMap(),
      home: ChangeNotifierProvider(
        create: (context) => DistrictVm(DistrictRepository()),
        child: const DistrictView(),
      ),
    );
  }
}
