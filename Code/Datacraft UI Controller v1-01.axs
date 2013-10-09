MODULE_NAME='Datacraft UI Controller v1-01' ( DEV duetDevice, DEV controllerDevice, DEV uiDevice[] )
(***********************************************************)
(*  FILE CREATED ON: 08/16/2012  AT: 10:47:53              *)
(***********************************************************)
(***********************************************************)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 06/05/2013  AT: 15:29:13        *)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
    $History: $
*)

#DEFINE DEBUG TRUE

DEFINE_CONSTANT

UI_MAX_DEVICES = 30

//Meeting State Constants - Edit if these are different
M_STATE_PROVISIONAL		= 1
M_STATE_CONFIRMED		= 10
M_STATE_IN_PROGRESS		= 9
M_STATE_ENDED			= 11

//Meeting Type for use with Ad Hoc bookings from the UI
AD_HOC_MEETING_TYPE		= 20

//Set for API User key for permissions
EXTEND_MEETING_USER_KEY		= 2

#INCLUDE 'Core Library'
#INCLUDE 'UI Kit API'
#INCLUDE 'Datacraft UI Controller Constansts v1-01'
#INCLUDE 'DatacraftTouchPanelAPI'
#INCLUDE 'Datacraft UI Functions v1-01'

DEFINE_VARIABLE

CHAR serverAddress[255]

(***********************************************************)
(*                   UI KIT FUNCTIONS                      *)
(***********************************************************)

DEFINE_FUNCTION UserInterfacesShouldRegister() {
    STACK_VAR INTEGER n

    for(n = 1; n <= LENGTH_ARRAY(uiDevice); n ++) {
	UIRegisterDevice("'TP', ItoA(n)", "'Room Booking Panel ', ItoA(n)", UI_DEVICES_ALL, uiDevice[n])
    }
}

DEFINE_FUNCTION UserInterfaceVarsShouldRegister() {
    UIVarRegisterWithFileStorage(UI_DEVICES_ALL, UI_VAR_ROOM_ID, '0')
    UIVarRegisterWithFileStorage(UI_DEVICES_ALL, UI_VAR_ROOM_COLLECTION_ID, '0')
    UIVarRegister(UI_DEVICES_ALL, UI_VAR_EMPLOYEE_CODE_ENTRY, '03')
    UIVarRegister(UI_DEVICES_ALL, UI_VAR_BOOKING_SELECTED_TIME, '')
    UIVarRegister(UI_DEVICES_ALL, UI_VAR_BOOKING_IN_PROGRESS, '0')
    UIVarRegisterWithFileStorage(UI_DEVICES_ALL, UI_VAR_ADHOC_BOOKING_ENABLED, '0')
    UIVarRegister(UI_DEVICES_ALL, UI_VAR_LOGIN_IN_PROGRESS, '0')
    UIVarRegisterWithFileStorage(UI_DEVICES_ALL, UI_VAR_END_MEETING_ENABLE, '0')
    UIVarRegister(UI_DEVICES_ALL, UI_VAR_EMPLOYEE_CODE_ENTRY_IN_PROGRESS, '0')
    UIVarRegister(UI_DEVICES_ALL, UI_VAR_HOME_PAGE_MODE, ItoA(UI_PAGE_INDEX_HOME_ERROR))
    UIVarRegister(UI_DEVICES_ALL, UI_VAR_USER_IS_BOOKING_A_MEETNG, '0')
    UIVarRegister(UI_DEVICES_ALL, UI_VAR_KEYBOARD_EDIT_MODE, '0')
}

DEFINE_FUNCTION UserInterfaceHasRegistered(CHAR uiDeviceKey[]) {
    LoadUIData(uiDeviceKey)
}

// END UI KIT

DEFINE_FUNCTION SaveUIData(CHAR uiDeviceKey[]) {
    STACK_VAR CHAR fileName[50]
    
    fileName = "'room_booking_ui_config_', uiDeviceKey, '.xml'"
    
    UISaveCurrentVarsToXML(uiDeviceKey, fileName)
}

DEFINE_FUNCTION LoadUIData(CHAR uiDeviceKey[]) {
    STACK_VAR CHAR fileName[50]
    
    fileName = "'room_booking_ui_config_', uiDeviceKey, '.xml'"
    
    UILoadCurrentVarsFromXML(uiDeviceKey, fileName)
}

DEFINE_FUNCTION UINavShowSetup(CHAR uiDeviceKey[]) {
    STACK_VAR INTEGER roomID
    STACK_VAR INTEGER roomIndex
    
    roomID = AtoI(UIGetVarValue(uiDeviceKey, UI_VAR_ROOM_ID))
    roomIndex = FindRoomIndexByID(roomID)
    
    UIText(uiDeviceKey, UI_JOIN_SETUP_ROOM_NAME, UI_STATE_ALL, "'Room Name:  ', rooms[roomIndex].name")
    UIText(uiDeviceKey, UI_JOIN_SETUP_ROOM_ID, UI_STATE_ALL, "'Room ID:  ', ItoA(roomID)")
    UIText(uiDeviceKey, UI_JOIN_SETUP_COLLECTION_ID, UI_STATE_ALL, "'Collection ID:  ', UIGetVarValue(uiDeviceKey, UI_VAR_ROOM_COLLECTION_ID)")
    UIText(uiDeviceKey, UI_JOIN_SETUP_SERVER_ADDRESS, UI_STATE_ALL, serverAddress)
    UIPage(uiDeviceKey, uiPageName_RoomBooking[UI_PAGE_INDEX_SETUP])
}

DEFINE_FUNCTION UINavShowMainMenu(CHAR uiDeviceKey[]) {
    //RoomBookingUISendRoomName(uiDeviceKey)
    UISetVarValue(uiDeviceKey, UI_VAR_USER_IS_BOOKING_A_MEETNG, '0')
    UIPageWithAnimation(uiDeviceKey, uiPageName_RoomBooking[AtoI(UIGetVarValue(uiDeviceKey, UI_VAR_HOME_PAGE_MODE))], ANIMATE_TYPE_SLIDE, ANIMATE_ORIGIN_LEFT, 5)
    UIPopupsClear(uiDeviceKey)
}

