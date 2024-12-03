import 'package:flutter/material.dart';
import '/widgets/get_path_widget.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  Future<String?> getPath() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final String? newPath = await showDialog<String>(
      context: context,
      builder: (context) => const GetPathDialog(),
      barrierDismissible: false,
    );
    if (newPath != null) {
      return newPath;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Welcome to the Dynamic Visualizer',
              style: Theme.of(context).textTheme.displayLarge,
              textAlign: TextAlign.center,
            ),
            BigWelcomeButton(
              children: [
                const Icon(
                  Icons.link_outlined,
                  size: 50,
                ),
                Text(
                  'Link to the temporary folder',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
              onTap: () {
                getPath().then((String? path) {
                  if (path != null) {
                    Navigator.pushNamed(
                      context,
                      "/visualizer",
                      arguments: path,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please select a folder',
                        ),
                      ),
                    );
                  }
                });
              },
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "You can get the link using the ",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  TextSpan(
                    text: "-o",
                    style: TextStyle(
                      color: Colors.redAccent.shade400,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: " option or by selecting ",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  TextSpan(
                    text: "get link",
                    style: TextStyle(
                      color: Colors.redAccent.shade400,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: " from the menu",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class BigWelcomeButton extends StatelessWidget {
  const BigWelcomeButton({
    super.key,
    required this.children,
    required this.onTap,
  });

  final List<Widget> children;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}
