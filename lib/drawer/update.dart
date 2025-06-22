import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:liquid_glass/liquid_glass.dart';

class updatedottunes extends StatefulWidget {
  const updatedottunes({super.key});

  @override
  State<updatedottunes> createState() => _updatedottunesState();
}

class _updatedottunesState extends State<updatedottunes>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildChangelogCard(String version, String description, double height) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(45),
        child: LiquidGlass(
          borderRadius: BorderRadius.circular(45),
          opacity: 0.1,
          child: Container(
            height: height,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  version,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Display',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Display',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 160.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    final top = constraints.biggest.height;
                    final isCollapsed = top <= kToolbarHeight + MediaQuery.of(context).padding.top;

                    return FlexibleSpaceBar(
                      centerTitle: true,
                      titlePadding: EdgeInsets.only(
                        top: isCollapsed ? 0.0 : 80.0,
                        left: 16.0,
                      ),
                      title: Align(
                        alignment: isCollapsed ? Alignment.centerLeft : Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            crossAxisAlignment: isCollapsed ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Update | History',
                                style: TextStyle(
                                  fontFamily: 'Display',
                                  fontSize: isCollapsed ? 24.0 : 42.0,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                              Text(
                                'Changelogs',
                                style: TextStyle(
                                  fontFamily: 'Display',
                                  fontSize: isCollapsed ? 12.0 : 18.0,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: _buildChangelogCard(
                  '1.2.0 | Stygian🌑',
                  '✨ New "Last Revision" Option\n🎨 Accent Color Customization\n🚀 Revamped Splash Screen',
                  229,
                ),
              ),
              SliverToBoxAdapter(
                child: _buildChangelogCard(
                  '1.1.0 | Refined 🔧',
                  '• App icon update 🖼️: The app icon has been redesigned.',
                  106,
                ),
              ),
              SliverToBoxAdapter(
                child: _buildChangelogCard(
                  '1.0.0 | Initial Launch 🚀',
                  '• Wallpaper browsing\n• Favorites section\n• Set wallpaper options\n• Smooth UI ✨',
                  289,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
