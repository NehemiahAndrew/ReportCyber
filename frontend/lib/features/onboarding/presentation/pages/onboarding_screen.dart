import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Report Anonymously',
      description:
          'Safely and securely report cyber threats with our privacy-first approach, ensuring your identity is always protected.',
      icon: Icons.shield_outlined,
      gradientColors: [const Color(0xFF0A1628), const Color(0xFF1A3A5C)],
      iconWidget: _buildShieldIcon(),
    ),
    OnboardingPage(
      title: 'Track Your Reports',
      description:
          'Monitor the status of your submitted reports in real-time. Get notified when there are updates or actions taken.',
      icon: Icons.track_changes,
      gradientColors: [const Color(0xFF0A1628), const Color(0xFF1A3A5C)],
      iconWidget: _buildTrackingIcon(),
    ),
    OnboardingPage(
      title: 'Report Cybercrime\nSecurely',
      description:
          'Welcome to our platform. Your anonymous reports help create a safer digital world for everyone.',
      icon: Icons.fingerprint,
      gradientColors: [const Color(0xFF0A1628), const Color(0xFF1A3A5C)],
      iconWidget: _buildFingerprintIcon(),
    ),
  ];

  static Widget _buildShieldIcon() {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF1A3A5C), const Color(0xFF0D2137)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Wooden platform at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [const Color(0xFFD4A574), const Color(0xFFB8956E)],
                ),
              ),
              child: Center(
                child: Container(
                  width: 100,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D2B1F),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          // Shield icon
          Positioned(
            top: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow
                Container(
                  width: 140,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A90A4).withOpacity(0.3),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
                // Shield shape
                CustomPaint(
                  size: const Size(120, 140),
                  painter: ShieldPainter(),
                ),
                // Person icon inside shield
                Positioned(
                  top: 35,
                  child: Column(
                    children: [
                      Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF6B8A9A).withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: 50,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B8A9A).withOpacity(0.8),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25),
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 8,
                            height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A6670),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildTrackingIcon() {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFF3A7BD5),
            const Color(0xFF1A3A5C),
            const Color(0xFF0D2137),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3A7BD5).withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF4A90A4).withOpacity(0.3),
                width: 2,
              ),
            ),
          ),
          // Middle ring
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF4A90A4).withOpacity(0.4),
                width: 2,
              ),
            ),
          ),
          // Inner ring
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF4A90A4).withOpacity(0.5),
                width: 2,
              ),
            ),
          ),
          // Center dot
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF4FC3F7),
            ),
          ),
          // Tracking line
          Positioned(
            child: Transform.rotate(
              angle: -0.5,
              child: Container(
                width: 3,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFF4FC3F7),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4FC3F7).withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Blip points
          Positioned(
            top: 50,
            right: 70,
            child: _buildBlip(8, const Color(0xFF4FC3F7)),
          ),
          Positioned(
            bottom: 80,
            left: 60,
            child: _buildBlip(6, const Color(0xFF81D4FA)),
          ),
          Positioned(
            top: 100,
            left: 50,
            child: _buildBlip(5, const Color(0xFFB3E5FC)),
          ),
        ],
      ),
    );
  }

  static Widget _buildBlip(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  static Widget _buildFingerprintIcon() {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFF3A7BD5),
            const Color(0xFF1E4976),
            const Color(0xFF0D2137),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3A7BD5).withOpacity(0.4),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Scanner corners
          Positioned(top: 60, left: 70, child: _buildCorner(true, true)),
          Positioned(top: 60, right: 70, child: _buildCorner(true, false)),
          Positioned(bottom: 60, left: 70, child: _buildCorner(false, true)),
          Positioned(bottom: 60, right: 70, child: _buildCorner(false, false)),
          // Fingerprint icon
          Icon(Icons.fingerprint, size: 120, color: const Color(0xFF81D4FA)),
        ],
      ),
    );
  }

  static Widget _buildCorner(bool isTop, bool isLeft) {
    return SizedBox(
      width: 30,
      height: 30,
      child: CustomPaint(
        painter: CornerPainter(isTop: isTop, isLeft: isLeft),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skip() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button (only show on first pages)
            if (_currentPage < _pages.length - 1)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: _skip,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Color(0xFF3A7BD5),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 56),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildDot(index),
                ),
              ),
            ),

            // Next button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A7BD5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Skip text on last page
            if (_currentPage == _pages.length - 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: TextButton(
                  onPressed: _skip,
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Color(0xFF3A7BD5), fontSize: 16),
                  ),
                ),
              )
            else
              const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon/Image
          page.iconWidget ??
              Icon(page.icon, size: 150, color: const Color(0xFF4FC3F7)),
          const SizedBox(height: 48),

          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    bool isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF3A7BD5)
            : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final Widget? iconWidget;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    this.iconWidget,
  });
}

class ShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(0xFF6B8A9A);

    final path = Path();

    // Shield shape
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height * 0.2);
    path.lineTo(size.width, size.height * 0.5);
    path.quadraticBezierTo(
      size.width,
      size.height * 0.8,
      size.width / 2,
      size.height,
    );
    path.quadraticBezierTo(0, size.height * 0.8, 0, size.height * 0.5);
    path.lineTo(0, size.height * 0.2);
    path.close();

    // Draw outer shield
    canvas.drawPath(path, paint);

    // Draw inner shield
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF6B8A9A).withOpacity(0.5);

    final innerPath = Path();
    final inset = 10.0;

    innerPath.moveTo(size.width / 2, inset);
    innerPath.lineTo(size.width - inset, size.height * 0.2 + inset / 2);
    innerPath.lineTo(size.width - inset, size.height * 0.5);
    innerPath.quadraticBezierTo(
      size.width - inset,
      size.height * 0.75,
      size.width / 2,
      size.height - inset,
    );
    innerPath.quadraticBezierTo(
      inset,
      size.height * 0.75,
      inset,
      size.height * 0.5,
    );
    innerPath.lineTo(inset, size.height * 0.2 + inset / 2);
    innerPath.close();

    canvas.drawPath(innerPath, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CornerPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;

  CornerPainter({required this.isTop, required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF4FC3F7);

    final path = Path();

    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
