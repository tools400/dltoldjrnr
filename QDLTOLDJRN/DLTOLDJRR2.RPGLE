      /IF NOT DEFINED(PROTOTYPE)
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
       //                                                                     *
       //=====================================================================*
       // >>PRE-COMPILER<<                                                    *
       //   >>CRTCMD<< CRTRPGMOD    MODULE(&LI/&OB) +                         *
       //                           SRCFILE(&SL/&SF) SRCMBR(&SM);             *
       //   >>IMPORTANT<<                                                     *
       //     >>PARM<< TRUNCNBR(*NO);                                         *
       //     >>PARM<< DBGVIEW(*LIST);                                        *
       //   >>END-IMPORTANT<<                                                 *
       //   >>EXECUTE<<                                                       *
       // >>END-PRE-COMPILER<<                                                *
       //=====================================================================*
     H NOMAIN
      /COPY QDLTOLDJRN,H_SPEC
      /COPY QDLTOLDJRN,COPYRIGHT

     FQPRINT    O    F  132        PRINTER oflind(*in70) usropn
     D g_printData     S            115A

      /ENDIF
       // ***************************************************************
       //  Exported Prototypes
       // ***************************************************************

     D cLOGGER_NONE    C                   0
     D cLOGGER_BASIC   C                   1
     D cLOGGER_VERBOSE...
     D                 C                   2

       //  Opens the printer file for logging.
     D Logger_open...
     D                 PR
     D                                     extproc('Logger_open')
     D  i_logLvl                     10I 0 value

       //  Appends a basic message to the printer file.
     D Logger_basic...
     D                 PR
     D                                     extproc('Logger_basic')
     D  i_message                   110A   const  varying
     D                                            options(*varsize: *nopass)

       //  Appends a verbose message to the printer file.
     D Logger_verbose...
     D                 PR
     D                                     extproc('Logger_verbose')
     D  i_message                   110A   const  varying
     D                                            options(*varsize: *nopass)

       //  Closes the printer file.
     D Logger_close...
     D                 PR
     D                                     extproc('Logger_close')

      /IF DEFINED(PROTOTYPE)
      /EOF
      /ENDIF

       // ***************************************************************
       //  External Prototypes
       // ***************************************************************

       //  ... Execute Command (QCMDEXC) API
     D QCMDEXC...
     D                 PR                  extpgm('QCMDEXC')
     D  i_cmd                     32702A   const  options(*varsize)
     D  i_length                     15P 5 const
     D  i_IGCprcCtrl                  3A   const  options(*nopass)

     D QCMDEXC_IGC     C                   'IGC'

       // ***************************************************************
       //  Internal Prototypes
       // ***************************************************************

       //  Prints a message.
     D printMessage...
     D                 PR
     D                                     extproc('printMessage')
     D  i_message                   110A   const  varying
     D                                            options(*varsize: *nopass)

       // ***************************************************************
       //  Logger status
       // ***************************************************************

     D g_logger...
     D                 DS                  qualified
     D  logLvl                       10I 0 inz

       // ***************************************************************
       //  O-Spec to print the sample data
       // ***************************************************************
     OQPRINT    e            PrintLine
     O                       g_printData        125

     OQPRINT    e            NewPage           6
     O                       g_printData        125

       // ***************************************************************
       //  Opens the printer file for logging.
       // ***************************************************************
     P Logger_open...
     P                 B                   export
     D                 PI
     D  i_logLvl                     10I 0 value

     D CMD_OVRPRTF     C                   'OVRPRTF FILE(QPRINT) +
     D                                      OVRFLW(60) HOLD(*YES) +
     D                                      USRDTA('''') +
     D                                      SPLFNAME(DLTOLDJRNR) +
     D                                      OVRSCOPE(*CALLLVL)'
       // ------------------------------------------------------------- *
      /FREE

       if (i_logLvl <= cLOGGER_NONE);
          return;
       endif;

       if (not %open(QPRINT));
          qcmdexc(CMD_OVRPRTF: %len(CMD_OVRPRTF));
          open QPRINT;
          *in70 = *on;
       endif;

       g_logger.logLvl = i_logLvl;

      /END-FREE
     P                 E

       // ***************************************************************
       //  Appends a "basic" message to the printer file.
       // ***************************************************************
     P Logger_basic...
     P                 B                   export
     D                 PI
     D  i_message                   110A   const  varying
     D                                            options(*varsize: *nopass)
       // ------------------------------------------------------------- *
      /FREE

       if (g_logger.logLvl < cLOGGER_BASIC);
          return;
       endif;

       if (%parms() >= 1);
          printMessage(i_message);
       else;
          printMessage();
       endif;

      /END-FREE
     P                 E

       // ***************************************************************
       //  Appends a "verbose" message to the printer file.
       // ***************************************************************
     P Logger_verbose...
     P                 B                   export
     D                 PI
     D  i_message                   110A   const  varying
     D                                            options(*varsize: *nopass)
       // ------------------------------------------------------------- *
      /FREE

       if (g_logger.logLvl < cLOGGER_VERBOSE);
          return;
       endif;

       if (%parms() >= 1);
          printMessage(i_message);
       else;
          printMessage();
       endif;

      /END-FREE
     P                 E

       // ***************************************************************
       //  Closes the printer file.
       // ***************************************************************
     P Logger_close...
     P                 B                   export
     D                 PI
       // ------------------------------------------------------------- *
      /FREE

       if (%open(QPRINT));
          close QPRINT;
       endif;

       clear g_logger;

      /END-FREE
     P                 E

       // ***************************************************************
       //  Prints a message.
       // ***************************************************************
     P printMessage...
     P                 B
     D                 PI
     D  i_message                   110A   const  varying
     D                                            options(*varsize: *nopass)
       // ------------------------------------------------------------- *
      /FREE

       if (*in70 = *on);
          except NewPage;
          *in70 = *off;
       endif;

       if (%parms() >= 1);
          g_printData = i_message;
       else;
          g_printData = '';
       endif;

       except PrintLine;

       g_printData = '';

      /END-FREE
     P                 E

