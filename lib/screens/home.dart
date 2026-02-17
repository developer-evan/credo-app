// import 'package:credo_faster/screens/auth/auth-service/auth-service.dart';
import 'package:credo_faster/screens/auth/login/login.dart';
import 'package:credo_faster/services/auth-service/auth-service.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userData;
  String? _token;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    setState(() => _isLoading = true);

    try {
      final token = await _authService.getToken();

      if (token == null || token.isEmpty) {
        print('=== ERROR: No token found ===');
        setState(() {
          _userData = null;
          _token = null;
          _isLoading = false;
        });
        return;
      }

      final userData = await _authService.getData(token);

      print('=== USER INFO ===');
      print('Token: $token');
      print('User Data: $userData');

      setState(() {
        _token = token;
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      print('=== ERROR fetching user data ===');
      print('Error: $e');
      setState(() {
        _userData = null;
        _token = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      await _authService.logout();

      // Navigate to login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'No user data found',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _handleLogout,
                    child: const Text('Back to Login'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _getUserInfo,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// User Profile Card
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            /// Profile Image
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: _userData!['image'] != null
                                  ? NetworkImage(_userData!['image'])
                                  : null,
                              child: _userData!['image'] == null
                                  ? const Icon(Icons.person, size: 50)
                                  : null,
                            ),
                            const SizedBox(height: 16),

                            /// User Name
                            Text(
                              '${_userData!['firstName']} ${_userData!['lastName']}',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),

                            /// Username
                            Text(
                              '@${_userData!['username']}',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    /// User Details Section
                    Text(
                      'User Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// Email
                    _buildInfoTile(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      value: _userData!['email'] ?? 'N/A',
                    ),

                    /// Gender
                    _buildInfoTile(
                      icon: Icons.person_outline,
                      title: 'Gender',
                      value: _userData!['gender'] ?? 'N/A',
                    ),

                    /// User ID
                    _buildInfoTile(
                      icon: Icons.badge_outlined,
                      title: 'User ID',
                      value: _userData!['id']?.toString() ?? 'N/A',
                    ),

                    const SizedBox(height: 24),

                    
                    const SizedBox(height: 24),

                    /// Logout Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _handleLogout,
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
