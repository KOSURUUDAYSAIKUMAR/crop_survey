class CropClassificationRequestModel {
  final String baseImage;

  CropClassificationRequestModel({required this.baseImage});

  Map<String, dynamic> toJson() {
    return {
      'base_image': baseImage,
    };
  }
} 