import 'dart:ui' as html;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Track sequence of taps with timestamps for the secret door
  final List<DateTime> _secretTaps = [];

  // Reset the tap sequence if no tap is detected after this duration
  final _resetDuration = const Duration(seconds: 2);

  // secure storage for token persistence
  final _secureStorage = const FlutterSecureStorage();

  @override
  void dispose() {
    // _secureStorage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, I'm",
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ).animate().fadeIn(duration: const Duration(milliseconds: 500)),
            const SizedBox(height: 16),
            Text(
                  "Gaurav Jha",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                )
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 500))
                .slideX(begin: -0.2, end: 0, curve: Curves.easeOut),
            const SizedBox(height: 8),
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'I build things for the web and mobile.',
                  textStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  speed: const Duration(milliseconds: 80),
                ),
              ],
              totalRepeatCount: 1,
              pause: const Duration(milliseconds: 1000),
              displayFullTextOnTap: true,
              stopPauseOnTap: true,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                // When the specific area is tapped, add the current time to the list
                final now = DateTime.now();
                _secretTaps.add(now);

                // Clean up old taps (more than resetDuration ago)
                _secretTaps.removeWhere(
                  (tap) => now.difference(tap) > _resetDuration,
                );

                // If we have 5 taps within the time window, show the admin dialog
                if (_secretTaps.length >= 5) {
                  _secretTaps.clear(); // Reset the sequence
                  _showAdminLoginDialog(context);
                }
              },
              // Make the hit area invisible and only cover a small part of the text
              child: Container(
                width: 500,
                color: Colors.transparent, // Invisible
                child: Text(
                  "I'm a software developer specializing in building exceptional digital experiences. Currently, I'm focused on building accessible, human-centered products.",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ),
            ).animate().fadeIn(
              duration: const Duration(milliseconds: 800),
              delay: const Duration(milliseconds: 300),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    elevation: 0,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 1,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 20,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/contact');
                  },
                  child: const Text("Get In Touch"),
                )
                .animate()
                .fadeIn(
                  duration: const Duration(milliseconds: 1000),
                  delay: const Duration(milliseconds: 500),
                )
                .scaleXY(begin: 0.9, end: 1.0),
          ],
        ),
      ),
    );
  }

  Future<void> _showAdminLoginDialog(BuildContext context) async {
    final passwordController = TextEditingController();
    bool isLoading = false;
    String? errorMessage;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Admin Login',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        errorText: errorMessage,
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.background,
                  ),
                  onPressed:
                      isLoading
                          ? null
                          : () async {
                            setState(() {
                              isLoading = true;
                              errorMessage = null;
                            });

                            try {
                              final response = await http.post(
                                Uri.parse(
                                  'https://noy-webhook-backend.onrender.com/admin/login',
                                ),
                                headers: {'Content-Type': 'application/json'},
                                body: jsonEncode({
                                  'password': passwordController.text,
                                }),
                              );

                              print("Response status: ${response.statusCode}");
                              print(response.body); // Debug print

                              if (response.statusCode == 200) {
                                // final data = jsonDecode(response.body);
                                final Map<String, dynamic> data = jsonDecode(
                                  response.body,
                                );

                                final String token =
                                    data['token'] as String? ?? '';
                                print('Token extracted: $token');

                                if (token.isEmpty) {
                                  setState(() {
                                    errorMessage =
                                        'Invalid server response (no token).';
                                    isLoading = false;
                                  });
                                  return;
                                }

                                // html.window.localStorage['admin_token'] = token;
                                // print('Admin token stored in localStorage: $token');

                                // close dialog
                                if (!mounted) return;
                                Navigator.of(context).pop();

                                print(
                                  'Navigating to admin page with token: $token',
                                );

                                // navigate to admin page and pass token via route arguments
                                Navigator.of(context).pushNamed(
                                  '/admin',
                                  arguments: {'token': token},
                                );

                                print('Navigation complete');
                              } else if (response.statusCode == 403 ||
                                  response.statusCode == 401) {
                                setState(() {
                                  errorMessage = 'Invalid password';
                                  isLoading = false;
                                });
                              } else {
                                setState(() {
                                  errorMessage =
                                      'Server error: ${response.statusCode}';
                                  isLoading = false;
                                });
                              }
                            } catch (e) {
                              setState(() {
                                errorMessage = 'Error connecting to server';
                                isLoading = false;
                              });
                            }
                          },
                  child:
                      isLoading
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.background,
                            ),
                          )
                          : const Text('Login'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
