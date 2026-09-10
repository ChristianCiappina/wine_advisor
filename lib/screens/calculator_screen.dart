import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../main.dart';
import '../widgets/language_pill.dart';

enum CalculatorOccasion {
  aperitivo,
  casual,
  dinner,
  party;

  String get labelKey {
    switch (this) {
      case CalculatorOccasion.aperitivo:
        return 'calc_occ_aperitivo';
      case CalculatorOccasion.casual:
        return 'calc_occ_casual';
      case CalculatorOccasion.dinner:
        return 'calc_occ_dinner';
      case CalculatorOccasion.party:
        return 'calc_occ_party';
    }
  }

  double get baseGlasses {
    switch (this) {
      case CalculatorOccasion.aperitivo:
        return 2.0;
      case CalculatorOccasion.casual:
        return 2.5;
      case CalculatorOccasion.dinner:
        return 3.5;
      case CalculatorOccasion.party:
        return 4.5;
    }
  }

  double get sparklingRatio {
    switch (this) {
      case CalculatorOccasion.aperitivo:
        return 0.8;
      case CalculatorOccasion.casual:
        return 0.0;
      case CalculatorOccasion.dinner:
        return 0.3;
      case CalculatorOccasion.party:
        return 0.4;
    }
  }

  double get whiteRatio {
    switch (this) {
      case CalculatorOccasion.aperitivo:
        return 0.2;
      case CalculatorOccasion.casual:
        return 0.4;
      case CalculatorOccasion.dinner:
        return 0.35;
      case CalculatorOccasion.party:
        return 0.3;
    }
  }

  double get redRatio {
    switch (this) {
      case CalculatorOccasion.aperitivo:
        return 0.0;
      case CalculatorOccasion.casual:
        return 0.6;
      case CalculatorOccasion.dinner:
        return 0.35;
      case CalculatorOccasion.party:
        return 0.3;
    }
  }
}

enum CalculatorPace {
  light,
  standard,
  festive;

  String get labelKey {
    switch (this) {
      case CalculatorPace.light:
        return 'calc_style_light';
      case CalculatorPace.standard:
        return 'calc_style_med';
      case CalculatorPace.festive:
        return 'calc_style_heavy';
    }
  }

