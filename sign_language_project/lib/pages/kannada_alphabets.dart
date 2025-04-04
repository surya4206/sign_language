import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'dart:math' as math;

class KannadaAlphabetsPage extends StatefulWidget {
  const KannadaAlphabetsPage({super.key});

  @override
  State<KannadaAlphabetsPage> createState() => _KannadaAlphabetsPageState();
}

class _KannadaAlphabetsPageState extends State<KannadaAlphabetsPage> {
  final List<Map<String, String>> _allVyanjanas = const [
    {'letter': 'ಕ', 'image': 'assets/sign_language_ka.jpg', 'transliteration': 'ka'},
    {'letter': 'ಖ', 'image': 'assets/sign_language_kha.jpg', 'transliteration': 'kha'},
    {'letter': 'ಗ', 'image': 'assets/sign_language_ga.jpg', 'transliteration': 'ga'},
    {'letter': 'ಘ', 'image': 'assets/sign_language_gha.jpg', 'transliteration': 'gha'},
    {'letter': 'ಙ', 'image': 'assets/sign_language_na1.jpg', 'transliteration': 'na1'},
    {'letter': 'ಚ', 'image': 'assets/sign_language_cha.jpg', 'transliteration': 'cha'},
    {'letter': 'ಛ', 'image': 'assets/sign_language_chha.jpg', 'transliteration': 'chha'},
    {'letter': 'ಜ', 'image': 'assets/sign_language_ja.jpg', 'transliteration': 'ja'},
    {'letter': 'ಝ', 'image': 'assets/sign_language_jha.jpg', 'transliteration': 'jha'},
    {'letter': 'ಞ', 'image': 'assets/sign_language_na2.jpg', 'transliteration': 'na2'},
    {'letter': 'ಟ', 'image': 'assets/sign_language_ta.jpg', 'transliteration': 'ta'},
    {'letter': 'ಠ', 'image': 'assets/sign_language_tta.jpg', 'transliteration': 'tta'},
    {'letter': 'ಡ', 'image': 'assets/sign_language_da.jpg', 'transliteration': 'da'},
    {'letter': 'ಢ', 'image': 'assets/sign_language_dda.jpg', 'transliteration': 'dda'},
    {'letter': 'ಣ', 'image': 'assets/sign_language_na3.jpg', 'transliteration': 'na3'},
    {'letter': 'ತ', 'image': 'assets/sign_language_tha.jpg', 'transliteration': 'tha'},
    {'letter': 'ಥ', 'image': 'assets/sign_language_ttha.jpg', 'transliteration': 'ttha'},
    {'letter': 'ದ', 'image': 'assets/sign_language_dha.jpg', 'transliteration': 'dha'},
    {'letter': 'ಧ', 'image': 'assets/sign_language_ddha.jpg', 'transliteration': 'ddha'},
    {'letter': 'ನ', 'image': 'assets/sign_language_na4.jpg', 'transliteration': 'na4'},
  ];

  final List<Map<String, String>> _allWords = const [
    {'word': 'ಬುಧವಾರ', 'video': 'assets/wednesday.mp4', 'transliteration': 'Wednesday'},
    {'word': 'ಸೇಬು', 'video': 'assets/apple.mp4', 'transliteration': 'Apple'},
  ];

  List<Map<String, String>> _filteredVyanjanas = [];
  List<Map<String, String>> _filteredWords = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredVyanjanas = List.from(_allVyanjanas);
    _filteredWords = List.from(_allWords);
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredVyanjanas = _allVyanjanas.where((item) {
        return item['letter']!.contains(query) || 
               item['transliteration']!.toLowerCase().contains(query);
      }).toList();

      _filteredWords = _allWords.where((item) {
        return item['word']!.contains(query) || 
               item['transliteration']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kannada Characters and Words',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey, Colors.white70],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                  hintText: 'Search by Kannada letter/word or English',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Characters'),
                    _buildGrid(_filteredVyanjanas, true),
                    _buildSectionTitle('Words'),
                    _buildGrid(_filteredWords, false),
                    if (_filteredVyanjanas.isEmpty && _filteredWords.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No results found',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.blueGrey[800],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey[800],
        ),
      ),
    );
  }

  Widget _buildGrid(List<Map<String, String>> items, bool isCharacter) {
    if (items.isEmpty) return const SizedBox.shrink();
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => isCharacter 
              ? _showLetterPopup(context, item['image']!)
              : _showVideoPopup(context, item['video']!),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.white, Colors.white70],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isCharacter ? item['letter']! : item['word']!,
                    style: GoogleFonts.poppins(
                      fontSize: 30, // change the font displayed
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  Text(
                    item['transliteration']!,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.blueGrey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLetterPopup(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text('Image not found'));
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showVideoPopup(BuildContext context, String videoPath) {
  final videoPlayerController = VideoPlayerController.asset(videoPath);
  bool isDisposed = false;
  // You can change this angle value to rotate the video (in radians)
  // 0 = no rotation, math.pi/2 = 90 degrees, math.pi = 180 degrees, 3*math.pi/2 = 270 degrees
  final double customRotationAngle = math.pi/2; // 90 degrees rotation

  Future<void> initializeVideo() async {
    try {
      await videoPlayerController.initialize();
      if (!isDisposed) {
        videoPlayerController.play();
        videoPlayerController.setLooping(true);
      }
    } catch (e) {
      if (!isDisposed) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading video: $e')),
        );
      }
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: FutureBuilder(
          future: initializeVideo(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading video'));
            }
            if (videoPlayerController.value.isInitialized) {
              return Stack(
                children: [
                  Center(
                    child: Transform.rotate(
                      angle: customRotationAngle, // Use custom rotation angle
                      child: AspectRatio(
                        // Adjust aspect ratio if needed for rotated video
                        aspectRatio: customRotationAngle % math.pi == 0 
                            ? videoPlayerController.value.aspectRatio 
                            : 1 / videoPlayerController.value.aspectRatio,
                        child: VideoPlayer(videoPlayerController),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        videoPlayerController.pause();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: VideoProgressIndicator(
                      videoPlayerController,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Colors.blue,
                      ),
                    ),
                  ),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      );
    },
  ).then((_) {
    isDisposed = true;
    videoPlayerController.dispose();
  });
}
}
