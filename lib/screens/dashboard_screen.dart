/*import 'package:flutter/material.dart';
import 'add_case_screen.dart';
import 'case_list_screen.dart';
import 'todays_hearings_screen.dart';
import '../widgets/app_drawer.dart';
class DashboardItem {
  final IconData icon;
  final String title;

  DashboardItem(this.icon, this.title);
}

final List<DashboardItem> dashboardItems = [
  DashboardItem(Icons.add_circle_outline, "Add Case"),
  DashboardItem(Icons.folder_open, "Case List"),
  DashboardItem(Icons.today, "Today's Hearings"),
  DashboardItem(Icons.search, "Search Judgement"),
  DashboardItem(Icons.gavel, "Case Status"),
  DashboardItem(Icons.people_outline, "Clients"),
];

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    int crossAxisCount = width < 600
        ? 2
        : width < 1000
            ? 3
            : width < 1400
                ? 4
                : 5;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF162F4A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: const [
            Icon(
              Icons.balance,
              color: Color(0xFFC9A227),
            ),
            SizedBox(width: 10),
            Text(
              "LexTrack",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.account_circle,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
        leading: Builder(
  builder: (context) => IconButton(
    icon: const Icon(Icons.menu, color: Colors.white),
    onPressed: () {
      Scaffold.of(context).openDrawer();
    },
  ),
),
      ),
      drawer: const AppDrawer(),
      backgroundColor: const Color(0xFF1E3A5F),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                dashboardHeader(),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.15,
                    ),
                    itemCount: dashboardItems.length,
                    itemBuilder: (context, index) {
                      final item = dashboardItems[index];
                      return dashboardCard(context, item.icon, item.title);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      
    );
  }

  Widget dashboardHeader() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(width: 250, child: statCard("Today's Hearings", "3", Icons.today)),
          const SizedBox(width: 12),
          SizedBox(width: 250, child: statCard("Active Cases", "12", Icons.folder_open)),
          const SizedBox(width: 12),
          SizedBox(width: 250, child: statCard("Upcoming", "5", Icons.schedule)),
        ],
      ),
    );
  }

  Widget statCard(String title, String count, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFC9A227).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFFC9A227),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget dashboardCard(BuildContext context, IconData icon, String title) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {

  if(title == "Add Case"){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCaseScreen(),
      ),
    );
  }

  if(title == "Case List"){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CaseListScreen(),
      ),
    );
  }
  if(title=="Today's Hearings"){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TodaysHearingsScreen(),
      ),
    );
  }

},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFC9A227).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 34,
                color: const Color(0xFFC9A227),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'add_case_screen.dart';
import 'case_list_screen.dart';
import 'todays_hearings_screen.dart';
import '../widgets/app_drawer.dart';
import '../database/case_database.dart';

class DashboardItem {
  final IconData icon;
  final String title;

  DashboardItem(this.icon, this.title);
}

final List<DashboardItem> dashboardItems = [
  DashboardItem(Icons.add_circle_outline, "Add Case"),
  DashboardItem(Icons.folder_open, "Case List"),
  DashboardItem(Icons.today, "Today's Hearings"),
  DashboardItem(Icons.search, "Search Judgement"),
  DashboardItem(Icons.gavel, "Case Status"),
  DashboardItem(Icons.people_outline, "Clients"),
];

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  int todayHearings = 0;
  int totalCases = 0;
  int pendingFees = 0;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  void loadStats() async {
    todayHearings = await CaseDatabase.getTodayHearingsCount();
    totalCases = await CaseDatabase.getTotalCasesCount();
    pendingFees = await CaseDatabase.getTotalPendingFees();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    int crossAxisCount = width < 600
        ? 2
        : width < 1000
            ? 3
            : width < 1400
                ? 4
                : 5;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF162F4A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: const [
            Icon(
              Icons.balance,
              color: Color(0xFFC9A227),
            ),
            SizedBox(width: 10),
            Text(
              "LexTrack",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.account_circle,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: const AppDrawer(),
      backgroundColor: const Color(0xFF1E3A5F),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                dashboardHeader(),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.15,
                    ),
                    itemCount: dashboardItems.length,
                    itemBuilder: (context, index) {
                      final item = dashboardItems[index];
                      return dashboardCard(context, item.icon, item.title);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget dashboardHeader() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(
              width: 250,
              child: statCard("Today's Hearings", "$todayHearings", Icons.today)),
          const SizedBox(width: 12),
          SizedBox(
              width: 250,
              child: statCard("Active Cases", "$totalCases", Icons.folder_open)),
          const SizedBox(width: 12),
          SizedBox(
              width: 250,
              child: statCard("Pending Fees", "₹$pendingFees", Icons.currency_rupee)),
        ],
      ),
    );
  }

  Widget statCard(String title, String count, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFC9A227).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFFC9A227),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget dashboardCard(BuildContext context, IconData icon, String title) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {

          if(title == "Add Case"){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddCaseScreen(),
              ),
            );
          }

          if(title == "Case List"){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CaseListScreen(),
              ),
            );
          }

          if(title=="Today's Hearings"){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TodaysHearingsScreen(),
              ),
            );
          }

        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFC9A227).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 34,
                color: const Color(0xFFC9A227),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      ),
    );
  }
}