DEFINE_FUNCTION UINavShowListOfTimes(CHAR uiDeviceKey[]) {
    UISetVarValue(uiDeviceKey, UI_VAR_USER_IS_BOOKING_A_MEETNG, '1')
    UIPageWithTimeOutToPage(uiDeviceKey, uiPageName_RoomBooking[UI_PAGE_INDEX_SELECT_TIME], 30, uiPageName_RoomBooking[AtoI(UIGetVarValue(uiDeviceKey, UI_VAR_HOME_PAGE_MODE))])
}

DEFINE_FUNCTION UINavShowMoreListOfTimes(CHAR uiDeviceKey[]) {
    UIPageWithTimeOutToPage(uiDeviceKey, uiPageName_RoomBooking[UI_PAGE_INDEX_SELECT_TIME_MORE], 30, uiPageName_RoomBooking[AtoI(UIGetVarValue(uiDeviceKey, UI_VAR_HOME_PAGE_MODE))])
}

DEFINE_FUNCTION UINavShowEmployeeCodeEntry(CHAR uiDeviceKey[]) {
    UIPageWithTimeOutToPage(uiDeviceKey, uiPageName_RoomBooking[UI_PAGE_INDEX_ENTER_CODE], 30, uiPageName_RoomBooking[AtoI(UIGetVarValue(uiDeviceKey, UI_VAR_HOME_PAGE_MODE))])
}

DEFINE_FUNCTION UISetModeInUse(CHAR uiDeviceKey[]) {
    UISetVarValue(uiDeviceKey, UI_VAR_HOME_PAGE_MODE, ItoA(UI_PAGE_INDEX_HOME_IN_USE))
    if(UIGetCurrentPageName(uiDeviceKey) == uiPageName_RoomBooking[UI_PAGE_INDEX_HOME_AVAILABLE] OR UIGetCurrentPageName(uiDeviceKey) == uiPageName_RoomBooking[UI_PAGE_INDEX_HOME_IN_USE OR UIGetCurrentPageName(uiDeviceKey) == uiPageName_RoomBooking[UI_PAGE_INDEX_HOME_ERROR] ]) {
	UINavShowMainMenu(uiDeviceKey)
    } else if(!AtoI(UIGetVarValue(uiDeviceKey, UI_VAR_USER_IS_BOOKING_A_MEETNG))) {
	UINavShowMainMenu(uiDeviceKey)
    }
}

DEFINE_FUNCTION UISetModeAvailable(CHAR uiDeviceKey[]) {
    UISetVarValue(uiDeviceKey, UI_VAR_HOME_PAGE_MODE, ItoA(UI_PAGE_INDEX_HOME_AVAILABLE))
    if(UIGetCurrentPageName(uiDeviceKey) == uiPageName_RoomBooking[UI_PAGE_INDEX_HOME_AVAILABLE] OR UIGetCurrentPageName(uiDeviceKey) == uiPageName_RoomBooking[UI_PAGE_INDEX_HOME_IN_USE OR UIGetCurrentPageName(uiDeviceKey) == uiPageName_RoomBooking[UI_PAGE_INDEX_HOME_ERROR] ]) {
	UINavShowMainMenu(uiDeviceKey)
    } else if(!AtoI(UIGetVarValue(uiDeviceKey, UI_VAR_USER_IS_BOOKING_A_MEETNG))) {
	UINavShowMainMenu(uiDeviceKey)
    }
}


DEFINE_FUNCTION UpdateUIRoomNameText(CHAR uiDeviceKey[], INTEGER uiJoin, CHAR name[]) {
    STACK_VAR INTEGER nameLength

    nameLength = LENGTH_STRING(name)
    
    // Code for changing the font according to size if you need it.
    // Use the font ID as per the panel documentation or from TPDesign
    
    /*if(nameLength <= 14) {
	UIFont(uiDeviceKey, uiJoin, UI_STATE_ALL, 34)
	UITextAlignAbsolute(uiDeviceKey, uiJoin, UI_STATE_ALL, 0, 8)
    } else if(nameLength <= 16) {
	UIFont(uiDeviceKey, uiJoin, UI_STATE_ALL, 37)
	UITextAlignAbsolute(uiDeviceKey, uiJoin, UI_STATE_ALL, 0, 15)
    } else if(nameLength <= 18) {
	UIFont(uiDeviceKey, uiJoin, UI_STATE_ALL, 48)
	UITextAlignAbsolute(uiDeviceKey, uiJoin, UI_STATE_ALL, 0, 20)
    } else if(nameLength <= 20) {
	UIFont(uiDeviceKey, uiJoin, UI_STATE_ALL, 44)
	UITextAlignAbsolute(uiDeviceKey, uiJoin, UI_STATE_ALL, 0, 25)
    } else {
	UIFont(uiDeviceKey, uiJoin, UI_STATE_ALL, 40)
	UITextAlignAbsolute(uiDeviceKey, uiJoin, UI_STATE_ALL, 0, 29)
    }
    */UIText(uiDeviceKey, uiJoin, UI_STATE_ALL, UPPER_STRING(name))
}


