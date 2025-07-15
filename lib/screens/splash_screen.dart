import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';
import 'package:timewise_dtu/theme/app_theme.dart';

class Star {
  final Offset position;
  final double radius;
  final double twinkleSpeed;

  Star({required this.position, required this.radius, required this.twinkleSpeed});
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _textFadeInAnimation;
  late Animation<double> _footerSlideUpAnimation;
  late Animation<double> _logoScaleAnimation;

  late List<Star> _stars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _textFadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.6, curve: Curves.easeOut),
      ),
    );

    _footerSlideUpAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _generateStars();
    _startSequence();
  }

  void _generateStars() {
    _stars = List.generate(150, (index) {
      final random = math.Random();
      return Star(
        position: Offset(random.nextDouble(), random.nextDouble()),
        radius: random.nextDouble() * 1.5 + 0.5,
        twinkleSpeed: random.nextDouble() * 2.0 + 1.0,
      );
    });
  }

  void _startSequence() async {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _controller.forward();

    await Future.delayed(const Duration(milliseconds: 3600));
    if (mounted) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => CustomPaint(
                painter: StarfieldPainter(
                  progress: _controller.value,
                  stars: _stars,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  _buildTitle(),
                  const SizedBox(height: 24),
                  _buildSubtitle(),
                  const SizedBox(height: 40),
                  _buildDotLoader(),
                  const Spacer(flex: 1),
                  _buildFooter(),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return ScaleTransition(
      scale: _logoScaleAnimation,
      child: FadeTransition(
        opacity: _textFadeInAnimation,
        child: const AnimatedAppName(),
      ),
    );
  }

  Widget _buildSubtitle() {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7),
      ),
      child: Text(
        'Manage your time wisely',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.2,
            ),
      ),
    );
  }

  Widget _buildDotLoader() {
    return FadeTransition(
      opacity: _textFadeInAnimation,
      child: DotLoader(controller: _controller),
    );
  }

  Widget _buildFooter() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _footerSlideUpAnimation.value),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.5, 0.9),
            ),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          Text(
            'Made by Akshat Singh',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textTertiary,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialLink(
                icon: const Icon(Icons.code_rounded, size: 20, color: AppTheme.textSecondary),
                label: 'GitHub',
                url: 'https://github.com/akshat2474',
              ),
              const SizedBox(width: 24),
              _buildSocialLink(
                icon: const Icon(Icons.work_outline_rounded, size: 20, color: AppTheme.textSecondary),
                label: 'LinkedIn',
                url: 'https://www.linkedin.com/in/akshat-singh-48a03b312/',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLink({required Widget icon, required String label, required String url}) {
    return InkWell(
      onTap: () => _launchURL(url),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedAppName extends StatefulWidget {
  const AnimatedAppName({super.key});
  @override
  State<AnimatedAppName> createState() => _AnimatedAppNameState();
}

class _AnimatedAppNameState extends State<AnimatedAppName> with SingleTickerProviderStateMixin {
  late AnimationController _charController;
  @override
  void initState() {
    super.initState();
    _charController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _charController.forward();
  }
  @override
  void dispose() {
    _charController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.displayMedium?.copyWith(
      fontWeight: FontWeight.w700, 
      letterSpacing: 4, 
      color: Colors.white, 
      fontSize: 58, 
      shadows: [
        Shadow(
          offset: const Offset(0, 2), 
          blurRadius: 4, 
          color: AppTheme.primary.withOpacity(0.3),
        ),
      ],
    );
    const appName = 'TimeWise';
    return AnimatedBuilder(
      animation: _charController, 
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min, 
          children: List.generate(appName.length, (index) {
            final delay = index / appName.length;
            final animation = CurvedAnimation(
              parent: _charController, 
              curve: Interval(
                delay * 0.6, 
                math.min(delay * 0.6 + 0.4, 1.0), 
                curve: Curves.elasticOut
              ),
            );
            return FadeTransition(
              opacity: animation, 
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5), 
                  end: Offset.zero,
                ).animate(animation), 
                child: Text(appName[index], style: textStyle),
              ),
            );
          }),
        );
      },
    );
  }
}

class DotLoader extends StatelessWidget {
  final AnimationController controller;
  const DotLoader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final opacity = (math.sin((controller.value + delay) * math.pi * 2) + 1) / 2;
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class StarfieldPainter extends CustomPainter {
  final double progress;
  final List<Star> stars;

  StarfieldPainter({required this.progress, required this.stars});

  @override
  void paint(Canvas canvas, Size size) {
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -1.2),
        radius: 1.5,
        colors: [
          AppTheme.primary.withOpacity(0.3),
          AppTheme.background,
        ],
        stops: const [0.0, 0.6],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), gradientPaint);

    final starPaint = Paint()..color = Colors.white;
    final curve = Curves.easeOut.transform(progress);

    for (final star in stars) {
      final twinkle = 0.5 + (math.sin(progress * math.pi * star.twinkleSpeed) * 0.5);
      final opacity = (twinkle * curve).clamp(0.0, 1.0);
      
      starPaint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(
        Offset(star.position.dx * size.width, star.position.dy * size.height),
        star.radius,
        starPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant StarfieldPainter oldDelegate) => true;
}
