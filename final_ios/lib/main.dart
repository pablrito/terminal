import 'package:final_ios/screen/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fast, Fluid and Secure ',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const OnboardingPage1(),
    );
  }
}

class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnboardingPagePresenter(
        pages: [
          OnboardingPageModel(
            title: 'Fast, Fluid and Secure',
            description: 'Enjoy the best of the world in the palm of your hands.',
            imageAsset: 'assets/image1.svg',
            bgColor: Colors.transparent,
           textColor: Colors.white,
          ),
          OnboardingPageModel(
            title: 'Connect with your friends',
            description: 'Connect with your friends anytime, anywhere.',
            imageAsset: 'assets/image2.svg',
            bgColor: Colors.transparent,
            textColor: Colors.white,
          ),
          OnboardingPageModel(
            title: 'Bookmark your favorites',
            description: 'Bookmark your favorite quotes to read later.',
            imageAsset: 'assets/image3.svg',
            bgColor: Colors.transparent,
            textColor: Colors.white,
          ),
          OnboardingPageModel(
            title: 'Follow creators',
            description: 'Follow your favorite creators to stay updated.',
            imageAsset: 'assets/image4.svg',
            bgColor: Colors.transparent,
            textColor: Colors.white,
          ),
        ],
        onSkip: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        },
        onFinish: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        },
      ),
    );
  }
}

class OnboardingPagePresenter extends StatefulWidget {
  final List<OnboardingPageModel> pages;
  final VoidCallback? onSkip;
  final VoidCallback? onFinish;

  const OnboardingPagePresenter({
    super.key,
    required this.pages,
    this.onSkip,
    this.onFinish,
  });

  @override
  State<OnboardingPagePresenter> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPagePresenter> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/blue1.jpg'), // Background Image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Page Content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.pages.length,
                    onPageChanged: (idx) {
                      setState(() {
                        _currentPage = idx;
                      });
                    },
                    itemBuilder: (context, idx) {
                      final item = widget.pages[idx];
                      return Column(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child:
                              
                               SvgPicture.asset(
                                item.imageAsset,
                                height: 300,
                                width: 300,
                                color: Colors.white,
                                 //   fit: BoxFit.contain, // Adjusts how the image is scaled

                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    item.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: item.textColor,
                                        ),
                                  ),
                                ),
                                Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 280),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24.0, vertical: 8.0),
                                  child: Text(
                                    item.description,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: item.textColor,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Page Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),

                // Navigation Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: widget.onSkip ??
                            () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HomeScreen()),
                              );
                            },
                        child: const Text("Skip"),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          if (_currentPage == widget.pages.length - 1) {
                            widget.onFinish?.call();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOutCubic,
                            );
                          }
                        },
                        child: Row(
                          children: [
                            Text(_currentPage == widget.pages.length - 1
                                ? "Finish"
                                : "Next"),
                            const SizedBox(width: 8),
                            Icon(_currentPage == widget.pages.length - 1
                                ? Icons.done
                                : Icons.arrow_forward),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPageModel {
  final String title;
  final String description;
  final String imageAsset;
  final Color bgColor;
  final Color textColor;

  OnboardingPageModel({
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.bgColor,
    required this.textColor,
  });
}
