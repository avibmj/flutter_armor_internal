import 'package:flutter/material.dart';
import 'package:armor_internal/ui/funding/canvasing.dart';
import 'package:armor_internal/ui/funding/followup.dart';

class Funding extends StatefulWidget {
  @override
  _FundingState createState() => _FundingState();
}

class _FundingState extends State<Funding> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan Funding", style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            SizedBox(height: 40),
            Center(
              child: Text(
                "SHARELOC",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                  letterSpacing: 1.2,
                ),
              ),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildModernOptionCard(
                  context: context,
                  title: "Canvasing",
                  icon: Icons.group_add_rounded,
                  page: Canvasing(),
                ),
                SizedBox(width: 24),
                _buildModernOptionCard(
                  context: context,
                  title: "Followup/\nMaintenance",
                  icon: Icons.handshake_rounded,
                  page: Followup(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernOptionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget page,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 30,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.blue[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
