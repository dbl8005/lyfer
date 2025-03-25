import 'dart:convert';

class QuoteModel {
  final String text;
  final String author;

  QuoteModel({
    required this.text,
    required this.author,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      text: json['q'] ?? '',
      author: json['a'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'q': text,
      'a': author,
    };
  }
}
