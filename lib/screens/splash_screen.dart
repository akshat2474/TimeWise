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
      duration: const Duration(milliseconds: 8000),
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

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_backgroundController);

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
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

      bool launched = false;

      try {
        launched = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        try {
          launched = await launchUrl(
            url,
            mode: LaunchMode.platformDefault,
          );
        } catch (e) {
          launched = await launchUrl(
            url,
            mode: LaunchMode.inAppWebView,
          );
        }
      }

      if (!launched) {
        throw 'Could not launch $urlString';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Could not open link. Please check your internet connection.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
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
              Color(0xFF0F0F0F),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: SubtleGridPainter(_backgroundAnimation.value),
                );
              },
            ),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 32),
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
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    final glowIntensity = 0.3 + _glowAnimation.value * 0.2;
                    return Text(
                      'TimeWise',
                      style: TextStyle(
                        fontSize: 76,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        letterSpacing: 2,
                        height: 1,
                        shadows: [
                          Shadow(
                            color:
                                Colors.white.withOpacity(glowIntensity * 0.4),
                            blurRadius: 15,
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
                    fontSize: 19,
                    color: Colors.grey[300],
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Delhi Technological University',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 70),
                if (_showContent) _buildLoadingBarWithRunner(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingBarWithRunner() {
    return AnimatedBuilder(
      animation: _loadingController,
      builder: (context, child) {
        return Column(
          children: [
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
                fontWeight: FontWeight.w300,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              height: 50,
              child: CustomPaint(
                painter:
                    SmoothLoadingBarWithRunnerPainter(_loadingAnimation.value),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${(_loadingAnimation.value * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontWeight: FontWeight.w300,
                letterSpacing: 0.5,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFooter() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
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
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
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

class SubtleGridPainter extends CustomPainter {
  final double progress;

  SubtleGridPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    _drawSubtleGrid(canvas, size);
    _drawFloatingParticles(canvas, size);
    _drawSubtleGradientOverlay(canvas, size);
  }

  void _drawSubtleGrid(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 0.5;

    const spacing = 80.0;
    final offset = (progress * spacing * 0.3) % spacing;
    for (double x = -spacing + offset; x < size.width + spacing; x += spacing) {
      final linePhase = (x / size.width + progress * 0.5) % 1;
      final opacity = (0.02 + math.sin(linePhase * 2 * math.pi) * 0.015)
          .clamp(0.005, 0.035);
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = -spacing + offset;
        y < size.height + spacing;
        y += spacing) {
      final linePhase = (y / size.height + progress * 0.5) % 1;
      final opacity = (0.02 + math.sin(linePhase * 2 * math.pi) * 0.015)
          .clamp(0.005, 0.035);
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawFloatingParticles(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42);

    for (int i = 0; i < 12; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      final phase = (progress + i * 0.2) % 1;
      final floatX = baseX + math.sin(phase * 2 * math.pi) * 12;
      final floatY = baseY + math.cos(phase * 2 * math.pi) * 8;

      final opacity = (math.sin(phase * math.pi) * 0.06).clamp(0.02, 0.06);
      final particleSize = 0.8 + math.sin(phase * math.pi) * 0.4;

      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(floatX, floatY), particleSize, paint);
    }
  }

  void _drawSubtleGradientOverlay(Canvas canvas, Size size) {
    final paint = Paint();

    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.5,
      colors: [
        Colors.white.withOpacity(0.015),
        Colors.transparent,
        Colors.black.withOpacity(0.08),
      ],
      stops: const [0.0, 0.7, 1.0],
    );

    paint.shader = gradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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
    _drawMotionLines(canvas, center, paint, runTime);
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

  void _drawMotionLines(
      Canvas canvas, Offset center, Paint paint, double runTime) {
    final motionPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final lineX = center.dx - 15 - (i * 4);
      final lineY = center.dy - 5 + (i * 1.5);
      final lineLength = 6 + math.sin(runTime * 2 * math.pi + i) * 2;

      canvas.drawLine(
        Offset(lineX, lineY),
        Offset(lineX - lineLength, lineY),
        motionPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