DEFINE_FUNCTION UpdateUIStartMeetingButtonState(CHAR uiDeviceKey[], INTEGER state) {
    STACK_VAR _UI_COLOUR colour

    if(state == M_STATE_CONFIRMED) {
	UIText(uiDeviceKey, UI_JOIN_START_MEETING, UI_STATE_ALL, 'START MEETING')
	colour.red = $FF
	colour.green = $FF
	colour.blue = $FF
	UITextColour(uiDeviceKey, UI_JOIN_START_MEETING, UI_STATE_ALL, colour)
	UIBorderColour(uiDeviceKey, UI_JOIN_START_MEETING, UI_STATE_ALL, colour)
	UIButtonShow(uiDeviceKey, UI_JOIN_START_MEETING)
    } else if(state == M_STATE_IN_PROGRESS && AtoI(UIGetVarValue(uiDeviceKey, UI_VAR_END_MEETING_ENABLE))) {
	UIText(uiDeviceKey, UI_JOIN_START_MEETING, UI_STATE_ALL, "'MEETING IN PROGRESS', $0A, 'END MEETING'")
	colour.red = $FF
	colour.green = $FF
	colour.blue = $FF
	UITextColour(uiDeviceKey, UI_JOIN_START_MEETING, UI_STATE_ALL, colour)
	UIBorderColour(uiDeviceKey, UI_JOIN_START_MEETING, UI_STATE_ALL, colour)
	UIButtonShow(uiDeviceKey, UI_JOIN_START_MEETING)
    } else if(state == M_STATE_IN_PROGRESS) {
	UIText(uiDeviceKey, UI_JOIN_START_MEETING, UI_STATE_ALL, 'MEETING IN PROGRESS')
	colour.red = $CC
	colour.green = $CC
	colour.blue = $CC
	UITextColour(uiDeviceKey, UI_JOIN_START_MEETING, UI_STATE_ALL, colour)
	colour.red = $AA
	colour.green = $AA
	colour.blue = $AA
	UIBorderColour(uiDeviceKey, UI_JOIN_START_MEETING, UI_STATE_ALL, colour)
	UIButtonShow(uiDeviceKey, UI_JOIN_START_MEETING)
    } else if(state == M_STATE_ENDED) {
	UIText(uiDeviceKey, UI_JOIN_START_MEETING, UI_STATE_ALL, 'MEETING HAS ENDED')
	colour.red = $CC
	colour.green = $CC
	colour.blue = $CC
	UITextColour(uiDeviceKey, UI_JOIN_START_MEETING, UI_STATE_ALL, colour)
	colour.red = $AA
	colour.green = $AA
	colour.blue = $AA
	UIBorderColour(uiDeviceKey, UI_JOIN_START_MEETING, UI_STATE_ALL, colour)
	UIButtonShow(uiDeviceKey, UI_JOIN_START_MEETING)
    } else {
	UIButtonHide(uiDeviceKey, UI_JOIN_START_MEETING)
    }
}

DEFINE_FUNCTION UpdateUIwithRoomID(CHAR uiDeviceKey[], INTEGER roomID) {
    STACK_VAR INTEGER roomIndex
    STACK_VAR LONG meetingID
    STACK_VAR INTEGER meetingIndex
    STACK_VAR CHAR timeString[15]
    STACK_VAR INTEGER uiDeviceIndex
    STACK_VAR INTEGER currentMeetingExists
    
    currentMeetingExists = 0
    uiDeviceIndex = UIGetDeviceIndexFromKey(uiDeviceKey)
    roomIndex = FindRoomIndexByID(roomID)
    if(roomIndex) {
	meetingID = FindCurrentMeetingIDForRoom(roomID)
	UpdateUIRoomNameText(uiDeviceKey, UI_JOIN_ROOM_NAME, rooms[roomIndex].name)
	if(!meetingID && NumberOfMinutesUntilNextMeeting(roomID) <= 5) {
	    meetingID = FindNextMeetingIDForRoom(roomID)
	}
	if(meetingID) {
	    currentMeetingExists = TRUE
	    meetingIndex = FindMeetingIndexByID(roomID, meetingID)
	    UIText(uiDeviceKey, UI_JOIN_CURRENT_MEETING_OWNER, UI_STATE_ALL, SwapNameFormatting(rooms[roomIndex].todaysMeetings[meetingIndex].ownerName))
	    UIText(uiDeviceKey, UI_JOIN_CURRENT_MEETING_TITLE, UI_STATE_ALL, rooms[roomIndex].todaysMeetings[meetingIndex].title)
	    UIText(uiDeviceKey, UI_JOIN_CURRENT_MEETING_TIMES, UI_STATE_ALL, FormatTimeString(rooms[roomIndex].todaysMeetings[meetingIndex].startTime, rooms[roomIndex].todaysMeetings[meetingIndex].endTime))
	    UpdateUIStartMeetingButtonState(uiDeviceKey, rooms[roomIndex].todaysMeetings[meetingIndex].state)
	    if(AtoI(UIGetVarValue(uiDeviceKey, UI_VAR_BOOKING_IN_PROGRESS))) {
		UISetVarValue(uiDeviceKey, UI_VAR_BOOKING_IN_PROGRESS, '0')
	    }
	    UISetModeInUse(uiDeviceKey)
	    if(rooms[roomIndex].todaysMeetings[meetingIndex].state == M_STATE_PROVISIONAL OR rooms[roomIndex].todaysMeetings[meetingIndex].state == M_STATE_IN_PROGRESS) { // You may need to adjust these state values
		SEND_COMMAND controllerDevice, "'CURRENT_MEETING_INFO-', ItoA(rooms[roomIndex].id), ',', ItoA(meetingID), ',',
		    TimeAsTimeStamp(rooms[roomIndex].todaysMeetings[meetingIndex].startTime), ',',
		    TimeAsTimeStamp(rooms[roomIndex].todaysMeetings[meetingIndex].endTime), ',',
		    ItoA(NumberOfMinutesUntilEndOfMeeting(roomID, meetingID)), ',',
		    ItoA(rooms[roomIndex].todaysMeetings[meetingIndex].state), ',',
		    rooms[roomIndex].todaysMeetings[meetingIndex].ownerName"
	    } else {
		SEND_COMMAND controllerDevice, "'NO_CURRENT_MEETING-', ItoA(uiDeviceIndex)"
	    }
	} else if(!AtoI(UIGetVarValue(uiDeviceKey, UI_VAR_BOOKING_IN_PROGRESS))) {
	    if(AtoI(UIGetVarValue(uiDeviceKey, UI_VAR_ADHOC_BOOKING_ENABLED))) {
		UIButtonShow(uiDeviceKey, UI_JOIN_BOOK_MEETING)
	    } else {
		UIButtonHide(uiDeviceKey, UI_JOIN_BOOK_MEETING)
	    }
	    UISetModeAvailable(uiDeviceKey)
	    SEND_COMMAND controllerDevice, "'NO_CURRENT_MEETING-', ItoA(uiDeviceIndex)"
	}
	if(meetingID) {
	    meetingID = FindNextMeetingIDForRoomSkippingMeetingID(roomID, meetingID)
	} else {
	    meetingID = FindNextMeetingIDForRoom(roomID)
	}
	if(meetingID) {
	    meetingIndex = FindMeetingIndexByID(roomID, meetingID)
	    UIText(uiDeviceKey, UI_JOIN_NEXT_MEETING_OWNER, UI_STATE_ALL, SwapNameFormatting(rooms[roomIndex].todaysMeetings[meetingIndex].ownerName))
	    UIText(uiDeviceKey, UI_JOIN_NEXT_MEETING_TITLE, UI_STATE_ALL, rooms[roomIndex].todaysMeetings[meetingIndex].title)
	    UIText(uiDeviceKey, UI_JOIN_NEXT_MEETING_TIMES, UI_STATE_ALL, FormatTimeString(rooms[roomIndex].todaysMeetings[meetingIndex].startTime, rooms[roomIndex].todaysMeetings[meetingIndex].endTime))
	} else {
	    UIText(uiDeviceKey, UI_JOIN_NEXT_MEETING_OWNER, UI_STATE_ALL, 'No further meetings today')
	    UIText(uiDeviceKey, UI_JOIN_NEXT_MEETING_TITLE, UI_STATE_ALL, '')
	    if(!AtoI(UIGetVarValue(uiDeviceKey, UI_VAR_ADHOC_BOOKING_ENABLED))) {
		UIText(uiDeviceKey, UI_JOIN_NEXT_MEETING_TIMES, UI_STATE_ALL, 'Contact reception to book this room')
	    } else {
		UIText(uiDeviceKey, UI_JOIN_NEXT_MEETING_TIMES, UI_STATE_ALL, '')
	    }
	}
    }
}

