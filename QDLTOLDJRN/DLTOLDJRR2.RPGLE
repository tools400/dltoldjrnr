**free
/if NOT defined(PROTOTYPE)
//=====================================================================*
//                                                                     *
//  Kurzdokumentation :                                                *
//                                                                     *
//  Bereich . . . : DLTOLDJRNR                                         *
//  Objekt  . . . : DLTOLDJRR2                                         *
//  Beschreibung  : Tool: DLTOLDJRNR (Delete old Journal Rcv    ) Log  *
//  Author  . . . : Thomas Raddatz   <thomas.raddatz@tools400.de>      *
//  Datum . . . . : 08.01.2011                                         *
//                                                                     *
//=====================================================================*
//                                                                     *
//  This software is free software, you can redistribute it and/or     *
//  modify it under the terms of the GNU General Public License (GPL)  *
//  as published by the Free Software Foundation.                      *
//                                                                     *
//  See GNU General Public License for details.                        *
//          http://www.opensource.org                                  *
//          http://www.opensource.org/licenses/gpl-license.html        *
//                                                                     *
//=====================================================================*
//  History:                                                           *
//                                                                     *
//  Datum       Name          Änderung                                 *
//  ----------  ------------  ---------------------------------------  *
//  08.01.2019  Th.Raddatz    Converted to /free.                      *
//  31.05.2026  Th.Raddatz    Extracted spooled file printer to        *
//                            module DLTOLDJRR3.
//                                                                     *
//=====================================================================*
// >>PRE-COMPILER<<                                                    *
//   >>CRTCMD<< CRTRPGMOD    MODULE(&LI/&OB) +                         *
//                           SRCFILE(&SL/&SF) SRCMBR(&SM);             *
//   >>IMPORTANT<<                                                     *
//     >>PARM<< TRUNCNBR(*NO);                                         *
//     >>PARM<< DBGVIEW(*LIST);                                        *
//     >>PARM<< OPTION(*EVENTF);                                       *
//   >>END-IMPORTANT<<                                                 *
//   >>EXECUTE<<                                                       *
// >>END-PRE-COMPILER<<                                                *
//=====================================================================*
ctl-opt nomain;
/copy QDLTOLDJRN,H_SPEC
/copy QDLTOLDJRN,COPYRIGHT

/endif
// ***************************************************************
//  Exported Prototypes
// ***************************************************************

dcl-c cLOGGER_NONE 0;
dcl-c cLOGGER_BASIC 1;
dcl-c cLOGGER_VERBOSE 2;

//  Opens the printer file for logging.
dcl-pr Logger_open extproc('Logger_open');
  i_logLvl int(10) value;
end-pr;

//  Appends a basic message to the printer file.
dcl-pr Logger_basic extproc('Logger_basic');
  i_message varchar(110) options(*varsize: *nopass) const;
end-pr;

//  Appends a verbose message to the printer file.
dcl-pr Logger_verbose extproc('Logger_verbose');
  i_message varchar(110) options(*varsize: *nopass) const;
end-pr;

//  Closes the printer file.
dcl-pr Logger_close extproc('Logger_close');
end-pr;

/if defined(PROTOTYPE)
/eof
/endif

// ***************************************************************
//  External Prototypes
// ***************************************************************

/define PROTOTYPE
/copy QDLTOLDJRN,DLTOLDJRR3
/undefine PROTOTYPE

// ***************************************************************
//  Logger status
// ***************************************************************

dcl-ds g_logger qualified;
  logLvl int(10) inz;
end-ds;

// ***************************************************************
//  Opens the printer file for logging.
// ***************************************************************
dcl-proc Logger_open export;
  dcl-pi *n;
    i_logLvl int(10) value;
  end-pi;

  // Page size: DIN A4
  dcl-s cmd_ovrPrtF varchar(250);
  // ------------------------------------------------------------- *

  if (i_logLvl <= cLOGGER_NONE);
    return;
  endif;

  SpooledFile_openForDinA4Pages();

  g_logger.logLvl = i_logLvl;

end-proc;

// ***************************************************************
//  Appends a "basic" message to the printer file.
// ***************************************************************
dcl-proc Logger_basic export;
  dcl-pi *n;
    i_message varchar(110) options(*varsize: *nopass) const;
  end-pi;
  // ------------------------------------------------------------- *

  if (g_logger.logLvl < cLOGGER_BASIC);
    return;
  endif;

  if (%parms() >= 1);
    appendMessage(i_message);
  else;
    appendMessage('');
  endif;

end-proc;

// ***************************************************************
//  Appends a "verbose" message to the printer file.
// ***************************************************************
dcl-proc Logger_verbose export;
  dcl-pi *n;
    i_message varchar(110) options(*varsize: *nopass) const;
  end-pi;
  // ------------------------------------------------------------- *

  if (g_logger.logLvl < cLOGGER_VERBOSE);
    return;
  endif;

  if (%parms() >= 1);
    appendMessage(i_message);
  else;
    appendMessage('');
  endif;

end-proc;

// ***************************************************************
//  Closes the printer file.
// ***************************************************************
dcl-proc Logger_close export;
  dcl-pi *n;
  end-pi;
  // ------------------------------------------------------------- *

  if (SpooledFile_isOpen());
    SpooledFile_close();
  endif;

  clear g_logger;

end-proc;

// ***************************************************************
//  Appends a message to the log output.
// ***************************************************************
dcl-proc appendMessage export;
  dcl-pi *n extproc(*dclcase);
    i_message varchar(110) options(*varsize: *nopass) const;
  end-pi;
  // ------------------------------------------------------------- *

  if (%parms() >= 1);
    SpooledFile_print(i_message);
  else;
    SpooledFile_print('');
  endif;

end-proc;

