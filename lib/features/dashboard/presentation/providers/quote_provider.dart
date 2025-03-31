import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyfer/features/dashboard/data/quote_repository.dart';
import 'package:lyfer/features/dashboard/domain/models/quote_model.dart';

final quoteRepositoryProvider = Provider<QuoteRepository>((ref) {
  return QuoteRepository();
});

final quoteProvider = FutureProvider<QuoteModel>((ref) async {
  try {
    return await ref.read(quoteRepositoryProvider).fetchQuoteFromAPI();
  } catch (e) {
    print('Error in quote provider: $e');
    // Re-throw to let the UI handle it
    throw e;
  }
});