DEFINE_FUNCTION UpdateUI(CHAR uiDeviceKey[]) {
    INTEGER roomID

    roomID = AtoI(UIGetVarValue(uiDeviceKey, UI_VAR_ALT_ROOM_ID))
    if(roomID) {
	if(FindCurrentMeetingIDForRoom(roomID)) {
	    UpdateUIwithRoomID(uiDeviceKey, roomID)
	} else {
	    roomID = 0
	}
    }
    if(!roomID) {
	roomID = AtoI(UIGetVarValue(uiDeviceKey, UI_VAR_ROOM_ID))
	if(roomID) {
	    UpdateUIwithRoomID(uiDeviceKey, roomID)
	}
    }
}

DEFINE_FUNCTION UpdateAnyUIForRoomID(INTEGER roomID) {
    STACK_VAR INTEGER n
    STACK_VAR CHAR uiDeviceKey[UI_KEY_MAX_LENGTH]

    for(n = 1; n <= MAX_LENGTH_ARRAY(uiDevice); n ++) {
	uiDeviceKey = UIGetKeyForDevice(uiDevice[n])
	if(AtoI(UIGetVarValue(uiDeviceKey, UI_VAR_ROOM_ID)) == roomID) {
	    UpdateUI(uiDeviceKey)
	}
    }
}




///////////////////////////////////////////////////////////// Datacraft Module Events

DEFINE_FUNCTION DCEvent_AuthenticationError(INTEGER code, CHAR description[]) {
    DebugAddDataToArray('Roombooking Auth Error', 'code', ItoA(code))
    DebugAddDataToArray('Roombooking Auth Error', 'description', description)
}

DEFINE_FUNCTION DCEvent_SessionAquired(INTEGER userid, INTEGER permission, INTEGER admin) {
    DebugAddDataToArray('Roombooking Session Aquired', 'userid', ItoA(userid))
    DebugAddDataToArray('Roombooking Session Aquired', 'permission', ItoA(permission))
    DebugAddDataToArray('Roombooking Session Aquired', 'admin', ItoA(admin))
    DebugSendArrayToConsole('Roombooking Session Aquired')
    RefreshAll()
}

DEFINE_FUNCTION DCEvent_UserLoginSuccess(CHAR username[], INTEGER userid, INTEGER permission, CHAR costcode[], INTEGER costcodeid) {
    STACK_VAR INTEGER roomID
    STACK_VAR INTEGER collectionID
    STACK_VAR CHAR uiDeviceKey[UI_KEY_MAX_LENGTH]
    STACK_VAR _TIME t
    currentUserID = userid
    uiDeviceKey = FindUIDeviceKeyForCurrentLoginAttempt()
    if(LENGTH_STRING(uiDeviceKey)) {
	roomID = AtoI(UIGetVarValue(uiDeviceKey, UI_VAR_ROOM_ID))
	collectionID = AtoI(UIGetVarValue(uiDeviceKey, UI_VAR_ROOM_COLLECTION_ID))
	UISetVarValue(uiDeviceKey, UI_VAR_LOGIN_IN_PROGRESS, '0')
	UISetVarValue(uiDeviceKey, UI_VAR_BOOKING_IN_PROGRESS, '1')
	TimeCreate(t)
	DC_AddBookingEx(roomID, 'GMT Standard Time', TimeAsTimeStamp(t), UIGetVarValue(uiDeviceKey, UI_VAR_BOOKING_SELECTED_TIME), currentUserID, collectionID, 'Ad hoc meeting', AD_HOC_MEETING_TYPE)
    }
    DebugAddDataToArray('User Login Success', 'username', username)
    DebugAddDataToArray('User Login Success', 'userid', ItoA(userid))
    DebugAddDataToArray('User Login Success', 'permission', ItoA(permission))
    DebugAddDataToArray('User Login Success', 'costcode', costcode)
    DebugAddDataToArray('User Login Success', 'costcodeid', ItoA(costcodeid))
    DebugSendArrayToConsole('User Login Success')
}

