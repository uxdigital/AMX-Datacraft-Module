PROGRAM_NAME='Main'
(***********************************************************)
(*  FILE CREATED ON: 05/13/2013  AT: 23:45:23              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 06/05/2013  AT: 17:37:55        *)
(*******************************************************************************)
(*                                                                             *)
(*     _____            _              _  ____             _                   *)
(*    |     | ___  ___ | |_  ___  ___ | ||    \  ___  ___ |_| ___  ___  ___    *)
(*    |   --|| . ||   ||  _||  _|| . || ||  |  || -_||_ -|| || . ||   ||_ -|   *)
(*    |_____||___||_|_||_|  |_|  |___||_||____/ |___||___||_||_  ||_|_||___|   *)
(*                                                           |___|             *)
(*                                                                             *)
(*                   © Control Designs Software Ltd (2012)                     *)
(*                         www.controldesigns.co.uk                            *)
(*                                                                             *)
(*      Tel: +44 (0)1753 208 490     Email: support@controldesigns.co.uk       *)
(*                                                                             *)
(*******************************************************************************)
(*                                                                             *)
(*            Written by Mike Jobson (Control Designs Software Ltd)            *)
(*                                                                             *)
(** REVISION HISTORY ***********************************************************)
(*                                                                             *)
(*  v1-01 (release) --/--/--                                                   *)
(*  Add release info here!                                                     *)
(*      -----------------------------------------------------------------      *)
(*  v1-01 (beta)    30/05/13                                                   *)
(*  First release - Currently in beta development                              *)
(*                                                                             *)
(*******************************************************************************)
(*                                                                             *)
(*  Permission is hereby granted, free of charge, to any person obtaining a    *)
(*  copy of this software and associated documentation files (the "Software"), *)
(*  to deal in the Software without restriction, including without limitation  *)
(*  the rights to use, copy, modify, merge, publish, distribute, sublicense,   *)
(*  and/or sell copies of the Software, and to permit persons to whom the      *)
(*  Software is furnished to do so, subject to the following conditions:       *)
(*                                                                             *)
(*  The above copyright notice and this permission notice and header shall     *)
(*  be included in all copies or substantial portions of the Software.         *)
(*                                                                             *)
(*  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS    *)
(*  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF                 *)
(*  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.     *)
(*  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY       *)
(*  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT  *)
(*  OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR   *)
(*  THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                 *)
(*                                                                             *)
(*******************************************************************************)


#DEFINE DEBUG TRUE // Set to TRUE to enable debugging from Core Library Modules

DEFINE_VARIABLE

CHAR datacraftIPAddress[]		= '81.137.76.18:9003'
INTEGER roomBookingIDForThisRoom	= 26
(*******************************************************************************)
(*  IMPORT CORE LIBRARY HERE                                                   *)
(*  This is includes generic functions and code which can be re-used in main   *)
(*  and other modules. Also includes 'SNAPI' and some add-on functions.        *)
(*******************************************************************************)
#DEFINE CORE_LIBRARY
#INCLUDE 'Core Library'


(*******************************************************************************)
(*  DEFINE USER INTERFACES HERE                                                *)
(*  Include a UI Controller for all panels                                     *)
(*******************************************************************************)
DEFINE_DEVICE

// Room touch panels... have defined 2 so seperate independant panels for the
// same room. You may wish to have an iPad also or someone requests a 2nd
// panel so it's always best to program 2 threadsafe instances of a UI.
dvUI_RoomControlPanel_1						= 10001:1:0
dvUI_RoomControlPanel_2						= 10002:1:0

// Room booking panel. This is for the Datacraft mail UI functionality.
dvUI_RoomBookingPanel_1						= 10011:1:0
dvUI_RoomBookingPanel_2						= 10012:1:0

DEFINE_VARIABLE

// Array of the main touch panel devices which will be passed into the
// room touch panel UI Controller.
DEV uiMainPanels[]						= {
    dvUI_RoomControlPanel_1,
    dvUI_RoomControlPanel_2
}

// Array of the room booking touch panel device which will be passed into
// the Datacraft UI Controller.
DEV uiBookingPanels[]						= {
    dvUI_RoomBookingPanel_1,
    dvUI_RoomBookingPanel_2
}


(*******************************************************************************)
(*  DEFINE OTHER DEVICES HERE                                                  *)
(*******************************************************************************)
DEFINE_DEVICE

dvDisplay_1							= 5001:1:0
dvDisplay_2							= 5001:2:0


(*******************************************************************************)
(*  DEFINE DEVICE ARRAYS HERE                                                  *)
(*******************************************************************************)
DEFINE_VARIABLE

DEV displays[]							= {
    dvDisplay_1,
    dvDisplay_2
}


(*******************************************************************************)
(*  DEFINE VIRTUAL DEVICES HERE                                                *)
(*******************************************************************************)
DEFINE_DEVICE

// Standard Virtual Devices start with 33001
dvDisplay_1_Controller						= 33001:1:0
dvDisplay_2_Controller						= 33002:2:0

// Datacraft UI Controller Device
vdvDatacraftController						= 33011:1:0

