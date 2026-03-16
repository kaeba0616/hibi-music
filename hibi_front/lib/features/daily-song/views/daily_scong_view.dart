import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hidi/features/artists/views/artist_view.dart';

class DailySongView extends ConsumerStatefulWidget {
  static const String routeName = 'songs';
  static const String routeURL = '/songs/:songId';
  final int songId;
  const DailySongView({super.key, required this.songId});

  @override
  ConsumerState<DailySongView> createState() => _DailySongViewState();
}

class _DailySongViewState extends ConsumerState<DailySongView> {
  bool _showLyrics = false;
  void _onArtist() {
    context.pushNamed(ArtistView.routeName, pathParameters: {'artistId': "1"});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Song title")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  image: DecorationImage(
                    image: AssetImage("assets/images/Samekosaba.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Song title",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage("assets/images/hebi_ever.jpg"),
              ),
              title: const Text(
                "artistName",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                'Artist',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              onTap: () {
                _onArtist();
              },
            ),
            const SizedBox(height: 20),
            Text(
              'From the album',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            Text(
              "AlbumName",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _showLyrics = !_showLyrics;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _showLyrics
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                    Text(
                      _showLyrics ? 'Hide Lyrics' : 'Show Lyrics',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState:
                  _showLyrics
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
              firstChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 10),
                  Text(
                    '(Verse 1)\nOh, the rhythm takes control, a melody so sweet,\nEvery note a story told, on this vibrant street.\nFeel the bass drum in your soul, a pulsating beat,\nMusic makes the spirit whole, from your head to feet.'
                    '\n\n(Chorus)\nSing along, let your voice be free, in this harmonious space,\nLost in sound, for all to see, a smile upon your face.\nEvery chord, a memory, time cannot erase,\nMusic\'s magic, wild and free, in this joyful place.'
                    '\n\n(Verse 2)\nThrough the speakers, clear and bright, a symphony unfolds,\nBringing colors to the night, as the story\'s told.\nDancing in the fading light, brave and strong and bold,\nMusic fills us with delight, more precious than pure gold.'
                    '\n\n(Chorus)\nSing along, let your voice be free, in this harmonious space,\nLost in sound, for all to see, a smile upon your face.\nEvery chord, a memory, time cannot erase,\nMusic\'s magic, wild and free, in this joyful place.'
                    '\n\n(Bridge)\nFrom the quiet, gentle hum, to the roaring, grand crescendo,\nMusic\'s journey has begun, a beautiful memento.\nLet your heart beat like a drum, let your feelings flow,\nAs the melodies become, all that you will know.'
                    '\n\n(Chorus)\nSing along, let your voice be free, in this harmonious space,\nLost in sound, for all to see, a smile upon your face.\nEvery chord, a memory, time cannot erase,\nMusic\'s magic, wild and free, in this joyful place.'
                    '\n\n(Outro)\nYeah, music\'s magic, pure and true, forever it will stay,\nGuiding us in all we do, lighting up our way.',
                  ),
                ],
              ),
              secondChild:
                  Container(), // Empty container when lyrics are hidden
            ),
          ],
        ),
      ),
    );
  }
}
