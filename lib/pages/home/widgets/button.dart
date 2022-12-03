import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

Widget buttonScan(context, text, img, screen) {
  return InkWell(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    ),
    child: Container(
      width: 70.w,
      height: 7.h,
      decoration: const BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              img,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    ),
  );
}
