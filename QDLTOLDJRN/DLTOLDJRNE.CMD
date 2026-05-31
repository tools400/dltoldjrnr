/* =================================================================== */
/*                                                                     */
/*  Kurzdokumentation :                                                */
/*                                                                     */
/*  Bereich . . . : DLTOLDJRNR                                         */
/*  Objekt  . . . : DLTOLDJRNR                                         */
/*  Beschreibung  : Tool: DLTOLDJRNR (Delete old Journal Rcv    )      */
/*  Author  . . . : Thomas Raddatz   <thomas.raddatz@tools400.de>      */
/*  Datum . . . . : 25.07.2001                                         */
/*                                                                     */
/* =================================================================== */
/*                                                                     */
/*  This software is free software, you can redistribute it and/or     */
/*  modify it under the terms of the GNU General Public License (GPL)  */
/*  as published by the Free Software Foundation.                      */
/*                                                                     */
/*  See GNU General Public License for details.                        */
/*          http://www.opensource.org                                  */
/*          http://www.opensource.org/licenses/gpl-license.html        */
/*                                                                     */
/* =================================================================== */
/*  History:                                                           */
/*                                                                     */
/*  Datum       Name          Änderung                                 */
/*  ----------  ------------  ---------------------------------------  */
/*                                                                     */
/* =================================================================== */
/* >>PRE-COMPILER<<                                                    */
/*                                                                     */
/*   >>CRTCMD<< CRTCMD       CMD(&LI/DLTOLDJRNR) +                     */
/*                           SRCFILE(&SL/&SF) +                        */
/*                           SRCMBR(&SM);                              */
/*                                                                     */
/*   >>COMPILE<<                                                       */
/*     >>PARM<< PGM(&LI/DLTOLDJRNR);                                   */
/*     >>PARM<< HLPPNLGRP(&LI/DLTOLDJRP );                             */
/*     >>PARM<< HLPID(DLTOLDJRNR);                                     */
/*   >>END-COMPILE<<                                                   */
/*                                                                     */
/*   >>EXECUTE<<                                                       */
/*                                                                     */
/* >>END-PRE-COMPILER<<                                                */
/* =================================================================== */

            CMD PROMPT('Delete old Journal Receiver')

      /* ------------------------------------------------------------ */
      /* Parameters for journal information                           */
      /* (QjoRetrieveJournalInformation)                              */
      /* ------------------------------------------------------------ */

            PARM KWD(JRN)        +
                 TYPE(QUAL1)     +
                 MIN(1)          +
                 PROMPT('Journal' 1)

      /* ------------------------------------------------------------ */
      /* Parameters for selection of receiver                         */
      /* ------------------------------------------------------------ */

            PARM KWD(AGE)        +
                 TYPE(*DEC)      +
                 LEN(3 0)        +
                 MIN(1)          +
                 PROMPT('Age (days)' 5)

      /* ------------------------------------------------------------ */
      /* Processing parameters                                        */
      /* ------------------------------------------------------------ */
            PARM KWD(DETACH) +
                 TYPE(*CHAR) +
                 LEN(10) +
                 RSTD(*YES) +
                 DFT(*NO) +
                 SPCVAL( +
                        (*NO  )  +
                        (*YES )) +
                 MIN(0) +
                 PROMPT('Detach curr. journal reveicer' 2)

            PARM KWD(SAVOPT) +
                 TYPE(*CHAR) +
                 LEN(10) +
                 RSTD(*YES) +
                 DFT(*SAVEDONLY) +
                 SPCVAL( +
                        (*SAVEDONLY  )  +
                        (*ALL        )) +
                 MIN(0) +
                 PROMPT('Save option' 3)

      /* ------------------------------------------------------------ */
      /* Parameters for DLTJRNRCV command                             */
      /* ------------------------------------------------------------ */
            PARM KWD(DLTOPT) +
                 TYPE(*CHAR) +
                 LEN(11) +
                 RSTD(*YES) +
                 DFT(*NONE) +
                 SPCVAL( +
                        (*IGNINQMSG  )  +
                        (*IGNEXITPGM )  +
                        (*IGNTGTRCV  )) +
                 SNGVAL((*NONE )) +
                 MIN(0) +
                 MAX(3) +
                 PROMPT('Option' 4)

      /* ------------------------------------------------------------ */
      /* Parameters for log output                                    */
      /* ------------------------------------------------------------ */
            PARM KWD(LOGLVL) +
                 TYPE(*INT2) +
                 RSTD(*YES) +
                 DFT(*NONE) +
                 SPCVAL( +
                        (*NONE     0 )  +
                        (*BASIC    1 )  +
                        (*VERBOSE  2 )) +
                 MIN(0) +
                 PMTCTL(*PMTRQS) +
                 PROMPT('Log level' 6)

      /* ------------------------------------------------------------ */

   QUAL1:   QUAL TYPE(*NAME) LEN(10)
            QUAL TYPE(*NAME) LEN(10) SPCVAL(*LIBL *CURLIB)               +
                 DFT(*LIBL) +
                 PROMPT('Library')

