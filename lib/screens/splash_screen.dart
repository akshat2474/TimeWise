import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';
import 'package:timewise_dtu/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _textFadeInAnimation;
  late Animation<double> _footerSlideUpAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    );

    _textFadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOut),
      ),
    );

    _footerSlideUpAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _startSequence();
  }

  void _startSequence() async {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _controller.forward();

    await Future.delayed(const Duration(milliseconds: 4000));
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
                painter: CombinedBackgroundPainter(progress: _controller.value),
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
                  const Spacer(flex: 2),
                  _buildLoadingIndicator(),
                  const Spacer(flex: 2),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return FadeTransition(
      opacity: _textFadeInAnimation,
      child: const AnimatedAppName(),
    );
  }

  Widget _buildLoadingIndicator() {
    return FadeTransition(
      opacity: _textFadeInAnimation,
      child: SizedBox(
        width: 220,
        height: 4,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => CustomPaint(
            painter: ShimmerLoadingBarPainter(
              progress: _controller.value,
              shimmerColor: AppTheme.primary,
              backgroundColor: AppTheme.surfaceVariant.withOpacity(0.5),
            ),
          ),
        ),
      ),
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
              curve: const Interval(0.6, 1.0),
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
      duration: const Duration(milliseconds: 1200),
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
          fontWeight: FontWeight.w600,
          letterSpacing: 3,
          color: Colors.white,
          fontSize: 55
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
              curve: Interval(delay * 0.5, math.min(delay * 0.5 + 0.5, 1.0), curve: Curves.easeOut),
            );
            return FadeTransition(
              opacity: animation,
              child: Text(appName[index], style: textStyle),
            );
          }),
        );
      },
    );
  }
}

class ShimmerLoadingBarPainter extends CustomPainter {
  final double progress;
  final Color shimmerColor;
  final Color backgroundColor;

  ShimmerLoadingBarPainter({required this.progress, required this.shimmerColor, required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(size.height / 2)), backgroundPaint);
    
    final shimmerWidth = size.width * 0.4;
    final shimmerPosition = (size.width + shimmerWidth) * (progress * 2 % 1) - shimmerWidth;

    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.transparent, shimmerColor.withOpacity(0.8), Colors.transparent],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(shimmerPosition, 0, shimmerWidth, size.height));
    
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(size.height / 2)), shimmerPaint);
  }
  
  @override
  bool shouldRepaint(covariant ShimmerLoadingBarPainter oldDelegate) => true;
}

class CombinedBackgroundPainter extends CustomPainter {
  final double progress;
  CombinedBackgroundPainter({required this.progress});

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

    final dotPaint = Paint()
      ..color = AppTheme.primary.withOpacity(0.2);

    const gridSize = 40.0;
    
    final gridOpacity = math.sin(progress * math.pi);
    dotPaint.color = dotPaint.color.withOpacity(dotPaint.color.opacity * gridOpacity);

    for (double y = 0; y < size.height; y += gridSize) {
      for (double x = 0; x < size.width; x += gridSize) {
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CombinedBackgroundPainter oldDelegate) => progress != oldDelegate.progress;
}
