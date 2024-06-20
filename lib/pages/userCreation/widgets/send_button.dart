import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SendButton extends StatelessWidget {
  final Function()? onTap;

  const SendButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(horizontal: 25.0),
            decoration: BoxDecoration(
              color: Color.fromRGBO(8, 31, 92, 1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Center(
                child: Text(
              "SEND",
              style: TextStyle(
                color: Color.fromRGBO(247, 242, 235, 1),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ))));
  }
}
