import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hostations_commerce/core/presentation/cubits/app/app_cubit.dart';

class ThemeScreen extends StatelessWidget {
  static const String routeName = '/settings';

  const ThemeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme'),
      ),
      body: ListView(
        children: [
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              value: context.read<AppCubit>().state.themeMode == ThemeMode.dark,
              onChanged: (value) => context.read<AppCubit>().toggleTheme(value),
              secondary: const Icon(Icons.brightness_4),
            ),
          ),
        ],
      ),
    );
  }
}
