import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lyfer/features/dashboard/domain/models/quote_model.dart';

class QuoteRepository {
  static const String _cacheKey = 'cached_quote';
  static const String _cacheDateKey = 'cached_quote_date';
  static const Duration _cacheDuration = Duration(hours: 24);
  static const String _apiUrl = 'https://zenquotes.io/api/today';
  static final QuoteModel _fallbackQuote = QuoteModel(
    text:
        'The only limit to our realization of tomorrow is our doubts of today.',
    author: 'Franklin D. Roosevelt',
  );

// todo: Fetches a quote from the API or returns a cached quote if available

  Future<QuoteModel> fetchQuoteFromAPI() async {
    final response = await http.get(
      Uri.parse('https://zenquotes.io/api/today'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return QuoteModel.fromJson(data[0]);
    } else {
      throw Exception('Failed to load quote from API');
    }
  }
}
