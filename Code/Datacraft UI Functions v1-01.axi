PROGRAM_NAME='Datacraft UI Functions v1-01'
(***********************************************************)
(*  FILE CREATED ON: 08/18/2012  AT: 23:42:02              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 06/03/2013  AT: 14:09:44        *)
(***********************************************************)


(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

CHAR UI_DEVICES_ALL[]					= 'ALL'

CHAR UI_VAR_ROOM_ID[]					= 'roomID'
CHAR UI_VAR_ROOM_COLLECTION_ID[]			= 'roomCollectionID'
CHAR UI_VAR_ALT_ROOM_ID[]				= 'altRoomID'
CHAR UI_VAR_ALT_ROOM_COLLECTION_ID[]			= 'altRoomCollectionID'
CHAR UI_VAR_EMPLOYEE_CODE_ENTRY[]			= 'employeeCodeEntry'
CHAR UI_VAR_BOOKING_SELECTED_TIME[]			= 'bookingSelectedTime'
CHAR UI_VAR_BOOKING_IN_PROGRESS[]			= 'bookingInProgress'
CHAR UI_VAR_ADHOC_BOOKING_ENABLED[]			= 'adhocBookingEnabled'
CHAR UI_VAR_LOGIN_IN_PROGRESS[]				= 'loginInProgress'
CHAR UI_VAR_END_MEETING_ENABLE[]			= 'endMeetingEnable'
CHAR UI_VAR_EMPLOYEE_CODE_ENTRY_IN_PROGRESS[]		= 'codeEntryInProgess'
CHAR UI_VAR_HOME_PAGE_MODE[]				= 'homePageMode'
CHAR UI_VAR_USER_IS_BOOKING_A_MEETNG[]			= 'userIsBookingAMeeting'

INTEGER MEETING_TITLE_MAX_LENGTH			= 50
INTEGER NAME_MAX_LENGTH					= 50
#IF_NOT_DEFINED ROOM_NAME_MAX_LENGTH
INTEGER ROOM_NAME_MAX_LENGTH				= 30
#END_IF
INTEGER ROOM_PHONE_NUM_MAX_LENGTH			= 30
INTEGER	INITIALS_MAX_LENGTH				= 5
INTEGER COSTCODE_MAX_LENGTH				= 10
INTEGER STATE_NAME_MAX_LENGTH				= 30
INTEGER MEETING_TYPE_NAME_MAX_LENGTH			= 30

INTEGER MAX_NUMBER_OF_MEETINGS_PER_ROOM			= 30
INTEGER MAX_NUMBER_ROOMS_IN_STORAGE			= 30
INTEGER MAX_NUMBER_USERS_IN_STORAGE			= 50
INTEGER MAX_NUMBER_STATES				= 20
INTEGER MAX_NUMBER_MEETING_TYPES			= 20

SINTEGER ROUNDING_MINUTES[]				= {
    0, 15, 30, 45
}

INTEGER NUMBER_OF_TIME_OPTIONS				= 18

INTEGER HIP_TYPE_SETUP					= 0
INTEGER HIP_TYPE_MAIN					= 1
INTEGER HIP_TYPE_SETDOWN				= 2

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

STRUCT _MEETING {
    LONG id
    INTEGER index
    CHAR title[MEETING_TITLE_MAX_LENGTH]
    _TIME startTime
    _TIME endTime
    INTEGER state
    INTEGER type
    CHAR ownerName[NAME_MAX_LENGTH]
    CHAR agentName[NAME_MAX_LENGTH]
    INTEGER roomID
    LONG hipID
    INTEGER hipType
}

STRUCT _USER {
    INTEGER id
    CHAR name[NAME_MAX_LENGTH]
    CHAR initials[INITIALS_MAX_LENGTH]
    INTEGER agentID
    CHAR costcode[COSTCODE_MAX_LENGTH]
    INTEGER costcodeID
    INTEGER siteID
}

STRUCT _ROOM {
    INTEGER id
    CHAR name[ROOM_NAME_MAX_LENGTH]
    CHAR shortName[ROOM_NAME_MAX_LENGTH]
    INTEGER floor
    INTEGER capacity
    CHAR phoneNumber[ROOM_PHONE_NUM_MAX_LENGTH]
    INTEGER maxChangeID
    INTEGER chartInterval
    _MEETING todaysMeetings[MAX_NUMBER_OF_MEETINGS_PER_ROOM]
    INTEGER numberOfMeetings
}

STRUCT _STATE {
    INTEGER id
    CHAR name[STATE_NAME_MAX_LENGTH]
    INTEGER colour
    INTEGER ordinal
}

STRUCT _MEETING_TYPE {
    INTEGER id
    CHAR name[MEETING_TYPE_NAME_MAX_LENGTH]
    INTEGER colour
    INTEGER ordinal
}

STRUCT _TIME_LIST_BUTTON {
    INTEGER defined
    _TIME presetTime
    CHAR text[5]
}

STRUCT _TIME_LIST {
    CHAR uiDeviceKey[UI_KEY_MAX_LENGTH]
    INTEGER roomID
    _TIME_LIST_BUTTON btn[NUMBER_OF_TIME_OPTIONS]
}


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

VOLATILE _ROOM rooms[MAX_NUMBER_ROOMS_IN_STORAGE]
VOLATILE _USER users[MAX_NUMBER_USERS_IN_STORAGE]
VOLATILE _TIME_LIST timeList[UI_MAX_DEVICES]
VOLATILE INTEGER currentUserID					= 0
VOLATILE _STATE states[MAX_NUMBER_STATES]
VOLATILE _MEETING_TYPE meetingTypes[MAX_NUMBER_MEETING_TYPES]

DEFINE_FUNCTION INTEGER AddMinutesToTime(_TIME t, INTEGER minutes) {
    STACK_VAR INTEGER result
    STACK_VAR INTEGER n
    STACK_VAR _TIME tTemp

    result = TRUE
    tTemp = t

    for(n = 1; n <= minutes; n ++) {
	tTemp.minutes ++

	if(tTemp.minutes > 59) {
	    tTemp.minutes = 0

	    if(tTemp.hours < 23) {
		tTemp.hours ++
	    } else {
		result = FALSE
		break
	    }
	}
    }

    if(result) {
	t = tTemp
    }

    return result
}

DEFINE_FUNCTION INTEGER NumberOfMinutesUntilEndOfMeeting(INTEGER roomID, LONG meetingID) {
    STACK_VAR INTEGER meetingIndex
    STACK_VAR INTEGER roomIndex
    STACK_VAR INTEGER count
    STACK_VAR _TIME t1
    STACK_VAR _TIME t2

    roomIndex = FindRoomIndexByID(roomID)
    meetingIndex = FindMeetingIndexByID(roomID, meetingID)
    count = 0

    if(meetingIndex) {
	TimeCreate(t1)
	t1.seconds = 0
	t2 = rooms[roomIndex].todaysMeetings[meetingIndex].endTime
	t2.seconds = 0

	while(!TimeMatches(t1, t2)) {
	    t1.minutes ++

	    count ++

	    if(t1.minutes > 59) {
		t1.minutes = 0

		t1.hours ++

		if(t1.hours > 23) {
		    count = 0
		    break
		}
	    }
	}
    }

    return count
}

DEFINE_FUNCTION INTEGER NumberOfMinutesUntilNextMeeting(INTEGER roomID) {
    STACK_VAR LONG meetingID
    STACK_VAR INTEGER meetingIndex
    STACK_VAR INTEGER roomIndex
    STACK_VAR INTEGER count
    STACK_VAR _TIME t1
    STACK_VAR _TIME t2

    roomIndex = FindRoomIndexByID(roomID)
    meetingID = 0
    meetingIndex = 0
    count = 0

    if(roomIndex) {
	meetingID = FindNextMeetingIDForRoom(roomID)
    }

    if(meetingID) {
	meetingIndex = FindMeetingIndexByID(roomID, meetingID)
    }

    if(meetingIndex) {
	TimeCreate(t1)
	t1.seconds = 0
	t2 = rooms[roomIndex].todaysMeetings[meetingIndex].startTime
	t2.seconds = 0

	while(!TimeMatches(t1, t2)) {
	    t1.minutes ++

	    count ++

	    if(t1.minutes > 59) {
		t1.minutes = 0

		t1.hours ++

		if(t1.hours > 23) {
		    count = 0
		    break
		}
	    }
	}
    }

    return count
}

DEFINE_FUNCTION INTEGER RoundingMinutesCheck(_TIME t) {
    STACK_VAR INTEGER n
    STACK_VAR INTEGER result

    result = 0

    for(n = 1; n <= MAX_LENGTH_ARRAY(ROUNDING_MINUTES); n ++) {
	if(t.minutes == ROUNDING_MINUTES[n]) {
	    result = TRUE
	    break
	}
    }

    return result
}

DEFINE_FUNCTION INTEGER RoundUpTimeToRoundingMinutes(_TIME t) {
    STACK_VAR INTEGER result

    result = 0

    while(!RoundingMinutesCheck(t)) {
	AddMinutesToTime(t, 1)
	result ++
    }

    return result
}

DEFINE_FUNCTION INTEGER ShowAvailableTimesForNewMeeting(CHAR uiDeviceKey[], INTEGER roomID) {
    STACK_VAR _TIME nextMeetingTime
    STACK_VAR _TIME loopTime
    STACK_VAR INTEGER count
    STACK_VAR INTEGER roundedMinutes
    STACK_VAR _TIME_LIST_BUTTON btn

    count = 0
    TimeCreate(loopTime)
    loopTime.seconds = 0

    TimeListClear(uiDeviceKey)

    DebugAddDataToArray('Show times for new meeting', 'uiDeviceKey', uiDeviceKey)
    DebugAddDataToArray('Show times for new meeting', 'roomID', ItoA(roomID))
    DebugAddDataToArray('Show times for new meeting', 'TimeCreate(loopTime)', TimeAsTimeStampWithSeconds(loopTime))

    if(!FindCurrentMeetingIDForRoom(roomID)) { // Check no meeting is currently going on!
	DebugAddDataToArray('Show times for new meeting', 'FindCurrentMeetingIDForRoom(roomID)', 'FALSE')

	if(FindNextMeetingIDForRoom(roomID)) {
	    nextMeetingTime = rooms[FindRoomIndexByID(roomID)].todaysMeetings[FindMeetingIndexByID(roomID, FindNextMeetingIDForRoom(roomID))].startTime
	} else {
	    TimeCreate(nextMeetingTime)
	    nextMeetingTime.hours = 23
	    nextMeetingTime.minutes = 59
	    nextMeetingTime.seconds = 0
	}

	DebugAddDataToArray('Show times for new meeting', 'nextMeetingTime', TimeAsTimeStampWithSeconds(nextMeetingTime))

	roundedMinutes = RoundUpTimeToRoundingMinutes(loopTime)

	if(roundedMinutes > 5) {
	    DebugAddDataToArray('Show times for new meeting', 'loopTime rounded up', TimeAsTimeStampWithSeconds(loopTime))
	    if(TimeIsBeforeOrEqualToTime(loopTime, nextMeetingTime)) {
		count ++
		InitTypeTimeListBtn(btn)
		btn.presetTime = loopTime
		btn.text = "FORMAT('%02d', btn.presetTime.hours), FORMAT(':%02d', btn.presetTime.minutes)"
		TimeListAddBtn(uiDeviceKey, roomID, btn)
	    }
	}

	while(AddMinutesToTime(loopTime, 15) && count < NUMBER_OF_TIME_OPTIONS) {
	    if(TimeIsBeforeOrEqualToTime(loopTime, nextMeetingTime)) {
		count ++
		InitTypeTimeListBtn(btn)
		btn.presetTime = loopTime
		btn.text = "FORMAT('%02d', btn.presetTime.hours), FORMAT(':%02d', btn.presetTime.minutes)"
		TimeListAddBtn(uiDeviceKey, roomID, btn)
	    } else {
		break
	    }

	    DebugAddDataToArray('Show times for new meeting', "'loop count = ', ItoA(count), ' loopTime'", TimeAsTimeStampWithSeconds(loopTime))
	}
    }

    DebugAddDataToArray('Show times for new meeting', 'count', ItoA(count))
    DebugSendArrayToConsole('Show times for new meeting')

    return count
}

DEFINE_FUNCTION INTEGER ShowAvailableTimesForExtendingMeeting(CHAR uiDeviceKey[], INTEGER roomID) {
    STACK_VAR _TIME nextMeetingTime
    STACK_VAR _TIME loopTime
    STACK_VAR INTEGER count
    STACK_VAR _TIME_LIST_BUTTON btn

    count = 0

    TimeListClear(uiDeviceKey)

    DebugAddDataToArray('Show times for extending meeting', 'uiDeviceKey', uiDeviceKey)
    DebugAddDataToArray('Show times for extending meeting', 'roomID', ItoA(roomID))

    if(FindCurrentMeetingIDForRoom(roomID)) { // Check for current meeting ID
	DebugAddDataToArray('Show times for extending meeting', 'FindCurrentMeetingIDForRoom(roomID)', 'TRUE')
	loopTime = rooms[FindRoomIndexByID(roomID)].todaysMeetings[FindMeetingIndexByID(roomID, FindCurrentMeetingIDForRoom(roomID))].endTime
	DebugAddDataToArray('Show times for extending meeting', 'loopTime', TimeAsTimeStampWithSeconds(loopTime))

	if(FindNextMeetingIDForRoom(roomID)) {
	    nextMeetingTime = rooms[FindRoomIndexByID(roomID)].todaysMeetings[FindMeetingIndexByID(roomID, FindNextMeetingIDForRoom(roomID))].startTime
	} else {
	    TimeCreate(nextMeetingTime)
	    nextMeetingTime.hours = 23
	    nextMeetingTime.minutes = 59
	    nextMeetingTime.seconds = 0
	}

	DebugAddDataToArray('Show times for extending meeting', 'nextMeetingTime', TimeAsTimeStampWithSeconds(nextMeetingTime))

	if(RoundUpTimeToRoundingMinutes(loopTime)) {
	    DebugAddDataToArray('Show times for extending meeting', 'loopTime rounded up', TimeAsTimeStampWithSeconds(loopTime))
	    if(TimeIsBeforeOrEqualToTime(loopTime, nextMeetingTime)) {
		count ++
		InitTypeTimeListBtn(btn)
		btn.presetTime = loopTime
		btn.text = "FORMAT('%02d', btn.presetTime.hours), FORMAT(':%02d', btn.presetTime.minutes)"
		TimeListAddBtn(uiDeviceKey, roomID, btn)
	    }
	}

	while(AddMinutesToTime(loopTime, 15) && count < NUMBER_OF_TIME_OPTIONS) {
	    if(TimeIsBeforeOrEqualToTime(loopTime, nextMeetingTime)) {
		count ++
		InitTypeTimeListBtn(btn)
		btn.presetTime = loopTime
		btn.text = "FORMAT('%02d', btn.presetTime.hours), FORMAT(':%02d', btn.presetTime.minutes)"
		TimeListAddBtn(uiDeviceKey, roomID, btn)
	    } else {
		break
	    }

	    DebugAddDataToArray('Show times for extending meeting', "'loop count = ', ItoA(count), ' loopTime'", TimeAsTimeStampWithSeconds(loopTime))
	}
    }

    DebugAddDataToArray('Show times for extending meeting', 'count', ItoA(count))
    DebugSendArrayToConsole('Show times for extending meeting')

    return count
}

DEFINE_FUNCTION InitTypeMeeting(_MEETING meeting) {
    STACK_VAR _TIME t

    TimeTypeInit(t)

    meeting.id = 0
    meeting.index = 0
    meeting.title = ''
    meeting.startTime = t
    meeting.endTime = t
    meeting.ownerName = ''
    meeting.agentName = ''
    meeting.state = 0
    meeting.type = 0
    meeting.roomID = 0
    meeting.hipType = 0
    meeting.hipID = 0
}

DEFINE_FUNCTION InitTypeUser(_USER user) {
    user.id = 0
    user.initials = ''
    user.name = ''
    user.siteID = 0
    user.costcode = ''
    user.costcodeID = 0
}

DEFINE_FUNCTION InitAllUserData() {
    STACK_VAR INTEGER n

    for(n = 1; n <= MAX_LENGTH_ARRAY(users); n ++) {
	InitTypeUser(users[n])
    }
}

DEFINE_FUNCTION InitTypeState(_STATE state) {
    state.id = 0
    state.name = ''
    state.colour = 0
    state.ordinal = 0
}

DEFINE_FUNCTION InitAllStateData() {
    STACK_VAR INTEGER n

    for(n = 1; n <= MAX_LENGTH_ARRAY(states); n ++) {
	InitTypeState(states[n])
    }
}

DEFINE_FUNCTION InitTypeMeetingType(_MEETING_TYPE meetingType) {
    meetingType.id = 0
    meetingType.name = ''
    meetingType.colour = 0
    meetingType.ordinal = 0
}

DEFINE_FUNCTION InitAllMeetingTypeData() {
    STACK_VAR INTEGER n

    for(n = 1; n <= MAX_LENGTH_ARRAY(meetingTypes); n ++) {
	InitTypeMeetingType(meetingTypes[n])
    }
}

DEFINE_FUNCTION InitTypeRoom(_ROOM room) {
    STACK_VAR INTEGER n

    room.id = 0
    room.capacity = 0
    room.floor = 0
    room.maxChangeID = 0
    room.chartInterval = 0
    room.shortName = ''
    room.name = ''
    room.phoneNumber = ''
    room.numberOfMeetings = 0

    for(n = 1; n <= MAX_LENGTH_ARRAY(room.todaysMeetings); n ++) {
	InitTypeMeeting(room.todaysMeetings[n])
    }
}

DEFINE_FUNCTION InitAllRoomData() {
    STACK_VAR INTEGER n

    for(n = 1; n <= MAX_LENGTH_ARRAY(rooms); n ++) {
	InitTypeRoom(rooms[n])
    }
}

DEFINE_FUNCTION InitTypeTimeListBtn(_TIME_LIST_BUTTON btn) {
    btn.defined = 0
    TimeTypeInit(btn.presetTime)
    btn.text = ''
}

DEFINE_FUNCTION InitTypeTimeList(_TIME_LIST list) {
    STACK_VAR INTEGER n

    list.roomID = 0
    list.uiDeviceKey = ''

    for(n = 1; n <= MAX_LENGTH_ARRAY(list.btn); n ++) {
	InitTypeTimeListBtn(list.btn[n])
    }
}

DEFINE_FUNCTION InitAllTimeLists() {
    STACK_VAR INTEGER n

    for(n = 1; n <= MAX_LENGTH_ARRAY(timeList); n ++) {
	InitTypeTimeList(timeList[n])
    }
}

DEFINE_FUNCTION INTEGER TimeListFindIndexForKey(CHAR uiDeviceKey[]) {
    STACK_VAR INTEGER n
    STACK_VAR INTEGER foundIndex

    foundIndex = 0

    for(n = 1; n <= MAX_LENGTH_ARRAY(timeList); n ++) {
	if(timeList[n].uiDeviceKey == uiDeviceKey) {
	    foundIndex = n
	    break
	}
    }

    return foundIndex
}

DEFINE_FUNCTION INTEGER TimeListClear(CHAR uiDeviceKey[]) {
    STACK_VAR INTEGER foundIndex

    foundIndex = TimeListFindIndexForKey(uiDeviceKey)

    if(foundIndex) {
	InitTypeTimeList(timeList[foundIndex])
    }

    return foundIndex
}

DEFINE_FUNCTION TimeListAddBtn(CHAR uiDeviceKey[], INTEGER roomID, _TIME_LIST_BUTTON btn) {
    STACK_VAR INTEGER listIndex
    STACK_VAR INTEGER btnIndex
    STACK_VAR INTEGER n

    listIndex = TimeListFindIndexForKey(uiDeviceKey)

    if(!listIndex) {
	for(listIndex = 1; listIndex <= MAX_LENGTH_ARRAY(timeList); listIndex ++) {
	    if(!LENGTH_ARRAY(timeList[listIndex].uiDeviceKey)) {
		InitTypeTimeList(timeList[listIndex])
		break
	    }
	}
    }

    if(listIndex) {
	timeList[listIndex].uiDeviceKey = uiDeviceKey
	timeList[listIndex].roomID = roomID

	for(n = 1; n <= MAX_LENGTH_ARRAY(timeList[listIndex].btn); n ++) {
	    if(!timeList[listIndex].btn[n].defined) {
		timeList[listIndex].btn[n] = btn
		timeList[listIndex].btn[n].defined = TRUE
		break
	    }
	}
    }
}

DEFINE_FUNCTION CHAR[5] TimeListGetBtnText(CHAR uiDeviceKey[], INTEGER index) {
    STACK_VAR INTEGER listIndex

    listIndex = TimeListFindIndexForKey(uiDeviceKey)

    if(listIndex) {
	return timeList[listIndex].btn[index].text
    } else {
	return ''
    }
}

DEFINE_FUNCTION INTEGER TimeListGetRoomID(CHAR uiDeviceKey[]) {
    STACK_VAR INTEGER listIndex

    listIndex = TimeListFindIndexForKey(uiDeviceKey)

    if(listIndex) {
	return timeList[listIndex].roomID
    } else {
	return 0
    }
}

DEFINE_FUNCTION CHAR[TIME_STAMP_LENGTH] TimeListGetBtnTime(CHAR uiDeviceKey[], INTEGER index) {
    STACK_VAR INTEGER listIndex

    listIndex = TimeListFindIndexForKey(uiDeviceKey)

    if(listIndex) {
	return TimeAsTimeStamp(timeList[listIndex].btn[index].presetTime)
    } else {
	return ''
    }
}

DEFINE_FUNCTION TimeListUIUpdate(CHAR uiDeviceKey[]) {
    STACK_VAR INTEGER n
    STACK_VAR INTEGER listIndex
    STACK_VAR INTEGER count

    listIndex = TimeListFindIndexForKey(uiDeviceKey)
    count = 0

    if(listIndex) {
	for(n = 1; n <= MAX_LENGTH_ARRAY(uiBtns_Time_Option); n ++) {
	    if(n <= MAX_LENGTH_ARRAY(timeList[listIndex].btn)) {
		if(timeList[listIndex].btn[n].defined) {
		    UIText(uiDeviceKey, uiBtns_Time_Option[n], UI_STATE_ALL, timeList[listIndex].btn[n].text)
		    UIButtonShow(uiDeviceKey, uiBtns_Time_Option[n])
		    count ++
		} else {
		    UIButtonHide(uiDeviceKey, uiBtns_Time_Option[n])
		}
	    } else {
		UIButtonHide(uiDeviceKey, uiBtns_Time_Option[n])
	    }
	}
    }

    if(count > 6) {
	UIButtonShow(uiDeviceKey, UI_JOIN_TIME_OPTION_MORE)
    } else if(count) {
	UIButtonHide(uiDeviceKey, UI_JOIN_TIME_OPTION_MORE)
    }
}

DEFINE_FUNCTION InitAllData() {
    InitAllRoomData()
    InitAllUserData()
    InitAllTimeLists()
    InitAllMeetingTypeData()
    InitAllStateData()
}

DEFINE_FUNCTION INTEGER AddMeetingData(_MEETING meeting, INTEGER meetingIndex) {
    STACK_VAR INTEGER n
    STACK_VAR INTEGER nextAvailableIndex
    STACK_VAR INTEGER existingIndex
    STACK_VAR _ROOM room
    STACK_VAR INTEGER roomIndex

    nextAvailableIndex = 0
    existingIndex = 0

    roomIndex = FindRoomIndexByID(meeting.roomID)

    if(!roomIndex) {
	InitTypeRoom(room)
	room.id = meeting.roomID
	room.name = 'Unknown'
	room.shortName = 'Unknown'
	roomIndex = AddRoomData(room)
	DC_GetRoomDetails(room.id)
    }

    DebugAddDataToArray('Process Meeting Info', 'meeting.id', ItoA(meeting.id))
    DebugAddDataToArray('Process Meeting Info', 'meeting.index', ItoA(meeting.index))
    DebugAddDataToArray('Process Meeting Info', 'meeting.roomID', ItoA(meeting.roomID))
    DebugAddDataToArray('Process Meeting Info', 'meeting.title', meeting.title)
    DebugAddDataToArray('Process Meeting Info', 'meeting.ownerName', meeting.ownerName)
    DebugAddDataToArray('Process Meeting Info', 'meeting.agentName', meeting.agentName)
    DebugAddDataToArray('Process Meeting Info', 'meeting.startTime', "'[', TimeAsTimeStamp(meeting.startTime), ']'")
    DebugAddDataToArray('Process Meeting Info', 'meeting.endTime', "'[', TimeAsTimeStamp(meeting.endTime), ']'")

    if(roomIndex) {
	if(!meetingIndex) {
	    for(n = 1; n <= MAX_LENGTH_ARRAY(rooms[roomIndex].todaysMeetings); n ++) {
		if(!rooms[roomIndex].todaysMeetings[n].id) {
		    nextAvailableIndex = n
		    break
		}
	    }

	    for(n = 1; n <= MAX_LENGTH_ARRAY(rooms[roomIndex].todaysMeetings); n ++) {
		if(rooms[roomIndex].todaysMeetings[n].id == meeting.id) {
		    existingIndex = n
		    break
		}
	    }

	    if(existingIndex) {
		DebugAddDataToArray('Process Meeting Info', 'Existing Meeting?', 'YES')
		DebugSendArrayToConsole('Process Meeting Info')
		rooms[roomIndex].todaysMeetings[existingIndex] = meeting
		return existingIndex
	    } else if(nextAvailableIndex) {
		DebugAddDataToArray('Process Meeting Info', 'Existing Meeting?', 'NO')
		DebugSendArrayToConsole('Process Meeting Info')
		rooms[roomIndex].todaysMeetings[nextAvailableIndex] = meeting
		return nextAvailableIndex
	    } else {
		DebugAddDataToArray('Process Meeting Info', 'ERROR', 'No more space in data array!')
		DebugSendArrayToConsole('Process Meeting Info')
		return 0
	    }
	} else {
	    rooms[roomIndex].todaysMeetings[meetingIndex] = meeting
	    return meetingIndex
	}
    } else {
	DebugAddDataToArray('Process Meeting Info', 'ERROR', 'roomIndex == 0')
	DebugSendArrayToConsole('Process Meeting Info')
	return 0
    }
}

DEFINE_FUNCTION INTEGER FindMeetingIndexByID(INTEGER roomID, LONG meetingID) {
    STACK_VAR INTEGER n
    STACK_VAR INTEGER result
    STACK_VAR INTEGER roomIndex

    result = 0

    roomIndex = FindRoomIndexByID(roomID)

    if(roomIndex) {
	for(n = 1; n <= MAX_LENGTH_ARRAY(rooms[roomIndex].todaysMeetings); n ++) {
	    if(rooms[roomIndex].todaysMeetings[n].id = meetingID && meetingID) {
		result = n
		break
	    }
	}
    }

    return result
}

DEFINE_FUNCTION INTEGER AddRoomData(_ROOM room) {
    STACK_VAR INTEGER n
    STACK_VAR INTEGER nextAvailableIndex
    STACK_VAR INTEGER existingIndex

    nextAvailableIndex = 0
    existingIndex = 0

    DebugAddDataToArray('Process Room Info', 'room.id', ItoA(room.id))
    DebugAddDataToArray('Process Room Info', 'room.name', room.name)
    DebugAddDataToArray('Process Room Info', 'room.shortName', room.shortName)
    DebugAddDataToArray('Process Room Info', 'room.floor', ItoA(room.floor))

    for(n = 1; n <= MAX_LENGTH_ARRAY(rooms); n ++) {
	if(!rooms[n].id) {
	    nextAvailableIndex = n
	    break
	}
    }

    for(n = 1; n <= MAX_LENGTH_ARRAY(rooms); n ++) {
	if(rooms[n].id == room.id) {
	    existingIndex = n
	    break
	}
    }

    if(existingIndex) {
	DebugAddDataToArray('Process Room Info', 'Existing Room?', 'YES')
	DebugSendArrayToConsole('Process Room Info')
	rooms[existingIndex] = room
	return existingIndex
    } else if(nextAvailableIndex) {
	DebugAddDataToArray('Process Room Info', 'Existing Room?', 'NO')
	DebugSendArrayToConsole('Process Room Info')
	rooms[nextAvailableIndex] = room
	RequestTodaysMeetings(room.id)
	return nextAvailableIndex
    } else {
	DebugAddDataToArray('Process Room Info', 'ERROR', 'No more space in data array!')
	DebugSendArrayToConsole('Process Room Info')
	return 0
    }
}

DEFINE_FUNCTION INTEGER FindRoomIndexByID(INTEGER roomID) {
    STACK_VAR INTEGER n
    STACK_VAR INTEGER result

    result = 0

    for(n = 1; n <= MAX_LENGTH_ARRAY(rooms); n ++) {
	if(rooms[n].id = roomID && roomID) {
	    result = n
	    break
	}
    }

    return result
}

DEFINE_FUNCTION INTEGER FindRoomIDforMeetingID(LONG meetingID) {
    STACK_VAR INTEGER a
    STACK_VAR INTEGER b
    STACK_VAR INTEGER result

    result = 0

    for(a = 1; a <= MAX_LENGTH_ARRAY(rooms); a ++) {
	for(b = 1; b <= MAX_LENGTH_ARRAY(rooms[a].todaysMeetings); b ++) {
	    if(rooms[a].todaysMeetings[b].id = meetingID) {
		result = rooms[a].id
		break
	    }
	}

	if(result) {
	    break
	}
    }

    return result
}

DEFINE_FUNCTION INTEGER AddUserData(_USER user) {
    STACK_VAR INTEGER n
    STACK_VAR INTEGER nextAvailableIndex
    STACK_VAR INTEGER existingIndex

    nextAvailableIndex = 0
    existingIndex = 0

    for(n = 1; n <= MAX_LENGTH_ARRAY(users); n ++) {
	if(!users[n].id) {
	    nextAvailableIndex = n
	    break
	}
    }

    for(n = 1; n <= MAX_LENGTH_ARRAY(users); n ++) {
	if(users[n].id == user.id) {
	    existingIndex = n
	    break
	}
    }

    if(existingIndex) {
	users[existingIndex] = user
	return existingIndex
    } else if(nextAvailableIndex) {
	users[nextAvailableIndex] = user
	return nextAvailableIndex
    } else {
	return 0
    }
}

DEFINE_FUNCTION INTEGER AddMeetingStateData(_STATE state, INTEGER stateIndex) {
    STACK_VAR INTEGER n
    STACK_VAR INTEGER nextAvailableIndex
    STACK_VAR INTEGER existingIndex

    nextAvailableIndex = 0
    existingIndex = 0

    if(!stateIndex) {
	for(n = 1; n <= MAX_LENGTH_ARRAY(states); n ++) {
	    if(!states[n].id) {
		nextAvailableIndex = n
		break
	    }
	}

	for(n = 1; n <= MAX_LENGTH_ARRAY(states); n ++) {
	    if(states[n].id == state.id) {
		existingIndex = n
		break
	    }
	}

	if(existingIndex) {
	    states[existingIndex] = state
	    return existingIndex
	} else if(nextAvailableIndex) {
	    states[nextAvailableIndex] = state
	    return nextAvailableIndex
	} else {
	    return 0
	}
    } else {
	states[stateIndex] = state
	return stateIndex
    }
}

DEFINE_FUNCTION INTEGER AddMeetingTypeData(_MEETING_TYPE meetingType, INTEGER typeIndex) {
    STACK_VAR INTEGER n
    STACK_VAR INTEGER nextAvailableIndex
    STACK_VAR INTEGER existingIndex

    nextAvailableIndex = 0
    existingIndex = 0

    if(!typeIndex) {
	for(n = 1; n <= MAX_LENGTH_ARRAY(meetingTypes); n ++) {
	    if(!meetingTypes[n].id) {
		nextAvailableIndex = n
		break
	    }
	}

	for(n = 1; n <= MAX_LENGTH_ARRAY(meetingTypes); n ++) {
	    if(meetingTypes[n].id == meetingType.id) {
		existingIndex = n
		break
	    }
	}

	if(existingIndex) {
	    meetingTypes[existingIndex] = meetingType
	    return existingIndex
	} else if(nextAvailableIndex) {
	    meetingTypes[nextAvailableIndex] = meetingType
	    return nextAvailableIndex
	} else {
	    return 0
	}
    } else {
	meetingTypes[typeIndex] = meetingType
	return typeIndex
    }
}

DEFINE_FUNCTION INTEGER FindUserIndexByID(INTEGER userID) {
    STACK_VAR INTEGER n
    STACK_VAR INTEGER result

    result = 0

    for(n = 1; n <= MAX_LENGTH_ARRAY(users); n ++) {
	if(users[n].id = userID && userID) {
	    result = n
	    break
	}
    }

    return result
}

DEFINE_FUNCTION RemovePreviousDaysMeetings(INTEGER roomID) {
    STACK_VAR INTEGER roomIndex
    STACK_VAR _TIME t
    STACK_VAR CHAR timeStamp[TIME_STAMP_LENGTH]

    TimeCreate(t)
    timeStamp = TimeAsTimeStamp(t)

    roomIndex = FindRoomIndexByID(roomID)

    if(roomIndex) {

    }
}

DEFINE_FUNCTION RequestTodaysMeetings(INTEGER roomID) {
    STACK_VAR INTEGER n
    STACK_VAR INTEGER roomIndex
    STACK_VAR _TIME tStart
    STACK_VAR _TIME tEnd

    roomIndex = FindRoomIndexByID(roomID)
    
    if(!GetNumberOfMeetingsForRoom(roomID)) {
	UpdateAnyUIForRoomID(roomID)
    }
    
    if(roomIndex) {
	for(n = 1; n <= MAX_LENGTH_ARRAY(rooms[roomIndex].todaysMeetings); n ++) {
	    InitTypeMeeting(rooms[roomIndex].todaysMeetings[n])
	}
	rooms[roomIndex].numberOfMeetings = 0
    }

    TimeCreate(tStart) // creates current time as struct

    tStart.hours = 0
    tStart.minutes = 0
    tStart.seconds = 0

    tEnd = tStart
    tEnd.hours = 23
    tEnd.minutes = 59

    DC_GetBookings(roomID, 'GMT Standard Time', TimeAsTimeStamp(tStart), TimeAsTimeStamp(tEnd))
}

DEFINE_FUNCTION INTEGER SetNumberOfMeetingsForRoom(INTEGER roomID, INTEGER numberOfMeetings) {
    STACK_VAR INTEGER n
    STACK_VAR INTEGER roomIndex
    
    roomIndex = FindRoomIndexByID(roomID)
    
    if(roomIndex) {
	rooms[roomIndex].numberOfMeetings = numberOfMeetings
	return TRUE
    } else {
	return FALSE
    }
}

DEFINE_FUNCTION INTEGER GetNumberOfMeetingsForRoom(INTEGER roomID) {
    STACK_VAR INTEGER n
    STACK_VAR INTEGER roomIndex
    STACK_VAR INTEGER result
    
    roomIndex = FindRoomIndexByID(roomID)
    result = 0
    
    if(roomIndex) {
	result = rooms[roomIndex].numberOfMeetings
    } else {
	result = 0
    }
    
    return result
}

DEFINE_FUNCTION INTEGER GetNumberOfMeetingsForTodayInRoom(INTEGER roomID) {
    STACK_VAR INTEGER n
    STACK_VAR INTEGER roomIndex
    STACK_VAR INTEGER result

    result = 0
    roomIndex = FindRoomIndexByID(roomID)

    if(roomIndex) {
	for(n = 1; n <= MAX_LENGTH_ARRAY(rooms[roomIndex].todaysMeetings); n ++) {
	    if(rooms[roomIndex].todaysMeetings[n].id) {
		result ++
	    }
	}
    }

    return result
}

DEFINE_FUNCTION LONG FindCurrentMeetingIDForRoom(INTEGER roomID) {
    STACK_VAR INTEGER n
    STACK_VAR INTEGER roomIndex
    STACK_VAR LONG result

    result = 0
    roomIndex = FindRoomIndexByID(roomID)

    if(roomIndex) {
	for(n = 1; n <= MAX_LENGTH_ARRAY(rooms[roomIndex].todaysMeetings); n ++) {
	    if(rooms[roomIndex].todaysMeetings[n].id) {
		if(TimeCurrentIsBetweenTimes(rooms[roomIndex].todaysMeetings[n].startTime, rooms[roomIndex].todaysMeetings[n].endTime)) {
		    if(rooms[roomIndex].todaysMeetings[n].hipType == HIP_TYPE_MAIN) {
			result = rooms[roomIndex].todaysMeetings[n].id
			break
		    } else {
			result = rooms[roomIndex].todaysMeetings[n].hipID
			break
		    }
		}
	    }
	}
    }

    return result
}

DEFINE_FUNCTION LONG FindAsscociatedSetupMeeting(INTEGER roomID, LONG hipID, INTEGER hipType) {
    STACK_VAR INTEGER roomIndex
    STACK_VAR LONG result
    STACK_VAR INTEGER n

    result = 0

    roomIndex = FindRoomIndexByID(roomID)

    if(roomIndex) {
	for(n = 1; n <= MAX_LENGTH_ARRAY(rooms[roomIndex].todaysMeetings); n ++) {
	    if(rooms[roomIndex].todaysMeetings[n].hipID == hipID && rooms[roomIndex].todaysMeetings[n].hipType == hipType) {
		result = rooms[roomIndex].todaysMeetings[n].id
		break
	    }
	}
    }

    return result
}

DEFINE_FUNCTION LONG FindNextMeetingIDForRoom(INTEGER roomID) {
    STACK_VAR INTEGER n
    STACK_VAR INTEGER roomIndex
    STACK_VAR LONG hipID
    STACK_VAR LONG result
    STACK_VAR _TIME t1
    STACK_VAR _TIME t2

    result = 0
    roomIndex = FindRoomIndexByID(roomID)
    hipID = FindCurrentMeetingIDForRoom(roomID)

    if(roomIndex) {
	for(n = 1; n <= MAX_LENGTH_ARRAY(rooms[roomIndex].todaysMeetings); n ++) {
	    if(rooms[roomIndex].todaysMeetings[n].id) {
		if(TimeIsAfterCurrentTime(rooms[roomIndex].todaysMeetings[n].startTime)) {
		    if(rooms[roomIndex].todaysMeetings[n].hipType == HIP_TYPE_MAIN && rooms[roomIndex].todaysMeetings[n].hipID <> hipID) {
			result = rooms[roomIndex].todaysMeetings[n].id
			break
		    }
		}
	    }
	}
    }

    return result
}

DEFINE_FUNCTION LONG FindNextMeetingIDForRoomSkippingMeetingID(INTEGER roomID, LONG meetingID) {
    STACK_VAR INTEGER n
    STACK_VAR INTEGER roomIndex
    STACK_VAR LONG hipID
    STACK_VAR LONG result
    STACK_VAR _TIME t1
    STACK_VAR _TIME t2

    result = 0
    roomIndex = FindRoomIndexByID(roomID)
    hipID = FindCurrentMeetingIDForRoom(roomID)

    if(roomIndex) {
	for(n = 1; n <= MAX_LENGTH_ARRAY(rooms[roomIndex].todaysMeetings); n ++) {
	    if(rooms[roomIndex].todaysMeetings[n].id) {
		if(TimeIsAfterCurrentTime(rooms[roomIndex].todaysMeetings[n].startTime) && rooms[roomIndex].todaysMeetings[n].id <> meetingID && meetingID) {
		    if(rooms[roomIndex].todaysMeetings[n].hipType == HIP_TYPE_MAIN && rooms[roomIndex].todaysMeetings[n].hipID <> hipID) {
			result = rooms[roomIndex].todaysMeetings[n].id
			break
		    }
		}
	    }
	}
    }

    return result
}

DEFINE_FUNCTION CHAR[15] FormatTimeString(_TIME t1, _TIME t2) {
    STACK_VAR CHAR result[15]

    result = "FORMAT('%02d', t1.hours), FORMAT(':%02d to ', t1.minutes), FORMAT('%02d', t2.hours), FORMAT(':%02d', t2.minutes)"

    return result
}

DEFINE_FUNCTION RefreshAll() {
    STACK_VAR INTEGER n
    STACK_VAR CHAR uiDeviceKey[UI_KEY_MAX_LENGTH]
    STACK_VAR INTEGER roomID
    STACK_VAR INTEGER previousRoomID

    roomID = 0
    previousRoomID = 0
    InitAllRoomData()

    for(n = 1; n <= MAX_LENGTH_ARRAY(uiDevice); n ++) {
	uiDeviceKey = UIGetKeyForDevice(uiDevice[n])
	roomID = AtoI(UIGetVarValue(uiDeviceKey, UI_VAR_ROOM_ID))
	if(previousRoomID <> roomID && roomID) {
	    DC_GetRoomDetails(roomID)
	    previousRoomID = roomID
	}
    }
}

DEFINE_FUNCTION RefreshRoom(INTEGER roomID) {
    STACK_VAR INTEGER roomIndex

    roomIndex = FindRoomIndexByID(roomID)

    if(roomIndex) {
	InitTypeRoom(rooms[roomIndex])
    }

    DC_GetRoomDetails(roomID)
}

DEFINE_FUNCTION UpdateMeetingsForRegisteredRooms() {
    STACK_VAR INTEGER n
    STACK_VAR INTEGER lastRoomID
    
    for(n = 1; n <= MAX_LENGTH_ARRAY(rooms); n ++) {
	if(rooms[n].id) {
	    RequestTodaysMeetings(rooms[n].id)
	}
    }
}

DEFINE_FUNCTION SetUIEmployeeCode(CHAR uiDeviceKey[], CHAR code[]) {
    UISetVarValue(uiDeviceKey, UI_VAR_EMPLOYEE_CODE_ENTRY, "code, '_'")
    UIText(uiDeviceKey, UI_JOIN_KEYBOARD_DISPLAY, UI_STATE_ALL, code)
}

DEFINE_FUNCTION ResetUIEmployeeCode(CHAR uiDeviceKey[]) {
    STACK_VAR LONG timeLineID
    STACK_VAR LONG timeLineRepeatTime[1]

    timeLineID = 5000 + UIGetDeviceIndexFromKey(uiDeviceKey)
    timeLineRepeatTime[1] = 500

    if(TIMELINE_ACTIVE(timeLineID)) {
	TIMELINE_KILL(timeLineID)
    } else {
	TIMELINE_CREATE(timeLineID, timeLineRepeatTime, 1, TIMELINE_ABSOLUTE, TIMELINE_REPEAT)
    }

    UISetVarValue(uiDeviceKey, UI_VAR_EMPLOYEE_CODE_ENTRY, '')
    UIText(uiDeviceKey, UI_JOIN_KEYBOARD_DISPLAY, UI_STATE_ALL, '')
    UISetVarValue(uiDeviceKey, UI_VAR_EMPLOYEE_CODE_ENTRY_IN_PROGRESS, '1')
}

DEFINE_FUNCTION FormatUIEmployeeCodeCursor(CHAR uiDeviceKey[]) {
    STACK_VAR CHAR temp[50]

    temp = UIGetVarValue(uiDeviceKey, UI_VAR_EMPLOYEE_CODE_ENTRY)

    if(RIGHT_STRING(temp, 1) == '_') {
	UISetVarValue(uiDeviceKey, UI_VAR_EMPLOYEE_CODE_ENTRY, LEFT_STRING(temp, LENGTH_STRING(temp) - 1))
    } else {
	UISetVarValue(uiDeviceKey, UI_VAR_EMPLOYEE_CODE_ENTRY, "temp, '_'")
    }

    UIText(uiDeviceKey, UI_JOIN_KEYBOARD_DISPLAY, UI_STATE_ALL, UIGetVarValue(uiDeviceKey, UI_VAR_EMPLOYEE_CODE_ENTRY))
}

DEFINE_FUNCTION CHAR[NAME_MAX_LENGTH] SwapNameFormatting(CHAR name[]) {
    STACK_VAR CHAR temp[NAME_MAX_LENGTH]
    STACK_VAR INTEGER m1

    if(FIND_STRING(name, ', ', 1)) {
	m1 = FIND_STRING(name, ', ', 1)


	temp = "MID_STRING(name, m1 + 2, LENGTH_STRING(temp) - m1 - 2)"
	temp = "temp, $20, MID_STRING(name, 1, m1 - 1)"
	name = temp

	return temp
    } else {
	return name
    }
}

DEFINE_FUNCTION CHAR[UI_KEY_MAX_LENGTH] FindUIDeviceKeyForCurrentLoginAttempt() {
    STACK_VAR INTEGER n
    STACK_VAR CHAR uiDeviceKey[UI_KEY_MAX_LENGTH]
    STACK_VAR CHAR result[UI_KEY_MAX_LENGTH]

    result = ''

    for(n = 1; n <= MAX_LENGTH_ARRAY(uiDevice); n ++) {
	uiDeviceKey = UIGetKeyForDevice(uiDevice[n])
	if(AtoI(UIGetVarValue(uiDeviceKey, UI_VAR_LOGIN_IN_PROGRESS))) {
	    result = uiDeviceKey
	    break
	}
    }

    return result
}

DEFINE_FUNCTION CHAR[UI_KEY_MAX_LENGTH] FindUIDeviceKeyForCurrentBookingAttempt() {
    STACK_VAR INTEGER n
    STACK_VAR CHAR uiDeviceKey[UI_KEY_MAX_LENGTH]
    STACK_VAR CHAR result[UI_KEY_MAX_LENGTH]

    result = ''

    for(n = 1; n <= MAX_LENGTH_ARRAY(uiDevice); n ++) {
	uiDeviceKey = UIGetKeyForDevice(uiDevice[n])
	if(AtoI(UIGetVarValue(uiDeviceKey, UI_VAR_BOOKING_IN_PROGRESS))) {
	    result = uiDeviceKey
	    break
	}
    }

    return result
}

DEFINE_EVENT

TIMELINE_EVENT[5001]
TIMELINE_EVENT[5002]
TIMELINE_EVENT[5003]
TIMELINE_EVENT[5004]
TIMELINE_EVENT[5005]
TIMELINE_EVENT[5006]
TIMELINE_EVENT[5007]
TIMELINE_EVENT[5008]
TIMELINE_EVENT[5009]
TIMELINE_EVENT[5010]
TIMELINE_EVENT[5011]
TIMELINE_EVENT[5012]
TIMELINE_EVENT[5013]
TIMELINE_EVENT[5014]
TIMELINE_EVENT[5015]
TIMELINE_EVENT[5016]
TIMELINE_EVENT[5017]
TIMELINE_EVENT[5018]
TIMELINE_EVENT[5019]
TIMELINE_EVENT[5020]
TIMELINE_EVENT[5021]
TIMELINE_EVENT[5022]
TIMELINE_EVENT[5023]
TIMELINE_EVENT[5024]
TIMELINE_EVENT[5025]
TIMELINE_EVENT[5026]
TIMELINE_EVENT[5027]
TIMELINE_EVENT[5028]
TIMELINE_EVENT[5029]
TIMELINE_EVENT[5030] {
    STACK_VAR INTEGER uiDeviceIndex
    STACK_VAR CHAR uiDeviceKey[UI_KEY_MAX_LENGTH]

    uiDeviceIndex = timeline.id - 5000

    uiDeviceKey = UIGetKeyForIndex(uiDeviceIndex)

    if(!AtoI(UIGetVarValue(uiDeviceKey, UI_VAR_EMPLOYEE_CODE_ENTRY_IN_PROGRESS))) {
	TIMELINE_KILL(timeline.id)
    } else {
	FormatUIEmployeeCodeCursor(uiDeviceKey)
    }
}

