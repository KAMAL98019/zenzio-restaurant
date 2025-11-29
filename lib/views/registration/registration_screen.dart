import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/registration_viewmodel.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/step_indicator.dart';
import 'step1_restaurant_details.dart';
import 'step2_contact_hours.dart';
import 'step3_documents_bank.dart';
import '../dashboard/dashboard_screen.dart';

class RegistrationScreen extends StatelessWidget {
  final Map<String, dynamic>? payload;
  const RegistrationScreen({Key? key, this.payload}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = RegistrationViewModel();
        if (payload != null) {
          viewModel.populateRegistrationFieldsFromJson(payload!);
        }
        return viewModel;
      },
      child: Consumer<RegistrationViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: CustomAppBar(
              title: 'Register Your Restaurant',
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (viewModel.currentStep > 0) {
                    viewModel.previousStep();
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: StepIndicator(
                      currentStep: viewModel.currentStep + 1,
                      totalSteps: viewModel.totalSteps,
                    ),
                  ),
                ),
              ],
            ),
            body: IndexedStack(
              index: viewModel.currentStep,
              children: const [
                Step1RestaurantDetails(),
                Step2ContactHours(),
                Step3DocumentsBank(),
              ],
            ),
          );
        },
      ),
    );
  }
}
