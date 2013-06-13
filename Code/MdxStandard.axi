
#define MDXSTANDARD_INCLUDED


(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

// Allow programmer to override some things
#if_not_defined MDX_MAX_PARAMS
MDX_MAX_PARAMS    = 5;
#end_if
#if_not_defined MDX_MAX_PARAMLEN
MDX_MAX_PARAMLEN  = 96;
#end_if
#if_not_defined MDX_MAX_DATALEN
MDX_MAX_DATALEN   = 512;
#end_if
(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE



// For the command parser
Structure MDX_PARAMETERS
{
    sinteger 	count; 	// Count of detected parameters, or -1 if there was a problem.
    char    	param[MDX_MAX_PARAMS][MDX_MAX_PARAMLEN]	// List of detected parameters
    char    	rawdata[MDX_MAX_DATALEN]				// The raw parameter data. Anything rightside of '=' or '?' for special use.
};

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)


///////////////////////////////////////////////////////////////////////////////
// ##########
// # Name   : ==== fn_MdxParseASCIIDataExchange ====
// # Purpose: To parse out command and parameter data from module send_command or send_string
// # Params : (1) IN  - module send_command/string data
// #          (2) IN  - list of possible seperater char's usualy single '|' or ':', 
// #          (3) OUT - parsed property/method name part
// #          (4) OUT - parsed property/method numeric part
// #          (5) OUT - MDX_PARAMETERS structure
// #          (6) OUT - flag indicating command is a SET method
// #          (7) OUT - flag indicating command is a GET query
// # Returns: None.
// # Notes  : Parses the strings sent to or from modules extracting the various parts
// #          of the command out into command name, parameters and returning the count
// #          of parameters present. If set/get indicators are not present isMethod(5)
// #          and isQuery(6) will be false. Assci content from the left entity is rturned  
// #          in (3), numeric content is contained in (4).
// ##########
Define_Function fn_MdxParseASCIIDataExchange(char cmddata[], char separator[], char name[], integer numeric, MDX_PARAMETERS params, char isMethod, char isQuery)
{
    integer lenData, mxlenName, i;
    integer nToken; // Current token value: 0=name; 1+ = nParameter
    char sNumeric[32]
    
    //// Get the lengths
    lenData   = Length_String(cmddata);   
    mxlenName = Max_Length_String(name);  // Space in "name"
	
	// Assume an error
	params.count = -1;
    
    // Examine every char
    for(i = 1; i <= lenData; i++)
    {
        select
        {   
            // Found the set operator
            active(cmdData[i] == '='): 
            {
                if(!nToken) // Only if before params
                {
                    nToken++;
                    isMethod = 1;
                    continue;
                }
                
            }                        
            // Found the get operator
            active(cmdData[i] == '?'): 
            {
                if(!nToken) // Only if before params
                {
                    nToken++;
                    isQuery = 1;
                    continue;
                }
            }
            // Look for one of the possible seperator chars
            active(Find_String("separator","cmdData[i]",1)):
            {
                if(nToken) // Only for parameters
                {   
                    params.rawdata = "params.rawdata,cmdData[i]";
                    nToken++;
                    continue;
                }                
            }
            // Look for leftside numerics
            active(cmdData[i] >= '0' and cmdData[i] <= '9'):
            {
                if(!nToken) // Only during the name copy
                {
                    if(Length_String(sNUmeric) < Max_Length_String(sNumeric))
                    {
                            sNumeric = "sNumeric,cmdData[i]"; // copy to the numerics buffer
                    }
                    continue;
                }
                else
                {
                    // Allow numerics to be copied to the params after the name copy
                }
            }                                
        }
        
		// Good so far but no params known as yet.
		if(params.count == -1) params.count = 0
		
        // Copy the params to the rawdata member and param[x] members
        if(nToken)
        {
            // Copy to rawdata anyway for special parsing
            params.rawdata = "params.rawdata,cmdData[i]";
            
            // Copy to the correct param
            if(nToken <= MDX_MAX_PARAMS)
			{
				if(Length_String(params.param[nToken]) < MDX_MAX_PARAMLEN)
				{
					params.param[nToken] = "params.param[nToken],cmdData[i]";
				}
				
				// Set the length of the param array and count var
				if(Length_Array(params.param) < nToken)
				{
					Set_Length_Array(params.param, nToken);
					params.count = Type_Cast(nToken);
				}
			}
        }
        // Other wise copy to the name string
        else
        {
            if(Length_String(name) < Max_Length_String(name))
            {
                name = "name,cmdData[i]";
            }
        }
    }
    
    // Convert any leftside digits found
    if(Length_String(sNumeric)) numeric = atoi(sNumeric);
	
	// Set the param count flag
	
}



(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START


(***********************************************************)
(*                THE EVENTS GOES BELOW                    *)
(***********************************************************)
DEFINE_EVENT

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)