import 'package:flutter/material.dart';

class AnimatedActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final List<Color> gradientColors;
  final double height;
  final bool fullWidth;

  const AnimatedActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    required this.gradientColors,
    this.height = 110,
    this.fullWidth = false,
  });

  @override
  State<AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<AnimatedActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 0.08,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.forward();
  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final scale = 1 - _controller.value;
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Transform.scale(
        scale: scale,
        child: Container(
          height: widget.height,
          width: widget.fullWidth ? double.infinity : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.gradientColors,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: size.width * 0.11,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: size.width * 0.042,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
