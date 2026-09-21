import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// Vertical scroll ("手卷") campaign map. Full content (5 chapters x 10
/// levels, Hive progress) lands in Phase 3; this is a structural
/// placeholder so navigation can already target it.
class CampaignMapScreen extends StatelessWidget {
  const CampaignMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.jadeWhite,
      appBar: AppBar(title: const Text('从卒到帅')),
      body: const Center(child: Text('Campaign mode coming in Phase 3')),
    );
  }
}
