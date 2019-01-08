     /*-------------------------------------------------------------*/
     /*   Cmd-ADDMSGD für Message-ID :   USR0001                    */
     /* Programm fehlerhaft beendet. Siehe Joblog.                  */
     /*-------------------------------------------------------------*/

             PGM        PARM(&TOLIB)

             DCL        VAR(&TOLIB) TYPE(*CHAR) LEN(10)

             RMVMSGD MSGID(USR0001) MSGF(&TOLIB/DLTOLDJRNR)
             MONMSG  MSGID(CPF2419)     /* MsgID nicht gefunden */

             ADDMSGD +
                MSGID(USR0001) +
                MSGF(&TOLIB/DLTOLDJRNR) +
                MSG(+
'Programm fehlerhaft beendet. Siehe Joblog.'                          +
                ) +
                SEV(00) +
     /*   Keine Ersatzvariablen definiert!                          */ +
                ALROPT(*NO) +
                CCSID( 65535) +
                /*  -EOF-  */

     /*-------------------------------------------------------------*/
     /*   Cmd-ADDMSGD für Message-ID :   USR0002                    */
     /* Gelöschter Journalempfänger: &2/&1.                         */
     /*-------------------------------------------------------------*/

             RMVMSGD MSGID(USR0002) MSGF(&TOLIB/DLTOLDJRNR)
             MONMSG  MSGID(CPF2419)     /* MsgID nicht gefunden */

             ADDMSGD +
                MSGID(USR0002) +
                MSGF(&TOLIB/DLTOLDJRNR) +
                MSG(+
'Gelöschter Journalempfänger: &2/&1.'                                 +
                ) +
                SEV(00) +
                FMT( +
                    (*CHAR 010) +
                    (*CHAR 010) +
                ) +
                ALROPT(*NO) +
                CCSID( 65535) +
                /*  -EOF-  */

     /*-------------------------------------------------------------*/
     /*   Cmd-ADDMSGD für Message-ID :   USR0003                    */
     /* Anzahl gelöschter Journalempfänger &1 von &2.               */
     /*-------------------------------------------------------------*/

             RMVMSGD MSGID(USR0003) MSGF(&TOLIB/DLTOLDJRNR)
             MONMSG  MSGID(CPF2419)     /* MsgID nicht gefunden */

             ADDMSGD +
                MSGID(USR0003) +
                MSGF(&TOLIB/DLTOLDJRNR) +
                MSG(+
'Anzahl gelöschter Journalempfänger &1 von &2.'                       +
                ) +
                SEV(00) +
                FMT( +
                    (*DEC 010 0) +
                    (*DEC 010 0) +
                ) +
                ALROPT(*NO) +
                CCSID( 65535) +
                /*  -EOF-  */

             RCLRSC LVL(*)

             ENDPGM
