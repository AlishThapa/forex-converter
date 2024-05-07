import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ForexInfoScreen extends StatelessWidget {
  ForexInfoScreen({Key? key}) : super(key: key);
  final String _url = 'https://mail.google.com/mail/u/0/#inbox?compose=DmwnWrRvwTlBFWqgTKMwXwGBMxlCbtFqTvKzKlBTXdRxVSSsFRXxwdxmnNcDCdtVwSRKqxMvLLXQ';

  Future<void> _launchUrl() async {
    if (!await launchUrl(
      Uri.parse(_url),
    )) {
      throw Exception('Could not launch');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Forex Converter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Forex Converter Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'The Forex Converter is a tool that helps users convert currencies from one to another using real-time exchange rates. It\'s an essential tool for traders and individuals who are dealing with multiple currencies.',
              style: TextStyle(fontSize: 16),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Made with flutter️ by',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    _launchUrl();
                  },
                  child: Text(
                    'Alish Thapa',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
