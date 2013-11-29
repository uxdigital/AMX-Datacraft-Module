PROGRAM_NAME='Datacraft UI Controller Constansts v1-01'
(***********************************************************)
(*  FILE CREATED ON: 05/30/2013  AT: 16:06:14              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 06/03/2013  AT: 11:42:39        *)
(***********************************************************)

DEFINE_CONSTANT

UI_JOIN_ROOM_NAME				= 11

UI_JOIN_NEXT_MEETING_OWNER			= 21
UI_JOIN_NEXT_MEETING_TIMES			= 22
UI_JOIN_NEXT_MEETING_TITLE			= 23

UI_JOIN_CURRENT_MEETING_OWNER			= 31
UI_JOIN_CURRENT_MEETING_TIMES			= 32
UI_JOIN_CURRENT_MEETING_TITLE			= 33

UI_JOIN_START_MEETING				= 41
UI_JOIN_BOOK_MEETING				= 42
UI_JOIN_PAGE_BACK				= 43

UI_JOIN_TIME_OPTION_1				= 51
UI_JOIN_TIME_OPTION_2				= 52
UI_JOIN_TIME_OPTION_3				= 53
UI_JOIN_TIME_OPTION_4				= 54
UI_JOIN_TIME_OPTION_5				= 55
UI_JOIN_TIME_OPTION_6				= 56
UI_JOIN_TIME_OPTION_7				= 57
UI_JOIN_TIME_OPTION_8				= 58
UI_JOIN_TIME_OPTION_9				= 59
UI_JOIN_TIME_OPTION_10				= 60
UI_JOIN_TIME_OPTION_11				= 61
UI_JOIN_TIME_OPTION_12				= 62
UI_JOIN_TIME_OPTION_13				= 63
UI_JOIN_TIME_OPTION_14				= 64
UI_JOIN_TIME_OPTION_15				= 65
UI_JOIN_TIME_OPTION_16				= 66
UI_JOIN_TIME_OPTION_17				= 67
UI_JOIN_TIME_OPTION_18				= 68

UI_JOIN_TIME_OPTION_MORE			= 70


UI_JOIN_KEYBOARD_DISPLAY			= 100

UI_JOIN_KEYBOARD_1				= 101
UI_JOIN_KEYBOARD_2				= 102
UI_JOIN_KEYBOARD_3				= 103
UI_JOIN_KEYBOARD_4				= 104
UI_JOIN_KEYBOARD_5				= 105
UI_JOIN_KEYBOARD_6				= 106
UI_JOIN_KEYBOARD_7				= 107
UI_JOIN_KEYBOARD_8				= 108
UI_JOIN_KEYBOARD_9				= 109
UI_JOIN_KEYBOARD_0				= 110
UI_JOIN_KEYBOARD_A				= 111
UI_JOIN_KEYBOARD_B				= 112
UI_JOIN_KEYBOARD_C				= 113
UI_JOIN_KEYBOARD_D				= 114
UI_JOIN_KEYBOARD_E				= 115
UI_JOIN_KEYBOARD_F				= 116
UI_JOIN_KEYBOARD_G				= 117
UI_JOIN_KEYBOARD_H				= 118
UI_JOIN_KEYBOARD_I				= 119
UI_JOIN_KEYBOARD_J				= 120
UI_JOIN_KEYBOARD_K				= 121
UI_JOIN_KEYBOARD_L				= 122
UI_JOIN_KEYBOARD_M				= 123
UI_JOIN_KEYBOARD_N				= 124
UI_JOIN_KEYBOARD_O				= 125
UI_JOIN_KEYBOARD_P				= 126
UI_JOIN_KEYBOARD_Q				= 127
UI_JOIN_KEYBOARD_R				= 128
UI_JOIN_KEYBOARD_S				= 129
UI_JOIN_KEYBOARD_T				= 130
UI_JOIN_KEYBOARD_U				= 131
UI_JOIN_KEYBOARD_V				= 132
UI_JOIN_KEYBOARD_W				= 133
UI_JOIN_KEYBOARD_X				= 134
UI_JOIN_KEYBOARD_Y				= 135
UI_JOIN_KEYBOARD_Z				= 136

UI_JOIN_KEYBOARD_SPACE				= 137
UI_JOIN_KEYBOARD_DELETE				= 138
UI_JOIN_KEYBOARD_CLEAR				= 139
UI_JOIN_KEYBOARD_CONFIRM			= 140

UI_JOIN_SETUP_ROOM_NAME				= 151
UI_JOIN_SETUP_ROOM_ID				= 152
UI_JOIN_SETUP_COLLECTION_ID			= 153
UI_JOIN_SETUP_SERVER_ADDRESS			= 154
UI_JOIN_SETUP_SERVER_ADDRESS_EDIT		= 155


