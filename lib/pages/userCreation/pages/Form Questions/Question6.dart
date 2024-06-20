import 'package:flutter/material.dart';

class QuestionSix extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSkip;

  const QuestionSix({Key? key, required this.controller, required this.onSkip})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Color.fromARGB(255, 8, 31, 92),
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "What is your waist circumference?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 8, 31, 92),
                    ),
                  ),
                ),
                SizedBox(height: 50),
                Image.asset('lib/assets/question6_image.png'),
                SizedBox(height: 50),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 8, 31, 92),
                      ),
                    ),
                    labelText: 'Enter your waist circumference (cm)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
