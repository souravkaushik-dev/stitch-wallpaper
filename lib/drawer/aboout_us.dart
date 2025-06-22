import 'package:flutter/material.dart';
import 'package:m3_carousel/m3_carousel.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<Map<String, String>> apps = [
    {
      "name": "stitch",
      "icon": "assets/stitch.webp",
      "link": "https://play.google.com/store/apps/details?id=com.dotstudios.stitch",
    },
    {
      "name": "dottunes",
      "icon": "assets/dottunes.webp",
      "link": "https://play.google.com/store/apps/details?id=com.dotstudios.dottunes",
    },
  ];

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160.0,
            floating: false,
            pinned: true,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                var top = constraints.biggest.height;
                bool isCollapsed = top <= kToolbarHeight + MediaQuery.of(context).padding.top;
                double roundedCorner = isCollapsed ? 20.0 : 30.0;

                return FlexibleSpaceBar(
                  centerTitle: true,
                  titlePadding: EdgeInsets.only(top: isCollapsed ? 0.0 : 80.0, left: 16.0),
                  title: Align(
                    alignment: isCollapsed ? Alignment.centerLeft : Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: isCollapsed ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                        children: [
                          Text(
                            '.paper | .studios',
                            style: TextStyle(
                              fontFamily: 'Display',
                              fontSize: isCollapsed ? 24.0 : 32.0,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            'About',
                            style: TextStyle(
                              fontFamily: 'Display',
                              fontSize: isCollapsed ? 12.0 : 18.0,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(roundedCorner),
                      ),
                    ),
                  ),
                );
              },
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
          ),

          _buildSection(theme, 'stitch’s Role in Dot Studios:',
              'stitch is a cornerstone project at Dot Studios, embodying our vision to bring stunning, high-quality wallpapers directly to users. As part of our commitment to creating intuitive and visually captivating experiences, stitch merges cutting-edge technology with sleek design. With its rich collection and continuous updates, it represents Dot Studios’ passion for crafting apps that elevate everyday digital experiences.'),

          _buildSection(theme, 'Future Features:',
              'stitch continues to evolve, with plans for even more features, categories, and customization options. Whether it’s AI-powered wallpaper recommendations, enhanced search functionality, or improved user interaction, stitch aims to stay at the forefront of the wallpaper app industry.'),

          _buildAppsCarousel(theme),
        ],
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(45),
          child: Container(
            color: theme.colorScheme.secondaryContainer,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Display',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'Display'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppsCarousel(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(45),
          child: Container(
            color: theme.colorScheme.secondaryContainer,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore Dot Studios Apps:',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Display',
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 150,
                  child: M3Carousel(
                    type: "contained",
                    heroAlignment: "center",
                    freeScroll: true,
                    children: apps.map((app) {
                      return GestureDetector(
                        onTap: () => _launchURL(app["link"]!),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20), // Rounded corners
                              child: Image.asset(
                                app["icon"]!,
                                width: 164,
                                height: 100,
                                fit: BoxFit.cover, // Ensures the image fills the space
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              app["name"]!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Display',
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
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
