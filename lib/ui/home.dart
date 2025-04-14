import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:armor_internal/ui/collaction/collapps.dart';
import '../ui/funding/funding.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class MenuItem {
  final IconData icon;
  final String label;
  final String? url;
  final Widget? widgetPage;

  MenuItem(this.icon, this.label, {this.url, this.widgetPage});
}

class _HomeState extends State<Home> {
  String name = '';
  String id = '';
  String username = '';
  String userGroup = 'User-Group';
  String isFundingActivityReportApps = "0";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    setState(() {
      name = localStorage.getString('nama_karyawan') ?? '';
      id = localStorage.getString('user_id') ?? '';
      username = localStorage.getString('username') ?? '';
      userGroup = localStorage.getString('user_group') ?? 'User-Group';
      isFundingActivityReportApps = localStorage.getString('isFundingActivityReportApps') ?? '0';
    });
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.blue[800],
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        top: false, // We'll handle the top padding manually
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              floating: false,
              backgroundColor: Colors.blue[800],
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[800]!, Colors.blue[600]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top,
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            child: Icon(Icons.person, size: 32, color: Colors.white),
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                userGroup,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSection('General', [
                    MenuItem(Icons.public, "Website", url: "https://bprartomoro.co.id"),
                    MenuItem(Icons.email, "Web Mail", url: "https://etna.scxserver.com:2096/"),
                    MenuItem(Icons.phone_android, "M-Banking", url: "https://play.google.com/store/apps/details?id=appinventor.ai_kuszab86.artomoro"),
                    MenuItem(Icons.chat_bubble, "Omnichannel", url: "https://account.mekari.com/users/sign_in?client_id=cH1Z2PHwsu8WIJwy&return_to=L2F1dGgvP2NsaWVudF9pZD1jSDFaMlBId3N1OFdJSnd5JnJlc3BvbnNlX3R5cGU9Y29kZSZzY29wZT1zc286cHJvZmlsZSZyZWRpcmVjdF91cmk9aHR0cHM6Ly9jaGF0LnFvbnRhay5jb20vc3NvLWNhbGxiYWNr"),
                  ]),

                  SizedBox(height: 24),
                  _buildSection('Dashboard Marketing', [
                    MenuItem(Icons.analytics, "Dashboard", url: "https://dgx-lab.online/dashboard/public/dashboard"),
                    MenuItem(Icons.business, "Back Office", url: "https://armor.on.joget.cloud/jw/web/login"),
                  ]),

                  SizedBox(height: 24),
                  _buildSection('Coll Apps', [
                    MenuItem(Icons.assignment, "Laporan", widgetPage: null, url: null),
                    MenuItem(Icons.admin_panel_settings, "Admin", url: "https://armor.on.joget.cloud/jw/web/login"),
                  ]),

                  if (isFundingActivityReportApps == "1") ...[
                    SizedBox(height: 24),
                    _buildSection('Marketing Activity Report', [
                      MenuItem(Icons.bar_chart, "Dashboard", url: "https://bprartomoro.co.id/dashboard_old/public/marketing/$id"),
                      MenuItem(Icons.description, "Laporan", widgetPage: Funding()),
                      MenuItem(Icons.people, "Admin", url: "https://armor.on.joget.cloud/jw/web/loginm"),
                    ]),
                  ],

                  SizedBox(height: 24),
                  _buildSection('ArmorKu', [
                    MenuItem(Icons.android, "Android", url: "https://play.google.com/store/apps/details?id=com.absenku.armorku"),
                    MenuItem(Icons.apple, "iOS", url: "https://apps.apple.com/us/app/armorku/id1659959864"),
                    MenuItem(Icons.public, "Web", url: "https://armorku.absenku.com/web/login"),
                  ]),

                  SizedBox(height: 24),
                  _buildSection('Penempelan Stiker', [
                    MenuItem(Icons.add, "Buat Laporan", url: "https://docs.google.com/forms/d/e/1FAIpQLSdWvA_-31h3GRurKDcABE9VcPPRgaNs0DgjTJ0vvSNndXXBCQ/viewform"),
                    MenuItem(Icons.search, "Cek Laporan", url: "https://docs.google.com/spreadsheets/d/e/2PACX-1vQ7BiSNCursC5xNGgqtkODQ44ZAs0E5WtdcxRoRVKpsPe0a_Dhwk7x1cp6GK35fbK040uAMOscG6U5K/pubhtml?gid=457462778&single=true"),
                  ]),

                  SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 8 : 0,
                  right: 8,
                ),
                child: _buildMenuItem(items[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    return SizedBox(
      width: 80,
      height: 100,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _handleMenuItemTap(item, context),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, size: 24, color: Colors.blue[700]),
                ),
                SizedBox(height: 4),
                Flexible(
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    child: Text(
                      item.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleMenuItemTap(MenuItem item, BuildContext context) async {
    if (item.widgetPage != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => item.widgetPage!),
      );
    } else if (item.label == "Laporan") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CollApps()),
      );
    } else if (item.url != null) {
      Uri url = Uri.parse(item.url!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Tidak dapat membuka ${item.label}")),
        );
      }
    }
  }
}