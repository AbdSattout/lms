import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/injection_container.dart';
import '../bloc/certificate_bloc.dart';
import '../bloc/certificate_event.dart';
import '../bloc/certificate_state.dart';
import '../widgets/certificate_card.dart';

class MyCertificatesPage extends StatelessWidget {
  const MyCertificatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CertificateBloc>()..add(LoadMyCertificates()),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: const Text('شهاداتي')),
          body: BlocBuilder<CertificateBloc, CertificateState>(
            builder: (context, state) {
              return switch (state) {
                CertificateInitial() || CertificateLoading() =>
                const Center(child: CircularProgressIndicator()),
                CertificateEmpty() => _EmptyState(),
                CertificateFailed() => _ErrorState(
                  message: state.message,
                  onRetry: () => context.read<CertificateBloc>().add(LoadMyCertificates()),
                ),
                CertificateLoaded() => RefreshIndicator(
                  onRefresh: () async => context.read<CertificateBloc>().add(RefreshMyCertificates()),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.certificates.length,
                    itemBuilder: (context, index) {
                      final cert = state.certificates[index];
                      return CertificateCard(certificate: cert);
                    },
                  ),
                ),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xffF2C94C).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events_rounded, size: 46, color: Color(0xffB7791F)),
          ),
          const SizedBox(height: 16),
          Text('لا توجد شهادات بعد', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: colors.onSurface)),
          const SizedBox(height: 6),
          Text('أكمل الاختبارات النهائية للكورسات للحصول على شهاداتك.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: colors.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
          ],
        ),
      ),
    );
  }
}