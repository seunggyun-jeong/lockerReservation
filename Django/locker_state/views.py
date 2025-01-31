from rest_framework.response import Response
from rest_framework.decorators import api_view
from rest_framework import exceptions
from rest_framework import status

import json
from collections import OrderedDict
from datetime import datetime

from .models import Locker
from .serializers import LockerSerializer, LockerCreateSerializer
from lockerReservation.session import session_funcs
from lockerReservation.settings import CLOSINGTIME

# Create your views here.
#


@api_view(['GET', 'POST'])
def LockerList(request, format=None):
    err = ""
    stcode = status.HTTP_404_NOT_FOUND
    try:
        if request.method == 'GET':  # 사물함 조회 (파라미터는 location)
            loc = request.GET['location']
            if len(loc) > 1:
                err = "not enable data"
                raise exceptions.ParseError("not enable data")
            # print(loc)
            queryset = Locker.objects.filter(
                location=loc).order_by('row', 'column')
            serializer = LockerSerializer(queryset, many=True)

            if (loc == 'a'):  # 1층 114앞
                rows = 5
                columns = 20

            elif (loc == 'b'):  # 1층 113앞
                rows = 5
                columns = 6

            elif (loc == 'c'):  # 2층 220앞
                rows = 5
                columns = 22

            elif (loc == 'd'):  # 2층 119앞
                rows = 5
                columns = 2

            elif (loc == 'e'):  # 2층 221앞
                rows = 5
                columns = 12

            else:
                err = "not enable data"
                raise exceptions.ParseError("not enable data")

            ret = OrderedDict()
            ret['rows'] = rows
            ret['columns'] = columns
            my_data = []
            db_data = []

            if (session_funcs().get(request) != None):
                if (Locker.objects.filter(studentID=session_funcs().get(request)).exists()):
                    myLock = Locker.objects.get(
                        studentID=session_funcs().get(request))
                    ret['myLocker'] = (
                        {"location": myLock.location, "row": myLock.row, "column": myLock.column})
                    # print(my_data)
                else:
                    ret['myLocker'] = None
            else:
                ret['myLocker'] = None

            # ret['myLocker'] = my_data

            for data in serializer.data:
                db_data.append(data)

            ret['lockers'] = db_data
            # return Response(serializer.data,status = status.HTTP_200_OK)
            return Response(ret, status=status.HTTP_200_OK)

        elif request.method == 'POST':  # 사물함 예약
            # print(request)
            if datetime.now() > CLOSINGTIME:
                err = "timeout"
                stcode = status.HTTP_403_FORBIDDEN
                raise serializers.ValidationError('timeout')

            serializer = LockerCreateSerializer(data=request.data)
            # 세션 확인 (이거 studentID 보내기 힘들면 없애고 그냥 세션에서 받아올예정)
            if request.data['studentID'] != session_funcs().get(request):
                err = "studentID error"
                stcode = status.HTTP_401_UNAUTHORIZED
                raise serializers.ValidationError('studentID error')

            if Locker.objects.filter(**request.data).exists():  # 예약 취소 (중복일때)
                lk = Locker.objects.get(studentID=request.data['studentID'])
                lk.delete()
                return Response({"delete": "success"}, status=status.HTTP_202_ACCEPTED)

            # 사용중인 사물함 예약
            if Locker.objects.filter(location=request.data['location'], row=request.data['row'], column=request.data['column']).exists():
                err = "location is already use"
                stcode = status.HTTP_409_CONFLICT
                raise serializers.ValidationError('location is already use')

            # 이미 예약한 사람이 다른곳에 예약 시도시 발생
            if Locker.objects.filter(studentID=request.data['studentID']).exists():
                err = "This student already reservation"
                stcode = status.HTTP_409_CONFLICT
                raise serializers.ValidationError('This data already exists')

            if (len(request.data['studentID']) > 8 or len(request.data['location']) > 1):  # 사이즈 통제
                err = "not enable data"
                raise exceptions.ParseError("not enable data")

            if (request.data['studentID'] == None or request.data['location'] == None or request.data['row'] == None or request.data['column'] == None):  # 값 통제
                err = "not enable data"
                raise exceptions.ParseError("not enable data")

            # print('post on')
            if serializer.is_valid():
                serializer.save()  # create
                return Response(serializer.data, status=status.HTTP_201_CREATED)
    except:
        return Response({"error": err}, status=stcode)
    # return Response(status=status.HTTP_404_NOT_FOUND)
