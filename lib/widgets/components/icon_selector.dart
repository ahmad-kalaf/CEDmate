import 'package:cedmate/cedmate_colors.dart';
import 'package:flutter/material.dart';

class IconSelector<T> extends StatelessWidget {
  final String title;
  final T selectedValue;
  final String description;
  final List<T> values;
  final List<Widget> icons;
  final List<Color> colors;
  final ValueChanged<T> onChanged;
  final PageController? pageController;
  final double height;
  final Color selectedColor;
  final Color unselectedColor;

  const IconSelector({
    super.key,
    required this.title,
    required this.selectedValue,
    required this.description,
    required this.values,
    required this.icons,
    required this.colors,
    required this.onChanged,
    this.pageController,
    this.height = 100,
    this.selectedColor = CEDColors.primary,
    this.unselectedColor = Colors.white,
  }) : assert(
         values.length == icons.length,
         'values und icons müssen gleich lang sein',
       ),
       assert(values.length > 0, 'values darf nicht leer sein');

  @override
  Widget build(BuildContext context) {
    final controller =
        pageController ??
        PageController(
          initialPage: values.indexOf(selectedValue),
          viewportFraction: 0.25,
        );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
      ),
      child: Column(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: height,
            child: PageView.builder(
              controller: controller,
              itemCount: values.length,
              onPageChanged: (page) {
                onChanged(values[page]);
              },
              itemBuilder: (context, index) {
                final value = values[index];
                final isSelected = value == selectedValue;

                return GestureDetector(
                  onTap: () {
                    controller.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    );
                    onChanged(value);
                  },
                  child: AnimatedOpacity(
                    opacity: isSelected ? 1.0 : 0.3,
                    duration: const Duration(milliseconds: 200),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(color: Colors.transparent),
                      child: Center(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors[index],
                          ),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: icons[index],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 8),
          Center(
            child: Text(
              description,
              style: Theme.of(context).textTheme.labelLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