DEFINE_VARIABLE

VOLATILE INTEGER uiBtns_Time_Option[]		= {
    UI_JOIN_TIME_OPTION_1,
    UI_JOIN_TIME_OPTION_2,
    UI_JOIN_TIME_OPTION_3,
    UI_JOIN_TIME_OPTION_4,
    UI_JOIN_TIME_OPTION_5,
    UI_JOIN_TIME_OPTION_6,
    UI_JOIN_TIME_OPTION_7,
    UI_JOIN_TIME_OPTION_8,
    UI_JOIN_TIME_OPTION_9,
    UI_JOIN_TIME_OPTION_10,
    UI_JOIN_TIME_OPTION_11,
    UI_JOIN_TIME_OPTION_12,
    UI_JOIN_TIME_OPTION_13,
    UI_JOIN_TIME_OPTION_14,
    UI_JOIN_TIME_OPTION_15,
    UI_JOIN_TIME_OPTION_16,
    UI_JOIN_TIME_OPTION_17,
    UI_JOIN_TIME_OPTION_18
}


// Use an offset of 47 + Index
VOLATILE INTEGER uiBtns_Keyboard_Numbers[]	= {
    UI_JOIN_KEYBOARD_0,		// Decimal 48
    UI_JOIN_KEYBOARD_1,
    UI_JOIN_KEYBOARD_2,
    UI_JOIN_KEYBOARD_3,
    UI_JOIN_KEYBOARD_4,
    UI_JOIN_KEYBOARD_5,
    UI_JOIN_KEYBOARD_6,
    UI_JOIN_KEYBOARD_7,
    UI_JOIN_KEYBOARD_8,
    UI_JOIN_KEYBOARD_9		// Decimal 57
}

// Use an offset of 64 + Index
VOLATILE INTEGER uiBtns_Keyboard_Leters[]	= {
    UI_JOIN_KEYBOARD_A,		// Decimal 65
    UI_JOIN_KEYBOARD_B,
    UI_JOIN_KEYBOARD_C,
    UI_JOIN_KEYBOARD_D,
    UI_JOIN_KEYBOARD_E,
    UI_JOIN_KEYBOARD_F,
    UI_JOIN_KEYBOARD_G,
    UI_JOIN_KEYBOARD_H,
    UI_JOIN_KEYBOARD_I,
    UI_JOIN_KEYBOARD_J,
    UI_JOIN_KEYBOARD_K,
    UI_JOIN_KEYBOARD_L,
    UI_JOIN_KEYBOARD_M,
    UI_JOIN_KEYBOARD_N,
    UI_JOIN_KEYBOARD_O,
    UI_JOIN_KEYBOARD_P,
    UI_JOIN_KEYBOARD_Q,
    UI_JOIN_KEYBOARD_R,
    UI_JOIN_KEYBOARD_S,
    UI_JOIN_KEYBOARD_T,
    UI_JOIN_KEYBOARD_U,
    UI_JOIN_KEYBOARD_V,
    UI_JOIN_KEYBOARD_W,
    UI_JOIN_KEYBOARD_X,
    UI_JOIN_KEYBOARD_Y,
    UI_JOIN_KEYBOARD_Z
}

VOLATILE INTEGER uiBtns_Keyboard_Others[]	= {
    UI_JOIN_KEYBOARD_SPACE,
    UI_JOIN_KEYBOARD_DELETE,
    UI_JOIN_KEYBOARD_CLEAR,
    UI_JOIN_KEYBOARD_CONFIRM
}


DEFINE_CONSTANT

UI_PAGE_INDEX_SETUP				= 1
UI_PAGE_INDEX_HOME_ERROR			= 2
UI_PAGE_INDEX_HOME_AVAILABLE			= 3
UI_PAGE_INDEX_HOME_IN_USE			= 4
UI_PAGE_INDEX_SELECT_TIME			= 5
UI_PAGE_INDEX_SELECT_TIME_MORE			= 6
UI_PAGE_INDEX_ENTER_CODE			= 7

CHAR UI_POPUP_ROOM_BOOKING_ERROR[]		= 'Room Booking Error'
CHAR UI_POPUP_ROOM_BOOKING_WAIT[]		= 'Room Booking Wait'
CHAR UI_POPUP_ROOM_BOOKING_NOT_ALLOWED[]	= 'Room Booking Not Possible'

DEFINE_VARIABLE

VOLATILE CHAR uiPageName_RoomBooking[][UI_PAGE_NAME_MAX_LENGTH] = {
    '00 - Setup',
    '01 - Home Blank',
    '02 - Home Available',
    '03 - Home In Use',
    '04 - Select Time',
    '05 - Select Time More',
    '06 - Enter Employee Code'
}
