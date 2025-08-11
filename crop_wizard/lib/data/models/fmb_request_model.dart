class FmbRequestModel {
  final String url;
  final String? kharifCropFilter;
  final String? rabiCropFilter;
  final String? landTypeFilter;

  FmbRequestModel({
    required this.url,
    this.kharifCropFilter,
    this.rabiCropFilter,
    this.landTypeFilter,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'kharifCropFilter': kharifCropFilter,
      'rabiCropFilter': rabiCropFilter,
      'landTypeFilter': landTypeFilter,
    };
  }

  factory FmbRequestModel.fromJson(Map<String, dynamic> json) {
    return FmbRequestModel(
      url: json['url'],
      kharifCropFilter: json['kharifCropFilter'],
      rabiCropFilter: json['rabiCropFilter'],
      landTypeFilter: json['landTypeFilter'],
    );
  }
}
