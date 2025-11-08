import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/experience.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Experience Card Widget
class ExperienceCard extends StatelessWidget {
  final Experience experience;
  final bool isSelected;
  final VoidCallback onTap;

  const ExperienceCard({
    super.key,
    required this.experience,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(right: 16),
        width: 130, // Slightly smaller
        height: 170, // Slightly smaller
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Transform.rotate(
            angle:
                (isSelected ? 0.05 : -0.05) *
                (experience.id % 3 - 1), // Slight tilt left/right/center
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image with grayscale filter when not selected
                if (isSelected)
                  CachedNetworkImage(
                    imageUrl: experience.imageUrl,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.base2,
                      child: const Icon(Icons.error, color: Colors.white),
                    ),
                  )
                else
                  ColorFiltered(
                    colorFilter: const ColorFilter.matrix([
                      0.2126, 0.7152, 0.0722, 0, 0, // Red channel
                      0.2126, 0.7152, 0.0722, 0, 0, // Green channel
                      0.2126, 0.7152, 0.0722, 0, 0, // Blue channel
                      0, 0, 0, 1, 0, // Alpha channel
                    ]),
                    child: CachedNetworkImage(
                      imageUrl: experience.imageUrl,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.base2,
                        child: const Icon(Icons.error, color: Colors.white),
                      ),
                    ),
                  ),
                // Gradient overlay for better text readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                // Experience name
                Positioned(
                  bottom: 16,
                  left: 12,
                  right: 12,
                  child: Text(
                    experience.name.toUpperCase(),
                    style: AppTextStyles.b1Bold(
                      context,
                    ).copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
