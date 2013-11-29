PROGRAM_NAME='DatacraftTouchPanelAPI'
(***********************************************************)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 09/14/2012  AT: 17:21:19        *)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
    $History: $
*)
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE



(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

// Override some MDX stuff
MDX_MAX_PARAMS    = 15;
MDX_MAX_PARAMLEN  = 64;
MDX_MAX_DATALEN   = 1024;

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE


(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
#include 'MdxStandard.axi'

///////////////////////////////////////////////////////////// Datacraft Module API calls

// Call to start an initial session with Datacraft.
// - The module handles session managment semi-automatically you just need to kick the initial session of at start
// - Results in a SessionAquired event.
Define_Function DC_StartSession()
{
	Send_Command duetDevice,"'SESSION-START'";
}

// Call to authenticate a user. Results in Event UserLoginSuccess() or UserLoginFail()
// - UserLoginSuccess will contain <userid> which can be used in other calls
// - After 3 unsucessful logins a AuthenticationError event will occure and you will need to start aew session.
Define_Function DC_UserLogin(char user[], char pass[])
{
	Send_Command duetDevice,"'USER-LOGIN=',user,'|',pass";
}

// Call to retrieve full user details of the user with <userid> (from UserLogin).
// - Results in Event UserDetails
Define_Function DC_GetUserDetails(integer userid)
{
	Send_Command duetDevice,"'GET-USERDETAILS=',itoa(userid)";
}

// Call to get details for the assigned room. You need to get <roomid> from the Datacraft web interface.
// - Results in Event RoomDetails.
Define_Function DC_GetRoomDetails(integer roomid)
{
	Send_Command duetDevice,"'GET-ROOMDETAILS=',itoa(roomid)";
}

// Call to get a list of bookings within the time period specified.
// - Results in 1 RoomBookings event containing the count of bookings, and then 0 or more DefineRoomBooking events.
// - the end of the list is indicated by a DefineRoomBooking event with a zero value index.
// - Period parameters take the form: 'YYYY-MM-DD HH:MM'
// - Timezone will be a string for your local time zone. EG: 'GMT Standard Time'
Define_Function DC_GetBookings(integer roomid, char timezone[], char periodstart[], char periodend[])
{
	Send_Command duetDevice,"'GET-BOOKINGS=',itoa(roomid),'|',timezone,'|',periodstart,'|',periodend";
}

// Call to Add a booking
// - roomid is the id of the room you wish to make a booking for
// - timezone will be a string for your local time zone. EG: 'GMT Standard Time'
// - starttime Time and Date of the meeting start in the form: 'YYYY-MM-DD HH:MM'
// - endtime Time and Date of the meeting start in the form: 'YYYY-MM-DD HH:MM'
// - userid id of a user with permission to add bookings. Use 'UserLogin' to obtain the id of a user
// - collectionid is the id of the group of rooms that this room belogns to for the Datacraft Touch Panel API and is unique to each site
// - title is the Title for the meeting you are booking
Define_Function DC_AddBooking(integer roomid, char timezone[], char starttime[], char endtime[], integer userid, integer collectionid, char title[])
{
	Send_Command duetDevice,"'ADD-BOOKING=',itoa(roomid),'|',timezone,'|',starttime,'|',endtime,'|',itoa(userid),'|',itoa(collectionid),'|',title";
}

// Call to Add a booking - Extended
// - roomid is the id of the room you wish to make a booking for
// - timezone will be a string for your local time zone. EG: 'GMT Standard Time' 
// - starttime Time and Date of the meeting start in the form: 'YYYY-MM-DD HH:MM'
// - endtime Time and Date of the meeting start in the form: 'YYYY-MM-DD HH:MM'
// - userid id of a user with permission to add bookings. Use 'UserLogin' to obtain the id of a user
// - collectionid is the id of the group of rooms that this room belogns to for the Datacraft Touch Panel API and is unique to each site
// - title is the Title for the meeting you are booking
// - meetingtypeid is the desired typeid from DefineMeetingType event
Define_Function DC_AddBookingEx(integer roomid, char timezone[], char starttime[], char endtime[], integer userid, integer collectionid, char title[], integer meetingtypeid)
{	
	Send_Command duetDevice,"'ADD-BOOKING=',itoa(roomid),'|',timezone,'|',starttime,'|',endtime,'|',itoa(userid),'|',itoa(collectionid),'|',title,'|',itoa(meetingtypeid)";
}

// Call to start the meeting with <meetingid> from a DefineRoomBooking event.
// - <userid> is optional and can be 0.
Define_Function DC_MeetingStart(integer userid, long meetingid)
{
	Send_Command duetDevice,"'MEETING-START=',itoa(userid),'|',itoa(meetingid)";
}

// Call to end the meeting with <meetingid> from a DefineRoomBooking event.
// - <userid> is optional and can be 0.
Define_Function DC_MeetingEnd(integer userid, long meetingid)
{
	Send_Command duetDevice,"'MEETING-END=',itoa(userid),'|',itoa(meetingid)";
}

// Call to extend the meeting with <meetingid> to the date/time specified.
// - <userid> is optional and can be 0.
// - Newendtime takes the form 'YYYY-MM-DD HH:MM'
Define_Function DC_MeetingExtend(integer userid, long meetingid, char newendtime[])
{
	Send_Command duetDevice,"'MEETING-EXTEND=',itoa(userid),'|',itoa(meetingid),'|',newendtime";
}

// Call to get a list of meeting types as specified in DefineRoomBooking-meetingtype.
// Results in several DefineMeetingType events. The end of the list is indicated by index=0
Define_Function DC_GetMeetingTypes()
{
	Send_Command duetDevice,"'GET-MEETINGTYPES'";
}

// Call to get a list of meeting states as specified in DefineRoomBooking-meetingstate.
// Results in several DefineMeetingState events. The end of the list is indicated by index=0
Define_Function DC_GetMeetingStates()
{
	Send_Command duetDevice,"'GET-MEETINGSTATES'";
}


// Leave this alone
Define_Function DC_ProcessAPI(char apistring[])  // Do Not Modify!
{
	MDX_PARAMETERS params;
	integer numeric;
	char cmdname[32], method, query;

	fn_MdxParseASCIIDataExchange(apistring, '|', cmdname, numeric, params, method, query);

	if(length_string(cmdname))
	{
		////////// API Command List
		switch(cmdname)
		{
			case 'ERROR-AUTHENTICATION': // ERROR-AUTHENTICATION=<code>|<description>
			{
				DCEvent_AuthenticationError(atoi(params.param[1]),params.param[2]);
			}
			case 'SESSION-AQUIRED': // SESSION-AQUIRED=<userid>|<permission>|<admin>
			{
				DCEvent_SessionAquired(atoi(params.param[1]),atoi(params.param[2]),atoi(params.param[3]));
			}
			case 'LOGIN-SUCCESS': // LOGIN-SUCCESS=<username>|<userid>|<permission>|<costcode>|<costcodeid>
			{
				DCEvent_UserLoginSuccess(params.param[1],atoi(params.param[2]),atoi(params.param[3]),params.param[4],params.param[5]);
			}
			case 'LOGIN-FAIL': // LOGIN-FAIL=<username>
			{
				DCEvent_UserLoginFail(params.param[1]);
			}
			case 'USER-DETAILS': // USER-DETAILS=<userid>|<name>|<initials>|<agentid>|<costcode>|<costcodeid>|<siteid>|<departent>|<phone>|<email>|<room>
			{
				DCEvent_UserDetails(atoi(params.param[1]),params.param[2],params.param[3],atoi(params.param[4]),params.param[5],atoi(params.param[6]),atoi(params.param[7]),params.param[8],params.param[9],params.param[10],params.param[11]);
			}
			case 'ROOM-DETAILS': // ROOM-DETAILS=<roomid>|<name>|<longname>|<floor>|<capacity>|<phone>|<maxchangeid>|<chartinterval>
			{
				DCEvent_RoomDetails(atoi(params.param[1]),params.param[2],params.param[3],params.param[4],atoi(params.param[5]),params.param[6],atoi(params.param[7]),atoi(params.param[8]));
			}
			case 'DEFIN-ROOM-LAYOUT': // ROOM-LAYOUT<index>=<roomid>|<layoutid>|<name>|<maxcpacity>|<mincapacity>
			{
				DCEvent_DefRoomLayout(numeric,atoi(params.param[1]),atoi(params.param[2]),params.param[3],atoi(params.param[4]),atoi(params.param[5]));
			}
			case 'ROOM-BOOKINGS': // ROOM-BOOKINGS=<roomid>|<startdate>|<starttime>|<enddate>|<endtime>|<count>
			{
				DCEvent_RoomBookings(atoi(params.param[1]),params.param[2],params.param[3],params.param[4],params.param[5],atoi(params.param[6]));
			}
			case 'DEFINE-ROOM-BOOKING': // DEFINE-BOOKING<index>=<roomid>|<meetingid>|<startdate>|<starttime>|<enddate>|<endtime>|<title>|<ownername>|<ownerphone>|<agentname>|<agentphone>|<meetingstate>|<meetingtype>|<hiptype>|<hipid>
			{
				DCEvent_DefineRoomBooking(numeric, atoi(params.param[1]),atoi(params.param[2]),
															  params.param[3],params.param[4],params.param[5],params.param[6],
															  params.param[7],params.param[8],params.param[9],params.param[10],params.param[11],
															  atoi(params.param[12]),atoi(params.param[13]),atoi(params.param[14]),atoi(params.param[15]));
			}
			case 'ADD-BOOKING-RESULT': // ADD-BOOKING-RESULT=<meetingid>|<cancelstate>|<versionnum>
			{
				slong meetingid, cancelstate;
				meetingid = atoi(params.param[1]);
				cancelstate = atoi(params.param[2]);

				// Successful
				if(meetingid >0)
					DCEvent_AddBookingOK(type_cast(meetingid), type_cast(cancelstate));
				else
					DCEvent_AddBookingError();
			}
			case 'MEETING-STATE': // MEETING-STATE=<meetingid>|<state>|<statename>
			{
				DCEvent_MeetingState(atoi(params.param[1]),atoi(params.param[2]),atoi(params.param[3]));
			}
			case 'MEETING-EXTENDED':
			{
				DCEvent_MeetingExtended(atoi(params.param[1]),atoi(params.param[2]));
			}
			case 'DEFINE-MEETING-STATE': // DEFINE-MEETING-STATES<index>=<stateid>|<name>|<colour>|<ordinal>
			{
				DCEvent_DefineMeetingState(numeric, atoi(params.param[1]),params.param[2],params.param[3],atoi(params.param[4]));
			}
			case 'DEFINE-MEETING-TYPE': // DEFINE-MEETING-TYPES<index>=<typeid>|<name>|<colour>|<ordinal>
			{
				DCEvent_DefineMeetingType(numeric, atoi(params.param[1]),params.param[2],params.param[3],atoi(params.param[4]));
			}

			case 'ERROR': // ERROR=<description>
			{
				Send_string 0,"'DATACRAFT-TPAPI: Error: ',params.param[1]";
			}

		}
	}
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[duetDevice]
{
	Online: {
		//DC_StartSession()
	}
	String:
	{
		DC_ProcessAPI(data.text);
	}
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

