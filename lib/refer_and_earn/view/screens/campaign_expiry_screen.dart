import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../widgets/campaign_widgets.dart';
import '../widgets/common_widget.dart';

class CampaignExpiryScreen extends StatelessWidget {
  final Function({
    required String campaignType,
    required String expiryOption,
    DateTime? selectedDate,
    required bool notifyCustomers,
    int? duration,
  })
  onChanged;
  final bool isMobile;

  CampaignExpiryScreen({
    super.key,
    required this.onChanged,
    required this.isMobile,
  });

  final TextEditingController _dateController = TextEditingController();

  Future<void> _pickDateTime(
    BuildContext context,
    ReferralProvider provider,
  ) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: provider.expiryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: provider.expiryDate != null
          ? TimeOfDay.fromDateTime(provider.expiryDate!)
          : TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    final combinedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    provider.updateExpiryDate(combinedDateTime);

    _notifyParent(provider);
  }

  void _notifyParent(ReferralProvider provider) {
    if (provider.campaignType == "Fixed Period" &&
        provider.expiryOption != "Set Specific End Date & Time") {
      DateTime defaultDate = DateTime.now();
      if (provider.expiryOption == "Based on Hours") {
        defaultDate = defaultDate.add(const Duration(hours: 72));
      } else if (provider.expiryOption == "Based on Days") {
        defaultDate = defaultDate.add(const Duration(days: 30));
      }
      provider.updateExpiryDate(defaultDate);
    }

    onChanged(
      campaignType: provider.campaignType,
      expiryOption: provider.expiryOption,
      selectedDate: provider.expiryDate,
      notifyCustomers: provider.notifyCustomers,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReferralProvider>(
      builder: (context, provider, _) {
        if (provider.expiryDate != null) {
          _dateController.text =
              "${provider.expiryDate!.day.toString()}-"
              "${provider.expiryDate!.month.toString()}-"
              "${provider.expiryDate!.year} "
              "${provider.expiryDate!.hour.toString()}:"
              "${provider.expiryDate!.minute.toString()}";
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    return Column(
                      children: [
                        CustomRadioListTile(
                          title: "Fixed Period",
                          value: "Fixed Period",
                          groupValue: provider.campaignType,
                          onChanged: (val) {
                            provider.updateCampaignType(val!);
                            _notifyParent(provider);
                          },
                        ),
                        CustomRadioListTile(
                          title: "After Friend's First Order",
                          value: "After Friend's First Order",
                          groupValue: provider.campaignType,
                          onChanged: (val) {
                            provider.updateCampaignType(val!);
                            _notifyParent(provider);
                          },
                        ),
                      ],
                    );
                  } else {
                    return Row(
                      children: [
                        Expanded(
                          child: CustomRadioListTile(
                            title: "Fixed Period",
                            value: "Fixed Period",
                            groupValue: provider.campaignType,
                            onChanged: (val) {
                              provider.updateCampaignType(val!);
                              _notifyParent(provider);
                            },
                          ),
                        ),
                        Expanded(
                          child: CustomRadioListTile(
                            title: "After Friend's First Order",
                            value: "After Friend's First Order",
                            groupValue: provider.campaignType,
                            onChanged: (val) {
                              provider.updateCampaignType(val!);
                              _notifyParent(provider);
                            },
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 10),

              if (provider.campaignType == "Fixed Period") ...[
                BuildExpiryContainerAllCampaign(
                  provider: provider,
                  isMobile: isMobile,
                ),
                const SizedBox(height: 20),

                if (provider.expiryOption == "Set Specific End Date & Time")
                  SizedBox(
                    width: double.infinity,
                    child: TextField(
                      readOnly: true,
                      controller: _dateController,
                      onTap: () => _pickDateTime(context, provider),
                      decoration: InputDecoration(
                        hintText: "dd-MM-yyyy HH:mm",
                        suffixIcon: const Icon(
                          Icons.calendar_today,
                          color: ColorsClass.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
              ],
              ListTile(
                leading: CustomCheckBox(
                  value: provider.notifyCustomers,
                  onChanged: (val) {
                    provider.updateNotifyCustomers(val ?? false);
                    _notifyParent(provider);
                  },
                ),
                title: Text(
                  "Notify customer before expiry",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
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
