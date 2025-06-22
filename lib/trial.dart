import 'package:draggable_home/draggable_home.dart';
import 'package:flutter/material.dart';

class stitchHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DraggableHome(
      title: Text("stitch"),
      headerWidget: headerWidget(),
      headerExpandedHeight: 0.4, // Adjust height as needed
      body: [
        // Your wallpapers grid, carousel, etc.
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Today's Trending", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        // Add your wallpaper grid or list here
      ],
    );
  }

  Widget headerWidget() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Text(
          "Wallpaper of the Week",
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
