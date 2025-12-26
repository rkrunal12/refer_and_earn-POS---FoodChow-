import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../../model/referred_restrauant_model.dart';
import 'package:provider/provider.dart';

import 'package:flutter_svg/flutter_svg.dart';

/// Mobile RestRestaurant Referral Table
class CustomTableRestaurantMobileReferral extends StatelessWidget {
  final List<ReferredRestaurantsModel>? list;

  const CustomTableRestaurantMobileReferral({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    if (list == null || list!.isEmpty) {
      return const Center(child: Text("No referrals available"));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: list!.length,
      itemBuilder: (context, index) {
        final data = list![index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          data.name ?? "-",
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildActions(context, data.id, data.restaurantId, data.claimed),
                    ],
                  ),

                  const Divider(thickness: 1, color: Colors.grey),

                  _buildRow("Mobile", data.mobile ?? "-"),
                  _buildRow("Email", data.email ?? "-"),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text("$title:", style: GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: GoogleFonts.poppins(fontSize: 14), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildStatus(int? data) {
    final isCompleted = data == 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0x808DBD90) : const Color(0x80D87E7E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isCompleted ? const Color(0xFF007521) : const Color(0xFFFC0005), width: 2),
      ),
      child: Text(
        isCompleted ? "Completed" : "Pending",
        style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 11, color: ColorsClass.blackColor),
      ),
    );
  }

  Widget _buildActions(BuildContext context, int? id, String? restaurantId, int? claimed) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatus(claimed),
        const SizedBox(width: 8),
        Consumer<ReferralProvider>(
          builder: (context, provider, _) {
            return InkWell(
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SizedBox(
                          width: 300,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.delete_outline, color: Colors.teal, size: 48),
                              const SizedBox(height: 16),
                              Text("Delete Referral", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Text(
                                "Are you sure you want to delete this referral?",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Colors.teal),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.teal)),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onPressed: () async {
                                        await Provider.of<ReferralProvider>(context, listen: false).deleteRestaurantReferralData(restaurantId, id);
                                        Navigator.pop(context);
                                      },
                                      child: Text("Delete", style: GoogleFonts.poppins(color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: SizedBox(height: 25, width: 25, child: SvgPicture.asset("assets/svg/mobile_delete.svg")),
            );
          },
        ),
      ],
    );
  }
}
