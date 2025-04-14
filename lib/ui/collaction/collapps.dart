import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/bottomNavigation.dart';
import '../login.dart';
import '../home.dart';
import 'collaction_bucket.dart';
import 'collaction_kunjungan.dart';
import 'collaction_pembayaran.dart';

class CollApps extends StatefulWidget {
  @override
  _CollAppsState createState() => _CollAppsState();
}

class _CollAppsState extends State<CollApps> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
  }

  void _onItemTapped(int index) {
    print("Navigasi ke index: $index");

    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Home()),
        (route) => false,
      );
    } else if (index == 3) {
      _confirmLogout();
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi Logout"),
          content: Text("Apakah Anda yakin ingin keluar?"),
          actions: [
            TextButton(
              child: Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Logout"),
              onPressed: () async {
                Navigator.of(context).pop();
                SharedPreferences localStorage = await SharedPreferences.getInstance();
                await localStorage.remove('user');
                await localStorage.remove('token');
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.blue),
        title: Text(
          'Collection Apps',
          style: TextStyle(
            color: Colors.blue[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color.fromARGB(255, 234, 250, 255),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth;
          double cardWidth = maxWidth > 600 ? 500 : maxWidth * 0.9;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // SizedBox(
                //   width: cardWidth,
                //   child: Card(
                //     color: Colors.white,
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(15),
                //     ),
                //     elevation: 10,
                //     child: Padding(
                //       padding: const EdgeInsets.all(20),
                //       child: Column(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           SizedBox(
                //             width: maxWidth * 0.5,
                //             height: maxWidth * 0.5,
                //             child: PieChart(
                //               PieChartData(
                //                 sections: [
                //                   PieChartSectionData(
                //                       color: Colors.red,
                //                       value: 80,
                //                       title: '80%',
                //                       radius: maxWidth * 0.15,
                //                       titleStyle: TextStyle(
                //                           fontSize: 16,
                //                           fontWeight: FontWeight.bold,
                //                           color: Colors.white)),
                //                   PieChartSectionData(
                //                       color: Colors.blue,
                //                       value: 20,
                //                       title: '20%',
                //                       radius: maxWidth * 0.15,
                //                       titleStyle: TextStyle(
                //                           fontSize: 16,
                //                           fontWeight: FontWeight.bold,
                //                           color: Colors.white)),
                //                 ],
                //               ),
                //             ),
                //           ),
                //           SizedBox(height: 20),
                //           _buildText("Total Tunggakan | Rp. 437,584,615.00", 20, true),
                //           _buildText("Total Outstanding | Rp. 437,584,615.00", 18, false),
                //           _buildText("Total Pembayaran | Rp. 0.00", 18, false),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                SizedBox(
                  width: cardWidth,
                  child: Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _responsiveMenuButton(context, Icons.edit_document, 'Bucket', BucketScreen()),
                            _responsiveMenuButton(context, Icons.table_rows, 'Kunjungan Diluar Bucket', CollactionKunjungan()),
                            _responsiveMenuButton(context, Icons.payments_outlined, 'Pembayaran Diluar Bucket', CollactionPembayaran()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        context: context,
      ),
    );
  }

  Widget _buildText(String text, double size, bool isBold) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        style: TextStyle(
            fontSize: size,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87),
      ),
    );
  }

  Widget _responsiveMenuButton(
      BuildContext context, IconData icon, String label, Widget page) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: Colors.blue),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
