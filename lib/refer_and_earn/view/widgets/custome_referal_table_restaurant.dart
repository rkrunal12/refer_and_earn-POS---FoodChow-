import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../reponsive.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart' show ReferralProvider;
import '../../model/referred_restrauant_model.dart';
import 'custome_table_restautant.dart';

/// Table showing restaurant referrals
class CustomReferralTableRestaurant extends StatelessWidget {
  final List<ReferredRestaurantsModel>? list;

  const CustomReferralTableRestaurant({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return CustomTableRestaurantMobileReferral(list: list);
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(const Color(0x550AA89E)),
            headingTextStyle: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600),
            border: TableBorder.all(borderRadius: BorderRadius.circular(10), width: 1, color: ColorsClass.tableDevider),
            columnSpacing: 20,
            columns: const [
              DataColumn(label: Center(child: Text("Name"))),
              DataColumn(label: Center(child: Text("Mobile No."))),
              DataColumn(label: Center(child: Text("Email"))),
              DataColumn(label: Center(child: Text("Sign Up"))),
              DataColumn(label: Center(child: Text("Reward"))),
              DataColumn(label: Center(child: Text("Status"))),
              DataColumn(label: Center(child: Text("Action"))),
            ],
            rows: list != null && list!.isNotEmpty ? list!.map((data) => _buildDataRow(data, context)).toList() : [],
          ),
        ),
      );
    }
  }

  DataRow _buildDataRow(ReferredRestaurantsModel data, BuildContext context) {
    const cellStyle = TextStyle(fontWeight: FontWeight.w400);

    debugPrint(data.toJson().toString());

    return DataRow(
      cells: [
        DataCell(Center(child: Text(data.name ?? "-", style: cellStyle))),
        DataCell(Center(child: Text(data.mobile ?? "-", style: cellStyle))),
        DataCell(Center(child: Text(data.email ?? "-", style: cellStyle))),
        DataCell(Center(child: Text(data.claimed == 1 ? "Yes" : "No", style: cellStyle))),
        DataCell(Center(child: Text("Claim(1 Month Free)", style: cellStyle))),
        DataCell(
          Center(
            child: Container(
              height: 25,
              width: 100,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: data.claimed == 1 ? const Color(0x808DBD90) : const Color(0x80D87E7E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: data.claimed == 1 ? const Color(0xFF007521) : const Color(0xFFFC0005), width: 2),
              ),
              child: FittedBox(
                child: Text(data.claimed == 1 ? "Completed" : "Pending", style: GoogleFonts.poppins(fontWeight: FontWeight.w400)),
              ),
            ),
          ),
        ),
        DataCell(
          Center(
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
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
                                        await Provider.of<ReferralProvider>(
                                          context,
                                          listen: false,
                                        ).deleteRestaurantReferralData(data.restaurantId, data.id);
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
            ),
          ),
        ),
      ],
    );
  }
}
