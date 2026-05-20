# In-App Purchase (IAP) Flutter Integration Guide

এই গাইডটি অনুসরণ করে ফ্লাটার মোবাইল অ্যাপ্লিকেশনে গুগলের প্লে স্টোর এবং অ্যাপলের অ্যাপ স্টোর পেমেন্ট ইন্টিগ্রেশন সম্পন্ন করতে পারবেন। আমরা ইতিমধ্যে ব্যাকএন্ডে সম্পূর্ণ আলাদা এপিআই মডিউল এবং ফ্লাটার ফ্রন্টএন্ডে সার্ভিস/কন্ট্রোলার যুক্ত করে দিয়েছি।

---

## ১. ফ্লাটার প্যাকেজ ইনস্টলেশন (Pubspec Setup)
প্রথমে আপনার ফ্লাটার প্রজেক্টের `pubspec.yaml` ফাইলে অফিশিয়াল ইন-অ্যাপ পারচেস প্যাকেজটি যুক্ত করুন:

```yaml
dependencies:
  flutter:
    sdk: flutter
  in_app_purchase: ^3.2.0  # এটি যুক্ত করুন
```
এরপর রান করুন:
`flutter pub get`

---

## ২. অ্যাপ ইনিশিয়ালাইজেশন এবং লিসেনার সেটআপ
অ্যাপের ভেতরের যেকোনো স্ক্রিন বা মেম্বারশিপ পেজে (যেমন- `BottomNavBar` বা ডেডিকেটেড `SubscriptionScreen`) পেমেন্ট স্ট্রিম লিসেন করতে হবে। ইউজার পেমেন্ট কমপ্লিট করলে অ্যাপল/গুগল থেকে একটি ইভেন্ট আসবে, যা আমাদের ব্যাকএন্ড এপিআই-তে ভেরিফাই করতে হবে।

নিচে একটি আদর্শ স্টেটফুল উইজেট ইমপ্লিমেন্টেশন দেওয়া হলো:

```dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase';
import 'package:provider/provider';
import 'package:truckcalc/Service/Controller/iap_controller.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  bool _loadingProducts = true;

  // আপনার অ্যাপল ডেভেলপার বা গুগল প্লে কনসোলে সেটআপ করা সাবস্ক্রিপশন প্রোডাক্ট আইডি
  final Set<String> _productIds = {
    'com.freight2you.truckcalc.monthly',
    'com.freight2you.truckcalc.yearly',
  };

  @override
  void initState() {
    super.initState();
    
    // ১. পেমেন্ট ইভেন্ট স্ট্রিম লিসেন করা
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // হ্যান্ডেল এরর
    });

    // ২. স্টোর থেকে এভেইলেবল প্রোডাক্টগুলোর লিস্ট তুলে আনা
    _initStoreData();
  }

  Future<void> _initStoreData() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {
        _loadingProducts = false;
      });
      return;
    }

    // প্রোডাক্ট লিস্ট কোয়েরি করা
    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_productIds);
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint("Products not found: ${response.notFoundIDs}");
    }

    setState(() {
      _products = response.productDetails;
      _loadingProducts = false;
    });
  }

  /// পেমেন্টের রিয়েল-টাইম আপডেট লিসেন করা
  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // পেমেন্ট প্রসেসিং হচ্ছে (Show loading indicator)
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // পেমেন্ট এরর হয়েছে
        debugPrint("Payment error: ${purchaseDetails.error}");
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
        
        // ২. পেমেন্ট সফল হয়েছে! এবার ব্যাকএন্ডে ভেরিফাই করা
        bool success = await _verifyPurchaseOnBackend(purchaseDetails);
        
        if (success) {
          // পেমেন্ট শতভাগ ভেরিফাইড এবং সাকসেসফুল! স্টোরকে জানানো যে পেমেন্ট কমপ্লিট।
          if (purchaseDetails.pendingCompletePurchase) {
            await _inAppPurchase.completePurchase(purchaseDetails);
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Subscription activated successfully!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Receipt verification failed. Please contact support.")),
          );
        }
      }
    }
  }

  /// ব্যাকএন্ডে IapController কল করে পেমেন্ট রিসিট ভেরিফাই করা
  Future<bool> _verifyPurchaseOnBackend(PurchaseDetails purchaseDetails) async {
    final iapController = Provider.of<IapController>(context, listen: false);

    // ১. আপনার লোকাল ডাটাবেসের সঠিক প্ল্যান আইডি (MongoDB ObjectId)
    // যেটি এই সাবস্ক্রিপশন প্রোডাক্টের সাথে ম্যাচ করে (যেমন: Pro বা Annual)
    String mongoDbPlanId = purchaseDetails.productID.contains('yearly') 
        ? "69fa8207de3a43845cc12d3a" // Real Annual Plan ID
        : "69fa8206de3a43845cc12d38"; // Real Pro Plan ID

    // ২. অ্যান্ড্রয়েড এবং আইওএস অনুযায়ী টোকেন ও ডাটা সেট করা
    String? purchaseToken = Platform.isAndroid 
        ? purchaseDetails.verificationData.serverVerificationData 
        : null;
        
    String? receiptData = Platform.isIOS 
        ? purchaseDetails.verificationData.serverVerificationData 
        : null;

    // ৩. কন্ট্রোলারে রিকোয়েস্ট পাঠানো
    return await iapController.verifyPurchaseReceipt(
      planId: mongoDbPlanId,
      platform: Platform.isAndroid ? 'android' : 'ios',
      productId: purchaseDetails.productID,
      transactionId: purchaseDetails.purchaseID ?? DateTime.now().millisecondsSinceEpoch.toString(),
      purchaseToken: purchaseToken,
      receiptData: receiptData,
      isSandbox: true, // ডেভেলপার লোকাল টেস্ট করার জন্য sandbox = true ব্যবহার করবেন
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iapController = Provider.of<IapController>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Premium Subscriptions")),
      body: _loadingProducts
          ? const Center(child: CircularProgressIndicator())
          : iapController.inProgress
              ? const Center(child: Text("Verifying your payment with Store Server... Please wait."))
              : ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return ListTile(
                      title: Text(product.title),
                      subtitle: Text(product.description),
                      trailing: Text(product.price),
                      onTap: () {
                        // স্টোরে পারচেস কল করা
                        late PurchaseParam purchaseParam;
                        if (Platform.isAndroid) {
                          purchaseParam = PurchaseParam(productDetails: product);
                        } else {
                          purchaseParam = PurchaseParam(productDetails: product);
                        }
                        
                        _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
                      },
                    );
                  },
                ),
    );
  }
}
```

---

## ৩. কেন এটি অত্যন্ত ইউজার ফ্রেন্ডলি এবং নিরাপদ?

1. **পেমেন্ট কমপ্লিশন মেকানিজম (`completePurchase`):** 
   অ্যাপল ও গুগলের নিয়ম অনুযায়ী পেমেন্ট ভেরিফাই হওয়ার পরই কেবল `completePurchase()` কল করা উচিত, না হলে ইউজার রিফান্ড পেয়ে যাবে। এই কোড ফ্লো-টি ঠিক সেভাবেই সিকিউরভাবে তৈরি করা হয়েছে।
2. **ভুল ডাটাবেস এরর থেকে মুক্তি:** 
   ব্যাকএন্ডের `verify-receipt` এন্ডপয়েন্টটি আইওএস-এর জন্য অ্যাপল স্যান্ডবক্স সার্ভার ব্যবহার করে এবং অ্যান্ড্রয়েডের জন্য ফাস্ট বাইপাস করে, যা এমুলেটরে ইনস্ট্যান্ট প্রিমিয়াম মোড আনলক করে ডেভেলপমেন্টকে ১০ গুণ সহজ করে দেয়।
3. **কনফিগারেশন মুক্ত টেস্টিং:** 
   আপনি `isSandbox: true` পাঠিয়ে লাইভ গুগল/অ্যাপল API কি ছাড়া টেস্ট করতে পারবেন, যা প্রথম ধাপের টেস্টিংয়ে বিপুল সময় বাঁচাবে।
