import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:refer_and_earn/refer_and_earn/view/widgets/custome_table_restautant.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../../model/referred_restrauant_model.dart';
import '../widgets/campaign_detailed_campaign_info.dart';
import 'add_referral_screen.dart';

class RestraurentReferal extends StatefulWidget {
  const RestraurentReferal({super.key});

  @override
  State<RestraurentReferal> createState() => _RestraurentReferalState();
}

class _RestraurentReferalState extends State<RestraurentReferal> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReferralProvider>(context, listen: false).fetchRestaurantReferralData(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final referProvider = Provider.of<ReferralProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final smallScreen = constraints.maxWidth <= 700;
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                     "Dashboard",
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddReferralScreen())),
                    child: Container(
                      height: 40,
                      width: 100,
                      decoration: BoxDecoration(color: ColorsClass.primary, borderRadius: BorderRadius.circular(4)),
                      child: Center(
                        child: Text(
                           "+ Add",
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: ColorsClass.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              smallScreen
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CampaignDetailedCampaignInfo(title: "Total Referrals", number: referProvider.referralList.length.toString()),
                        const SizedBox(height: 10),
                        CampaignDetailedCampaignInfo(title: "Successfully Referrals", number: referProvider.activeRefer.length.toString()),
                        const SizedBox(height: 10),
                        CampaignDetailedCampaignInfo(title: "Pending Referrals", number: referProvider.inactiveRefer.length.toString()),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: CampaignDetailedCampaignInfo(title: "Total Referrals", number: referProvider.referralList.length.toString()),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CampaignDetailedCampaignInfo(title: "Successfully Referrals", number: referProvider.activeRefer.length.toString()),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CampaignDetailedCampaignInfo(title: "Pending Referrals", number: referProvider.inactiveRefer.length.toString()),
                        ),
                      ],
                    ),

              const SizedBox(height: 10),

              Expanded(
                child: Card(
                  color: ColorsClass.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Consumer<ReferralProvider>(
                      builder: (context, provider, _) {
                        if (provider.isReferralLoading) {
                          return const Center(child: CircularProgressIndicator.adaptive());
                        }

                        if (provider.referralList.isEmpty) {
                          return const Center(child: Text("NO DATA"));
                        }

                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          child: CustomReferralTableRestaurant(list: provider.referralList),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Table showing restaurant referrals
class CustomReferralTableRestaurant extends StatelessWidget {
  final List<ReferredRestaurantsModel>? list;

  const CustomReferralTableRestaurant({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 650) {
          return CustomTableRestaurantMobileReferral(list: list);
        } else {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
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
      },
    );
  }

  DataRow _buildDataRow(ReferredRestaurantsModel data, BuildContext context) {
    const cellStyle = TextStyle(fontWeight: FontWeight.w400);

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
                await Provider.of<ReferralProvider>(context, listen: false).deleteRestaurantReferralData(data.restaurantId, data.id);
              },
            ),
          ),
        ),
      ],
    );
  }
}
