/* -------------------------------------------------------------------------- */
/* DLTOLDJRNR - SCRIPT MEMBER                                                 */
/* Use commands  xmlgenINC (generate text for install pgm)                    */
/*               xmlgenMBR (to define source members                          */
/*               xmlgenCMD (execute qcmdexc at run time                       */
/* Put &TOLIB where you want user selected lib at run time.                   */
   DCL &TOLIB *CHAR 10
/* -------------------------------------------------------------------------- */
             XMLGENINC  XINCLUDE(*YES)

             XMLGENVRS XSRCFILE(QDLTOLDJRN) XSRCLIB(TOOLS400) XSRCMBR(COPYRIGHT)

             XMLGENCND  XMSG('Select language (GER, ENG)') +
                          XVALUES(GER ENG)

             XMLGENSET  XVAR(&SRCFILE) XVALUE(QDLTOLDJRN)

/* ---------------------------------- */
/*  Deploy source member              */
/* ---------------------------------- */
             XMLGENMBR  XMBR(A_INSTALL ) XMBRATR(CLLE  ) +
                          XFROMSRCF(QDLTOLDJRN) XFROMSRCL(TOOLS400) +
                          XTOSRCF(QDLTOLDJRN) XOBJTYPE(*FILE  ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(A_MSG_ENG ) XMBRATR(CLP   ) +
                          XFROMSRCF(QDLTOLDJRN) XFROMSRCL(TOOLS400) +
                          XTOSRCF(QDLTOLDJRN) XOBJTYPE(*FILE  ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(A_MSG_GER ) XMBRATR(CLP   ) +
                          XFROMSRCF(QDLTOLDJRN) XFROMSRCL(TOOLS400) +
                          XTOSRCF(QDLTOLDJRN) XOBJTYPE(*FILE  ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(A_README  ) XMBRATR(TXT   ) +
                          XFROMSRCF(QDLTOLDJRN) XFROMSRCL(TOOLS400) +
                          XTOSRCF(QDLTOLDJRN) XOBJTYPE(*FILE  ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)
             XMLGENMBR  XMBR(COPYRIGHT ) XMBRATR(RPGLE) +
                          XFROMSRCF(QDLTOLDJRN) XFROMSRCL(UBMSYS  ) +
                          XTOSRCF(QDLTOLDJRN) XOBJTYPE(*CMD ) +
                          XGENCRT(*NO )

             XMLGENMBR  XMBR(DLTOLDJRNG) XMBRATR(CMD  ) +
                          XFROMSRCF(QDLTOLDJRN) XFROMSRCL(UBMSYS  ) +
                          XTOSRCF(QDLTOLDJRN) XOBJTYPE(*CMD ) +
                          XGENCRT(*NO )

             XMLGENMBR  XMBR(DLTOLDJRNE) XMBRATR(CMD  ) +
                          XFROMSRCF(QDLTOLDJRN) XFROMSRCL(UBMSYS  ) +
                          XTOSRCF(QDLTOLDJRN) XOBJTYPE(*CMD ) +
                          XGENCRT(*NO )

             XMLGENMBR  XMBR(DLTOLDJRPG) XMBRATR(PNLGRP) +
                          XFROMSRCF(QDLTOLDJRN) XFROMSRCL(UBMSYS  ) +
                          XTOSRCF(QDLTOLDJRN) XOBJTYPE(*PNLGRP) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(DLTOLDJRPE) XMBRATR(PNLGRP) +
                          XFROMSRCF(QDLTOLDJRN) XFROMSRCL(UBMSYS  ) +
                          XTOSRCF(QDLTOLDJRN) XOBJTYPE(*PNLGRP) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(DLTOLDJRR1) XMBRATR(RPGLE ) +
                          XFROMSRCF(QDLTOLDJRN) XFROMSRCL(UBMSYS  ) +
                          XTOSRCF(QDLTOLDJRN) XOBJTYPE(*PGM   ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(DLTOLDJRR2) XMBRATR(RPGLE ) +
                          XFROMSRCF(QDLTOLDJRN) XFROMSRCL(UBMSYS  ) +
                          XTOSRCF(QDLTOLDJRN) XOBJTYPE(*PGM   ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(H_SPEC    ) XMBRATR(RPGLE ) +
                          XFROMSRCF(QDLTOLDJRN) XFROMSRCL(UBMSYS  ) +
                          XTOSRCF(QDLTOLDJRN) XOBJTYPE(*PGM   ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(USR0001   ) XMBRATR(RPGLE ) +
                          XFROMSRCF(QDLTOLDJRN) XFROMSRCL(UBMSYS  ) +
                          XTOSRCF(QDLTOLDJRN) XOBJTYPE(*PGM   ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(USR0002   ) XMBRATR(RPGLE ) +
                          XFROMSRCF(QDLTOLDJRN) XFROMSRCL(UBMSYS  ) +
                          XTOSRCF(QDLTOLDJRN) XOBJTYPE(*PGM   ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(USR0003   ) XMBRATR(RPGLE ) +
                          XFROMSRCF(QDLTOLDJRN) XFROMSRCL(UBMSYS  ) +
                          XTOSRCF(QDLTOLDJRN) XOBJTYPE(*PGM   ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

/* ---------------------------------- */
/*  Create objects                    */
/* ---------------------------------- */
             XMLGENCMD  XCMD(CRTBNDCL PGM(&TOLIB/A_INSTALL) +
                          SRCFILE(&TOLIB/QDLTOLDJRN) SRCMBR(*PGM) +
                          DFTACTGRP(*NO) ACTGRP(*NEW) +
                          DBGVIEW(*LIST)) XDLTSPLF(A_INSTALL)

             XMLGENCMD  XCMD(CALL PGM(&TOLIB/A_INSTALL) +
                             PARM('&TGTRLS' '&SRCFILE' '&TOLIB' '&LANG'))
             XMLGENCMD  XCMD(DLTPGM PGM(&TOLIB/A_INSTALL))

