import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart' show Provider;
import 'package:refer_and_earn/refer_and_earn/color_class.dart';

import '../../controller/provider/refer_provider.dart';

class ChatboastHome extends StatelessWidget {
  const ChatboastHome({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReferralProvider>(context, listen: false);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Text(
                "Hello 👋👋",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.orangeAccent,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 8),
              Container(
                height: 30,
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Center(
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 20,
                        child: Image.asset("assets/images/24-7.png"),
                      ),
                      const SizedBox(width: 5),
                      Text("Talk with our AI agent for 27/7 help"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                color: ColorsClass.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 25,
                  ),
                  child: Column(
                    children: [
                      Image.asset("assets/images/refer_and_earn/demo.png"),
                      InkWell(
                        onTap: () async {
                          provider.urlLaunch(
                            "https://www.foodchow.com/free-demo",
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: ColorsClass.primary,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                "Book A Demo With A Coach",
                                style: GoogleFonts.poppins(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: ColorsClass.white,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    spacing: 8,
                    children: [
                      Text(
                        "About Foodchow Restaurant Marketing Platform",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorsClass.blackColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(height: 2, color: ColorsClass.deviderColor),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          provider.urlLaunch(
                            "https://foodchow.gitbook.io/getting-started/quickstart-to-foodchow",
                          );
                        },
                        child: _FoodchowAboutContainer(
                          title: "Getting Started For Free",
                          subtitle:
                              "Register your restaurant and try it for free",
                        ),
                      ),
                      _FoodchowAboutContainer(
                        title: "Partner Success Program",
                        subtitle:
                            "Join our partner program to help restaurant succeed",
                      ),
                      InkWell(
                        onTap: () {
                          provider.urlLaunch("https://www.foodchow.com/faqs");
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: ColorsClass.primary,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                "See All FAQs",
                                style: GoogleFonts.poppins(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FoodchowAboutContainer extends StatelessWidget {
  const _FoodchowAboutContainer({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsClass.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorsClass.tableDevider, width: 1),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: ColorsClass.blackColor,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.black.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
