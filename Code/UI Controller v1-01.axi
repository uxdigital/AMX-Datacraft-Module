PROGRAM_NAME='UI Controller v1-01'
(***********************************************************)
(*  FILE CREATED ON: 05/13/2013  AT: 23:55:17              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 06/05/2013  AT: 18:32:47        *)
(***********************************************************)

#IF_NOT_DEFINED CORE_LIBRARY
#INCLUDE 'Core Library'
#END_IF

#DEFINE UI_KIT
#INCLUDE 'UI Kit API'
#INCLUDE 'UI Language API'
#INCLUDE 'UI Controller Core v1-01'


DEFINE_FUNCTION ShowPage_Main(char uiDeviceKey[]) {
    UIPage(uiDeviceKey, 'MAIN PAGE')
}

DEFINE_FUNCTION UIActionSheetResult(CHAR uiDeviceKey[], CHAR actionSheetKey[], CHAR actionSheetResponseBtn[]) {
    STACK_VAR INTEGER n

    switch(actionSheetKey) {
	case 'EXTEND_MEETING': {
	    if(actionSheetResponseBtn == 'YES') {
		ShowExtendMeetingOptions(uiDeviceKey)
	    }
	}
	case 'EXTEND_MEETING_NOT_POSSIBLE': {
	    
	}
    }
    UIActionSheetClose(UIGetGroupKeyFromKey(uiDeviceKey))
}

DEFINE_FUNCTION ShowExtendMeetingOptions(CHAR uiDeviceKey[]) {
    UIPopup(uiDeviceKey, UI_POPUP_EXTEND_MEETING_TIMES, 'Extend Meeting', 1, 0)
    UIPageWithTimeOut(uiDeviceKey, 'Extend Meeting', 10)
}

DEFINE_EVENT

DATA_EVENT[vdvDatacraftController] {
    COMMAND: {
	STACK_VAR _SNAPI_DATA snapi
	STACK_VAR INTEGER n
	
	SNAPI_InitDataFromString(snapi, data.text)
	
	switch(snapi.cmd) {
	    case 'CURRENT_MEETING_INFO': {
		if(AtoI(snapi.param[5]) > 10) {
		    UpdateMeetingInfoText("'MEETING ENDS ', MID_STRING(snapi.param[4], 12, 5)", 0)
		} else {
		    UpdateMeetingInfoText("'MEETING ENDS IN:  ', snapi.param[5], '  MINUTES'", 1)
		}
		
		if(AtoI(snapi.param[5]) <= 5 && !meetingExtendOptionShown) {
		    SEND_COMMAND vdvDataCraftController, "'?EXTEND_MEETING_TIMES-', ItoA(roomBookingIDForThisRoom)"
		} else if(AtoI(snapi.param[5]) > 5) {
		    meetingExtendOptionShown = 0
		}
	    }
	    case 'EXTEND_MEETING_TIMES': {
		switch(snapi.param[1]) {
		    case 'COUNT': {
			if(AtoI(snapi.param[2])) {
			    for(n = AtoI(snapi.param[2]) + 1; n <= MAX_LENGTH_ARRAY(uiBtns_Extend_Meeting_Option); n ++) {
				UIButtonHide(UI_GROUP_KEY_CONTROL_MAIN, uiBtns_Extend_Meeting_Option[n])
			    }
			    meetingExtendOptionShown = TRUE
			    UIPage(UI_GROUP_KEY_CONTROL_MAIN, UIGetCurrentPageName(UI_GROUP_KEY_CONTROL_MAIN))
			    UIActionSheetShowExtendMeeting(UI_GROUP_KEY_CONTROL_MAIN)
			    UIWake(UI_GROUP_KEY_CONTROL_MAIN)
			} else {
			    meetingExtendOptionShown = TRUE
			    UIPage(UI_GROUP_KEY_CONTROL_MAIN, UIGetCurrentPageName(UI_GROUP_KEY_CONTROL_MAIN))
			    UIActionSheetShowExtendMeetingNotPossible(UI_GROUP_KEY_CONTROL_MAIN)
			    UIWake(UI_GROUP_KEY_CONTROL_MAIN)
			}
		    }
		    case 'BUTTON': {
			n = AtoI(snapi.param[2])
			if(n <= MAX_LENGTH_ARRAY(uiBtns_Extend_Meeting_Option)) {
			    UIText(UI_GROUP_KEY_CONTROL_MAIN, uiBtns_Extend_Meeting_Option[n], UI_STATE_ALL, snapi.param[3])
			    UIButtonShow(UI_GROUP_KEY_CONTROL_MAIN, uiBtns_Extend_Meeting_Option[n])
			}
		    }
		}
	    }
	    case 'NO_CURRENT_MEETING': {
		UpdateMeetingInfoText('', 0)
		meetingExtendOptionShown = 0
		UIActionSheetClose(UI_GROUP_KEY_CONTROL_MAIN)
	    }
	    default: {
		
	    }
	}
    }
}

BUTTON_EVENT[uiMainPanels, uiBtns_Extend_Meeting_Option] {
    PUSH: {
	STACK_VAR INTEGER uiBtnIndex
	STACK_VAR CHAR uiDeviceKey[UI_KEY_MAX_LENGTH]
	
	uiBtnIndex = GET_LAST(uiBtns_Extend_Meeting_Option)
	uiDeviceKey = UIGetKeyForDevice(button.input.device)
	
	SEND_COMMAND vdvDataCraftController, "'EXTEND_MEETING_SELECT_TIME-', ItoA(uiBtnIndex)"
	
	UIPageBack(uiDeviceKey)
    }
}

BUTTON_EVENT[uiMainPanels, 0] {
    PUSH: {
	
    }
}