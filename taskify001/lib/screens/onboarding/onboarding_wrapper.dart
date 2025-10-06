import 'package:flutter/material.dart';
import 'onboarding1.dart';
import 'onboarding2.dart';
import 'onboarding3.dart';

class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({super.key});

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  final PageController _controller = PageController();
  int page = 0;

  void _onPageChanged(int p) => setState(() => page = p);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        onPageChanged: _onPageChanged,
        children: [
          Onboarding1(controller: _controller),
          Onboarding2(controller: _controller),
          Onboarding3(controller: _controller),
        ],
      ),
    );
  }
}
