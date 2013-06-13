PROGRAM_NAME='UI Controller Core v1-01'
(***********************************************************)
(*  FILE CREATED ON: 05/14/2013  AT: 00:19:22              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 06/05/2013  AT: 17:23:24        *)
(***********************************************************)

#IF_NOT_DEFINED CORE_LIBRARY
#INCLUDE 'Core Library v1-02'
#END_IF

#IF_NOT_DEFINED UI_KIT
#INCLUDE 'UI Kit API v1-01'
#INCLUDE 'UI Language API v1-01'
#END_IF

DEFINE_CONSTANT

CHAR UI_GROUP_KEY_CONTROL_MAIN[]			= 'UIGP_MAIN'

CHAR UI_VAR_SELECTED_SOURCE[]				= 'UIVAR_SRC'

INTEGER UI_JOIN_MEETING_END_TIME			= 10

UI_JOIN_ACTIONSHEET_TITLE				= 61
UI_JOIN_ACTIONSHEET_SUBTITLE				= 62
UI_JOIN_ACTIONSHEET_BUTTON_1				= 63
UI_JOIN_ACTIONSHEET_BUTTON_2				= 64
UI_JOIN_ACTIONSHEET_BUTTON_3				= 65
UI_JOIN_ACTIONSHEET_BUTTON_4				= 66
UI_JOIN_ACTIONSHEET_BUTTON_5				= 67

INTEGER UI_JOIN_EXTEND_MEETING_OPTION_1			= 201
INTEGER UI_JOIN_EXTEND_MEETING_OPTION_2			= 202
INTEGER UI_JOIN_EXTEND_MEETING_OPTION_3			= 203
INTEGER UI_JOIN_EXTEND_MEETING_OPTION_4			= 204
INTEGER UI_JOIN_EXTEND_MEETING_OPTION_5			= 205
INTEGER UI_JOIN_EXTEND_MEETING_OPTION_6			= 206
INTEGER UI_JOIN_EXTEND_MEETING_OPTION_7			= 207
INTEGER UI_JOIN_EXTEND_MEETING_OPTION_8			= 208

CHAR UI_POPUP_EXTEND_MEETING_TIMES[]			= 'Extend Meeting Times'

UI_POPUP_ACTIONSHEET_1_BUTTON				= 1
UI_POPUP_ACTIONSHEET_2_BUTTON				= 2
UI_POPUP_ACTIONSHEET_3_BUTTON				= 3
UI_POPUP_ACTIONSHEET_4_BUTTON				= 4
UI_POPUP_ACTIONSHEET_5_BUTTON				= 5

DEFINE_VARIABLE

INTEGER meetingExtendOptionShown			= FALSE

VOLATILE INTEGER uiBtns_ActionSheet[]			= {
    UI_JOIN_ACTIONSHEET_BUTTON_1,
    UI_JOIN_ACTIONSHEET_BUTTON_2,
    UI_JOIN_ACTIONSHEET_BUTTON_3,
    UI_JOIN_ACTIONSHEET_BUTTON_4,
    UI_JOIN_ACTIONSHEET_BUTTON_5
}

VOLATILE CHAR uiPopup_ActionSheet[][UI_POPUP_NAME_MAX_LENGTH]	= {
    'Actionsheet with 1 Button',
    'Actionsheet with 2 Buttons',
    'Actionsheet with 3 Buttons',
    'Actionsheet with 4 Buttons',
    'Actionsheet with 5 Buttons'
}

VOLATILE INTEGER uiBtns_Extend_Meeting_Option[]		= {
    UI_JOIN_EXTEND_MEETING_OPTION_1,
    UI_JOIN_EXTEND_MEETING_OPTION_2,
    UI_JOIN_EXTEND_MEETING_OPTION_3,
    UI_JOIN_EXTEND_MEETING_OPTION_4,
    UI_JOIN_EXTEND_MEETING_OPTION_5,
    UI_JOIN_EXTEND_MEETING_OPTION_6,
    UI_JOIN_EXTEND_MEETING_OPTION_7,
    UI_JOIN_EXTEND_MEETING_OPTION_8
}

DEFINE_FUNCTION UserInterfacesShouldRegister() {
    STACK_VAR INTEGER n
    
    for(n = 1; n <= MAX_LENGTH_ARRAY(uiMainPanels); n ++) {
	UIRegisterDevice("'TP', ItoA(n)", "'Touch Panel ', ItoA(n)", UI_GROUP_KEY_CONTROL_MAIN, uiMainPanels[n])
	DebugSendStringToConsole("'Registering TP', ItoA(n)")
    }
}

