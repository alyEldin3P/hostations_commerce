import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hostations_commerce/core/di/dependency_injection.dart';
import 'package:hostations_commerce/core/presentation/cubits/app/app_cubit.dart';
import 'package:hostations_commerce/core/presentation/cubits/app/app_state.dart';
import 'package:hostations_commerce/widgets/app_widgets.dart';
import 'package:hostations_commerce/theme/app_theme.dart';

class OnboardingScreen extends StatelessWidget {
  static const String routeName = '/onboarding';

  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _OnboardingScreenContent();
  }
}

class _OnboardingScreenContent extends StatefulWidget {
  const _OnboardingScreenContent();

  @override
  State<_OnboardingScreenContent> createState() => _OnboardingScreenContentState();
}

class _OnboardingScreenContentState extends State<_OnboardingScreenContent> {
  final PageController _pageController = PageController();

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Welcome to Hostations',
      'description': 'Your one-stop shop for all your e-commerce needs',
      'imagePath': 'assets/images/onboarding1.png',
    },
    {
      'title': 'Discover Products',
      'description': 'Browse through thousands of products from your favorite stores',
      'imagePath': 'assets/images/onboarding2.png',
    },
    {
      'title': 'Easy Checkout',
      'description': 'Secure and fast checkout process for a seamless shopping experience',
      'imagePath': 'assets/images/onboarding3.png',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    context.read<AppCubit>().goToOnboardingScreen(index);
  }

  void _nextPage() {
    final cubit = context.read<AppCubit>();
    if (cubit.isLastOnboardingScreen()) {
      _completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    final cubit = context.read<AppCubit>();
    await cubit.setHasOpenedAppBefore();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/language');
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: BlocConsumer<AppCubit, AppState>(
        listener: (context, state) {
          if (state.status == AppStateStatus.failure) {
            DependencyInjector().snackBarService.showError(state.errorMessage);
          }
        },
        builder: (context, state) {
          if (state.status == AppStateStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AppButton(
                      label: 'Skip',
                      onPressed: _skipOnboarding,
                      outlined: true,
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _onboardingData.length,
                    itemBuilder: (context, index) {
                      return _OnboardingPage(
                        title: _onboardingData[index]['title'] ?? '',
                        description: _onboardingData[index]['description'] ?? '',
                        imagePath: _onboardingData[index]['imagePath'] ?? '',
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      state.currentOnboardingIndex > 0
                          ? AppButton(
                              label: 'Back',
                              onPressed: _previousPage,
                              outlined: true,
                              icon: Icons.arrow_back,
                            )
                          : const SizedBox(width: 90),
                      Row(
                        children: List.generate(
                          _onboardingData.length,
                          (index) => _DotIndicator(
                            isActive: index == state.currentOnboardingIndex,
                          ),
                        ),
                      ),
                      AppButton(
                        label: state.currentOnboardingIndex == _onboardingData.length - 1 ? 'Done' : 'Next',
                        onPressed: _nextPage,
                        icon: state.currentOnboardingIndex == _onboardingData.length - 1 ? Icons.check_circle : Icons.arrow_forward,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: AppCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  imagePath,
                  height: 220,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 220,
                      width: 220,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            AppText(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            AppText(
              description,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  final bool isActive;

  const _DotIndicator({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 28 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
