MODULE_NAME='UI Language Core v1-01' ( DEV controllerDevice, DEV uiDevice[], CHAR uiDeviceKey[][], CHAR uiGroupKey[][] )
(***********************************************************)
(*  FILE CREATED ON: 02/04/2013  AT: 19:42:13              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 02/04/2013  AT: 20:59:10        *)
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
(*      Tel: +44 (0)1753 314 660     Email: support@controldesigns.co.uk       *)
(*                                                                             *)
(*******************************************************************************)
(*                                                                             *)
(*                           UI Language v1-01                                 *)
(*                   requires UI Kit API v1-01 or later                        *)
(*                                                                             *)
(*            Written by Mike Jobson (Control Designs Software Ltd)            *)
(*                                                                             *)
(** REVISION HISTORY ***********************************************************)
(*                                                                             *)
(*  v1-01 (beta)                                                               *)
(*  First release developed in beta only at this point in time                 *)
(*  No known issues - Notes to follow in coming update                         *)
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

#DEFINE DEBUG 1

#INCLUDE 'Core Library v1-01'
#INCLUDE 'UI Kit API v1-01'


DEFINE_CONSTANT

UI_MAX_LANGUAGES					= 2
UI_MAX_LANGUAGE_BTN_TEXT_LENGTH				= 50
UI_MAX_LANGUAGE_STORAGE_SIZE				= 1000

UI_VAR_LANGUAGE_SELECTED				= 'CURRENT_LANG'

DEFINE_FUNCTION UserInterfacesShouldRegister() {
    STACK_VAR INTEGER n
    
    for(n = 1; n <= MAX_LENGTH_ARRAY(uiDevice); n ++) {
	UIRegisterDevice(uiDeviceKey[n], "'UI Lang Device ', ItoA(n)", uiGroupKey[n], uiDevice[n])
    }
}

DEFINE_FUNCTION UserInterfaceVarsShouldRegister() {
    STACK_VAR INTEGER n
    
    for(n = 1; n <= MAX_LENGTH_ARRAY(uiDeviceKey); n ++) {
	UIVarRegister(uiDeviceKey[n], UI_VAR_LANGUAGE_SELECTED, '1')
    }
}

DEFINE_TYPE

STRUCT _btnLanguageText {
    INTEGER address
    CHAR uiDeviceKey[UI_KEY_MAX_LENGTH]
    INTEGER defined
    CHAR text[UI_MAX_LANGUAGES][UI_MAX_LANGUAGE_BTN_TEXT_LENGTH]
}

DEFINE_VARIABLE

_btnLanguageText uiLanguageBtnText[UI_MAX_LANGUAGE_STORAGE_SIZE]

DEFINE_FUNCTION UILanguageTypeInit(_btnLanguageText btnLangText) {
    STACK_VAR INTEGER lang
    
    btnLangText.address = 0
    btnLangText.uiDeviceKey = ''
    btnLangText.defined = FALSE
    for(lang = 1; lang <= MAX_LENGTH_ARRAY(btnLangText.text); lang ++) {
	btnLangText.text[lang] = ''
    }
}

DEFINE_FUNCTION UILanguageInitAll() {
    STACK_VAR INTEGER n
    STACK_VAR INTEGER lang
    
    for(n = 1; n <= MAX_LENGTH_ARRAY(uiLanguageBtnText); n ++) {
	UILanguageTypeInit(uiLanguageBtnText[n])
    }
}

DEFINE_FUNCTION INTEGER UILanguageBtnTextDefine(INTEGER btnAddress, CHAR uiDeviceKey[], CHAR languageText1[], CHAR languageText2[]) {
    STACK_VAR INTEGER n
    STACK_VAR INTEGER result
    
    result = 0
    
    for(n = 1; n <= MAX_LENGTH_ARRAY(uiLanguageBtnText); n ++) {
	if(!uiLanguageBtnText[n].defined) {
	    result = n
	}
    }
    
    if(result) {
	uiLanguageBtnText[result].address = btnAddress
	uiLanguageBtnText[result].uiDeviceKey = uiDeviceKey
	uiLanguageBtnText[result].text[1] = languageText1
	uiLanguageBtnText[result].text[2] = languageText2
    }
    
    return result
}

DEFINE_FUNCTION CHAR[UI_MAX_LANGUAGE_BTN_TEXT_LENGTH] UILanguageGetButtonText(INTEGER btnAddress, CHAR uiDeviceKey[], INTEGER language) {
    STACK_VAR INTEGER n
    STACK_VAR INTEGER result
    
    result = 0
    
    if(language) {
	for(n = 1; n <= MAX_LENGTH_ARRAY(uiLanguageBtnText); n ++) {
	    if(uiLanguageBtnText[n].address == btnAddress && uiLanguageBtnText[n].uiDeviceKey == uiDeviceKey) {
		return uiLanguageBtnText[n].text[language]
		result = language
		break
	    }
	}
    }
}

DEFINE_FUNCTION UISetLanguage(CHAR uiDeviceKey[UI_KEY_MAX_LENGTH], INTEGER language) {
    STACK_VAR INTEGER n
    STACK_VAR CHAR popup[UI_POPUP_NAME_MAX_LENGTH]
    
    if(language && language <= UI_MAX_LANGUAGES) {
	UISetVarValue(uiDeviceKey, UI_VAR_LANGUAGE_SELECTED, ItoA(language))
	
	for(n = 1; n <= MAX_LENGTH_ARRAY(uiLanguageBtnText); n ++) {
	    if(uiLanguageBtnText[n].uiDeviceKey == uiDeviceKey) {
		UIText(uiDeviceKey, uiLanguageBtnText[n].address, UI_STATE_ALL, uiLanguageBtnText[n].text[language])
	    }
	}
    }
}


DEFINE_START

UILanguageInitAll()



DEFINE_EVENT

DATA_EVENT[controllerDevice] {
    COMMAND: {
	STACK_VAR CHAR commandString[DUET_MAX_CMD_LEN]
	STACK_VAR CHAR commandHeader[DUET_MAX_HDR_LEN]
	STACK_VAR CHAR commandParam[DUET_MAX_PARAM_LEN]
	STACK_VAR CHAR commandParamArray[DUET_MAX_PARAM_ARRAY_SIZE][DUET_MAX_PARAM_LEN]
	
	commandString = data.text
	
	commandHeader = DuetParseCmdHeader(commandString)
	DuetParseParamsToArray(commandString, commandParamArray)
	
	switch(commandHeader) {
	    case 'DEFINE_BTN' : {
		UILanguageBtnTextDefine(AtoI(commandParamArray[2]), commandParamArray[1], commandParamArray[3], commandParamArray[4])
	    }
	    case 'LANGUAGE_SELECT' : {
		UISetLanguage(commandParamArray[1], AtoI(commandParamArray[2]))
	    }
	}
    }
}

DATA_EVENT[uiDevice] {
    ONLINE: {
	STACK_VAR CHAR key[UI_KEY_MAX_LENGTH]
	
	key = UIGetKeyForDevice(data.device)
	
	UISetLanguage(key, AtoI(UIGetVarValue(key, UI_VAR_LANGUAGE_SELECTED)))
    }
}