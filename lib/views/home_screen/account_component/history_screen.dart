import 'package:ecom/controllers/controllers.dart';
import 'package:ecom/extension/extensions.dart';
import 'package:ecom/models/home_screen/account_component/history_card_model.dart';
import 'package:ecom/theme/app_color.dart';
import 'package:ecom/theme/app_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../models/models.dart';



class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});
  static const String routeName = "OrderHistoryScreen";
  static CustomTransitionPage page() {
    return CustomTransitionPage<void>(
      key: const ValueKey(routeName),
      name: routeName,
      child: const OrderHistoryScreen(),
      transitionsBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation, Widget child) =>
          SlideTransition(
        position: animation.drive(
          Tween<Offset>(
            begin: const Offset(-1.0, 0),
            end: Offset.zero,
          ).chain(
            CurveTween(curve: Curves.linear),
          ),
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProfileProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Track Orders',
          style: AppTypography.body.copyWith(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: FutureBuilder<List<HistoryInfoModel>>(
            future: context.read<HomeProvider>().getHistory(),
            builder: (context, AsyncSnapshot<List<HistoryInfoModel>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return ListView.separated(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final info = snapshot.data![index];
                      return HistoryInfo(
                        time: info.time,
                        cardModels: info.historyCardModel,
                      );
                    },
                    separatorBuilder: (context, index) => 10.verticalSpace,
                  );
                } else {
                  return Center(child: _buildEmptyCart());
                }
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset('assets/home_screen/empty-card.svg'),
        10.verticalSpace,
        Text('No Histories!', style: AppTypography.title)
      ],
    );
  }
}

class HistoryInfo extends StatelessWidget {
  const HistoryInfo({
    super.key,
    required this.time,
    required this.cardModels,
  });
  final String time;
  final List<HistoryCardModel> cardModels;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: AppTypography.title,
        ),
        5.verticalSpace,
        ListView.separated(
          shrinkWrap: true,
          physics: const ScrollPhysics(),
          primary: false,
          itemBuilder: (context, index) {
            final currentCard = cardModels[index];
            if (cardModels.isEmpty) {
              return _buildEmptyCart();
            }
            return HistoryCard(
                title: currentCard.title,
                price: currentCard.price,
                status: currentCard.status,
                quantity: currentCard.quantity);
          },
          separatorBuilder: (context, index) => 5.verticalSpace,
          itemCount: cardModels.length,
        )
      ],
    );
  }

  Widget _buildEmptyCart() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset('assets/home_screen/empty-card.svg'),
        10.verticalSpace,
        Text('No Histories!', style: AppTypography.title)
      ],
    );
  }
}

class HistoryCard extends StatelessWidget {
  const HistoryCard(
      {super.key,
      required this.price,
      required this.status,
      required this.title,
      required this.quantity});
  final String title;
  final String price;
  final String status;
  final int quantity;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 200.w,
                child: Text(
                  title,
                  style: AppTypography.title.copyWith(color: Colors.black),
                ),
              ),
              5.verticalSpace,
              Text(
                'Price: $price đ',
                style: AppTypography.body.copyWith(color: Colors.black),
              ),
              5.verticalSpace,
              Text('Total: $quantity',
                  style: AppTypography.body.copyWith(color: Colors.black))
            ],
          ),
          Padding(
            padding: EdgeInsets.all(10.r),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: getColor(status),
              ),
              child: Padding(
                padding: EdgeInsets.all(8.r),
                child: Text(
                  status.capitalize(),
                  style: AppTypography.body.copyWith(color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color getColor(String status) {
    if (status == 'shipping') {
      return AppColor.buttonColor;
    } else if (status == 'shipped') {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }
}
