import 'package:find_it_app/core/constants/app_colors.dart';
import 'package:find_it_app/core/constants/constants.dart';
import 'package:find_it_app/features/found/found.dart';
import 'package:find_it_app/features/home/home.dart';
import 'package:find_it_app/features/lost/lost.dart';
import 'package:find_it_app/features/view/view.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  final int selectedIndex;

  const MainScreen({super.key, this.selectedIndex = 0});

  @override
  State<MainScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<MainScreen> {
  late int _selectedIndex;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.jumpToPage(_selectedIndex);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            HomeSreen(),
            FoundScreen(),
            LostScreen(),
            ViewScreen(),
          ],
        ),
        bottomNavigationBar: ClipRRect(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.blueColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              backgroundColor: AppColors.blueColor,
              type: BottomNavigationBarType.fixed,
              onTap: _onItemTapped,
              selectedItemColor: AppColors.yellowColor,
              unselectedItemColor: Colors.white,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.asset(Constants.home, width: 22, height: 22),
                  ),
                  activeIcon: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.asset(Constants.home, width: 25, height: 25),
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.asset(Constants.found, width: 22, height: 22),
                  ),
                  activeIcon: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.asset(Constants.found, width: 25, height: 25),
                  ),
                  label: 'Found',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.asset(Constants.lost, width: 22, height: 22),
                  ),
                  activeIcon: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.asset(Constants.lost, width: 25, height: 25),
                  ),
                  label: 'Lost',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.asset(Constants.view, width: 22, height: 22),
                  ),
                  activeIcon: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.asset(Constants.view, width: 25, height: 25),
                  ),
                  label: 'View',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
