class KatakanaResponseModel {
  String converted;
  String outputType;

  KatakanaResponseModel({required this.converted, required this.outputType});

  KatakanaResponseModel.fromJson(Map<String, dynamic> json)
      : converted = json['converted'] ?? '',
        outputType = json['output_type'] ?? '';

  Map<String, dynamic> toJson() => {
        'converted': converted,
        'output_type': outputType,
      };
}
