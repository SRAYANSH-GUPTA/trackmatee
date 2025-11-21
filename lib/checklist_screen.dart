import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// Updated categories based on your request
  final Map<String, List<String>> _tabItems = {
    'Essentials': ['Hair Dryer', 'Serum', 'Power Bank', 'Sunglasses', 'Charger'],
    'Travel Items': [
      'Passport',
      'Extra Clothes',
      'Travel Pillow',
      'Toiletries'
    ],
    'Weather': ['Jacket', 'Umbrella', 'Sunscreen'],
    'Health': ['Painkiller', 'Antacid', 'Band Aid'],
    'Kids & Family': ['Kid Snacks', 'Baby Diapers']
  };

  late List<String> _flatItems;
  Set<String> _checked = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _flatItems = _createFlatList();
    _loadChecked();
  }

  List<String> _createFlatList() {
    final List<String> out = [];
    _tabItems.forEach((tab, items) {
      for (var it in items) {
        out.add('$tab|$it');
      }
    });
    return out;
  }

  Future<void> _loadChecked() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('checked') ?? [];
    setState(() {
      _checked = saved.toSet();
      _loaded = true;
    });
  }

  Future<void> _saveChecked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('checked', _checked.toList());
  }

  void _toggleCheck(String key) {
    setState(() {
      if (_checked.contains(key)) {
        _checked.remove(key);
      } else {
        _checked.add(key);
      }
    });
    _saveChecked();
  }

  double _progressPercent() {
    final total = _flatItems.length;
    if (total == 0) return 0.0;
    return _checked.length / total;
  }

  void _aiSuggestForActiveTab() {
    final activeIndex = _tabController.index;
    final tabName = _tabItems.keys.elementAt(activeIndex);
    final suggestions = <String>[];

    if (tabName == 'Essentials') {
      if (!_checked.contains('Essentials|Power Bank')) suggestions.add('Power Bank');
      if (!_checked.contains('Essentials|Charger')) suggestions.add('Charger');
    } else if (tabName == 'Travel Items') {
      if (!_checked.contains('Travel Items|Passport')) suggestions.add('Passport');
    } else if (tabName == 'Weather') {
      if (!_checked.contains('Weather|Umbrella')) suggestions.add('Umbrella');
    } else if (tabName == 'Health') {
      if (!_checked.contains('Health|Painkiller')) suggestions.add('Painkiller');
    } else if (tabName == 'Kids & Family') {
      if (!_checked.contains('Kids & Family|Kid Snacks')) suggestions.add('Kid Snacks');
    }

    setState(() {
      for (var s in suggestions) {
        _checked.add('$tabName|$s');
      }
    });
    _saveChecked();

    if (suggestions.isEmpty) {
      _showSnack('No new suggestions for "$tabName"');
    } else {
      _showSnack('Added suggestions: ${suggestions.join(', ')}');
    }
  }

  void _showSnack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 2)),
    );
  }

  Widget _smallProgressSegments(double percent) {
    const int segments = 5;
    final int filled = (percent * segments).round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(segments, (i) {
        final bool isFilled = i < filled;
        return Container(
          width: 40,
          height: 14,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: isFilled ? const Color(0xFFBFA3FF) : Colors.white24,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progressPercent();
    final percentText = (progress * 100).round().toString();
    final textStyleSmall = TextStyle(color: Colors.white70, fontSize: 12);
    final primaryPurple = const Color(0xFFBFA3FF);

    return Scaffold(
      backgroundColor: const Color(0xFF100F14),
      body: SafeArea(
        child: !_loaded
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              const SizedBox(height: 10),

              /// 🔥 TOP PROGRESS PERCENTAGE MOVED HERE
              Text(
                '$percentText% packed',
                style: const TextStyle(
                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),

              /// Text
              Text('Select more items to complete packing',
                  style: textStyleSmall),

              const SizedBox(height: 8),

              Row(
                children: [
                  Text('0%', style: textStyleSmall),
                  const SizedBox(width: 12),
                  Expanded(child: _smallProgressSegments(progress)),
                  const SizedBox(width: 12),
                  Text('100%', style: textStyleSmall),
                ],
              ),

              const SizedBox(height: 20),

              Icon(Icons.backpack_outlined, color: primaryPurple, size: 46),
              const SizedBox(height: 10),
              const Text(
                'Suggested checklist',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'A personalized travel essential checklist to help you pack,\nGenerated using pattern recognition',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),

              const SizedBox(height: 18),

              /// TABS
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1C24),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelPadding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  unselectedLabelColor: Colors.white70,
                  labelColor: Colors.white,
                  indicator: BoxDecoration(
                    color: primaryPurple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  tabs: _tabItems.keys
                      .map((name) => Tab(text: name))
                      .toList(),
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0E12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _aiSuggestForActiveTab,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryPurple,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.lightbulb_outline),
                            label: const Text('AI Suggest'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: _tabItems.keys.map((tabKey) {
                            final items = _tabItems[tabKey]!;
                            return ListView.builder(
                              itemCount: items.length,
                              padding: const EdgeInsets.only(top: 8, bottom: 12),
                              itemBuilder: (context, index) {
                                final item = items[index];
                                final key = '$tabKey|$item';
                                final checked = _checked.contains(key);
                                return GestureDetector(
                                  onTap: () => _toggleCheck(key),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF24222C),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 18,
                                          height: 18,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: checked
                                                ? Colors.white
                                                : const Color(0xFFFF5B61),
                                            border: Border.all(
                                              color: const Color(0xFFFF5B61),
                                              width: 1.2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            item,
                                            style: const TextStyle(
                                                color: Colors.white, fontSize: 16),
                                          ),
                                        ),
                                        if (checked)
                                          const Icon(Icons.check_circle,
                                              color: Colors.white)
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
