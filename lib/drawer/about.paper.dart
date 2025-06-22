import 'package:flutter/material.dart';

class Aboutdottunes extends StatefulWidget {
  const Aboutdottunes({super.key});

  @override
  State<Aboutdottunes> createState() => _AboutdottunesState();
}

class _AboutdottunesState extends State<Aboutdottunes> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Bouncy animation for AppBar
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
          // Scrollable SliverAppBar with bouncy animation
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
                  titlePadding: EdgeInsets.only(
                    top: isCollapsed ? 0.0 : 80.0, // Adjust padding when collapsed
                    left: 16.0,
                  ),
                  title: Align(
                    alignment: isCollapsed ? Alignment.centerLeft : Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.scaleDown, // Ensures the text scales down to fit
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: isCollapsed ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                        children: [
                          Text(
                            '.paper | 1.2.0 | Stygian🌑',
                            style: TextStyle(
                              fontFamily: 'Display',
                              fontSize: isCollapsed ? 24.0 : 32.0, // Adjust font size for collapsed state
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
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
          // Sliver item 1: dottunes Overview
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 20,
                right: 20,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(45),
                child: Container(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  height: 394,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heading text
                        Text(
                          'stitch Overview:',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600, fontFamily: 'Display',
                          ),
                        ),
                        const SizedBox(height: 8), // Space between heading and content
                        // Non-heading text
                        Text(
                          'stitch is a feature-rich wallpaper app that fetches breathtaking wallpapers directly from Wallhaven 🌍. '
                              'With a vast collection of 6K, 4K, and 2K wallpapers, it ensures your home and lock screen always look fresh and vibrant 🎨.\n\n'
                              'Built for speed and smooth performance ⚡, stitch delivers an immersive browsing experience, making it easy to discover, save, and apply wallpapers effortlessly 📲. '
                              'Regular updates 🔄 keep the app evolving, ensuring users always get the best.\n\n'
                              '🚀 stitch – Redefining wallpapers, one tap at a time!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Display', // Custom font family
                          ),
                          textAlign: TextAlign.center, // Optional: Adjust alignment if needed
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Sliver item 2: Key Features
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 20,
                right: 20,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(45),
                child: Container(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  height: 435,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heading text
                        Text(
                          'Key Features:',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold, fontFamily: 'Display',
                          ),
                        ),
                        const SizedBox(height: 8), // Space between heading and content
                        // Non-heading text
                        Text(
                          'stitch brings an exceptional wallpaper experience with:\n\n'
                              '• 🖼️ Stunning 6K, 4K, and 2K wallpapers for crystal-clear quality.\n'
                              '• 🔍 Powerful search to find wallpapers easily.\n'
                              '• 🎭 Curated categories for every style and mood.\n'
                              '• ❤️ Save favorites to access wallpapers anytime.\n'
                              '• 📲 One-tap wallpaper setting for home & lock screen.\n'
                              '• 🚀 Smooth and lag-free browsing experience.\n'
                              '• 🔄 Regular updates with fresh wallpapers and new features.\n',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Display', // Custom font family
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Sliver item 3: Future Enhancements
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 20,
                right: 20,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(45),
                child: Container(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  height: 379,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heading text
                        Text(
                          'Future Enhancements:',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold, fontFamily: 'Display',
                          ),
                        ),
                        const SizedBox(height: 8), // Space between heading and content
                        // Non-heading text
                        Text(
                          'stitch is continuously evolving to enhance your wallpaper experience! 🚀\n\n'
                              '• 🌟 More curated collections for diverse tastes.\n'
                              '• 🎨 AI-powered wallpaper recommendations based on your style.\n'
                              '• 📥 Offline wallpaper saving for easy access anytime.\n'
                              '• 📱 Widgets for quick wallpaper previews on the home screen.\n'
                              '• ⚡ Performance optimizations for even smoother browsing.\n'
                              '• 🔄 Frequent updates with fresh features and improvements.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Display', // Custom font family
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}