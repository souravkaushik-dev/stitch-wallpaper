import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FAQPage extends StatefulWidget {
  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  final List<Map<String, String>> faqs = [
    {
      'question': 'How does stitch work?',
      'answer': 'stitch works by fetching wallpapers directly from Wallhaven through their API. We are grateful to Wallhaven for providing us with this resource, and we are committed to providing you with the best wallpapers.'
    },
    {
      'question': 'Why does stitch lag while setting wallpapers?',
      'answer': 'stitch does not lag when setting wallpapers. The performance depends on the resolution of the wallpaper and the specifications of the mobile device you are using.'
    },
    {
      'question': 'Why does stitch take so much time while setting the wallpaper?',
      'answer': 'stitch may take some time while setting a wallpaper because the wallpapers vary in resolution, ranging from 6K, 4K, to 2K. The time required depends on the resolution of the wallpaper being set.'
    },
    {
      'question': 'Will stitch receive feature updates and maintenance updates on time?',
      'answer': 'Yes, stitch will receive feature and maintenance updates from time to time. In some situations, updates may be delayed, but they will surely be provided.'
    },
    {
      'question': 'Is stitch open-source?',
      'answer': 'No, stitch is developed from scratch with careful planning, and currently, there are no plans to make it open-source.'
    },
    // Add more questions and answers here
  ];

  // Store which FAQ item is expanded
  List<bool> _expanded = [];

  @override
  void initState() {
    super.initState();
    _expanded = List.generate(faqs.length, (_) => false); // Initialize with the correct size
  }

  @override
  Widget build(BuildContext context) {
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
                  titlePadding: EdgeInsets.only(
                    top: isCollapsed ? 0.0 : 80.0,
                    left: 16.0,
                  ),
                  title: Align(
                    alignment: isCollapsed ? Alignment.centerLeft : Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: isCollapsed ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                        children: [
                          Text(
                            '.faqs',
                            style: TextStyle(
                              fontFamily: 'Display',
                              fontSize: isCollapsed ? 24.0 : 42.0,
                              // Using dynamic color
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  background: Stack(
                    children: [
                      if (isCollapsed)
                        Positioned.fill(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                            child: Container(
                              // Dynamic background color
                            ),
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(roundedCorner),
                          ),
                          color: Colors.transparent,
                        ),
                      ),
                    ],
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
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final faq = faqs[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            faq['question']!,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _expanded[index] = !_expanded[index]; // Toggle the expansion state
                            });
                          },
                        ),
                        if (_expanded[index]) // Show the answer when expanded
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              faq['answer']!,
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Display',
                                fontWeight: FontWeight.w400// Applying 'Display' font family to answers
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
              childCount: faqs.length,
            ),
          ),
        ],
      ),
    );
  }
}
