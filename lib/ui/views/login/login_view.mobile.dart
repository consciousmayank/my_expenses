import 'package:expense_manager/extensions/textstyles_extension.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'login_viewmodel.dart';

class LoginViewMobile extends ViewModelWidget<LoginViewModel> {
  const LoginViewMobile({super.key});
  @override
  Widget build(BuildContext context, LoginViewModel viewModel) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Expense Tracker'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: PageView(
                  onPageChanged: (index) =>
                      viewModel.setSelectedOnboardingPage(index),
                  children: getOnboardingPages(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(getOnboardingPages().length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        shape: viewModel.selectedOnboardingPage == index
                            ? BoxShape.circle
                            : BoxShape.rectangle,
                        color: viewModel.selectedOnboardingPage == index
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300],
                      ),
                    );
                  }),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () => viewModel.signInWithGoogle(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Login Via Google',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Using Google Id to login will ensure your expenses are backed up in your google drive and can be restored if you delete the application, or use another device.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.grey,
                        ).button14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> getOnboardingPages() {
    return const [
      _OnboardingPage(
        title: 'Track Expenses',
        description: 'Keep track of your daily expenses easily',
        // image: 'assets/onboarding1.png',
      ),
      _OnboardingPage(
        title: 'Daily View',
        description: 'View your expenses day by day',
        // image: 'assets/onboarding2.png',
      ),
      _OnboardingPage(
        title: 'Monthly View',
        description: 'View your expenses month by month',
        // image: 'assets/onboarding3.png',
      ),
      _OnboardingPage(
        title: 'Yearly View',
        description: 'View your expenses year by year',
        // image: 'assets/onboarding3.png',
      ),
      _OnboardingPage(
        title: 'Analytics',
        description: 'View detailed reports and analytics\n\n\n(Coming Soon)',
        // image: 'assets/onboarding4.png',
      ),
    ];
  }
}

class _OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  // final String image;

  const _OnboardingPage({
    required this.title,
    required this.description,
    // required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image.asset(
          //   image,
          //   height: 200,
          // ),
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
