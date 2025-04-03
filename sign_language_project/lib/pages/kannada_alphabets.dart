import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  List<Map<String, String>> _filteredVyanjanas = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredVyanjanas = List.from(_allVyanjanas);
    _searchController.addListener(_filterLetters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLetters() {
    final query = _searchController.text.toLowerCase();
    
    if (query.isEmpty) {
      setState(() {
        _filteredVyanjanas = List.from(_allVyanjanas);
      });
      return;
    }

    setState(() {
      _filteredVyanjanas = _allVyanjanas.where((vyanjana) {
        final letter = vyanjana['letter']!;
        final transliteration = vyanjana['transliteration']!.toLowerCase();
        return letter.contains(query) || 
               transliteration.contains(query) ||
               transliteration.replaceAll(RegExp(r'[^a-zA-Z]'), '').contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kannada Vyanjanas',
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
                  hintText: 'Search by Kannada letter or English (ka, cha...)',
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
              child: _filteredVyanjanas.isEmpty
                  ? Center(
                      child: Text(
                        'No letters found',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _filteredVyanjanas.length,
                      itemBuilder: (context, index) {
                        final vyanjana = _filteredVyanjanas[index];
                        return GestureDetector(
                          onTap: () => _showLetterPopup(context, vyanjana['image']!),
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
                                    vyanjana['letter']!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey[800],
                                    ),
                                  ),
                                  Text(
                                    vyanjana['transliteration']!,
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
                    ),
            ),
          ],
        ),
      ),
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
                    return const Center(
                      child: Text('Image not found'),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
