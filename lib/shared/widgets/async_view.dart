import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api/api_exception.dart';
import '../../theme/app_theme.dart';

/// Drives a page section from a [Future]: shows a spinner while loading, an
/// error state with a Retry button on failure, and [builder] on success.
///
/// Re-fetch by assigning a new future into the page's `State` and calling
/// `setState`; [FutureBuilder] swaps to the new future automatically.
class AsyncView<T> extends StatelessWidget {
  final Future<T>? future;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback? onRetry;
  final double minHeight;

  const AsyncView({
    super.key,
    required this.future,
    required this.builder,
    this.onRetry,
    this.minHeight = 200,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snap) {
        switch (snap.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return _Center(
              minHeight: minHeight,
              child: const CircularProgressIndicator(strokeWidth: 3),
            );
          default:
            if (snap.hasError) {
              return _Center(
                minHeight: minHeight,
                child: _ErrorBody(
                  message: snap.error is ApiException
                      ? (snap.error as ApiException).message
                      : 'Something went wrong.',
                  onRetry: onRetry,
                ),
              );
            }
            if (snap.hasData) return builder(context, snap.data as T);
            return _Center(
                minHeight: minHeight, child: const SizedBox.shrink());
        }
      },
    );
  }
}

class _Center extends StatelessWidget {
  final Widget child;
  final double minHeight;
  const _Center({required this.child, required this.minHeight});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: minHeight,
      child: Center(child: child),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const _ErrorBody({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline_rounded,
            color: AppColors.statusRed, size: 32),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style:
                GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ],
    );
  }
}