DEFINE_FUNCTION DCEvent_UserLoginFail(CHAR username[]) {
    STACK_VAR CHAR uiDeviceKey[UI_KEY_MAX_LENGTH]

    uiDeviceKey = FindUIDeviceKeyForCurrentLoginAttempt()
    if(LENGTH_STRING(uiDeviceKey)) {
	UISetVarValue(uiDeviceKey, UI_VAR_LOGIN_IN_PROGRESS, '0')
	ResetUIEmployeeCode(uiDeviceKey)
	if(UIGetCurrentPageName(uiDeviceKey) == uiPageName_RoomBooking[UI_PAGE_INDEX_ENTER_CODE]) {
	    UIPopup(uiDeviceKey, UI_POPUP_ROOM_BOOKING_ERROR, uiPageName_RoomBooking[UI_PAGE_INDEX_ENTER_CODE], 1, 50)
	}
    }
    DebugAddDataToArray('User Login Fail', 'username', username)
    DebugSendArrayToConsole('User Login Fail')
}

DEFINE_FUNCTION DCEvent_UserDetails(INTEGER userID, CHAR name[], CHAR initials[], INTEGER agentID, CHAR costcode[], INTEGER costcodeID, INTEGER siteID, CHAR department[], CHAR phoneno[], CHAR emailaddr[], CHAR room[]) {
    STACK_VAR _USER user

    InitTypeUser(user)
    user.id = userID
    user.name = name
    user.initials = initials
    user.agentID = agentID
    user.costcode = costcode
    user.costcodeID = costcodeID
    user.siteID = siteID
    AddUserData(user)
}

DEFINE_FUNCTION DCEvent_RoomDetails(INTEGER roomid, CHAR name[], CHAR longname[], CHAR floor[], INTEGER capacity, CHAR phone[], INTEGER maxchangeid, INTEGER chartinterval) {
    STACK_VAR _ROOM room

    if(FindRoomIndexByID(roomid)) {
	room = rooms[FindRoomIndexByID(roomid)]
    } else {
	InitTypeRoom(room)
    }
    room.id = roomid
    room.name = longname
    room.shortName = name
    room.floor = AtoI(floor)
    room.capacity = capacity
    room.phoneNumber = phone
    room.maxChangeID = maxchangeid
    room.chartInterval = chartinterval
    AddRoomData(room)
    UpdateAnyUIForRoomID(room.id)
}

DEFINE_FUNCTION DCEvent_DefRoomLayout(INTEGER index, INTEGER roomid, INTEGER layoutid, CHAR name[], INTEGER maxcapacity, INTEGER mincapacity) {
    
}

DEFINE_FUNCTION DCEvent_RoomBookings(INTEGER roomid, CHAR periodstartdate[], CHAR periodstarttime[], CHAR periodenddate[], CHAR periodendtime[], INTEGER count) {
    SetNumberOfMeetingsForRoom(roomID, count)
}

DEFINE_FUNCTION DCEvent_DefineRoomBooking(INTEGER index, INTEGER roomid, LONG meetingid, CHAR startdate[], CHAR starttime[], CHAR enddate[], CHAR endtime[],
CHAR title[], CHAR ownername[], CHAR ownerphone[], CHAR agentname[], CHAR agentphone[], INTEGER meetingstate, INTEGER meetingtype, INTEGER hiptype, LONG hipid) {
    STACK_VAR _MEETING meeting
    STACK_VAR _TIME t

    InitTypeMeeting(meeting)
    if(index) {
	meeting.id = meetingid
	meeting.index = index
	meeting.roomID = roomid
	meeting.ownerName = ownername
	meeting.agentName = agentname
	meeting.state = meetingstate
	meeting.title = title
	meeting.type = meetingtype
	meeting.hipType = hiptype
	meeting.hipID = hipid
	TimeCreateFromStamp("startdate, $0D, starttime", t)
	meeting.startTime = t
	TimeCreateFromStamp("enddate, $0D, endtime", t)
	meeting.endTime = t
	AddMeetingData(meeting, index)
	if(index == GetNumberOfMeetingsForRoom(roomID)) {
	    UpdateAnyUIForRoomID(roomID)
	}
    }
}

DEFINE_FUNCTION DCEvent_MeetingState(LONG meetingid, INTEGER state, CHAR statename[]) {
    STACK_VAR INTEGER roomID
    STACK_VAR INTEGER roomIndex
    STACK_VAR INTEGER meetingIndex

    roomID = FindRoomIDforMeetingID(meetingid)
    if(roomID) {
	roomIndex = FindRoomIndexByID(roomID)
	meetingIndex = FindMeetingIndexByID(roomID, meetingID)
	rooms[roomIndex].todaysMeetings[meetingIndex].state = state
	UpdateAnyUIForRoomID(roomID)
    }
}

DEFINE_FUNCTION DCEvent_MeetingExtended(LONG meetingid, INTEGER state) {
    STACK_VAR INTEGER roomID

    DebugAddDataToArray('Meeting Extended Result', 'meetingid', ItoA(meetingid))
    DebugAddDataToArray('Meeting Extended Result', 'state', ItoA(state))
    DebugSendArrayToConsole('Meeting Extended Result')
    roomID = FindRoomIDforMeetingID(meetingID)
    RequestTodaysMeetings(roomID)
}

DEFINE_FUNCTION DCEvent_AddBookingOK(LONG meetingid, INTEGER cancelstate) {
    STACK_VAR CHAR uiDeviceKey[UI_KEY_MAX_LENGTH]
    STACK_VAR INTEGER roomID

    DebugAddDataToArray('Room Booking OK', 'meetingid', ItoA(meetingid))
    DebugAddDataToArray('Room Booking OK', 'cancelstate', ItoA(cancelstate))
    DebugSendArrayToConsole('Room Booking OK')

    uiDeviceKey = FindUIDeviceKeyForCurrentBookingAttempt()

    if(LENGTH_STRING(uiDeviceKey)) {
	roomID = AtoI(UIGetVarValue(uiDeviceKey, UI_VAR_ROOM_ID))
	if(UIGetCurrentPageName(uiDeviceKey) == uiPageName_RoomBooking[UI_PAGE_INDEX_ENTER_CODE]) {
	    UISetVarValue(uiDeviceKey, UI_VAR_USER_IS_BOOKING_A_MEETNG, '0')
	}
	RequestTodaysMeetings(roomID)
	DC_MeetingStart(0, meetingid)
    } else {
	UpdateMeetingsForRegisteredRooms()
    }
}

