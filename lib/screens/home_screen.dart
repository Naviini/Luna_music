import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Black Background
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70), // Resized AppBar
        child: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Lu',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: 'na',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white, size: 28),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white, size: 28),
              onPressed: () {},
            ),
          ],
        ),
      ),
       body: SingleChildScrollView(
        child: Column(
          children: [
            // ---- Top Section ----
            Stack(
              children: [
                const Positioned(
                  top: 50,
                  left: 20,
                  child: Opacity(
                    opacity: 0.4,
                    child: Icon(Icons.music_note, size: 100, color: Colors.white),
                  ),
                ),
                const Positioned(
                  top: 100,
                  right: 50,
                  child: Opacity(
                    opacity: 0.6,
                    child: Icon(Icons.music_note, size: 80, color: Colors.deepPurple),
                  ),
                ),
                const Positioned(
                  bottom: 150,
                  left: 80,
                  child: Opacity(
                    opacity: 0.5,
                    child: Icon(Icons.music_note, size: 120, color: Colors.deepPurple),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 80),
                  child: Column(
                    children: [
                      const Text(
                        "Let's",
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        "Create",
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Create that music, saying in your\nhead rent free.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text(
                          "START",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10), // Space before scrolling section

            // ---- Scrollable Containers ----
            ContainerSection(
              title: "Explore...",
              buttonText: "Explore now",
              onTap: () {
                // Navigate to Explore Page
              },
            ),
            const SizedBox(height: 20),
            ContainerSection(
              title: "Music\nBox",
              buttonText: "Create now",
              onTap: () {
                // Navigate to Music Box Page
              },
            ),

            const SizedBox(height: 40), // Space before New Releases section

            // ---- New Releases Section ----
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
    alignment: Alignment.centerLeft, // Aligns text to the left
              child: Text(
                "New releases",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 250, // Set height for horizontal scrolling
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5, // Replace with dynamic track count
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Navigate to Music Player Page with selected track
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey[800], // Placeholder color
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Name of the Track",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            "Artist’s Name",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

             
           const SizedBox(height: 10),
      
            // Top Creators Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Top creators",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 250, // Adjust height as needed
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5, // Replace with dynamic count
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[800], // Placeholder color
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Creator’s Name",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          "Rank",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            // ---- Catch Up Your Community Section ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Catch up your community.",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Found creators and listeners to match your vibe.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // Action for joining mailing list
                      },
                      child: const Text(
                        "JOIN MAILING LIST",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

           const SizedBox(height: 30),

            // ---- Footer Section ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildFooterColumn("MY ACCOUNT", [
                          _buildFooterLink("Sign In", "signin"),
                          _buildFooterLink("Register", "register"),
                          _buildFooterLink("Creator Status", "creatorstatus"),
                        ]),
                        _buildFooterColumn("HELP", [
                          _buildFooterLink("Beginner Tutorial", "tutorial"),
                          _buildFooterLink("Creativity Course", "course"),
                          _buildFooterLink("Listing", "listing"),
                        ]),
                        _buildFooterColumn("ABOUT", [
                          _buildFooterLink("Our Story", "story"),
                          _buildFooterLink("Media", "media"),
                          _buildFooterLink("Charities", "charities"),
                        ]),
                        _buildFooterColumn("LEGAL TERMS", [
                          _buildFooterLink("Terms of Use", "terms"),
                          _buildFooterLink("Terms of Authority", "authority"),
                          _buildFooterLink("Privacy Policy", "privacy"),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ---- Social Media Links ----
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialIcon(Icons.facebook, "https://facebook.com"),
                        const SizedBox(width: 16),
                        _buildSocialIcon(Icons.facebook, "https://instagram.com"),
                        const SizedBox(width: 16),
                        _buildSocialIcon(Icons.facebook, "https://twitter.com"),
                        const SizedBox(width: 16),
                        _buildSocialIcon(Icons.facebook, "https://linkedin.com"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Footer Column Builder
  Widget _buildFooterColumn(String title, List<Widget> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 10),
        ...links,
      ],
    );
  }

  // Footer Link Builder
  Widget _buildFooterLink(String text, String route) {
    return GestureDetector(
      onTap: () => (route),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Social Icon Builder
  Widget _buildSocialIcon(IconData icon, String url) {
    return GestureDetector(
      onTap: () => (url),
      child: CircleAvatar(
        backgroundColor: Colors.deepPurple,
        radius: 20,
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

 


        
// Reusable Container Widget
class ContainerSection extends StatelessWidget {
  final String title;
  final String buttonText;
  final VoidCallback onTap;

  const ContainerSection({
    super.key,
    required this.title,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.deepPurple, // Dark Purple Background
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onTap,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const Icon(Icons.arrow_right_alt, color: Colors.white),
                ],
              ),
            ),
          ],
        )
      ),
    );
  }
}
    
  


        
      
    
  


