class PestDetectionRequestModel {
  final String inputPrompt;
  final String inputImage; // base64 image
  final String userId;

  PestDetectionRequestModel({
    required this.inputPrompt,
    required this.inputImage,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'input_prompt': inputPrompt,
      'input_image': inputImage,
      'user_id': userId,
    };
  }
} 