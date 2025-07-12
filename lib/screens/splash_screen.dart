import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _loadingController;
  late AnimationController _backgroundController;
  late AnimationController _glowController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _loadingAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _glowAnimation;

  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSequence();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 10000),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 40.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutExpo,
    ));

    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));
    _backgroundAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_backgroundController);
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  void _startSequence() async {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _backgroundController.repeat();
    _glowController.repeat(reverse: true);
    await Future.delayed(const Duration(milliseconds: 400));
    _fadeController.forward();
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    _loadingController.forward();
    setState(() {
      _showContent = true;
    });

    await Future.delayed(const Duration(milliseconds: 3200));
    if (mounted) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  Future<void> _launchURL(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $urlString';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Could not open link. Please check your internet connection.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _loadingController.dispose();
    _backgroundController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF000000),
            ],
          ),
        ),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: StarfieldPainter(_backgroundAnimation.value),
                );
              },
            ),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: _buildMainContent(),
                  ),
                  _buildFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return AnimatedBuilder(
        animation: Listenable.merge([_slideController, _fadeController]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),
                    AnimatedBuilder(
                      animation: _glowController,
                      builder: (context, child) {
                        final glowIntensity = 0.3 + _glowAnimation.value * 0.2;
                        return Text(
                          'TimeWise',
                          style: TextStyle(
                            fontSize: 76,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                            letterSpacing: 2,
                            height: 1,
                            shadows: [
                              Shadow(
                                color: Colors.blue
                                    .withOpacity(glowIntensity * 0.3),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Smart Attendance Tracker',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[300],
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(flex: 2),
                    if (_showContent) _buildLoadingVisual(),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _buildLoadingVisual() {
    return AnimatedBuilder(
      animation: _loadingController,
      builder: (context, child) {
        return SizedBox(
          width: 200,
          height: 50,
          child: CustomPaint(
            painter: SmoothLoadingBarWithRunnerPainter(_loadingAnimation.value),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value * 0.85,
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              children: [
                Text(
                  'Made by Akshat Singh',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildEnhancedSocialLink(
                      Icons.code_rounded,
                      'GitHub',
                      'https://github.com/akshat2474',
                    ),
                    const SizedBox(width: 28),
                    _buildEnhancedSocialLink(
                      Icons.work_rounded,
                      'LinkedIn',
                      'https://www.linkedin.com/in/akshat-singh-48a03b312/',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedSocialLink(IconData icon, String label, String url) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white.withOpacity(0.25),
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.grey[300],
              size: 15,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 13,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StarfieldPainter extends CustomPainter {
  final double progress;
  final int starCount = 200;
  final math.Random random = math.Random(1337);

  StarfieldPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < starCount; i++) {
      final starRandom = math.Random(i);
      final depth = starRandom.nextDouble();

      final opacity = (0.2 + (depth * 0.8)).clamp(0.2, 1.0);
      final starSize = 0.5 + (depth * 1.5);

      final initialX = starRandom.nextDouble() * size.width;
      final initialY = starRandom.nextDouble() * size.height;

      final y = (initialY + (progress * 100 * depth)) % size.height;

      paint.color = Colors.white.withOpacity(opacity * 0.5);
      canvas.drawCircle(Offset(initialX, y), starSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarfieldPainter oldDelegate) =>
      progress != oldDelegate.progress;
}

class SmoothLoadingBarWithRunnerPainter extends CustomPainter {
  final double progress;

  SmoothLoadingBarWithRunnerPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    _drawLoadingBarBackground(canvas, size);
    _drawLoadingBarFill(canvas, size);
    _drawSmoothRunningMan(canvas, size);
  }

  void _drawLoadingBarBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height - 8, size.width, 6),
      const Radius.circular(3),
    );
    canvas.drawRRect(rect, paint);
  }

  void _drawLoadingBarFill(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    final fillWidth = size.width * progress;
    if (fillWidth > 0) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height - 8, fillWidth, 6),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  void _drawSmoothRunningMan(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final runnerX = (size.width - 20) * progress + 10;
    final runnerY = size.height - 20;
    final center = Offset(runnerX, runnerY);

    final runTime = progress * 12;
    final headBob = math.sin(runTime * 2 * math.pi) * 0.5;

    canvas.drawCircle(
      Offset(center.dx, center.dy - 15 + headBob),
      3,
      paint,
    );

    final bodyLean = math.sin(runTime * 2 * math.pi) * 0.3;
    canvas.drawLine(
      Offset(center.dx, center.dy - 12 + headBob),
      Offset(center.dx + bodyLean, center.dy + 5),
      paint,
    );

    _drawSmoothArms(canvas, center, paint, runTime);
    _drawSmoothLegs(canvas, center, paint, runTime);
  }

  void _drawSmoothArms(
      Canvas canvas, Offset center, Paint paint, double runTime) {
    const armLength = 8.0;
    final leftArmAngle = math.sin(runTime * 2 * math.pi) * 0.6;
    final rightArmAngle = math.sin(runTime * 2 * math.pi + math.pi) * 0.6;

    canvas.drawLine(
      Offset(center.dx, center.dy - 5),
      Offset(
        center.dx + armLength * math.sin(leftArmAngle),
        center.dy - 5 + armLength * math.cos(leftArmAngle),
      ),
      paint,
    );

    canvas.drawLine(
      Offset(center.dx, center.dy - 5),
      Offset(
        center.dx + armLength * math.sin(rightArmAngle),
        center.dy - 5 + armLength * math.cos(rightArmAngle),
      ),
      paint,
    );
  }

  void _drawSmoothLegs(
      Canvas canvas, Offset center, Paint paint, double runTime) {
    const legLength = 10.0;
    final leftLegAngle = math.sin(runTime * 2 * math.pi + math.pi) * 0.8;
    final rightLegAngle = math.sin(runTime * 2 * math.pi) * 0.8;

    final leftLegY =
        center.dy + 5 + (math.sin(runTime * 2 * math.pi + math.pi)).abs() * 1;
    final rightLegY =
        center.dy + 5 + (math.sin(runTime * 2 * math.pi)).abs() * 1;

    canvas.drawLine(
      Offset(center.dx, center.dy + 5),
      Offset(
        center.dx + legLength * math.sin(leftLegAngle),
        leftLegY + legLength * math.cos(leftLegAngle),
      ),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy + 5),
      Offset(
        center.dx + legLength * math.sin(rightLegAngle),
        rightLegY + legLength * math.cos(rightLegAngle),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