DEFINE_FUNCTION DCEvent_AddBookingError() {
    STACK_VAR CHAR uiDeviceKey[UI_KEY_MAX_LENGTH]

    DebugSendStringToConsole('Room booking error!')
    uiDeviceKey = FindUIDeviceKeyForCurrentBookingAttempt()
    if(LENGTH_STRING(uiDeviceKey)) {
	UISetVarValue(uiDeviceKey, UI_VAR_BOOKING_IN_PROGRESS, '0')
	if(UIGetCurrentPageName(uiDeviceKey) == uiPageName_RoomBooking[UI_PAGE_INDEX_ENTER_CODE]) {
	    UISetVarValue(uiDeviceKey, UI_VAR_USER_IS_BOOKING_A_MEETNG, '0')
	    UIPopup(uiDeviceKey, UI_POPUP_ROOM_BOOKING_ERROR, uiPageName_RoomBooking[AtoI(UIGetVarValue(uiDeviceKey, UI_VAR_HOME_PAGE_MODE))], 1, 50)
	    UIPage(uiDeviceKey, uiPageName_RoomBooking[AtoI(UIGetVarValue(uiDeviceKey, UI_VAR_HOME_PAGE_MODE))])
	}
    }
}

DEFINE_FUNCTION DCEvent_DefineMeetingState(INTEGER index, INTEGER stateid, CHAR name[], INTEGER colour, INTEGER ordinal) {
    STACK_VAR _STATE state

    InitTypeState(state)
    state.id = stateid
    state.name = name
    state.colour = colour
    state.ordinal = ordinal
    if(index) {
	AddMeetingStateData(state, index)
    }
    
    DebugAddDataToArray('Meeting Define State', 'index', ItoA(index))
    DebugAddDataToArray('Meeting Define State', 'state.id', ItoA(state.id))
    DebugAddDataToArray('Meeting Define State', 'state.name', state.name)
    DebugAddDataToArray('Meeting Define State', 'state.colour', ItoA(state.colour))
    DebugAddDataToArray('Meeting Define State', 'state.ordinal', ItoA(state.ordinal))
    DebugSendArrayToConsole('Meeting Define State')
}

