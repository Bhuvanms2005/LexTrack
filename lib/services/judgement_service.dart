import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class JudgementService {
  static Future<List<Map<String, String>>> fetchJudgements(String query) async {

    final response = await http.get(
      Uri.parse("https://indiankanoon.org/search/?formInput=$query"),
    );

    if (response.statusCode == 200) {

      final document = parser.parse(response.body);
      final results = document.querySelectorAll('.result');

      List<Map<String, String>> data = [];

      for (var item in results) {
        final linkElement = item.querySelector('a');

        if (linkElement != null) {
          String title = linkElement.text.trim();
          String link = "https://indiankanoon.org${linkElement.attributes['href']}";

          data.add({
            "title": title,
            "link": link,
          });
        }
      }

      return data;

    } else {
      return [];
    }
  }
}