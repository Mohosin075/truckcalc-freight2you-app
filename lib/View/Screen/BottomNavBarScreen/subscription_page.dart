import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:truckcalc/Service/Controller/iap_controller.dart';
import 'package:truckcalc/View/Widgets/app_background.dart';
import 'package:truckcalc/View/Widgets/CustomButton.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  bool _loadingProducts = true;
  bool _isPurchasing = false;

  // Google Play Console or Apple App Store Product IDs
  final Set<String> _productIds = {
    'com.freight2you.truckcalc.monthly',
    'com.freight2you.truckcalc.yearly',
  };

  @override
  void initState() {
    super.initState();
    
    // 1. Listen to real-time purchase updates stream
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      debugPrint("IAP Stream Error: $error");
    });

    // 2. Fetch available products from Apple App Store / Google Play Store
    _initStoreData();
  }

  Future<void> _initStoreData() async {
    try {
      final bool isAvailable = await _inAppPurchase.isAvailable();
      if (!isAvailable) {
        setState(() {
          _loadingProducts = false;
        });
        return;
      }

      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_productIds);
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint("IAP Products not found: ${response.notFoundIDs}");
      }

      setState(() {
        _products = response.productDetails;
        _loadingProducts = false;
      });
    } catch (e) {
      debugPrint("Error initializing IAP Store data: $e");
      setState(() {
        _loadingProducts = false;
      });
    }
  }

  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        setState(() {
          _isPurchasing = true;
        });
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        setState(() {
          _isPurchasing = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Purchase failed: ${purchaseDetails.error?.message ?? 'Unknown error'}")),
          );
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
        setState(() {
          _isPurchasing = true;
        });
        
        bool success = await _verifyPurchaseOnBackend(purchaseDetails);
        
        setState(() {
          _isPurchasing = false;
        });

        if (success) {
          if (purchaseDetails.pendingCompletePurchase) {
            await _inAppPurchase.completePurchase(purchaseDetails);
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("✅ Subscription activated successfully!"),
                backgroundColor: Color(0xFF00D193),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("❌ Receipt verification failed. Please contact support."),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        }
      }
    }
  }

  Future<bool> _verifyPurchaseOnBackend(PurchaseDetails purchaseDetails) async {
    final iapController = Provider.of<IapController>(context, listen: false);
    
    // Pro Plan ID: 69fa8206de3a43845cc12d38, Annual Plan ID: 69fa8207de3a43845cc12d3a
    String planId = purchaseDetails.productID.contains('yearly') 
        ? "69fa8207de3a43845cc12d3a" 
        : "69fa8206de3a43845cc12d38";

    String? purchaseToken = Platform.isAndroid 
        ? purchaseDetails.verificationData.serverVerificationData 
        : null;
        
    String? receiptData = Platform.isIOS 
        ? purchaseDetails.verificationData.serverVerificationData 
        : null;

    return await iapController.verifyPurchaseReceipt(
      planId: planId,
      platform: Platform.isAndroid ? 'android' : 'ios',
      productId: purchaseDetails.productID,
      transactionId: purchaseDetails.purchaseID ?? DateTime.now().millisecondsSinceEpoch.toString(),
      purchaseToken: purchaseToken,
      receiptData: receiptData,
      isSandbox: true,
    );
  }

  Future<void> _handleSubscriptionClick(String productId) async {
    ProductDetails? storeProduct;
    for (var p in _products) {
      if (p.id == productId) {
        storeProduct = p;
        break;
      }
    }

    if (storeProduct != null) {
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: storeProduct);
      try {
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to launch In-App Purchase: $e")),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This subscription plan is currently unavailable in the App Store/Play Store. Please make sure you are using a real device logged into a sandbox user account."),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iapController = Provider.of<IapController>(context);
    final bool showGlobalLoading = iapController.inProgress || _isPurchasing;

    // Resolve store-specific prices if loaded
    String monthlyPriceText = r'$9.99';
    String yearlyPriceText = r'$79.99';

    for (var p in _products) {
      if (p.id == 'com.freight2you.truckcalc.monthly') {
        monthlyPriceText = p.price;
      } else if (p.id == 'com.freight2you.truckcalc.yearly') {
        yearlyPriceText = p.price;
      }
    }

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subscription',
                          style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w600),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBC02D).withValues(alpha: 0.8), 
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text('Trial', style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _loadingProducts
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D193)))
                        : SingleChildScrollView(
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(20.w),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF880E4F), Color(0xFFE91E63)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Text(
                                    'Your free trial ends in 5 days. Upgrade to keep full access.',
                                    style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                _buildPlanCard('Free Trial', 'Free', '/7 days', [
                                  '10 calculations/day',
                                  'Basic history',
                                  'CSV export',
                                ]),
                                SizedBox(height: 16.h),
                                _buildPlanCard('Pro', monthlyPriceText, '/month', [
                                  'Unlimited calculations',
                                  'Full history',
                                  'PDF & CSV export',
                                  'Priority support',
                                ], showButton: true, buttonText: 'Select Pro', productId: 'com.freight2you.truckcalc.monthly'),
                                SizedBox(height: 16.h),
                                _buildPlanCard('Annual', yearlyPriceText, '/year', [
                                  'Unlimited calculations',
                                  'Full history',
                                  'PDF & CSV export',
                                  'Priority support',
                                ], showButton: true, buttonText: 'Select Annual', isBestValue: true, productId: 'com.freight2you.truckcalc.yearly'),
                                SizedBox(height: 100.h),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
              if (showGlobalLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black45,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00D193),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(String title, String price, String period, List<String> features, {bool showButton = false, String? buttonText, bool isBestValue = false, String? productId}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(title, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: price, style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold)),
                        TextSpan(text: period, style: TextStyle(color: Colors.white60, fontSize: 13.sp)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              ...features.map((f) => Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: Row(
                      children: [
                        Icon(Icons.check, color: const Color(0xFF00D193), size: 16.sp),
                        SizedBox(width: 12.w),
                        Text(f, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14.sp)),
                      ],
                    ),
                  )),
              if (showButton) ...[
                SizedBox(height: 20.h),
                CustomButton(
                  buttonName: buttonText!,
                  isYellowGradient: true,
                  onPressed: () => _handleSubscriptionClick(productId!),
                ),
              ],
            ],
          ),
          if (isBestValue)
            Positioned(
              top: -10.h,
              right: -25.w,
              child: Transform.rotate(
                angle: 0.5,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2C255),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Text('BEST VALUE', style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
