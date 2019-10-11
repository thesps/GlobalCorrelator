-- #########################################################################
-- #########################################################################
-- ###                                                                   ###
-- ###   Use of this code, whether in its current form or modified,      ###
-- ###   implies that you consent to the terms and conditions, namely:   ###
-- ###    - You acknowledge my contribution                              ###
-- ###    - This copyright notification remains intact                   ###
-- ###                                                                   ###
-- ###   Many thanks,                                                    ###
-- ###     Dr. Andrew W. Rose, Imperial College London, 2018             ###
-- ###                                                                   ###
-- #########################################################################
-- #########################################################################

-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;

LIBRARY Utilities;
USE Utilities.Utilities.ALL;

-- synthesis translate_off
library Interfaces;
use Interfaces.mp7_data_types.all;
-- synthesis translate_on
-- synthesis read_comments_as_HDL on
--library xil_defaultlib;
--use xil_defaultlib.emp_data_types.all;
-- synthesis read_comments_as_HDL off
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
PACKAGE DataType IS
-- -------------------------------------------------------------------------

  TYPE tData IS RECORD
  data : lword;
  DataValid : boolean;
  FrameValid : boolean;
END RECORD;

 CONSTANT cNull : tData := (data => lword_null, DataValid => False, FrameValid => False);
-- -------------------------------------------------------------------------       

  FUNCTION ToStdLogicVector( aData     : tData ) RETURN STD_LOGIC_VECTOR;
  FUNCTION ToDataType( aStdLogicVector : STD_LOGIC_VECTOR ) RETURN tData;

  FUNCTION WriteHeader RETURN STRING;
  FUNCTION WriteData( aData : tData ) RETURN STRING;

  FUNCTION from_lword(l : lword) RETURN tData;
  FUNCTION to_lword(d : tData) RETURN lword;

  ATTRIBUTE SIZE : NATURAL;
  ATTRIBUTE SIZE OF tData : TYPE IS 72;  
-- -------------------------------------------------------------------------       

END DataType;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
PACKAGE BODY DataType IS

  FUNCTION ToStdLogicVector( aData : tData ) RETURN STD_LOGIC_VECTOR IS
    VARIABLE lRet                  : STD_LOGIC_VECTOR( 71 DOWNTO 0 ) := ( OTHERS => '0' );
  BEGIN
    lRet(LWORD_WIDTH - 1 downto 0) := aData.data.data;
    lRet(LWORD_WIDTH) := aData.data.valid;
    lRet(LWORD_WIDTH + 1) := aData.data.start;
    lRet(LWORD_WIDTH + 2) := aData.data.strobe;
    RETURN lRet;
  END FUNCTION;

  FUNCTION ToDataType( aStdLogicVector : STD_LOGIC_VECTOR ) RETURN tData IS
    VARIABLE lRet                      : tData := cNull;
  BEGIN
    lRet.data.data := aStdLogicVector(LWORD_WIDTH - 1 downto 0);
    lRet.data.valid := aStdLogicVector(LWORD_WIDTH);
    lRet.data.start := aStdLogicVector(LWORD_WIDTH + 1);
    lRet.data.strobe := aStdLogicVector(LWORD_WIDTH + 2);
    lRet.DataValid := to_boolean(aStdLogicVector(LWORD_WIDTH));
    lRet.FrameValid := to_boolean(aStdLogicVector(LWORD_WIDTH));
    RETURN lRet;
  END FUNCTION;

  FUNCTION WriteHeader RETURN STRING IS
    VARIABLE aLine : LINE;
  BEGIN
    WRITE( aLine , STRING' ( "data" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "valid" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "start" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "strobe" ) , RIGHT , 15 );
    RETURN aLine.ALL;
  END WriteHeader;

  FUNCTION WriteData( aData : tData ) RETURN STRING IS
    VARIABLE aLine          : LINE;
  BEGIN
    WRITE( aLine , TO_INTEGER( unsigned(aData.data.data) ) , RIGHT , 15 );
    WRITE( aLine , aData.data.valid , RIGHT , 15 );
    WRITE( aLine , aData.data.start , RIGHT , 15 );
    WRITE( aLine , aData.data.strobe , RIGHT , 15 );
    RETURN aLine.ALL;
  END WriteData;

  FUNCTION from_lword(l : lword) RETURN tData IS
    VARIABLE d : tData := cNull;
  BEGIN
    d.data := l;
    d.DataValid := to_boolean(l.valid);
    d.FrameValid := to_boolean(l.valid);
    RETURN d;
  END from_lword;

  FUNCTION to_lword(d : tData) RETURN lword IS
    VARIABLE l : lword := lword_null;
  BEGIN
    l := d.data;
    RETURN l;
  END to_lword;

END DataType;
