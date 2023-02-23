import 'package:flutter/material.dart';
import 'package:locker_reservation_system/network/model/reservation_model.dart';
import 'package:provider/provider.dart';
import 'package:locker_reservation_system/providers/sid_prv.dart';
import 'package:locker_reservation_system/providers/reservation_prv.dart';

class ReservationMain extends StatelessWidget {
  ReservationMain({super.key});

  @override
  Widget build(BuildContext context) {
    int colCount = context.watch<ReservationProvider>().revModel.columns;
    int rowCount = context.watch<ReservationProvider>().revModel.rows;
    int nowRoomState = context.watch<ReservationProvider>().roomState;
    String loc =
        context.watch<ReservationProvider>().roomCodeList[nowRoomState];
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          for (int i = 0; i < rowCount; i++)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                for (int j = 0; j < colCount; j++)
                  caseButton(i, j, loc, colCount, nowRoomState, context),
              ],
            ),
        ],
      ),
    );
  }
}

Widget caseButton(int row, int column, String loc, int colCount,
    int nowRoomState, BuildContext context) {
  // 학번 정보
  String sid = context.watch<SidProvider>().sid;
  // Locker 정보 불러오기
  Locker? myLocker = context.watch<ReservationProvider>().revModel.myLocker;
  List<Locker> lockerList =
      context.watch<ReservationProvider>().revModel.lockers;

  // 해당 값에 따른 색상 지정
  List<String> caseColorList = [
    "images/blueCase.png",
    "images/greyCase.png",
    "images/redCase.png",
  ];

  int colorPicker = 0; // 기본 locker 색상은 blue
  int visitor = context.watch<ReservationProvider>().visitor;

  // 내 락커가 존재할 경우 해당 락커의 색상을 빨간색으로 지정
  if (myLocker != null && myLocker.column == column && myLocker.row == row) {
    colorPicker = 2;
  }

  // 사용 불가능한 락커의 색상은 회색으로 설정
  if (lockerList.isNotEmpty) {
    if (lockerList[visitor].column == column &&
        lockerList[visitor].row == row) {
      colorPicker = 1;
      context.read<ReservationProvider>().setVisitor();
    }
  }

  return ElevatedButton(
    style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromRGBO(0, 0, 0, 0),
        shadowColor: Color.fromARGB(0, 0, 0, 0)),
    child: Image.asset(
      caseColorList[colorPicker],
      width: 50,
      height: 50,
    ),
    onPressed: () {
      showDialog(
          context: context,
          barrierDismissible: true, // 바깥 영역 터치시 닫을지 여부
          builder: (BuildContext context) {
            return AlertDialog(
              content: reserveTip(row, column, colCount, loc, nowRoomState),
              insetPadding: const EdgeInsets.fromLTRB(0, 80, 0, 80),
              actions: [
                TextButton(
                  child: const Text('확인'),
                  onPressed: () {
                    context
                        .read<ReservationProvider>()
                        .reserveLocker(sid, loc, row, column);
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('취소'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
      print("행 : $row, 열: $column");
    },
  );
}

Widget reserveTip(
    int row, int column, int colCount, String loc, int nowRoomState) {
  List<String> list = [
    "1층 113호 앞",
    "1층 114호 앞",
    "2층 214호 앞",
    "2층 219호 앞",
    "2층 219호 옆"
  ];
  return Text(
      "${list[nowRoomState]}방의 ${(row * colCount) + column + 1}번 사물함을 선택하셨습니다.\n 이대로 예약을 진행하시겠습니까?");
}
