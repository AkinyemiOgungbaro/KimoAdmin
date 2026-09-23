import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'data/game_models.dart';
import 'tournament_only.dart';

class PuzzleTile extends StatelessWidget {
  final PuzzleImage image;
  final VoidCallback onDelete;
  final VoidCallback onTournamentOnly;
  const PuzzleTile(
      {super.key,
      required this.image,
      required this.onDelete,
      required this.onTournamentOnly});

  Widget _action(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 1,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Icon(icon, size: 16, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            image.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.pageBg,
              child: const Icon(Icons.broken_image_outlined,
                  color: AppColors.textMuted),
            ),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                color: AppColors.pageBg,
                child: const Center(
                    child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))),
              );
            },
          ),
          // Delete control — white circular button, dark icon (visible; the old
          // code used color.withOpacity(2) which clamped to the tile colour).
          Positioned(
            top: 6,
            right: 6,
            child: Column(
              children: [
                _action(Icons.delete_outline, 'Delete', onDelete),
                const SizedBox(height: 6),
                _action(
                    image.tournamentOnly
                        ? Icons.emoji_events
                        : Icons.emoji_events_outlined,
                    image.tournamentOnly
                        ? 'Put back in casual play'
                        : 'Keep for tournaments only',
                    onTournamentOnly),
              ],
            ),
          ),
          if (image.tournamentOnly)
            const Positioned(top: 6, left: 6, child: TournamentOnlyBadge()),
          if (!image.isActive)
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Inactive',
                    style: GoogleFonts.inter(fontSize: 9, color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}
