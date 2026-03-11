import 'package:flutter/material.dart';
import 'package:plushie_yourself/features/theme/app_colors.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const PaywallScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.warmBeige,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.subtleGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text('🧸', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 20),
            const Text(
              'You\'ve used your\n5 free plushies this week!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.warmBrown,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Upgrade for unlimited generations every week and keep creating adorable plushies.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.warmBrownLight,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            _buildPlanCard(
              emoji: '⭐',
              title: 'Monthly',
              price: '\$2.99',
              period: '/ month',
              highlighted: false,
            ),
            const SizedBox(height: 12),
            _buildPlanCard(
              emoji: '🎀',
              title: 'Lifetime',
              price: '\$9.99',
              period: 'one-time',
              highlighted: true,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _handlePurchase(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warmBrown,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Unlock Unlimited',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Maybe later',
                style: TextStyle(color: AppColors.warmBrownLight, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String emoji,
    required String title,
    required String price,
    required String period,
    required bool highlighted,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color:
            highlighted
                ? AppColors.warmAmber.withValues(alpha: 0.12)
                : AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlighted ? AppColors.warmAmber : AppColors.subtleGray,
          width: highlighted ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.warmBrown,
                ),
              ),
              if (highlighted)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warmAmber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Best value',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: price,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.warmBrown,
                  ),
                ),
                TextSpan(
                  text: ' $period',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.warmBrownLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handlePurchase(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: AppColors.cardSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Coming soon!',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.warmBrown,
              ),
            ),
            content: Text(
              'Payments are not yet enabled. Check back soon!',
              style: TextStyle(color: AppColors.warmBrownLight),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: AppColors.warmAmber,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
