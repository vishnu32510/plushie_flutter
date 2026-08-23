import '../theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeChangeDropdownButton extends StatelessWidget {
  const ThemeChangeDropdownButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return DropdownButtonHideUnderline(
          child: DropdownButton<ThemeType>(
            elevation: 0,
            dropdownColor: Theme.of(context).colorScheme.surface,
            focusColor: Theme.of(context).colorScheme.surface,
            enableFeedback: false,
            value: state.themeEventType,
            icon: const SizedBox(),
            items:
                ThemeType.values.map((ThemeType items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(items.iconData, size: 18),
                        const SizedBox(width: 8),
                        Text(items.themeName),
                      ],
                    ),
                  );
                }).toList(),
            onChanged: (ThemeType? newValue) {
              if (newValue != null) {
                BlocProvider.of<ThemeBloc>(
                  context,
                ).add(ThemeEventChange(newValue));
              }
            },
          ),
        );
      },
    );
  }
}
