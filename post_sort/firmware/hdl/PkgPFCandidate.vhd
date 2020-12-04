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

-- .library Vertex
-- .include ReuseableElements/PkgUtilities.vhd

-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;

LIBRARY Utilities;
USE Utilities.Utilities.ALL;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
PACKAGE DataType IS

-- -------------------------------------------------------------------------       
  TYPE tData IS RECORD
    ID  : integer range 0 to 7; -- 3 bits unsigned
    pt  : integer range -32768 to 32767; -- 16 bits signed
    eta : integer range -512 to 511; -- 10 bits signed
    phi : integer range -512 to 511; -- 10 bits signed
    data  : integer range 0 to 4095; -- 12 bits unsigned (opaque)
    DataValid    : BOOLEAN;
    FrameValid   : BOOLEAN;
  END RECORD;
  
  ATTRIBUTE SIZE : NATURAL;
  ATTRIBUTE SIZE of tData : TYPE IS 64; 

  CONSTANT cNull                       : tData           := (0,0,0,0,0,false,false);

  FUNCTION ">" ( Left , Right          : tData ) RETURN BOOLEAN;

  FUNCTION ToStdLogicVector( aData     : tData ) RETURN STD_LOGIC_VECTOR;
  FUNCTION ToDataType( aStdLogicVector : STD_LOGIC_VECTOR ) RETURN tData;
  FUNCTION FromW64( aStdLogicVector : STD_LOGIC_VECTOR ) RETURN tData;

  FUNCTION WriteHeader RETURN STRING;
  FUNCTION WriteData( aData : tData ) RETURN STRING;
-- -------------------------------------------------------------------------       

END DataType;
-- -------------------------------------------------------------------------



-- -------------------------------------------------------------------------
PACKAGE BODY DataType IS

  FUNCTION ">" ( Left , Right : tData ) RETURN BOOLEAN IS
  BEGIN
    IF Left.DataValid and Right.DataValid THEN
        IF Left.pt > Right.pt THEN
          RETURN TRUE;
        ELSE
          RETURN FALSE;
        END IF;
    ELSIF Left.DataValid THEN
        RETURN TRUE;
    ELSIF Right.DataValid THEN
        RETURN FALSE;
    ELSE
        RETURN FALSE;
    END IF;
  END FUNCTION;

  FUNCTION ToStdLogicVector( aData : tData ) RETURN STD_LOGIC_VECTOR IS
    VARIABLE lRet                  : STD_LOGIC_VECTOR( tData'Size-1 DOWNTO 0 ) := ( OTHERS => '0' );
  BEGIN
    lRet( 9 downto  0) := std_logic_vector(to_signed(aData.eta, 10));
    lRet(19 downto 10) := std_logic_vector(to_signed(aData.phi, 10));
    lRet(31 downto 20) := std_logic_vector(to_unsigned(aData.data, 12));
    lRet(47 downto 32) := std_logic_vector(to_signed(aData.pt, 16));
    lRet(50 downto 48) := std_logic_vector(to_unsigned(aData.id, 3));
    RETURN lRet;
  END FUNCTION;

  FUNCTION ToDataType( aStdLogicVector : STD_LOGIC_VECTOR ) RETURN tData IS
  BEGIN
    RETURN FromW64(aStdLogicVector);
  END FUNCTION;

  FUNCTION FromW64( aStdLogicVector : STD_LOGIC_VECTOR ) RETURN tData IS
    VARIABLE lRet                   : tData := cNull;
    VARIABLE pt                     : integer := to_integer(signed(aStdLogicVector(47 downto 32)));
  BEGIN
    lRet.eta :=  to_integer(  signed(aStdLogicVector( 9 downto  0)));
    lRet.phi :=  to_integer(  signed(aStdLogicVector(19 downto 10)));
    lRet.data := to_integer(unsigned(aStdLogicVector(31 downto 20)));
    lRet.pt  :=  pt;                              -- 47 downto 32
    lRet.id  :=  to_integer(unsigned(aStdLogicVector(50 downto 48)));
    lRet.DataValid := true when pt /= 0 else false;
    RETURN lRet;
  END FUNCTION;

  FUNCTION WriteHeader RETURN STRING IS
    VARIABLE aLine : LINE;
  BEGIN
    WRITE( aLine , STRING' ( "pt" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "id" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "eta" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "phi" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "data" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "FrameValid" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "DataValid" ) , RIGHT , 15 );
    RETURN aLine.ALL;
  END WriteHeader;

  FUNCTION WriteData( aData : tData ) RETURN STRING IS
    VARIABLE aLine          : LINE;
  BEGIN
    WRITE( aLine , aData.pt , RIGHT , 15 );
    WRITE( aLine , aData.id , RIGHT , 15 );
    WRITE( aLine , aData.eta , RIGHT , 15 );
    WRITE( aLine , aData.phi , RIGHT , 15 );
    WRITE( aLine , aData.data , RIGHT , 15 );
    WRITE( aLine , aData.FrameValid , RIGHT , 15 );
    WRITE( aLine , aData.DataValid , RIGHT , 15 );
    RETURN aLine.ALL;
  END WriteData;

END DataType;
