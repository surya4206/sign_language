import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KannadaAlphabetsPage extends StatelessWidget {
  final List<Map<String, String>> kannadaVyanjanas = const [
    {'letter': 'ಕ', 'image': 'assets/sign_language_ka.jpg'},
    {'letter': 'ಖ', 'image': 'assets/sign_language_kha.jpg'},
    {'letter': 'ಗ', 'image': 'assets/sign_language_ga.jpg'},
    {'letter': 'ಘ', 'image': 'assets/sign_language_gha.jpg'},
    {'letter': 'ಙ', 'image': 'assets/sign_language_na1.jpg'},
    {'letter': 'ಚ', 'image': 'assets/sign_language_cha.jpg'},
    {'letter': 'ಛ', 'image': 'assets/sign_language_chha.jpg'},
    {'letter': 'ಜ', 'image': 'assets/sign_language_ja.jpg'},
    {'letter': 'ಝ', 'image': 'assets/sign_language_jha.jpg'},
    {'letter': 'ಞ', 'image': 'assets/sign_language_na2.jpg'},
    {'letter': 'ಟ', 'image': 'assets/sign_language_ta.jpg'},
    {'letter': 'ಠ', 'image': 'assets/sign_language_tta.jpg'},
    {'letter': 'ಡ', 'image': 'assets/sign_language_da.jpg'},
    {'letter': 'ಢ', 'image': 'assets/sign_language_dda.jpg'},
    {'letter': 'ಣ', 'image': 'assets/sign_language_na3.jpg'},
    {'letter': 'ತ', 'image': 'assets/sign_language_tha.jpg'},
    {'letter': 'ಥ', 'image': 'assets/sign_language_ttha.jpg'},
    {'letter': 'ದ', 'image': 'assets/sign_language_dha.jpg'},
    {'letter': 'ಧ', 'image': 'assets/sign_language_ddha.jpg'},
    {'letter': 'ನ', 'image': 'assets/sign_language_na4.jpg'},
  ];

  const KannadaAlphabetsPage({super.key});

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
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: kannadaVyanjanas.length,
          itemBuilder: (context, index) {
            final vyanjana = kannadaVyanjanas[index];
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
                  child: Text(
                    vyanjana['letter']!,
                    style: GoogleFonts.poppins(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                ),
              ),
            );
          },
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
