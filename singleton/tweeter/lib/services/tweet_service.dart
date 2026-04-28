import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/tweet.dart';
import '../models/tweet_response.dart';

/// Singleton service for managing REST API calls to the tweets endpoint
/// Implements the Singleton pattern to ensure only one instance exists
class TweetService {
  static final TweetService _instance = TweetService._internal();

  final String baseUrl = 'https://tweeter-api-ybye.onrender.com/api';
  // final String baseUrl = 'http://localhost:8080/api';
  late http.Client _httpClient;

  // Private constructor
  TweetService._internal() {
    _httpClient = http.Client();
  }

  /// Factory constructor that always returns the same instance
  factory TweetService() {
    return _instance;
  }

  /// Get the singleton instance
  static TweetService getInstance() {
    return _instance;
  }

  /// Fetch all tweets from the API
  Future<List<Tweet>> fetchTweets() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/tweets'),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final tweetResponse = TweetResponse.fromJson(jsonData);
        return tweetResponse.content;
      } else {
        throw Exception(
          'Failed to load tweets. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching tweets: $e');
    }
  }

  /// Close the HTTP client (cleanup)
  void dispose() {
    _httpClient.close();
  }
}
