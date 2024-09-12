import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'home_page.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _selectedLanguage = 'English';
  String _result = '';
  String? _imageUrl;
  String? _videoUrl;
  String? _englishTitle;
  String? _kannadaTitle;

  VideoPlayerController? _videoController;

  final List<String> _languages = ['English', 'Kannada'];

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _disposeVideoController();
    super.dispose();
  }

  void _search() async {
    String query = _controller.text.trim();

    if (_selectedLanguage == 'English') {
      query = query.toLowerCase(); // Convert to lowercase for English
    }

    if (query.isEmpty) {
      setState(() {
        _result = 'Please enter a word.';
        _clearResults();
      });
      return;
    }

    try {
      String fieldToQuery =
      _selectedLanguage == 'English' ? 'english_title' : 'kannada_title';

      final firestoreRef = FirebaseFirestore.instance
          .collection('media')
          .where(fieldToQuery, isEqualTo: query);
      final querySnapshot = await firestoreRef.get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _result = 'No results found.';
          _clearResults();
        });
        return;
      }

      final document = querySnapshot.docs.first.data();
      final imageUrl = document['imageUrl'] as String?;
      final videoUrl = document['videoUrl'] as String?;
      final englishTitle = document['english_title'] as String?;
      final kannadaTitle = document['kannada_title'] as String?;

      setState(() {
        _result = 'Search results:';
        _imageUrl = imageUrl;
        _videoUrl = videoUrl;
        _englishTitle = englishTitle;
        _kannadaTitle = kannadaTitle;
        _disposeVideoController();
        if (videoUrl != null) {
          _videoController = VideoPlayerController.network(videoUrl)
            ..initialize().then((_) {
              setState(() {});
            });
        }
      });
    } catch (e) {
      setState(() {
        _result = 'Error fetching data: $e';
        _clearResults();
      });
    }
  }

  void _clearResults() {
    _imageUrl = null;
    _videoUrl = null;
    _englishTitle = null;
    _kannadaTitle = null;
    _disposeVideoController();
  }

  void _disposeVideoController() {
    if (_videoController != null) {
      _videoController!.dispose();
      _videoController = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign Language Search',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomePage()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
        ],
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Language:',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey[200]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                  value: _selectedLanguage,
                  items: _languages.map((String language) {
                    return DropdownMenuItem<String>(
                      value: language,
                      child: Text(
                        language,
                        style: GoogleFonts.poppins(),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedLanguage = newValue!;
                    });
                  },
                  isExpanded: true,
                  underline: const SizedBox(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  labelText: 'Enter a word',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.text,
                onSubmitted: (_) {
                  _search();
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _search,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Search',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              Text(
                _result,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              if (_englishTitle != null) ...[
                const SizedBox(height: 16),
                Text(
                  'English Title: $_englishTitle',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
              if (_kannadaTitle != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Kannada Title: $_kannadaTitle',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
              if (_imageUrl != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _imageUrl!,
                    fit: BoxFit.cover,
                    height: 200,
                    width: double.infinity,
                  ),
                ),
              ],
              if (_videoUrl != null &&
                  _videoController != null &&
                  _videoController!.value.isInitialized) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (_videoController!.value.isPlaying) {
                          _videoController!.pause();
                        } else {
                          _videoController!.play();
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: Icon(
                      _videoController!.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
