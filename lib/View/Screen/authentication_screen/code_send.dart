import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/View/Screen/authentication_screen/code_submit.dart';

import '../../Widgets/CustomButton.dart';
import '../../Widgets/appbar.dart';
class CodeSend extends StatelessWidget {
  const CodeSend({super.key});
  static const String name= '/code-send';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: common_appbar(titleName: 'Forgot Password',),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Code send',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 32.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'We have sent a instructions email to\nEvent@gmail.com.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 20.h),
            GestureDetector(
                onTap: (){
                  Navigator.pushNamed(context, CodeSubmit.name);
                },
                child: CustomButton(buttonName: 'Send Code')),
            SizedBox(height: 50.h),

          ],
        ),
      ),

    );
  }
}
