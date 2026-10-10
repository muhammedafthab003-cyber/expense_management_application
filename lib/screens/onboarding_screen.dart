
import 'package:expense_management_application/screens/home_screen.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9F8),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 7,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 290,
                    height: 290,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1,
                      ),
                    ),
                  ),

                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1,
                      ),
                    ),
                  ),

                
                  Image.asset(
                    'assets/images/onboarding.png',
                    width: 400,
                    height: 450,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),

            
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Spend Smarter\nSave More',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF438F89),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
            ),

            const SizedBox(height: 14),

        
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>HomeScreen()));
                   
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF579F98),
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: const Color(0xFF438F89)
                        .withValues(alpha: 0.4),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