// Duet Virtual Devices start with 41001
vdvDatacraft_DuetApiInterface					= 41011:1:0

(*******************************************************************************)
(*  DEFINE VIRTUAL DEVICE ARRAYS HERE                                          *)
(*******************************************************************************)
DEFINE_VARIABLE

DEV displayControllers[]					= {
    dvDisplay_1_Controller,
    dvDisplay_2_Controller
}

(*******************************************************************************)
(*  DEFINE TIMELINE FOR UPDATES                                                *)
(*******************************************************************************)
DEFINE_CONSTANT
LONG TIME_TIMELINE_REPEAT_TIME[]				= { 1000 }
LONG TIME_TIMELINE						= 2

DEFINE_VARIABLE
VOLATILE _TIME currentTime

DEFINE_FUNCTION TimeCheck() {
    TimeCreate(currentTime)
}

DEFINE_FUNCTION TimeStart() {
    TimeCreate(currentTime)
    TIMELINE_CREATE(TIME_TIMELINE, TIME_TIMELINE_REPEAT_TIME, LENGTH_ARRAY(TIME_TIMELINE_REPEAT_TIME), TIMELINE_ABSOLUTE, TIMELINE_REPEAT)
}

DEFINE_EVENT

TIMELINE_EVENT[TIME_TIMELINE] {
    TimeCheck()
    if(currentTime.hours == 0 && currentTime.minutes == 0 && currentTime.seconds == 0) {
	SEND_COMMAND vdvDataCraftController, "'UPDATE_ALL'"
    } else if(currentTime.seconds == 0) {
	SEND_COMMAND vdvDataCraftController, "'TIME_CHANGE'"
    }
}

(*******************************************************************************)
(*  DEFINE FUNCTIONS HERE                                                      *)
(*******************************************************************************)
DEFINE_FUNCTION RoomBookingSetRoomID(INTEGER uiDeviceIndex, INTEGER roomID, INTEGER collectionID) {
    SEND_COMMAND vdvDatacraftController, "'SET_ROOM_ID_FOR_UI-', ItoA(uiDeviceIndex), ',', ItoA(roomID), ',', ItoA(collectionID)"
}

DEFINE_FUNCTION RoomBookingSetAdhocBooking(INTEGER uiDeviceIndex, INTEGER enable) {
    SEND_COMMAND vdvDatacraftController, "'ENABLE_ADHOC_BOOKING-', ItoA(uiDeviceIndex), ',', ItoA(enable)"
}

DEFINE_FUNCTION RoomBookingSetEndMeetingButtonEnable(INTEGER uiDeviceIndex, INTEGER enable) {
    SEND_COMMAND vdvDatacraftController, "'ENABLE_END_MEETING_BUTTON-', ItoA(uiDeviceIndex), ',', ItoA(enable)"
}

//UI Controller for the Room Control Panels.
#INCLUDE 'UI Controller v1-01'

(*******************************************************************************)
(*  DATACRAFT MODULES                                                          *)
(*******************************************************************************)

DEFINE_MODULE 'DatacraftHospitality_dr1_0_0' mDatacraft (
    vdvDatacraft_DuetApiInterface,
    datacraftIPAddress )
    
DEFINE_MODULE 'Datacraft UI Controller v1-01' mDatacraftUI (
    vdvDatacraft_DuetApiInterface, 
    vdvDatacraftController,
    uiBookingPanels )


(*******************************************************************************)
(*  DEFINE STARTUP CODE HERE                                                   *)
(*******************************************************************************)
DEFINE_START {
    
}


(*******************************************************************************)
(*  DEFINE EVENT CODE AFTER HERE                                               *)
(*******************************************************************************)
DEFINE_EVENT

DATA_EVENT[vdvDatacraftController] {
    ONLINE: {
	wait 20 {
	    // set the room key for the room booking panel to 26 and collection key as 10
	    RoomBookingSetRoomID(1, 26, 10)
	    RoomBookingSetRoomID(2, 26, 10)
	    
	    // set to true if you wan the panel to accept adhoc bookings
	    RoomBookingSetAdhocBooking(1, TRUE)
	    RoomBookingSetAdhocBooking(2, TRUE)
	    
	    // set to true if you want the ability for people to end the meeting externally
	    RoomBookingSetEndMeetingButtonEnable(1, TRUE)
	    RoomBookingSetEndMeetingButtonEnable(2, TRUE)
	    
	    wait 20 {
		TimeStart()
	    }
	}
    }
    COMMAND: {
	STACK_VAR _SNAPI_DATA snapi
	
	SNAPI_InitDataFromString(snapi, data.text)
	
	switch(snapi.cmd) {
	    case 'SET_SERVER_ADDRESS': {
		datacraftIPAddress = snapi.param[1]
		
		SEND_COMMAND vdvDatacraft_DuetApiInterface, "'SESSION-START'"
	    }
	}
    }
}


(*******************************************************************************)
(*  DEFINE MAIN PROGRAM LOOP HERE                                              *)
(*******************************************************************************)
DEFINE_PROGRAM {
    
}

