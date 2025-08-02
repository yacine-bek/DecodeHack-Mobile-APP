import 'package:eco_system_things/screens/home_screeen.dart';
import 'package:eco_system_things/screens/profile_screen.dart';
import 'package:eco_system_things/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'messages_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static const Color _primaryColor = Color(0xFF98ddd8);
  static const Color _textDarkGreen = Color.fromARGB(255, 10, 56, 0);

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _navigateToMessages() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MessagesPage()),
    );
  }

  Future<void> _handleLogout() async {
    final authBox = Hive.box('authBox');
    await authBox.clear();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Widget _buildDrawerItem(String title, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, size: 29),
        title: Text(title, style: const TextStyle(fontSize: 22)),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _primaryColor,
        elevation: 4,
        title: const Text(
          "Ecology App",
          style: TextStyle(color: _textDarkGreen),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: _textDarkGreen),
            onPressed: _navigateToMessages,
          ),
        ],
      ),
      drawer: Drawer(
        surfaceTintColor: Colors.transparent,
        backgroundColor: _primaryColor,
        width: 250,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Image.asset("assets/images/logo.png", width: 150),
              ),
              Expanded(
                child: ListView(
                  children: [
                    _buildDrawerItem('Home', Icons.home, () {
                      _onItemTapped(0);
                      Navigator.pop(context);
                    }),
                    _buildDrawerItem('Profile', Icons.person, () {
                      _onItemTapped(1);
                      Navigator.pop(context);
                    }),
                    _buildDrawerItem('Messages', Icons.message, () {
                      Navigator.pop(context);
                      _navigateToMessages();
                    }),
                    _buildDrawerItem('Donation', Icons.favorite, () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFF91d5d8),
                          content: const Text(
                            "Donation clicked",
                            style: TextStyle(color: Colors.black),
                          ),
                          margin: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }),
                    _buildDrawerItem('Logout', Icons.logout, () {
                      Navigator.pop(context);
                      _handleLogout();
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: const [HomeScreen(), ProfileScreen()],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: _primaryColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.black,
          items: const [
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.home, color: Colors.white, size: 28),
              icon: Icon(Icons.home, size: 28),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.person, color: Colors.white, size: 28),
              icon: Icon(Icons.person, size: 28),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
