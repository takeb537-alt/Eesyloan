import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Amount slider state control karne ke liye variable
  double _currentAmount = 1000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Action Bar: Custom Header with search and profile icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, size: 30, color: Colors.black87),
                    onPressed: () {},
                  ),
                  // Search Bar UI component
                  Expanded(
                    child: Container(
                      height: 45,
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAEAEA).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 10),
                          Text('Search', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                  // Top Right user Profile Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orange.withOpacity(0.2),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Icon(Icons.person, color: Colors.orange),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // "EasyLoan" Main App Header Heading
              const Center(
                child: Text(
                  'EasyLoan',
                  style: TextStyle(fontSize: 38, fontWeight: FontWeight.w300, color: Colors.blackDE),
                ),
              ),
              const SizedBox(height: 25),

              // 2x2 Grid Layout Configuration for Personal Loans cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.4,
                children: [
                  _buildLoanGridCard('Personal Loan', '₹100', Icons.coiny, const Color(0xFFD6E4FF)),
                  _buildLoanGridCard('Personal Loan', '₹500', Icons.front_hand_outlined, const Color(0xFFD2F1EC)),
                  _buildLoanGridCard('Personal Loan', '₹1000', Icons.money, const Color(0xFFE1F5FE)),
                  _buildLoanGridCard('Personal Loan', '₹2000', Icons.payments_outlined, const Color(0xFFFFF1C5)),
                ],
              ),
              const SizedBox(height: 25),

              // Loan Categories Row Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Loan Categories',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  Text(
                    'Swipe >',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Horizontal Scrollable list view container for operational loan sectors
              SizedBox(
                height: 95,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryItem('Medical', Icons.medical_services_outlined, const Color(0xFFD6E4FF)),
                    _buildCategoryItem('Education', Icons.school_outlined, const Color(0xFFD2F1EC)),
                    _buildCategoryItem('Travel', Icons.flight_takeoff_outlined, const Color(0xFFFFD6D6)),
                    _buildCategoryItem('Business', Icons.business_center_outlined, const Color(0xFFFFF1C5)),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Interactive Slider Amount Selector block
              const Text(
                'Choose Your Amount',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 15),
              
              // Custom Widget representation displaying active dynamic state value indicator bubble
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, py: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF63A393),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '₹${_currentAmount.toInt()}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              
              // Amount Range Selection Slider Control Slider Implementation
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF63A393),
                  inactiveTrackColor: Colors.grey.shade300,
                  thumbColor: Colors.white,
                  valueIndicatorColor: const Color(0xFF63A393),
                ),
                child: Slider(
                  value: _currentAmount,
                  min: 100,
                  max: 2000,
                  divisions: 2, // Slider ranges precisely at 100, 1000, 2000 markers
                  onChanged: (value) {
                    setState(() {
                      _currentAmount = value;
                    });
                  },
                ),
              ),
              
              // Standard scale markers below the slider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('₹100', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                    Text('₹1000', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                    Text('₹2000', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(height: 35),

              // Primary Submission CTA Button Section
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF63A393),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Grid items architecture building template method
  Widget _buildLoanGridCard(String title, String amount, IconData icon, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(amount, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
              Icon(icon, size: 26, color: Colors.black54),
            ],
          )
        ],
      ),
    );
  }

  // Categories list node generating configuration mapping layout logic
  Widget _buildCategoryItem(String title, IconData icon, Color cardColor) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: Colors.black70),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black70)),
        ],
      ),
    );
  }
}