  double get factor {
    switch (this) {
      case CalculatorPace.light:
        return 0.8;
      case CalculatorPace.standard:
        return 1.0;
      case CalculatorPace.festive:
        return 1.3;
    }
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  int _guests = 6;
  CalculatorOccasion _occasion = CalculatorOccasion.dinner;
  CalculatorPace _pace = CalculatorPace.standard;

  int get _totalGlasses {
    return (_guests * _occasion.baseGlasses * _pace.factor).round();
  }

  int get _sparklingBottles {
    if (_occasion.sparklingRatio <= 0) return 0;
    final glasses = (_totalGlasses * _occasion.sparklingRatio).round();
    return (glasses / 6.0).ceil().clamp(1, 999);
  }

  int get _whiteBottles {
    if (_occasion.whiteRatio <= 0) return 0;
    final glasses = (_totalGlasses * _occasion.whiteRatio).round();
    return (glasses / 6.0).ceil().clamp(1, 999);
  }

  int get _redBottles {
    if (_occasion.redRatio <= 0) return 0;
    final glasses = (_totalGlasses * _occasion.redRatio).round();
    return (glasses / 6.0).ceil().clamp(1, 999);
  }

  int get _reserveBottles => 1;

  int get _totalBottles =>
      _sparklingBottles + _whiteBottles + _redBottles + _reserveBottles;

  String _buildShareText() {
    final buffer = StringBuffer();
    buffer.write(t('calc_share_text_1'));
    buffer.write(_guests);
    buffer.write(t('calc_share_text_2'));
    buffer.write(t(_occasion.labelKey));
    buffer.write(t('calc_share_text_3'));
    buffer.write('\n');

    if (_sparklingBottles > 0) {
      buffer.write('• 🍾 ${_sparklingBottles}x ${t('calc_sparkling')}\n');
    }
    if (_whiteBottles > 0) {
      buffer.write('• 🍏 ${_whiteBottles}x ${t('calc_white')}\n');
    }
    if (_redBottles > 0) {
      buffer.write('• 🍷 ${_redBottles}x ${t('calc_red')}\n');
    }
    buffer.write('• 🛡️ ${_reserveBottles}x ${t('calc_reserve')}\n');
    buffer.write(
      '\n👉 ${t('calc_total_bottles')}: $_totalBottles (${t('calc_reserve_badge')})',
    );
    buffer.write(t('calc_share_text_4'));
    return buffer.toString();
  }

  Future<void> _shareList() async {
    final shareText = _buildShareText();
    try {
      final box = context.findRenderObject() as RenderBox?;
      final position =
          box != null
              ? box.localToGlobal(Offset.zero) & box.size
              : Rect.zero;

      await SharePlus.instance.share(
        ShareParams(
          text: shareText,
          sharePositionOrigin: position,
        ),
      );
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: shareText));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t('calc_share_copied')),
            backgroundColor: Colors.blueGrey,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLang,
      builder: (context, lang, _) {
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              t('calc_title'),
              style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
            ),
            actions: const [
              LanguagePill(),
              SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Subtitle
                    Text(
                      t('calc_subtitle'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // SECTION 1: GUESTS COUNTER
                    _buildSectionHeader(
                      context,
                      icon: Icons.people_alt_outlined,
                      title: t('calc_guests_title'),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton.filledTonal(
                                  icon: const Icon(Icons.remove),
                                  onPressed:
                                      _guests > 2
                                          ? () => setState(() => _guests--)
                                          : null,
                                ),
                                const SizedBox(width: 24),
                                Column(
                                  children: [
                                    Text(
                                      '$_guests',
                                      style: theme.textTheme.displaySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                    ),
                                    Text(
                                      t('calc_guests_unit'),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 24),
                                IconButton.filledTonal(
                                  icon: const Icon(Icons.add),
                                  onPressed:
                                      _guests < 50
                                          ? () => setState(() => _guests++)
                                          : null,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Quick presets
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              children: [4, 6, 8, 12, 20].map((count) {
                                final isSelected = _guests == count;
                                return ChoiceChip(
                                  label: Text('$count'),
                                  selected: isSelected,
                                  onSelected: (_) {
                                    setState(() => _guests = count);
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // SECTION 2: OCCASION
                    _buildSectionHeader(
                      context,
                      icon: Icons.event_note,
                      title: t('calc_occasion_title'),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: CalculatorOccasion.values.map((occ) {
                        final isSelected = _occasion == occ;
                        return ChoiceChip(
                          avatar: isSelected
                              ? const Icon(Icons.check, size: 18)
                              : null,
                          label: Text(
                            t(occ.labelKey),
                            style: TextStyle(
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => _occasion = occ);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // SECTION 3: DRINKING PACE
                    _buildSectionHeader(
                      context,
                      icon: Icons.speed_outlined,
                      title: t('calc_style_title'),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: CalculatorPace.values.map((p) {
                        final isSelected = _pace == p;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.grey.withValues(alpha: 0.2),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: () => setState(() => _pace = p),
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : Colors.grey[400],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      t(p.labelKey),
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    // RESULTS BANNER
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withValues(alpha: 0.85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              t('calc_result_title').toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '$_totalBottles',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 56,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                t('calc_total_bottles'),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${t('calc_glasses_est')} ~$_totalGlasses (${t('calc_reserve_badge')})',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // BOTTLE BREAKDOWN TILES
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            if (_sparklingBottles > 0)
                              _buildWineBreakdownRow(
                                context,
                                emoji: '🍾',
                                title: t('calc_sparkling'),
                                bottles: _sparklingBottles,
                                color: const Color(0xFFE5A93C),
                              ),
                            if (_whiteBottles > 0)
                              _buildWineBreakdownRow(
                                context,
                                emoji: '🍏',
                                title: t('calc_white'),
                                bottles: _whiteBottles,
                                color: const Color(0xFF43A047),
                              ),
                            if (_redBottles > 0)
                              _buildWineBreakdownRow(
                                context,
                                emoji: '🍷',
                                title: t('calc_red'),
                                bottles: _redBottles,
                                color: const Color(0xFFC2185B),
                              ),
                            _buildWineBreakdownRow(
                              context,
                              emoji: '🛡️',
                              title: t('calc_reserve'),
                              bottles: _reserveBottles,
                              color: const Color(0xFF5C6BC0),
                              isReserve: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // SOMMELIER TIP
                    Card(
                      elevation: 0,
                      color: const Color(0xFFFFF8E1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFFFE082)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('💡', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                t('calc_reserve_tip'),
                                style: const TextStyle(
                                  color: Color(0xFF5D4037),
                                  height: 1.35,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // SHARE BUTTON
                    ElevatedButton.icon(
                      onPressed: _shareList,
                      icon: const Icon(Icons.share, size: 20),
                      label: Text(
                        t('calc_share_btn'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWineBreakdownRow(
    BuildContext context, {
    required String emoji,
    required String title,
    required int bottles,
    required Color color,
    bool isReserve = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (isReserve)
                  Text(
                    t('calc_reserve_badge'),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$bottles ${bottles == 1 ? "bt." : "bt."}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
