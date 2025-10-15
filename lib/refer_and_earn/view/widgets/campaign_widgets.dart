import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:refer_and_earn/refer_and_earn/view/widgets/update_campaign.dart';

import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../../controller/service/campaign_service.dart';
import '../../model/campaign_model.dart';
import '../../model/fetch_data_model.dart';
import '../screens/cash_back.dart';
import '../screens/restraurent_referal.dart';
import 'common_widgets.dart';
import '../screens/add_campaign.dart';
import '../screens/all_campaign.dart';

/// Image widget with fixed size
class ImageAssets extends StatelessWidget {
  final String path;
  final double height;
  final double width;

  const ImageAssets(this.path, {super.key, this.height = 45, this.width = 45});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height, width: width, child: Image.asset(path));
  }
}

/// Container with icon and text
class ContentContainer extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;

  const ContentContainer({
    super.key,
    required this.icon,
    required this.title,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? ColorsClass.primary : ColorsClass.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isSelected ? ColorsClass.white : ColorsClass.blackColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isSelected ? ColorsClass.white : ColorsClass.blackColor,
              ),
              overflow: TextOverflow
                  .ellipsis, // optional: shows "..." if text is too long
            ),
          ),
        ],
      ),
    );
  }
}

/// Container with image and text
class ContentContainerImage extends StatelessWidget {
  final String imagePath;
  final String title;
  final bool isSelected;

  const ContentContainerImage({
    super.key,
    required this.imagePath,
    required this.title,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? ColorsClass.primary : ColorsClass.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            height: 30,
            child: Image.asset(
              imagePath,
              color: isSelected ? ColorsClass.white : ColorsClass.blackColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isSelected ? ColorsClass.white : ColorsClass.blackColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// IndexedStack content
class BuildContent extends StatelessWidget {
  final int selectedIndex;

  const BuildContent({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: selectedIndex,
      children: const [
        AddCampaign(),
        AllCampaign(),
        CashBack(),
        RestraurentReferal(),
      ],
    );
  }
}

/// Campaign detailed card for summary
class CampaignDetailed extends StatelessWidget {
  final String title;
  final String number;

  const CampaignDetailed({
    super.key,
    required this.title,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Card(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                number,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 29,
                  color: ColorsClass.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Build campaign DataTable (desktop/tablet)
class BuildCustomTable extends StatelessWidget {
  final List<Data> data;

  const BuildCustomTable({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return data.isEmpty
        ? SizedBox()
        : LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      Color(0x550AA89E),
                    ),
                    border: TableBorder.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    columnSpacing: 20,
                    columns: const [
                      DataColumn(label: Text("Campaign Name")),
                      DataColumn(label: Text("Reward Type")),
                      DataColumn(label: Text("Friend's Reward")),
                      DataColumn(label: Text("Your Reward")),
                      DataColumn(label: Text("Validity")),
                      DataColumn(label: Text("Action")),
                    ],
                    rows: data.map((campaign) {
                      final campaignModel = CampaignModel(
                        campaignId: campaign.campaignId,
                        campaignName: campaign.campaignName,
                        customerReward: campaign.customerReward,
                        referrerReward: campaign.referrerReward,
                        minPurchase: campaign.minPurchase,
                        expiryEnable: campaign.expiryEnable == true ? 1 : 0,
                        expiryType: campaign.expiryType,
                        fixedPeriodType: campaign.fixedPeriodType,
                        endDate:
                            "${campaign.endDate?.year ?? DateTime.now().year}-${campaign.endDate?.month ?? DateTime.now().month}-${campaign.endDate?.day ?? DateTime.now().day} ${campaign.endDate?.hour ?? DateTime.now().hour}:${campaign.endDate?.minute ?? DateTime.now().minute}:${campaign.endDate?.second ?? DateTime.now().second}",
                        notifyCustomer: campaign.notifyCustomer == true ? 1 : 0,
                        rewardType: campaign.rewardType,
                        shopId: campaign.shopId?.toString(),
                        status: campaign.status == "1" ? 1 : 0,
                      );

                      return DataRow(
                        cells: [
                          DataCell(Text(campaign.campaignName ?? "")),
                          DataCell(Text(campaign.rewardType ?? "")),
                          DataCell(Text("${campaign.customerReward}%")),
                          DataCell(Text("${campaign.referrerReward}%")),
                          DataCell(
                            Text(
                              campaign.expiryEnable == false
                                  ? "No Expiry"
                                  : (campaign.expiryType ==
                                        "After Friend's First Order")
                                  ? "Expires After Friend's First Order"
                                  : "End: ${DateFormat('dd-MM-yyyy HH:mm:ss a').format(DateTime(campaign.endDate?.year ?? 1970, campaign.endDate?.month ?? 1, campaign.endDate?.day ?? 1, campaign.endDate?.hour ?? 0, campaign.endDate?.minute ?? 0, campaign.endDate?.second ?? 0))}",
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.teal,
                                  ),
                                  onPressed: () =>
                                      buildDialogeBox(context, campaignModel),
                                ),
                                Consumer<ReferralProvider>(
                                  builder: (context, provider, child) {
                                    return provider.loadingId ==
                                            campaign.campaignId
                                        ? const CircularProgressIndicator()
                                        : Switch.adaptive(
                                            value: campaignModel.status == 1,
                                            onChanged: (val) {
                                              debugPrint("Status Change: $val");
                                              CampaignService.updateCampaigns(
                                                campaignModel
                                                  ..status = val ? 1 : 0,
                                                context,
                                                false,
                                                true,
                                              );
                                            },
                                          );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final deleteData =
                                        await Provider.of<ReferralProvider>(
                                          context,
                                          listen: false,
                                        ).deleteCampaign(
                                          campaign.campaignId,
                                          campaign.shopId,
                                        );
                                    CustomSnackBar.show(deleteData, false);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          );
  }
}

/// Update Campaign Dialog
void buildDialogeBox(BuildContext context, CampaignModel campaignData) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Update Campaign"),
            InkWell(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close),
            ),
          ],
        ),
        content: UpdateCampaign(data: campaignData),
      );
    },
  );
}

/// Expiry container
class BuildExpiryContainer extends StatelessWidget {
  final ReferralProvider provider;
  final bool isMobile;

  const BuildExpiryContainer({
    super.key,
    required this.provider,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomRadioListTile(
            value: "Set Specific End Date & Time",
            title: "Set Specific End Date & Time",
            groupValue: provider.expiryOption,
            onChanged: (val) {
              provider.updateExpiryOption(val!);
              provider.updateExpiryDate(DateTime.now());
            },
          ),
          CustomRadioListTile(
            value: "Based on Hours",
            title: "Based on Hours",
            groupValue: provider.expiryOption,
            onChanged: (val) {
              provider.updateExpiryOption(val!);
              CustomSnackBar.show("Campaign will expire in 72 hours", isMobile);
            },
          ),
          CustomRadioListTile(
            value: "Based on Days",
            title: "Based on Days",
            groupValue: provider.expiryOption,
            onChanged: (val) {
              provider.updateExpiryOption(val!);
              CustomSnackBar.show("Campaign will expire in 30 Days", isMobile);
            },
          ),
        ],
      ),
    );
  }
}
