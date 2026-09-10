import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../widgets/language_pill.dart';

class ServiceGuideScreen extends StatefulWidget {
  const ServiceGuideScreen({super.key});

  @override
  State<ServiceGuideScreen> createState() => _ServiceGuideScreenState();
}

class _ServiceGuideScreenState extends State<ServiceGuideScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              t('service_title'),
              style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
            ),
            actions: const [
              LanguagePill(),
              SizedBox(width: 8),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: theme.colorScheme.primary,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              tabs: [
                Tab(text: t('service_tab_glasses')),
                Tab(text: t('service_tab_temp')),
                Tab(text: t('service_tab_hacks')),
              ],
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildGlassesTab(context),
                  _buildTemperatureTab(context),
                  _buildHacksTab(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // TAB 1: GLASSWARE
  Widget _buildGlassesTab(BuildContext context) {
    final theme = Theme.of(context);

    final glasses = [
      {
        'title': t('glass_tulip_title'),
        'wines': t('glass_tulip_wines'),
        'desc': t('glass_tulip_desc'),
        'emoji': '🌷',
        'badge': 'Bianchi & Rosati',
        'color': const Color(0xFF43A047),
      },
      {
        'title': t('glass_rhine_title'),
        'wines': t('glass_rhine_wines'),
        'desc': t('glass_rhine_desc'),
        'emoji': '🥂',
        'badge': 'Grandi Bianchi',
        'color': const Color(0xFF00897B),
      },
      {
        'title': t('glass_bordeaux_title'),
        'wines': t('glass_bordeaux_wines'),
        'desc': t('glass_bordeaux_desc'),
        'emoji': '🍷',
        'badge': 'Rossi Strutturati',
        'color': const Color(0xFF880E4F),
      },
      {
        'title': t('glass_burgundy_title'),
        'wines': t('glass_burgundy_wines'),
        'desc': t('glass_burgundy_desc'),
        'emoji': '🍇',
        'badge': 'Rossi Eleganti',
        'color': const Color(0xFFAD1457),
      },
      {
        'title': t('glass_flute_title'),
        'wines': t('glass_flute_wines'),
        'desc': t('glass_flute_desc'),
        'emoji': '🍾',
        'badge': 'Bollicine',
        'color': const Color(0xFFE5A93C),
      },
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        Card(
          elevation: 0,
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    t('service_glasses_intro'),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      height: 1.4,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...glasses.map((item) {
          final color = item['color'] as Color;
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          item['emoji'] as String,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item['badge'] as String,
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['title'] as String,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              item['wines'] as String,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item['desc'] as String,
                    style: TextStyle(
                      color: Colors.grey[800],
                      height: 1.35,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // TAB 2: TEMPERATURE & DECANTER
  Widget _buildTemperatureTab(BuildContext context) {
    final theme = Theme.of(context);

    final temperatures = [
      {
        'range': t('temp_range_sparkling'),
        'desc': t('temp_sparkling_desc'),
        'color': const Color(0xFF0288D1),
        'icon': Icons.ac_unit,
      },
      {
        'range': t('temp_range_white_light'),
        'desc': t('temp_white_light_desc'),
        'color': const Color(0xFF2E7D32),
        'icon': Icons.thermostat_outlined,
      },
      {
        'range': t('temp_range_white_rich'),
        'desc': t('temp_white_rich_desc'),
        'color': const Color(0xFFF57C00),
        'icon': Icons.thermostat_outlined,
      },
      {
        'range': t('temp_range_red_light'),
        'desc': t('temp_red_light_desc'),
        'color': const Color(0xFFD81B60),
        'icon': Icons.thermostat,
      },
      {
        'range': t('temp_range_red_full'),
        'desc': t('temp_red_full_desc'),
        'color': const Color(0xFFB71C1C),
        'icon': Icons.local_fire_department,
      },
    ];

    final decanterRules = [
      {
        'title': t('decanter_rule_1_title'),
        'desc': t('decanter_rule_1_desc'),
        'icon': Icons.air,
      },
      {
        'title': t('decanter_rule_2_title'),
        'desc': t('decanter_rule_2_desc'),
        'icon': Icons.access_time,
      },
      {
        'title': t('decanter_rule_3_title'),
        'desc': t('decanter_rule_3_desc'),
        'icon': Icons.block,
      },
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        // Intro
        Card(
          elevation: 0,
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🌡️', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    t('service_temp_intro'),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      height: 1.4,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Temperature Scale
        ...temperatures.map((item) {
          final color = item['color'] as Color;
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item['icon'] as IconData, color: color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['range'] as String,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['desc'] as String,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 24),

        // Decanter Section Title
        Row(
          children: [
            Icon(
              Icons.water_damage_outlined,
              size: 22,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              t('decanter_title'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ...decanterRules.map((rule) {
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            color: const Color(0xFFFFFDF9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: const Color(0xFFE0D7CE)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    rule['icon'] as IconData,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rule['title'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rule['desc'] as String,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // TAB 3: SOS SOMMELIER HACKS
  Widget _buildHacksTab(BuildContext context) {
    final theme = Theme.of(context);

    final hacks = [
      {
        'emoji': '🧊',
        'title': t('hack_ice_title'),
        'desc': t('hack_ice_desc'),
        'color': const Color(0xFF0288D1),
      },
      {
        'emoji': '🍾',
        'title': t('hack_storage_title'),
        'desc': t('hack_storage_desc'),
        'color': const Color(0xFF7B1FA2),
      },
      {
        'emoji': '🥄',
        'title': t('hack_spoon_title'),
        'desc': t('hack_spoon_desc'),
        'color': const Color(0xFFE65100),
      },
      {
        'emoji': '👃',
        'title': t('hack_cork_title'),
        'desc': t('hack_cork_desc'),
        'color': const Color(0xFFC2185B),
      },
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: hacks.map((hack) {
        final color = hack['color'] as Color;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        hack['emoji'] as String,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        hack['title'] as String,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  hack['desc'] as String,
                  style: TextStyle(
                    color: Colors.grey[800],
                    height: 1.4,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