DEFINE_FUNCTION UserInterfaceVarsShouldRegister() {
    UIVarRegister(UI_GROUP_KEY_CONTROL_MAIN, UI_VAR_SELECTED_SOURCE, '')
}

DEFINE_FUNCTION UpdateMeetingInfoText(CHAR text[], INTEGER alert) {
    _UI_COLOUR colour

    if(alert) {
	colour.red = $BF
	colour.green = 0
	colour.blue = 0
    } else {
	colour.red = $77
	colour.green = $77
	colour.blue = $77
    }

    UIText(UI_GROUP_KEY_CONTROL_MAIN, UI_JOIN_MEETING_END_TIME, UI_STATE_ALL, text)
    UITextColour(UI_GROUP_KEY_CONTROL_MAIN, UI_JOIN_MEETING_END_TIME, UI_STATE_ALL, colour)
}

DEFINE_FUNCTION UIActionSheetShowExtendMeeting(CHAR uiDeviceKey[]) {
    STACK_VAR _UI_ACTIONSHEET sheet
    STACK_VAR INTEGER n
    STACK_VAR INTEGER numberOfDisplays

    UIActionSheetInit(sheet) // Init type - passed by ref
    sheet.key = 'EXTEND_MEETING'
    sheet.title = "'EXTEND MEETING?'"
    sheet.titleJoin = UI_JOIN_ACTIONSHEET_TITLE
    sheet.subTitle = "'Would you like to extend your meeting?'"
    sheet.subTitleJoin = UI_JOIN_ACTIONSHEET_SUBTITLE
    sheet.popUpName = uiPopup_ActionSheet[UI_POPUP_ACTIONSHEET_2_BUTTON]
    sheet.timeOutTimeInSeconds = 0

    sheet.buttonChoice[1].key = 'NO'
    sheet.buttonChoice[1].title = 'NO'
    sheet.buttonChoice[1].titleJoin = UI_JOIN_ACTIONSHEET_BUTTON_1

    sheet.buttonChoice[2].key = 'YES'
    sheet.buttonChoice[2].title = 'YES'
    sheet.buttonChoice[2].titleJoin = UI_JOIN_ACTIONSHEET_BUTTON_2

    UIActionSheetShow(uiDeviceKey, sheet)
}

DEFINE_FUNCTION UIActionSheetShowExtendMeetingNotPossible(CHAR uiDeviceKey[]) {
    STACK_VAR _UI_ACTIONSHEET sheet
    STACK_VAR INTEGER n
    STACK_VAR INTEGER numberOfDisplays

    UIActionSheetInit(sheet) // Init type - passed by ref

    sheet.key = 'EXTEND_MEETING_NOT_POSSIBLE'
    sheet.title = "'MEETING ENDING SOON'"
    sheet.titleJoin = UI_JOIN_ACTIONSHEET_TITLE
    sheet.subTitle = "'Your meeting ends in less than 5 minutes and there is another meeting following yours.', $0A, 'Contact reception if you would like to book another room.'"
    sheet.subTitleJoin = UI_JOIN_ACTIONSHEET_SUBTITLE
    sheet.popUpName = uiPopup_ActionSheet[UI_POPUP_ACTIONSHEET_1_BUTTON]
    sheet.timeOutTimeInSeconds = 0

    sheet.buttonChoice[1].key = 'OK'
    sheet.buttonChoice[1].title = 'OK'
    sheet.buttonChoice[1].titleJoin = UI_JOIN_ACTIONSHEET_BUTTON_1

    UIActionSheetShow(uiDeviceKey, sheet)
}

DEFINE_EVENT

DATA_EVENT[uiMainPanels] {
    ONLINE: {
	STACK_VAR CHAR key[UI_KEY_MAX_LENGTH]
	
	ShowPage_Main(UIGetKeyForDevice(data.device))
    }
}

BUTTON_EVENT[uiMainPanels, uiBtns_ActionSheet] {
    PUSH: {
	STACK_VAR INTEGER uiBtnIndex
	STACK_VAR CHAR uiDeviceKey[UI_KEY_MAX_LENGTH]
	_UI_ACTIONSHEET actionSheet

	uiBtnIndex = GET_LAST(uiBtns_ActionSheet)
	uiDeviceKey = UIGetKeyForDevice(button.input.device)
	UIGetActionSheetFromDeviceKey(uiDeviceKey, actionSheet)

	UIActionSheetResult(uiDeviceKey, actionSheet.key, actionSheet.buttonChoice[uiBtnIndex].key)
    }
}