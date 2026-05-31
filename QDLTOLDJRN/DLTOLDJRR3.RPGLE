**free
/if NOT defined(PROTOTYPE)
//=====================================================================*
//                                                                     *
//  Kurzdokumentation :                                                *
//                                                                     *
//  Bereich . . . : DLTOLDJRNR                                         *
//  Objekt  . . . : DLTOLDJRR3                                         *
//  Beschreibung  : Delete Old Journal Receivers - Printer             *
//  Author  . . . : Thomas Raddatz   <thomas.raddatz@tools400.de>      *
//  Datum . . . . : 31.05.2026                                         *
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
//  31.05.2026  Th.Raddatz    Initial version.                         *
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

dcl-f qsysprt printer(132) usage(*output) oflind(g_printStatus.overflow) infds(g_printFeedback)
  usropn;

dcl-ds g_printFeedback qualified;
  cur_line int(5) pos(367);
  cur_page int(10) pos(369);
end-ds;

dcl-ds g_printStatus qualified;
  overflow ind inz(*off);
end-ds;

dcl-ds g_printConfig likeds(spooledFileConfig_t);

/endif
// ***************************************************************
//  Public API
// ***************************************************************

// Spooled file configuration for DIN A4 pages.
dcl-ds spooledFileConfig_t qualified template;
  leftBorder   int(5) inz(10);
  rightBorder  int(5) inz(5);
  topMargin    int(5) inz(5);
  pageLength   int(5) inz(70);
  pageWidth    int(5) inz(80);
  pageOverflow int(5) inz(66);
  cpi          int(5) inz(10); // 80 characters per line
  lpi          int(5) inz(6); // 70 lines on DIN A4 page
end-ds;

//  Opens the spooled file file for printing.
dcl-pr SpooledFile_open extproc('SpooledFile_open');
  i_config likeds(spooledFileConfig_t) value;
end-pr;

//  Opens the spooled file file for DIN A4 pages.
dcl-pr SpooledFile_openForDinA4Pages extproc('SpooledFile_openForDinA4Pages');
end-pr;

//  Returns *ON if the spoole file is open, otherwise *OFF.
dcl-pr SpooledFile_isOpen ind extproc('SpooledFile_isOpen');
end-pr;

//  Appends a line to the spooled file.
dcl-pr SpooledFile_print extproc('SpooledFile_print');
  i_line varchar(132) options(*varsize: *nopass) const;
end-pr;

//  Closes the spooled file.
dcl-pr SpooledFile_close extproc('SpooledFile_close');
end-pr;

/if defined(PROTOTYPE)
/eof
/endif

// ***************************************************************
//  Opens the spooled file file for DIN A4 pages.
// ***************************************************************
dcl-proc SpooledFile_openForDinA4Pages export;
  dcl-pi *n;
  end-pi;

  dcl-ds spooledFileConfig_A4 likeds(spooledFileConfig_t);

  spooledFileConfig_A4.leftBorder = 10;
  spooledFileConfig_A4.rightBorder = 5;
  spooledFileConfig_A4.topMargin = 5;
  spooledFileConfig_A4.pageLength = 70;
  spooledFileConfig_A4.pageWidth = 80;
  spooledFileConfig_A4.pageOverflow = 66;
  spooledFileConfig_A4.cpi = 10; // 80 characters per line
  spooledFileConfig_A4.lpi = 6; // 70 lines on DIN A4 page

  SpooledFile_open(spooledFileConfig_A4);

end-proc;

// ***************************************************************
//  Opens the spooled file file for printing.
// ***************************************************************
dcl-proc SpooledFile_open export;
  dcl-pi *n;
    i_config likeds(spooledFileConfig_t) value;
  end-pi;

  // Page size: DIN A4
  dcl-s cmd_ovrPrtF varchar(250);


  //  ... Execute Command (QCMDEXC) API
  dcl-pr QCMDEXC extpgm('QCMDEXC');
    i_cmd        char(32702) options(*varsize) const;
    i_length     packed(15: 5) const;
    i_IGCprcCtrl char(3) options(*nopass) const;
  end-pr;

  dcl-c QCMDEXC_IGC 'IGC';
  // ------------------------------------------------------------- *

  g_printConfig = i_config;

  if (not %open(QSYSPRT));
    //@formatter:off
    cmd_ovrPrtF = 'OVRPRTF FILE(QSYSPRT) HOLD(*YES) USRDTA('''') +
                   SPLFNAME(DLTOLDJRNR) +
                   PAGESIZE(' + %char(g_printConfig.pageLength) + ' ' +
                                %char(g_printConfig.pageWidth) + ') +
                   LPI(' + %char(g_printConfig.lpi) + ') +
                   CPI(' + %char(g_printConfig.cpi) + ') +
                   OVRFLW(' + %char(g_printConfig.pageOverflow) + ') +
                   OVRSCOPE(*CALLLVL)';
    //@formatter:off
    qcmdexc(cmd_ovrPrtF: %len(cmd_ovrPrtF));
    open QSYSPRT;
    clear g_printStatus;
    g_printStatus.overflow = *off;
    clear g_printFeedback;
    g_printFeedback.cur_line = 0;
    g_printFeedback.cur_page = 0;
  endif;

end-proc;

// ***************************************************************
//  Returns *ON if the spoole file is open, otherwise *OFF.
// ***************************************************************
dcl-proc SpooledFile_isOpen export;
  dcl-pi *n ind;
  end-pi;
  // ------------------------------------------------------------- *

  return %open(QSYSPRT);

end-proc;

// ***************************************************************
//  Closes the spooled file.
// ***************************************************************
dcl-proc SpooledFile_close export;
  dcl-pi *n;
  end-pi;
  // ------------------------------------------------------------- *

  if (%open(QSYSPRT));
    close QSYSPRT;
  endif;

  clear g_printConfig;

end-proc;

// ***************************************************************
//  Appends a line to the spooled file.
// ***************************************************************
dcl-proc SpooledFile_print export;
  dcl-pi *n;
    i_line varchar(132) options(*varsize: *nopass) const;
  end-pi;

  dcl-ds printLine len(132);
  end-ds;

  dcl-s cur_page int(10);
  // ------------------------------------------------------------- *

  if (g_printStatus.overflow);

    // Skip to next page
    cur_page = g_printFeedback.cur_page;
    dow (cur_page = g_printFeedback.cur_page);
      printLine = '';
      write QSYSPRT printLine;
    enddo;

    g_printStatus.overflow = *off;
  endif;


  // Skip to first line
  dow (g_printFeedback.cur_line <= g_printConfig.topMargin);
    printLine = '';
    write QSYSPRT printLine;
  enddo;

  if (%parms() >= %parmnum(i_line));
    // Create left margin
    %subst(printLine: g_printConfig.leftBorder) = i_line;
  else;
    printLine = '';
  endif;

  write QSYSPRT printLine;

  printLine = '';

end-proc;

