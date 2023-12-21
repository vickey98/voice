class KatakanaRequestModel {
  String sentence;
  String outputType;

  KatakanaRequestModel({required this.sentence, required this.outputType});

  Map<String, dynamic> toJson() => {
        'sentence': sentence,
        'output_type': outputType,
      };
}
