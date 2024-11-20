import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _userName = 'Willie B Daniels';
  String _location = 'Da sheets, Aa';
  File? _profileImage;

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _pickImage(ImageSource source) async {
  var permissionStatus = source == ImageSource.camera
      ? await Permission.camera.request()
      : await Permission.photos.request();

  if (permissionStatus.isGranted) {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Permission denied. Please enable access to continue.',
        ),
      ),
    );
  }
}

  Future<void> _changeLocation() async {
    TextEditingController locationController = TextEditingController(text: _location);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Location'),
          content: TextField(
            controller: locationController,
            decoration: const InputDecoration(hintText: 'Enter new location'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _location = locationController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _toggleDarkMode() {
    setState(() {
      _darkModeEnabled = !_darkModeEnabled;
    });
    print('Dark mode: $_darkModeEnabled'); // Debugging feedback
  }

  void _launchHelp() async {
    const url = 'https://images.app.goo.gl/ZHz7q71bRddFeeyr5';
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/home');
          },
        ),
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : const AssetImage('assets/profile_image.jpg') as ImageProvider,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: _userName,
                      ),
                      onSubmitted: (newName) {
                        setState(() {
                          _userName = newName;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSettingItem(
                title: 'Location',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_location, style: TextStyle(color: Colors.grey[600])),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: _changeLocation,
              ),
              _buildSettingItem(
                title: 'Notifications',
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
              ),
              _buildSettingItem(
                title: 'Language',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('EN', style: TextStyle(color: Colors.grey[600])),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () {
                  // Language functionality to be implemented.
                },
              ),
              _buildSettingItem(
                title: 'Temperature',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('°C', style: TextStyle(color: Colors.grey[600])),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () {
                  // Handle temperature unit functionality here.
                },
              ),
              _buildSettingItem(
                title: 'Dark Mode',
                trailing: Switch(
                  value: _darkModeEnabled,
                  onChanged: (value) {
                    _toggleDarkMode();
                  },
                ),
              ),
              _buildSettingItem(
                title: 'Help',
                trailing: const Icon(Icons.chevron_right),
                onTap: _launchHelp,
              ),
              _buildSettingItem(
                title: 'Log out',
                trailing: const Icon(Icons.logout),
                onTap: () {
                  Navigator.pushNamed(context, '/login');
                },
              ),
              const SizedBox(height: 32),
              Text(
                'Version 8.2.12',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
