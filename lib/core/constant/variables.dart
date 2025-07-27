
class Variables {
  static const String appName = 'MasjidKu';
  
  // Hadith API
  static const String hadithApiBase = 'https://hadithapi.com/api';
    static const apiKey =
      '\$2y\$10\$K1s5fAV2PvP5YDdxfk49YOgMM5nNG6MqhpIC0YfufjUIdMFn8rCN';

  
  // Endpoints with API key
  static String get booksEndpoint => '$hadithApiBase/books?apiKey=$apiKey';
  static String hadithsEndpoint({int? page, int? limit}) {
    final params = {
      'apiKey': apiKey,
      if (page != null) 'page': page.toString(),
      if (limit != null) 'limit': limit.toString(),
    };
    final query = Uri(queryParameters: params).query;
    return '$hadithApiBase/hadiths?$query';
  }
  
  // For getting chapters of a specific book
  static String bookChaptersEndpoint(String bookSlug) {
    return '$hadithApiBase/$bookSlug/chapters?apiKey=$apiKey}';
  }
  
  // Backend API
  static const String baseUrl = 'http://192.168.1.10:6000'; // TODO: change this to your backend url
}
