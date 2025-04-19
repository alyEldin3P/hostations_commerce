import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hostations_commerce/core/di/dependency_injection.dart';
import 'package:hostations_commerce/core/presentation/cubits/app/app_cubit.dart';
import 'package:hostations_commerce/core/presentation/cubits/app/app_state.dart';

class LanguageSelectionScreen extends StatelessWidget {
  static const String routeName = '/language';

  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // No need for a new BlocProvider since AppCubit is already provided at the app level
    return const _LanguageSelectionScreenContent();
  }
}

class _LanguageSelectionScreenContent extends StatelessWidget {
  const _LanguageSelectionScreenContent();

  void _selectLanguage(BuildContext context, String languageCode) async {
    final cubit = context.read<AppCubit>();
    await cubit.setLanguage(languageCode);

    if (!context.mounted) return;
    // Navigate to home screen
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

          final supportedLanguages = context.read<AppCubit>().getSupportedLanguages();

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'Select Your Language',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Choose your preferred language',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),
                  Expanded(
                    child: ListView.separated(
                      itemCount: supportedLanguages.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final language = supportedLanguages[index];
                        final isSelected = language['code'] == state.selectedLanguageCode;

                        return _LanguageItem(
                          languageCode: language['code'] as String,
                          languageName: language['name'] as String,
                          flagImagePath: language['flagImagePath'] as String,
                          isSelected: isSelected,
                          onTap: () => _selectLanguage(context, language['code'] as String),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      final selectedLanguageCode = state.selectedLanguageCode;
                      _selectLanguage(context, selectedLanguageCode);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LanguageItem extends StatelessWidget {
  final String languageCode;
  final String languageName;
  final String flagImagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageItem({
    required this.languageCode,
    required this.languageName,
    required this.flagImagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                flagImagePath,
                width: 32,
                height: 24,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 32,
                    height: 24,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.flag,
                      size: 16,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                languageName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
              ),
          ],
        ),
      ),
    );
  }
}
