import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../widgets/app_bottom_nav.dart';

// Custom painter for grid pattern
class GridPatternPainter extends CustomPainter {
  final Color lineColor;
  final double lineWidth;
  final double gridSize;

  GridPatternPainter({
    required this.lineColor,
    required this.lineWidth,
    required this.gridSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth;

    // Draw vertical lines
    for (double i = 0; i <= size.width; i += gridSize) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double i = 0; i <= size.height; i += gridSize) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroSection(),
            _buildContentContainer(context),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  Widget _buildHeroSection() {
    return Builder(
        builder: (context) => Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height < 700 ? 16 : 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4361ee), // Primary from home.html
                    Color(0xFF4cc9f0), // Secondary from home.html
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // App title
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/This.png',
                            width: 28,
                            height: 28,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            AppConstants.appName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  color: Color(0x40000000),
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Welcome message
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: MediaQuery.of(context).size.height < 700
                              ? 8
                              : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome to Calendar This',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  color: Color(0x40000000),
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your smart calendar assistant',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Hero illustration with enhanced design - responsive height
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height < 700
                          ? 140
                          : 180, // Smaller height on medium screens
                      margin: EdgeInsets.fromLTRB(24, 8, 24,
                          MediaQuery.of(context).size.height < 700 ? 8 : 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x30000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Background pattern
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: CustomPaint(
                                painter: GridPatternPainter(
                                  lineColor: Colors.white.withAlpha(20),
                                  lineWidth: 1,
                                  gridSize: 20,
                                ),
                              ),
                            ),
                          ),

                          // Calendar icon with glow effect
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(30),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        const Color(0xFF4361ee).withAlpha(100),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/icons/This.png',
                                width: 80,
                                height: 80,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                          // Decorative elements
                          Positioned(
                            top: 20,
                            left: 20,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(40),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.event_note,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            right: 20,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(40),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.notifications,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  Widget _buildContentContainer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActionCard(context),

          // Added space at the bottom to ensure content doesn't get hidden behind bottom nav
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF4361ee).withAlpha(5),
            blurRadius: 20,
            spreadRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Create Manual Event button (now with white style)
            _buildActionButton(
              context,
              label: 'Create Manual Event',
              icon: Icons.add_circle_outline,
              isPrimary: false,
              onPressed: () {
                // Navigate to the event creation view with the manual tab selected
                Navigator.pushNamed(context, AppConstants.eventCreationRoute);
              },
            ),

            const SizedBox(height: 16),

            // Extract from Text button (now with blue style)
            _buildActionButton(
              context,
              label: 'Extract from Text',
              icon: Icons.text_fields,
              isPrimary: true,
              onPressed: () {
                // Navigate to the event creation view with the text extraction tab selected
                Navigator.pushNamed(
                  context,
                  AppConstants.eventCreationRoute,
                  arguments: {'initialTab': 1},
                );
              },
            ),

            const SizedBox(height: 16),

            // Extract from Image button (premium)
            _buildPremiumActionButton(
              context,
              label: 'Extract from Image',
              icon: Icons.image,
              onPressed: () {
                // Navigate to the event creation view with the image extraction tab selected
                Navigator.pushNamed(
                  context,
                  AppConstants.eventCreationRoute,
                  arguments: {'initialTab': 2},
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: isPrimary ? const Color(0xFF4361ee) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: isPrimary ? 2 : 0,
      shadowColor: isPrimary
          ? const Color(0xFF4361ee).withAlpha(100)
          : Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        splashColor: isPrimary
            ? Colors.white.withAlpha(50)
            : const Color(0xFF4361ee).withAlpha(20),
        highlightColor: isPrimary
            ? Colors.white.withAlpha(20)
            : const Color(0xFF4361ee).withAlpha(10),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width < 360 ? 12 : 20,
              vertical: MediaQuery.of(context).size.width < 360 ? 12 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isPrimary ? null : Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              // Icon with background for better visual hierarchy
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? Colors.white.withAlpha(30)
                      : const Color(0xFF4361ee).withAlpha(10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: isPrimary ? Colors.white : const Color(0xFF4361ee),
                    size: 24,
                  ),
                ),
              ),

              // Label with description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isPrimary ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isPrimary
                          ? 'Extract event details from text'
                          : 'Create a new event manually',
                      style: TextStyle(
                        fontSize: 12,
                        color: isPrimary
                            ? Colors.white.withAlpha(200)
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow icon for better affordance
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isPrimary
                    ? Colors.white.withAlpha(150)
                    : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: const Color(0xFF9333ea).withAlpha(100),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.white.withAlpha(50),
        highlightColor: Colors.white.withAlpha(20),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width < 360 ? 12 : 20,
              vertical: MediaQuery.of(context).size.width < 360 ? 12 : 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF9333ea), Color(0xFF7c3aed)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Icon with background
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),

              // Label with description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Extract event details from images',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withAlpha(200),
                      ),
                    ),
                  ],
                ),
              ),

              // Premium badge with enhanced design
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withAlpha(50),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Premium',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
