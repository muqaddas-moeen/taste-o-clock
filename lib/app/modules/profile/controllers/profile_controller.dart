import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taste_o_clock/app/core/controllers/base_controller.dart';
import 'package:taste_o_clock/app/core/errors/failure.dart';
import 'package:taste_o_clock/app/core/utils/input_validators.dart';
import 'package:taste_o_clock/app/data/models/user_location_model.dart';
import 'package:taste_o_clock/app/data/models/user_payment_info_model.dart';
import 'package:taste_o_clock/app/data/repositories/user_repository.dart';
import 'package:taste_o_clock/app/modules/auth/controllers/auth_controller.dart';
import 'package:taste_o_clock/app/utils/helpers.dart';

class ProfileController extends BaseController {
  ProfileController({
    UserRepository? userRepository,
    AuthController? authController,
  })  : _userRepository = userRepository ?? Get.find<UserRepository>(),
        _authController = authController ?? Get.find<AuthController>();

  final UserRepository _userRepository;
  final AuthController _authController;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressLineController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController cardHolderController = TextEditingController();
  final TextEditingController cardLast4Controller = TextEditingController();
  final TextEditingController cardBrandController = TextEditingController();

  final Rx<PaymentMethod> selectedPaymentMethod =
      PaymentMethod.cashOnDelivery.obs;
  final RxBool isUpdatingLocation = false.obs;
  final RxBool isSavingLocation = false.obs;
  final RxBool isSavingPayment = false.obs;
  final RxBool isSavingDetails = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromUser(_authController.user.value);
    ever(_authController.user, _loadFromUser);
  }

  @override
  void onClose() {
    phoneController.dispose();
    addressLineController.dispose();
    cityController.dispose();
    stateController.dispose();
    postalCodeController.dispose();
    cardHolderController.dispose();
    cardLast4Controller.dispose();
    cardBrandController.dispose();
    super.onClose();
  }

  void _loadFromUser(dynamic user) {
    if (user == null) return;

    phoneController.text = user.phone ?? '';

    final location = user.location;
    if (location is UserLocationModel) {
      addressLineController.text = location.addressLine ?? '';
      cityController.text = location.city ?? '';
      stateController.text = location.state ?? '';
      postalCodeController.text = location.postalCode ?? '';
    }

    final payment = user.paymentInfo;
    if (payment is UserPaymentInfoModel) {
      selectedPaymentMethod.value = payment.paymentMethod;
      cardHolderController.text = payment.cardHolderName ?? '';
      cardLast4Controller.text = payment.cardLast4 ?? '';
      cardBrandController.text = payment.cardBrand ?? '';
    }
  }

  Future<void> useCurrentLocation() async {
    final userId = _authController.user.value?.id;
    if (userId == null) return;

    isUpdatingLocation.value = true;
    final result = await _userRepository.syncCurrentLocation(userId: userId);
    isUpdatingLocation.value = false;

    result.when(
      onSuccess: (updatedUser) {
        _authController.user.value = updatedUser;
        _loadFromUser(updatedUser);
        Helpers.showSuccess('Location updated from GPS.');
      },
      onFailure: handleFailure,
    );
  }

  Future<void> saveLocation() async {
    final userId = _authController.user.value?.id;
    if (userId == null) return;

    final addressLine = InputValidators.sanitizeText(
      addressLineController.text,
      maxLength: InputValidators.maxAddressLength,
    );
    final city = InputValidators.sanitizeText(
      cityController.text,
      maxLength: InputValidators.maxCityStateLength,
    );
    final state = InputValidators.sanitizeText(
      stateController.text,
      maxLength: InputValidators.maxCityStateLength,
    );
    final postalCode = InputValidators.sanitizeText(
      postalCodeController.text,
      maxLength: InputValidators.maxPostalLength,
    );

    final addressError = addressLine.isEmpty
        ? null
        : InputValidators.validateAddressLine(addressLine);
    if (addressError != null) {
      handleFailure(AppFailure(code: 'invalid_address', message: addressError));
      return;
    }

    final postalError = InputValidators.validatePostalCode(postalCode);
    if (postalError != null) {
      handleFailure(AppFailure(code: 'invalid_postal', message: postalError));
      return;
    }

    final existing = _authController.user.value?.location;
    final location = UserLocationModel(
      latitude: existing?.latitude ?? 0,
      longitude: existing?.longitude ?? 0,
      addressLine: addressLine,
      city: city,
      state: state,
      postalCode: postalCode,
      country: existing?.country,
      updatedAt: DateTime.now(),
    );

    if (!location.hasCoordinates &&
        location.formattedAddress.trim().isEmpty) {
      handleFailure(
        const AppFailure(
          code: 'missing_location',
          message: 'Use current location or enter an address.',
        ),
      );
      return;
    }

    isSavingLocation.value = true;
    final result = await _userRepository.updateLocation(
      userId: userId,
      location: location,
    );
    isSavingLocation.value = false;

    result.when(
      onSuccess: (updatedUser) {
        _authController.user.value = updatedUser;
        Helpers.showSuccess('Delivery location saved.');
      },
      onFailure: handleFailure,
    );
  }

  Future<void> savePaymentInfo() async {
    final userId = _authController.user.value?.id;
    if (userId == null) return;

    final paymentInfo = UserPaymentInfoModel(
      paymentMethod: selectedPaymentMethod.value,
      cardHolderName: InputValidators.sanitizeText(
        cardHolderController.text,
        maxLength: InputValidators.maxCardHolderLength,
      ),
      cardLast4: cardLast4Controller.text.trim(),
      cardBrand: InputValidators.sanitizeText(
        cardBrandController.text,
        maxLength: InputValidators.maxCardBrandLength,
      ),
      updatedAt: DateTime.now(),
    );

    if (paymentInfo.paymentMethod == PaymentMethod.card) {
      final holderError =
          InputValidators.validateCardHolder(paymentInfo.cardHolderName);
      if (holderError != null) {
        handleFailure(
          AppFailure(code: 'invalid_payment', message: holderError),
        );
        return;
      }

      final last4Error = InputValidators.validateCardLast4(paymentInfo.cardLast4);
      if (last4Error != null) {
        handleFailure(
          AppFailure(code: 'invalid_payment', message: last4Error),
        );
        return;
      }
    }

    if (!paymentInfo.isComplete) {
      handleFailure(
        const AppFailure(
          code: 'invalid_payment',
          message: 'Enter card holder name and last 4 digits, or choose cash on delivery.',
        ),
      );
      return;
    }

    isSavingPayment.value = true;
    final result = await _userRepository.updatePaymentInfo(
      userId: userId,
      paymentInfo: paymentInfo,
    );
    isSavingPayment.value = false;

    result.when(
      onSuccess: (updatedUser) {
        _authController.user.value = updatedUser;
        Helpers.showSuccess('Payment info saved.');
      },
      onFailure: handleFailure,
    );
  }

  Future<void> saveBasicDetails() async {
    final userId = _authController.user.value?.id;
    if (userId == null) return;

    final phone = InputValidators.sanitizeText(
      phoneController.text,
      maxLength: InputValidators.maxPhoneLength,
    );
    final phoneError = InputValidators.validatePhone(phone);
    if (phoneError != null) {
      handleFailure(AppFailure(code: 'invalid_phone', message: phoneError));
      return;
    }

    isSavingDetails.value = true;
    final result = await _userRepository.updateBasicDetails(
      userId: userId,
      phone: phone.isEmpty ? null : phone,
    );
    isSavingDetails.value = false;

    result.when(
      onSuccess: (updatedUser) {
        _authController.user.value = updatedUser;
        Helpers.showSuccess('Profile details saved.');
      },
      onFailure: handleFailure,
    );
  }

  Future<void> signOut() => _authController.signOut();
}
