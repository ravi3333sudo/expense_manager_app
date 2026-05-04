import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'animated_counter.dart';

class ProfessionalCard extends StatelessWidget {
  final String? title;
  final double? value;
  final IconData? icon;
  final LinearGradient? gradient;
  final Widget? child;
  final bool isAnimated;
  final VoidCallback? onTap;

  const ProfessionalCard({
    super.key,
    this.title,
    this.value,
    this.icon,
    this.gradient,
    this.child,
    this.isAnimated = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? const LinearGradient(
          colors: [Color(0xFF434343), Color(0xFF000000)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 77),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: child ?? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 51),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.blueGrey,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (title != null) ...[
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87.withValues(alpha: 204),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (value != null) ...[
                  isAnimated
                      ? AnimatedCounter(
                          value: value!,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                          duration: const Duration(milliseconds: 1500),
                        )
                      : Text(
                          currencyFormat.format(value),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            letterSpacing: 1,
                          ),
                        ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}