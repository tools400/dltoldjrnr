     /*-------------------------------------------------------------*/
     /*   Cmd-ADDMSGD für Message-ID :   USR0001                    */
     /* Program ended with errors. See job log.                     */
     /*-------------------------------------------------------------*/

             PGM        PARM(&TOLIB)

             DCL        VAR(&TOLIB) TYPE(*CHAR) LEN(10)

             RMVMSGD MSGID(USR0001) MSGF(&TOLIB/DLTOLDJRNR)
             MONMSG  MSGID(CPF2419)     /* MsgID nicht gefunden */

             ADDMSGD +
                MSGID(USR0001) +
                MSGF(&TOLIB/DLTOLDJRNR) +
                MSG(+
'Program ended with errors. See job log.'                             +
                ) +
                SEV(00) +
     /*   Keine Ersatzvariablen definiert!                          */ +
                ALROPT(*NO) +
                CCSID( 65535) +
                /*  -EOF-  */

     /*-------------------------------------------------------------*/
     /*   Cmd-ADDMSGD für Message-ID :   USR0002                    */
     /* Deleted journal receiver: &2/&1.                            */
     /*-------------------------------------------------------------*/

             RMVMSGD MSGID(USR0002) MSGF(&TOLIB/DLTOLDJRNR)
             MONMSG  MSGID(CPF2419)     /* MsgID nicht gefunden */

             ADDMSGD +
                MSGID(USR0002) +
                MSGF(&TOLIB/DLTOLDJRNR) +
                MSG(+
'Deleted journal receiver: &2/&1.'                                    +
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
     /* &1 of &2 journal receiver deleted.                          */
     /*-------------------------------------------------------------*/

             RMVMSGD MSGID(USR0003) MSGF(&TOLIB/DLTOLDJRNR)
             MONMSG  MSGID(CPF2419)     /* MsgID nicht gefunden */

             ADDMSGD +
                MSGID(USR0003) +
                MSGF(&TOLIB/DLTOLDJRNR) +
                MSG(+
'&1 of &2 journal receiver deleted.'                                  +
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