DEFINE_FUNCTION DCEvent_DefineMeetingType(INTEGER index, INTEGER typeid, CHAR name[], INTEGER colour, INTEGER ordinal) {
    STACK_VAR _MEETING_TYPE meetingType

    InitTypeMeetingType(meetingType)
    meetingType.id = typeid
    meetingType.name = name
    meetingType.colour = colour
    meetingType.ordinal = ordinal
    if(index) {
	AddMeetingTypeData(meetingType, index)
    }
    
    DebugAddDataToArray('Meeting Define Type', 'index', ItoA(index))
    DebugAddDataToArray('Meeting Define Type', 'meetingType.id', ItoA(meetingType.id))
    DebugAddDataToArray('Meeting Define Type', 'meetingType.name', meetingType.name)
    DebugAddDataToArray('Meeting Define Type', 'meetingType.colour', ItoA(meetingType.colour))
    DebugAddDataToArray('Meeting Define Type', 'meetingType.ordinal', ItoA(meetingType.ordinal))
    DebugSendArrayToConsole('Meeting Define Type')
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START {
    InitAllData()
}

DEFINE_EVENT

DATA_EVENT[controllerDevice] {
    COMMAND: {
	STACK_VAR _SNAPI_DATA snapi
	STACK_VAR INTEGER n
	STACK_VAR INTEGER a
	
	SNAPI_InitDataFromString(snapi, data.text)
	n = 0
	switch(snapi.cmd) {
	    case 'CONNECT': {
		DC_StartSession()
	    }
	    case 'SET_ROOM_ID_FOR_UI': {
		n = AtoI(snapi.param[1])
		if(n) {
		    if(UIIsRegistered(n)) {
			if(AtoI(snapi.param[2])) {
			    UISetVarValue(UIGetKeyForIndex(n), UI_VAR_ROOM_ID, snapi.param[2])
			    UISetVarValue(UIGetKeyForIndex(n), UI_VAR_ROOM_COLLECTION_ID, snapi.param[3])
			    SaveUIData(UIGetKeyForIndex(n))
			    RefreshRoom(AtoI(snapi.param[2]))
			}
		    }
		}
	    }
	    case 'ENABLE_ADHOC_BOOKING': {
		n = AtoI(snapi.param[1])
		if(n) {
		    if(UIIsRegistered(n)) {
			UISetVarValue(UIGetKeyForIndex(n), UI_VAR_ADHOC_BOOKING_ENABLED, snapi.param[2])
			SaveUIData(UIGetKeyForIndex(n))
		    }
		}
	    }
	    case 'ENABLE_END_MEETING_BUTTON': {
		n = AtoI(snapi.param[1])
		if(n) {
		    if(UIIsRegistered(n)) {
			UISetVarValue(UIGetKeyForIndex(n), UI_VAR_END_MEETING_ENABLE, snapi.param[2])
			SaveUIData(UIGetKeyForIndex(n))
		    }
		}
	    }
	    case 'UPDATE_ALL': {
		RefreshAll()
	    }
	    case 'TIME_CHANGE': {
		UpdateMeetingsForRegisteredRooms()
	    }
	    case '?CURRENT_MEETING_ID': {
		SEND_COMMAND controllerDevice, "'CURRENT_MEETING_ID-', snapi.param[1], ',', ItoA(FindCurrentMeetingIDForRoom(AtoI(snapi.param[1])))"
	    }
	    case 'END_MEETING': {
		STACK_VAR INTEGER roomID
		roomID = FindRoomIDforMeetingID(AtoI(snapi.param[1]))
		DC_MeetingEnd(0, AtoI(snapi.param[1]))
		RequestTodaysMeetings(roomID)
	    }
	    case 'START_MEETING': {
		DC_MeetingStart(0, AtoI(snapi.param[1]))
	    }
	    case '?EXTEND_MEETING_TIMES': {
		n = ShowAvailableTimesForExtendingMeeting('controller', AtoI(snapi.param[1]))
		SEND_COMMAND controllerDevice, "'EXTEND_MEETING_TIMES-COUNT,', ItoA(n)"
		if(n) {
		    for(a = 1; a <= n; a ++) {
			SEND_COMMAND controllerDevice, "'EXTEND_MEETING_TIMES-BUTTON,', ItoA(a), ',', TimeListGetBtnText('controller', a)"
		    }
		}
	    }
	    case 'EXTEND_MEETING_SELECT_TIME': {
		n = AtoI(snapi.param[1])
		if(n) {
		    DC_MeetingExtend(EXTEND_MEETING_USER_KEY, FindCurrentMeetingIDForRoom(TimeListGetRoomID('controller')), TimeListGetBtnTime('controller', n))
		}
	    }
	    case 'SERVER_ADDRESS': {
		serverAddress = snapi.param[1]
	    }
	    default: {
		
	    }
	}
    }
}

DATA_EVENT[uiDevice] {
    ONLINE: {
	UpdateUI(UIGetKeyForDevice(data.device))
    }
    STRING: {
	STACK_VAR CHAR uiDeviceKey[UI_KEY_MAX_LENGTH]
	STACK_VAR CHAR temp[255]
	STACK_VAR CHAR trash[255]
	
	uiDeviceKey = UIGetKeyForDevice(data.device)
	temp = data.text
	
	if(FIND_STRING(temp, '-ABORT', 1)) {
	    UISetVarValueInt(uiDeviceKey, UI_VAR_KEYBOARD_EDIT_MODE, 0)
	} else if(FIND_STRING(temp, 'KEYB-', 1)) {
	    
	    trash = REMOVE_STRING(temp, 'KEYB-', 1)
	    
	    serverAddress = temp
	    UIText(uiDeviceKey, UI_JOIN_SETUP_SERVER_ADDRESS, UI_STATE_ALL, serverAddress)
	    
	    UISetVarValueInt(uiDeviceKey, UI_VAR_KEYBOARD_EDIT_MODE, 0)
	    
	    SEND_COMMAND controllerDevice, "'SET_SERVER_ADDRESS-', serverAddress"
	}
    }
}

DATA_EVENT[duetDevice] {
    ONLINE: {
	SEND_COMMAND duetDevice, 'SESSION-START'
	wait 20 {
	    UpdateMeetingsForRegisteredRooms()
	}
    }
}

BUTTON_EVENT[uiDevice, UI_JOIN_ROOM_NAME] {
    HOLD[50]: {
	UINavShowSetup(UIGetKeyForDevice(button.input.device))
    }
}

BUTTON_EVENT[uiDevice, UI_JOIN_SETUP_SERVER_ADDRESS_EDIT] {
    PUSH: {
	UISetVarValueInt(UIGetKeyForDevice(button.input.device), UI_VAR_KEYBOARD_EDIT_MODE, 1)
	SEND_COMMAND button.input.device, "'@AKB-', serverAddress, ';Edit the server connection URL'"
    }
}

BUTTON_EVENT[uiDevice, UI_JOIN_START_MEETING] {
    PUSH: {
	STACK_VAR CHAR uiDeviceKey[UI_KEY_MAX_LENGTH]
	STACK_VAR INTEGER roomID
	STACK_VAR LONG meetingID
	STACK_VAR INTEGER meetingIndex
	STACK_VAR INTEGER roomIndex

	uiDeviceKey = UIGetKeyForDevice(button.input.device)
	roomID = AtoI(UIGetVarValue(uiDeviceKey, UI_VAR_ROOM_ID))
	if(roomID) {
	    meetingID = FindCurrentMeetingIDForRoom(roomID)
	    if(!meetingID && NumberOfMinutesUntilNextMeeting(roomID) <= 5) {
		meetingID = FindNextMeetingIDForRoom(roomID)
	    }
	    roomIndex = FindRoomIndexByID(roomID)
	    meetingIndex = FindMeetingIndexByID(roomID, meetingID)
	    if(rooms[roomIndex].todaysMeetings[meetingIndex].state == M_STATE_CONFIRMED) {
		DC_MeetingStart(0, meetingID)
	    } else if(rooms[roomIndex].todaysMeetings[meetingIndex].state == M_STATE_IN_PROGRESS) {
		DC_MeetingEnd(0, meetingID)
		RequestTodaysMeetings(roomID)
	    }
	}
    }
}

BUTTON_EVENT[uiDevice, UI_JOIN_BOOK_MEETING] {
    PUSH: {
	STACK_VAR CHAR uiDeviceKey[UI_KEY_MAX_LENGTH]
	STACK_VAR INTEGER roomID
	STACK_VAR LONG meetingID
	
	uiDeviceKey = UIGetKeyForDevice(button.input.device)
	roomID = AtoI(UIGetVarValue(uiDeviceKey, UI_VAR_ROOM_ID))
	if(roomID) {
	    if(ShowAvailableTimesForNewMeeting(uiDeviceKey, roomID)) {
		TimeListUIUpdate(uiDeviceKey)
		UINavShowListOfTimes(uiDeviceKey)
	    } else {
		UIPopup(uiDeviceKey, UI_POPUP_ROOM_BOOKING_NOT_ALLOWED, '', 1, 50)
	    }
	}
    }
}

BUTTON_EVENT[uiDevice, UI_JOIN_PAGE_BACK] {
    PUSH: {
	STACK_VAR CHAR uiDeviceKey[UI_KEY_MAX_LENGTH]
	
	uiDeviceKey = UIGetKeyForDevice(button.input.device)
	if(UIGetCurrentPageName(uiDeviceKey) == uiPageName_RoomBooking[UI_PAGE_INDEX_SETUP]) {
	    UINavShowMainMenu(uiDeviceKey)
	} else if(UIGetCurrentPageName(uiDeviceKey) == uiPageName_RoomBooking[UI_PAGE_INDEX_SELECT_TIME] OR UIGetCurrentPageName(uiDeviceKey) == uiPageName_RoomBooking[UI_PAGE_INDEX_SELECT_TIME_MORE]) {
	    DebugSendStringToConsole('Back if')
	    UINavShowMainMenu(uiDeviceKey)
	} else {
	    if(UIGetCurrentPageName(uiDeviceKey) == uiPageName_RoomBooking[UI_PAGE_INDEX_ENTER_CODE]) {
		UISetVarValueInt(uiDeviceKey, UI_VAR_EMPLOYEE_CODE_ENTRY_IN_PROGRESS, 0)
	    }
	    UIPageBack(uiDeviceKey)
	    DebugSendStringToConsole('Back else')
	}
    }
}

BUTTON_EVENT[uiDevice, UI_JOIN_TIME_OPTION_MORE] {
    PUSH: {
	UINavShowMoreListOfTimes(UIGetKeyForDevice(button.input.device))
    }
}

BUTTON_EVENT[uiDevice, uiBtns_Time_Option] {
    PUSH: {
	STACK_VAR CHAR uiDeviceKey[UI_KEY_MAX_LENGTH]
	STACK_VAR INTEGER btnIndex
	
	uiDeviceKey = UIGetKeyForDevice(button.input.device)
	btnIndex = GET_LAST(uiBtns_Time_Option)
	UISetVarValue(uiDeviceKey, UI_VAR_BOOKING_SELECTED_TIME, TimeListGetBtnTime(uiDeviceKey, btnIndex))
	ResetUIEmployeeCode(uiDeviceKey)
	UINavShowEmployeeCodeEntry(uiDeviceKey)
    }
}

BUTTON_EVENT[uiDevice, uiBtns_Keyboard_Numbers] {
    PUSH: {
	STACK_VAR CHAR uiDeviceKey[UI_KEY_MAX_LENGTH]
	STACK_VAR INTEGER charVal
	STACK_VAR CHAR temp[50]
	
	uiDeviceKey = UIGetKeyForDevice(button.input.device)
	charVal = GET_LAST(uiBtns_Keyboard_Numbers) + 47
	UIPageTimeOutReset(uiDeviceKey)
	temp = UIGetVarValue(uiDeviceKey, UI_VAR_EMPLOYEE_CODE_ENTRY)
	if(RIGHT_STRING(temp, 1) == '_') {
	    temp = LEFT_STRING(temp, LENGTH_STRING(temp) - 1)
	}
	SetUIEmployeeCode(uiDeviceKey, "temp, charVal")
    }
}

BUTTON_EVENT[uiDevice, uiBtns_Keyboard_Leters] {
    PUSH: {
	STACK_VAR CHAR uiDeviceKey[UI_KEY_MAX_LENGTH]
	STACK_VAR INTEGER charVal
	STACK_VAR CHAR temp[50]
	
	uiDeviceKey = UIGetKeyForDevice(button.input.device)
	charVal = GET_LAST(uiBtns_Keyboard_Leters) + 64
	UIPageTimeOutReset(uiDeviceKey)
	temp = UIGetVarValue(uiDeviceKey, UI_VAR_EMPLOYEE_CODE_ENTRY)
	if(RIGHT_STRING(temp, 1) == '_') {
	    temp = LEFT_STRING(temp, LENGTH_STRING(temp) - 1)
	}
	SetUIEmployeeCode(uiDeviceKey, "temp, charVal")
    }
}

BUTTON_EVENT[uiDevice, uiBtns_Keyboard_Others] {
    PUSH: {
	STACK_VAR CHAR uiDeviceKey[UI_KEY_MAX_LENGTH]
	STACK_VAR INTEGER roomID
	STACK_VAR CHAR temp[50]

	uiDeviceKey = UIGetKeyForDevice(button.input.device)
	UIPageTimeOutReset(uiDeviceKey)
	temp = UIGetVarValue(uiDeviceKey, UI_VAR_EMPLOYEE_CODE_ENTRY)
	if(RIGHT_STRING(temp, 1) == '_') {
	    temp = LEFT_STRING(temp, LENGTH_STRING(temp) - 1)
	}
	switch(uiBtns_Keyboard_Others[GET_LAST(uiBtns_Keyboard_Others)]) {
	    case UI_JOIN_KEYBOARD_CLEAR: {
		SetUIEmployeeCode(uiDeviceKey, '')
	    }
	    case UI_JOIN_KEYBOARD_DELETE: {
		SetUIEmployeeCode(uiDeviceKey, LEFT_STRING(temp, LENGTH_STRING(temp) - 1))
	    }
	    case UI_JOIN_KEYBOARD_SPACE: {
		SetUIEmployeeCode(uiDeviceKey, "temp, $20")
	    }
	    case UI_JOIN_KEYBOARD_CONFIRM: {
		roomID = AtoI(UIGetVarValue(uiDeviceKey, UI_VAR_ROOM_ID))
		if(UIGetCurrentPageName(uiDeviceKey) == uiPageName_RoomBooking[UI_PAGE_INDEX_ENTER_CODE]) {
		    UIPopup(uiDeviceKey, UI_POPUP_ROOM_BOOKING_WAIT, uiPageName_RoomBooking[UI_PAGE_INDEX_ENTER_CODE], 1, 50)
		}
		UISetVarValue(uiDeviceKey, UI_VAR_EMPLOYEE_CODE_ENTRY_IN_PROGRESS, '0')
		UISetVarValue(uiDeviceKey, UI_VAR_LOGIN_IN_PROGRESS, '1')
		if(UIGetVarValue(uiDeviceKey, UI_VAR_EMPLOYEE_CODE_ENTRY) == 'APIUSER') {
		    DC_UserLogin(temp, 'Datacraft2012')
		} else {
		    DC_UserLogin(temp, '')
		}
	    }
	}
    }
}
