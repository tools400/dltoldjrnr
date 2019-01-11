       //=====================================================================*
       //                                                                     *
       //  Kurzdokumentation :                                                *
       //                                                                     *
       //  Bereich . . . : DLTOLDJRNR                                         *
       //  Objekt  . . . : DLTOLDJRR1                                         *
       //  Beschreibung  : Tool: DLTOLDJRNR (Delete old Journal Rcv    ) CPP  *
       //  Author  . . . : Thomas Raddatz   <thomas.raddatz@tools400.de>      *
       //  Datum . . . . : 25.07.2001                                         *
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
       //  10.01.2003  Th.Raddatz    Removed special character § from source. *
       //                                                                     *
       //  16.12.2003  Th.Raddatz    Added mesage files.                      *
       //                                                                     *
       //  20.05.2008  Th.Raddatz    Changed parameter 'AGE' to mandatory.    *
       //                                                                     *
       //  24.05.2012  Th.Raddatz    Fixed "Object not found" error when      *
       //                            'curRcvNme' is blanks when searching     *
       //                            the oldest receiver and having reached   *
       //                            the very first receiver of the journal.  *
       //                                                                     *
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
       //   >>CMD<<    CRTPGM       PGM(&LI/DLTOLDJRNR) +                     *
       //                           MODULE(&LI/&OB  +                         *
       //                                  &LI/DLTOLDJRR2) +                  *
       //                           DETAIL(*BASIC) +                          *
       //                           ACTGRP(*NEW);                             *
       // >>END-PRE-COMPILER<<                                                *
       //=====================================================================*
      /COPY QDLTOLDJRN,H_SPEC
      /COPY QDLTOLDJRN,COPYRIGHT

       // ***************************************************************
       //  External Prototypes
       // ***************************************************************
     D qjoRtvJrnInf...
     D                 PR                  extproc('QjoRetrieveJournal-
     D                                     Information')
     D  rcvVar                     2048A         options(*varsize)
     D  rcvVarLen                    10I 0 const
     D  qJrnNme                      20A   const
     D  format                        8A   const
     D  jrnInfRtv                  2048A   const options(*varsize)
     D  errorCode                   272A         options(*varsize: *omit)

     D qjoRtvJrnRcvInf...
     D                 PR                  extproc('QjoRtvJrnReceiver-
     D                                     Information')
     D  rcvVar                     2048A         options(*varsize)
     D  rcvVarLen                    10I 0 const
     D  qJrnRcvNme                   20A   const
     D  format                        8A   const
     D  errorCode                   272A         options(*varsize: *omit)

     D QMHSNDPM...
     D                 PR                  extpgm('QMHSNDPM')
     D  msgID                         7A   const
     D  qMsgF                        20A   const
     D  msgDta                     2048A   const options(*varsize)
     D  msgDtaLen                    10I 0 const
     D  msgType                      10A   const
     D  callStkEnt                   10A   const
     D  callStkCnt                   10I 0 const
     D  msgKey                        4A   const
     D  errorCode                   272A         options(*varsize)

     D QMHRTVM...
     D                 PR                  extpgm('QMHRTVM')
     D  o_msgInf                  65535A          options(*varsize)
     D  i_msgInfLen                  10I 0 const
     D  i_format                      8A   const
     D  i_msgID                       7A   const
     D  i_qMsgF                      20A   const
     D  i_rplData                 65535A   const  options(*varsize )
     D  i_rpldataLen                 10I 0 const
     D  i_rplVars                    10A   const
     D  i_rtnCtrlChrs                10A   const
     D  io_ErrCode                65535A          options(*varsize )

     D rtvm0100_t      DS                  qualified               based(pDummy)
     D  bytRet                       10I 0
     D  bytAvl                       10I 0
     D  lenMsgRet                    10I 0
     D  lenMsgAvl                    10I 0
     D  lenHelpRet                   10I 0
     D  lenHelpAvl                   10I 0
     D  data                       2048A

       // ***************************************************************
       //  External Prototypes
       // ***************************************************************
      /DEFINE PROTOTYPE
      /COPY QDLTOLDJRN,DLTOLDJRR2
      /UNDEFINE PROTOTYPE

     D DLTOLDJRR1...
     D                 PR                  extpgm('DLTOLDJRNR')
     D  i_qJrnNme                          const likeds(qObj_t)
     D  i_ageInDays                   3P 0 const
     D  i_detach                     10A   const
     D  i_savOpt                     10A   const
     D  i_ds_dltOpt                        const likeds(ds_dltOpt_t)
     D  i_logLvl                      5I 0 const

       // ***************************************************************
       //  Internal Prototypes
       // ***************************************************************

     D main...
     D                 PR

     D apiTimeStmp_to_timeStmp...
     D                 PR              Z
     D  i_timeStamp13                13A   value

     D execSysCmd...
     D                 PR              N
     D  i_cmd                      1024A   value
     D  o_errorCode                               likeds(errorCode_t)

     D rtvJrnRcvInf...
     D                 PR              N
     D  i_jrnRcvNme                  10A   value
     D  i_jrnRcvLib                  10A   value
     D  o_rcvVar                   2048A

     D getReceiverStatus...
     D                 PR            64A   varying
     D  i_status                      1A   const

     D receiverWasSaved...
     D                 PR              N
     D  i_status                      1A   const

     D rtvMsgText...
     D                 PR           256A          varying
     D                                     extproc('rtvMsgText')
     D  i_errorCode                        const  likeds(errorCode_t)
     D  i_qMsgF                            const  likeds(qObj_t)
     D                                            options(*nopass)

     D sndDiagMsg...
     D                 PR                  extproc('sndDiagMsg')
     D  i_errorCode                        const  likeds(errorCode_t)

     D sndInfoMsg...
     D                 PR                  extproc('sndInfoMsg')
     D  i_msgID                       7A   const
     D  i_msgDta                    512A   const  varying

     D kill...
     D                 PR                  extproc('kill')
     D  i_msgID                       7A   const
     D  i_msgDta                   2048A   const options(*varsize)
     D  i_size                       10I 0 const

     D inzApiErrorCode...
     D                 PR                  likeds(errorCode_t)
     D                                     extproc('inzApiErrorCode')

       // ***************************************************************
       //  Type Definitions
       // ***************************************************************

     D qObj_t          DS                  qualified based(pDummy)
     D  name                         10A
     D  lib                          10A

     D ds_dltOpt_t     DS                  qualified based(pDummy)
     D  numE                          5I 0
     D  value                        11A   dim(3)

     D errorCode_t     DS                                          based(pDummy)
     D  bytPrv                       10I 0                                      Bytes provided
     D  bytAvl                       10I 0                                      Bytes availabl
     D  excID                         7A                                        Exception ID
     D  res_01                        1A                                        Reserved
     D  excDta                      256A                                        Exception data

       // ***************************************************************
       //  Global constants
       // ***************************************************************
     D cErrMsg         C                   const('Programm fehlerhaft beendet.')

     D qCPFMSG         DS                  qualified
     D  name                         10A   inz('QCPFMSG')
     D  lib                          10A   inz('QSYS'   )

     D qJRNMSG         DS                  qualified
     D  name                         10A   inz('DLTOLDJRNR')
     D  lib                          10A   inz

       // ***************************************************************
       //  *ENTRY - Parameter defined as global
       // ***************************************************************

       // Prototype for 'QCAPCMD'
     D QCAPCMD         PR                  EXTPGM('QCAPCMD')
     d  i_cmd                     32702A   const  options(*varsize)
     d  i_cmdLen                     10i 0 const
     d  i_ctrlBlk                 32767A   const  options(*varsize)
     d  i_ctrlBlkLen                 10i 0 const
     d  i_ctrlBlkFmt                  8a   const
     d  o_chgCmd                  32702A          options(*varsize)
     d  i_chgCmdLnPrv                10i 0 const
     d  o_chgCmdLnAvl                10i 0
     d  io_errorCode              32767A          options(*varsize)

       // Option control block
     d cpop0100_t      ds                  qualified based(pDummy)
     d  typeCmdPrc             1      4I 0
     d  DBCS_data              5      5A
     d  prmtAction             6      6A
     d  cmdStrSyntax           7      7A
     d  msgRtvKey              8     11A
     d  res_01                12     20A

      /DEFINE SDS_EXTENDED
      /COPY QCRTMSGDS,SDS

       // ***************************************************************
       //              EXECUTABLE CODE STARTS HERE
       // ***************************************************************
     D DLTOLDJRR1...
     D                 PI
     D  i_qJrnNme                          const likeds(qObj_t)
     D  i_ageInDays                   3P 0 const
     D  i_detach                     10A   const
     D  i_savOpt                     10A   const
     D  i_ds_dltOpt                        const likeds(ds_dltOpt_t)
     D  i_logLvl                      5I 0 const
      /FREE

       main();

       *inlr = *on;

      /END-FREE

       // ***************************************************************
       //  main program control
       //  (This ensures to have local variables in main stream, too.)
       // ***************************************************************
     P main...
     P                 B
     D                 PI

       // ---------------------------------------------------------------
       //  Definitions for QjoRetrieveJournalInformation
       // ---------------------------------------------------------------
     D RJRN0100        DS                  qualified
     D  bytRet                       10I 0 inz                                  Bytes Returned
     D  bytAvl                       10I 0 inz                                  Bytes Availabl
     D  ofsKeyInf                    10I 0 inz                                  Offset Key Inf
     D  jrnNme                       10A   inz                                  Journal Name
     D  jrnLib                       10A   inz                                  Journal Librar
     D  auxSP                        10I 0 inz                                  Aux Stg Pool
     D  msgQNme                      10A   inz                                  Message Queue
     D  msgQLib                      10A   inz                                  Message Queue
     D  mgeRcvOpt                     1A   inz                                  Manage Receive
     D  dltRcvOpt                     1A   inz                                  Delete Receive
     D  rcvSizRmv                     1A   inz                                  RcvSizOpt *RMV
     D  rcvSizMin                     1A   inz                                  RcvSizOpt *MIN
     D  res_01                        5A   inz                                  Reserved 01
     D  jrnTyp                        1A   inz                                  Journal Type
     D  rmtJrnTyp                     1A   inz                                  Rmt Journal Ty
     D  jrnState                      1A   inz                                  Journal State
     D  jrnDlvMde                     1A   inz                                  Journal Delive
     D  lclJrnNme                    10A   inz                                  Local Journal
     D  lclJrnLib                    10A   inz                                  Local Journal
     D  lclJrnSys                     8A   inz                                  Local Journal
     D  srcJrnNme                    10A   inz                                  Source Journal
     D  srcJrnLib                    10A   inz                                  Source Journal
     D  srcJrnSys                     8A   inz                                  Source Journal
     D  rdrRcvLib                    10A   inz                                  Redirected Rcv
     D  jrnTxt                       50A   inz                                  Journal Text
     D  res_02                       11A   inz                                  Reserved 02
     D  nbrAttRcv                    10I 0 inz                                  Nbr attached R
     D  attRcvNme                    10A   inz                                  Attached Rcv N
     D  attRcvLib                    10A   inz                                  Attached Rcv L
     D  lclJnSyAR                     8A   inz                                  Lcl Jrn Sys at
     D  srcJnSyAR                     8A   inz                                  Src Jrn Sys at
     D  att2RcvNm                    10A   inz                                  Attached dual
     D  att2RcvLb                    10A   inz                                  Attached dual
     D  res_03                      192A   inz                                  Reserved 03
     D  nbrKeys                      10I 0 inz                                  Nbr Keys in Ke

     D jrnInfRtv       DS                  qualified
     D  nbrVarLenRec                 10I 0 inz                                  Jrn Inf to ret

       // ---------------------------------------------------------------
       //  Definitions for rtvJrnRcvInf
       // ---------------------------------------------------------------
     D RRCV0100        DS          2048    qualified
     D  bytRet                       10I 0 inz                                  Bytes Returned
     D  bytAvl                       10I 0 inz                                  Bytes Availabl
     D  jrnRcvNme                    10A   inz                                  Journal Receiv
     D  jrnRcvLib                    10A   inz                                  Journal Receiv
     D  jrnNme                       10A   inz                                  Journal Nme
     D  jrnLib                       10A   inz                                  Journal Lib
     D  thrhld                       10I 0 inz                                  Threshold
     D  size                         10I 0 inz                                  Size
     D  auxSP                        10I 0 inz                                  Aux Stg Pool
     D  nbrJrnEnt                    10I 0 inz                                  Nbr Jrn Entrie
     D  maxEntLen                    10I 0 inz                                  Max ent-spc le
     D  maxNulInd                    10I 0 inz                                  Max Null val i
     D  fstSeqNbr                    10I 0 inz                                  First sequence
     D  res_01                        4A   inz                                  Reserved 01
     D  lstSeqNbr                    10I 0 inz                                  Last sequence
     D  res_02                        4A   inz                                  Reserved 02
     D  stat                          1A   inz                                  Status
     D  minLenVal                     1A   inz                                  Min fixed len
     D  res_03                        5A   inz                                  Reserved 03
     D  attDatTim                    13A   inz                                  Attached date
     D  detDatTim                    13A   inz                                  Detached date
     D  savDatTim                    13A   inz                                  Saved    date
     D  rcvTxt                       50A   inz                                  Text
     D  pndTrans                      1A   inz                                  Pending Transa
     D  rmtJrnTyp                     1A   inz                                  Remote Journal
     D  lclJrnNme                    10A   inz                                  Local Journal
     D  lclJrnLib                    10A   inz                                  Local Journal
     D  lclJrnSys                     8A   inz                                  Local Journal
     D  lclRcvLib                    10A   inz                                  Local Receiver
     D  srcJrnNme                    10A   inz                                  Source Journal
     D  srcJrnLib                    10A   inz                                  Source Journal
     D  srcJrnSys                     8A   inz                                  Source Journal
     D  srcRcvLib                    10A   inz                                  Source Receive
     D  rdrRcvLib                    10A   inz                                  Redirected Rcv
     D  dualRcvNme                   10A   inz                                  Dual Rcv Name
     D  dualRcvLb                    10A   inz                                  Dual Rcv Lib
     D  prvRcvNme                    10A   inz                                  Prv Jrn Rcv Na
     D  prvRcvLib                    10A   inz                                  Prv Jrn Rcv Li
     D  prv2RcvNm                    10A   inz                                  Prv Dual Jrn R
     D  prv2RcvLb                    10A   inz                                  Prv Dual Jrn R
     D  nxtRcvNme                    10A   inz                                  Nxt Jrn Rcv Na
     D  nxtRcvLib                    10A   inz                                  Nxt Jrn Rcv Li
     D  nxt2RcvNm                    10A   inz                                  Nxt Dual Jrn R
     D  nxt2RcvLb                    10A   inz                                  Nxt Dual Jrn R
     D  res_04                      140A   inz                                  Reserved 04

       // ---------------------------------------------------------------
       //  API error structure
       // ---------------------------------------------------------------
     D errorCode       DS                  likeds(errorCode_t) inz

       // ---------------------------------------------------------------
       //  Definitions for QMHSNDPM
       // ---------------------------------------------------------------

      /COPY QDLTOLDJRN,USR0001
      /COPY QDLTOLDJRN,USR0002
      /COPY QDLTOLDJRN,USR0003

       // ---------------------------------------------------------------
       //  Various fields
       // ---------------------------------------------------------------
     D curRcvNme       S             10A   inz
     D curRcvLib       S             10A   inz

     D lastRcvNme      S             10A   inz
     D lastRcvLib      S             10A   inz

     D tgtTimeStamp    S               Z   inz

     D dltCounter      S             10I 0 inz
     D rcvCounter      S             10I 0 inz
     D dltOpts         S            100A   inz
     D idx             S             10I 0 inz

     D LEFT_MARGIN     S             18A   inz
      /FREE

       qJRNMSG.name = 'DLTOLDJRNR';
       qJRNMSG.lib = sds.pgmLib;

       // -----------------------------------------
       //  Initialize counter
       // -----------------------------------------
       dltCounter = 0;
       rcvCounter = 0;

       // -----------------------------------------
       //  Open logger
       // -----------------------------------------
       If i_logLvl <> cLOGGER_NONE;
          Logger_open(i_logLvl);
          Logger_basic('Delete Old Journal Receiver');
          Logger_basic('---------------------------');
          Logger_basic('');
       Endif;

       // -----------------------------------------
       //  Get delete options
       // -----------------------------------------
       dltOpts = '';
       FOR idx = 1 TO i_ds_dltOpt.numE;
          dltOpts = %trimr(dltOpts) + ' ' + i_ds_dltOpt.value(idx);
       ENDFOR;

       // -----------------------------------------
       //  Set target timestamp
       // -----------------------------------------
       tgtTimeStamp = %date() + t'23.59.59';
       tgtTimeStamp = tgtTimeStamp - %days(i_ageInDays);

       //  Detach current receiver
       If i_detach = '*YES';
          Logger_verbose(
               'Detaching current journal receiver');
          If not execSysCmd(
                'CHGJRN JRN(' + %trim(i_qJrnNme.lib) +
                                '/'             +
                                %trim(i_qJrnNme.name) +
                          ') JRNRCV(*GEN)'
                : errorCode);
             sndDiagMsg(errorCode);
             Clear USR0001;
             Kill('USR0001': USR0001: %size(USR0001));
          Else;
             Logger_basic('Detached current receiver +
                          from journal ' +
                          %trim(i_qJrnNme.lib) +
                          '/'             +
                          %trim(i_qJrnNme.name));
          Endif;
       Endif;

       //  Retrieve journal information
       Logger_basic(
            'Retrieving journal information of +
             journal: ' +
                %trim(i_qJrnNme.lib) + '/' + %trim(i_qJrnNme.name));

       Clear RJRN0100;
       jrnInfRtv.nbrVarLenRec = 0;

       errorCode = inzApiErrorCode();
       qjoRtvJrnInf(RJRN0100: %size(RJRN0100): i_qJrnNme: 'RJRN0100'
                    : jrnInfRtv: errorCode);

       If errorCode.bytAvl <> 0;
          sndDiagMsg(errorCode);
          Clear USR0001;
          Kill('USR0001': USR0001: %size(USR0001));
       Endif;

       // -----------------------------------------
       //  Start loop to find the last receiver
       // -----------------------------------------
       Logger_verbose(
            'Going down the chain of journal +
             receivers to find the last receiver');

       curRcvNme = RJRN0100.attRcvNme;
       curRcvLib = RJRN0100.attRcvLib;

       Logger_verbose(
            '... first receiver: ' +
                %trim(curRcvLib)     +
                '/'                  +
                %trim(curRcvNme));

       //  Retrieve journal receiver information
       //  of previous attached receiver
       DoW curRcvNme <> '' and
          rtvJrnRcvInf(curRcvNme :
                    curRcvLib :
                    RRCV0100  );

          //  Show receiver properties
          Logger_verbose(
               '... properties of receiver: ' +
                   %trim(RRCV0100.jrnRcvLib) +
                   '/'                  +
                   %trim(RRCV0100.jrnRcvNme));
          Logger_verbose(LEFT_MARGIN +
               '    size: ' + %char(RRCV0100.size));
          Logger_verbose(LEFT_MARGIN +
               '  status: ' +
            getReceiverStatus(RRCV0100.stat));
          Logger_verbose(LEFT_MARGIN +
               'attached: ' +
               %char(apiTimeStmp_to_timeStmp(RRCV0100.attDatTim)));
          Logger_verbose(LEFT_MARGIN +
               'detached: ' +
               %char(apiTimeStmp_to_timeStmp(RRCV0100.detDatTim)));
          Logger_verbose(LEFT_MARGIN +
               '   saved: ' +
               %char(apiTimeStmp_to_timeStmp(RRCV0100.savDatTim)));

          //  Keep track of the total number of receivers available
          rcvCounter = rcvCounter + 1;

          //  If there was no error
          //  remind the last available revciever, then.
          lastRcvNme = curRcvNme;
          lastRcvLib = curRcvLib;

          //  Process the previous receiver
          curRcvNme  = RRCV0100.prvRcvNme;
          curRcvLib  = RRCV0100.prvRcvLib;

       Enddo;

       Logger_verbose(
            '... last receiver:  ' +
                 %trim(lastRcvLib) + '/' + %trim(lastRcvNme));

       Logger_verbose(
            'Total number of receivers: ' + %char(rcvCounter));

       // -----------------------------------------
       //  Start loop to delete journal receiver
       // -----------------------------------------
       Logger_basic(
            'Going up the chain of journal +
             receivers to delete receivers +
             that are older than: ' +
             %char(%date(tgtTimeStamp)) +
             ' / ' +
             %char(%time(tgtTimeStamp)));

       //  Retrieve journal receiver information
       //  of the last receiver in the chain
       DoW (rtvJrnRcvInf(lastRcvNme: lastRcvLib: RRCV0100)
            and (RJRN0100.attRcvNme + RJRN0100.attRcvLib <>
                 lastRcvNme + lastRcvLib));

          Logger_verbose(
               '... processing receiver:  ' +
                   %trim(RRCV0100.jrnRcvLib) + '/' + %trim(RRCV0100.jrnRcvNme));

          //  If the date matches the selection, ...
          If (apiTimeStmp_to_timeStmp(RRCV0100.detDatTim) < tgtTimeStamp);
             // ... then
             //     If the receiver had been saved or all reveicers are selected
             If (receiverWasSaved(RRCV0100.stat) or i_savOpt = '*ALL');
                // ... then
                // delete the receiver
                If (not execSysCmd(
                      'DLTJRNRCV JRNRCV(' +
                          %trim(RRCV0100.jrnRcvLib) + '/' +
                          %trim(RRCV0100.jrnRcvNme) +
                          ') ' +
                      'DLTOPT(' +
                          %trim(dltOpts) +
                          ')'
                      : errorCode));
                   // inform the user
                   sndDiagMsg(errorCode);
                   Clear USR0001;
                   Kill('USR0001': USR0001: %size(USR0001));
                   // exit loop in case of an error
                   Leave;
                Endif;

                Logger_basic('Deleted receiver ' +
                             %trim(RRCV0100.jrnRcvLib) + '/' +
                             %trim(RRCV0100.jrnRcvNme));

                //          keep a counter of how
                //          many receivers are deleted
                dltCounter = dltCounter + 1;

                //          send a message to the user
                Clear USR0002;
                USR00021 = RRCV0100.jrnRcvNme;
                USR00022 = RRCV0100.jrnRcvLib;
                sndInfoMsg('USR0002': USR0002);

             Else;
                //      ... else
                //          exit loop if receiver has not been saved yet
                Logger_verbose(
                     '... skipped receiver:  ' +
                         %trim(RRCV0100.jrnRcvLib) + '/' +
                         %trim(RRCV0100.jrnRcvNme) +
                     ' because it has not yet been saved');
                Logger_verbose(
                     '... exiting loop');
                Leave;
             Endif;
          Else;
             //  ... else
             //      ignore receiver if it is not old enough
             Logger_verbose(
                  '... skipped receiver:  ' +
                      %trim(RRCV0100.jrnRcvLib) + '/' +
                      %trim(RRCV0100.jrnRcvNme) +
                  ' because it is not old enough');
             Logger_verbose(
                  '... exiting loop');
             Leave;
          Endif;

          //  process the next receiver
          lastRcvNme  = RRCV0100.nxtRcvNme;
          lastRcvLib  = RRCV0100.nxtRcvLib;
       Enddo;

       Logger_basic(
            'Deleted ' + %char(dltCounter) +
            ' of ' + %char(rcvCounter) +
            ' journal receivers');

       Logger_basic(
            'Finished deleting receivers');

       // -----------------------------------------
       //  Close logger
       // -----------------------------------------
       Logger_close();

       //  After all receivers have been deleted that met the
       //  requirements, send a final message to the user.
       Clear USR0003;
       USR00031 = dltCounter;
       USR00032 = rcvCounter;
       sndInfoMsg('USR0003': USR0003);

      /END-FREE
     P                 E

       // ***************************************************************
       //  apiTimeStmp_to_timeStmp
       // ***************************************************************
     P apiTimeStmp_to_timeStmp...
     P                 B
     D                 PI              Z
     D  i_timeStamp13                13A   value

       //  CYYMMDDHHMMSS
     D datTim13        DS                  qualified
     D  cyymmdd                       7A   inz
     D  hhmmss                        6A   inz

     D date            S               D   inz
     D time            S               T   inz
     D timeStamp       S               Z   inz
       // ------------------------------------------------------------- *

      /FREE
       datTim13 = i_timeStamp13;

       Test(de) *cymd0 datTim13.cyymmdd;
       If (not %error());
          date = %date(datTim13.cyymmdd: *cymd0);
       Else;
          Clear date;
       Endif;

       Test(te) *hms0 datTim13.hhmmss;
       If (not %error());
          time = %time(datTim13.hhmmss: *hms0);
       Else;
          Clear time;
       Endif;

       timeStamp = date + time;

       Return timeStamp;

      /END-FREE
     P                 E

       // ***************************************************************
       //  execSysCmd
       // ***************************************************************
     P execSysCmd...
     P                 B
     D                 PI              N
     D  i_cmd                      1024A   value
     D  o_errorCode                               likeds(errorCode_t)

     D isOK            S               N   inz

     D srcCmdStrLen    S             10I 0 inz(%size(i_cmd))
     D optCtlBlk       DS                  likeds(cpop0100_t) inz
     D optCtlBlkLen    S             10I 0 inz(%size(optCtlBlk))
     D optCtlBlkFmt    S              8A   inz('CPOP0100')
     D chgCmdStr       S           1024A   inz
     D chgCmdStrAvl    S             10I 0 inz(%size(chgCmdStr))
     D chgCmdStrRet    S             10I 0 inz

     D errorCode       DS                  likeds(errorCode_t) inz
       // ------------------------------------------------------------- *
      /FREE

       Clear optCtlBlk;
       optCtlBlk.typeCmdPrc = 0;          // Process like QCMDEXC
       optCtlBlk.DBCS_data = '0';         // Ignore DBCS
       optCtlBlk.prmtAction = '0';        // Never prompt command
       optCtlBlk.cmdStrSyntax = '0';      // AS/400 Syntax
       optCtlBlk.msgRtvKey = *allx'00';
       optCtlBlk.res_01 = *allx'00';


       Clear errorCode;
       errorCode.bytPrv =%size(errorCode);

       QCAPCMD(i_cmd: srcCmdStrLen: optCtlBlk: optCtlBlkLen: optCtlBlkFmt:
               chgCmdStr: chgCmdStrAvl: chgCmdStrRet: errorCode);

       If errorCode.bytAvl = 0;
          isOK = *on;
       Else;
          isOK = *off;
       Endif;

       o_errorCode = errorCode;

       Return isOK;

      /END-FREE
     P                 E

       // ***************************************************************
       //  rtvJrnRcvInf
       // ***************************************************************

     P rtvJrnRcvInf...
     P                 B
     D                 PI              N
     D  i_jrnRcvNme                  10A   value
     D  i_jrnRcvLib                  10A   value
     D  o_rcvVar                   2048A

     D isOK            S               N   inz

       //  Definitions for QjoRetrieveJournalInformation
     D rcvVar          S           2048A   inz                                  Receiver var

     D qJrnRcv         DS                  qualified
     D  name                         10A   inz                                  Journal Receiv
     D  lib                          10A   inz                                  Journal Receiv

     D errorCode       DS                  likeds(errorCode_t) inz

      /COPY QDLTOLDJRN,USR0001
       // ------------------------------------------------------------- *
      /FREE

       Clear rcvVar;

       qJrnRcv.name = i_jrnRcvNme;
       qJrnRcv.lib = i_jrnRcvLib;

       Clear errorCode;
       errorCode.bytPrv =%size(errorCode);

       qjoRtvJrnRcvInf(
          rcvVar: %size(rcvVar): qJrnRcv: 'RRCV0100': errorCode);

       //  If there was no error ...
       If errorCode.bytAvl = 0;
          //  ... then
          //      pass back the retrieved information
          o_rcvVar = rcvVar;
          isOK     = *on;
       Else;
          //  ... else
          //      signal error condition
          If errorCode.excId <> 'CPF9801';
             Kill('USR0001': USR0001: %size(USR0001));
          Endif;
          o_rcvVar = ' ';
          isOK     = *off;
       Endif;

       Return isOK;

      /END-FREE
     P                 E

       // ***************************************************************
       //  Retrieve message text.
       // ***************************************************************
     P rtvMsgText...
     P                 B
     D                 PI           256A          varying
     D  i_errorCode                        const  likeds(errorCode_t)
     D  i_qMsgF                            const  likeds(qObj_t)
     D                                            options(*nopass)

     D qMsgF           DS                  likeds(i_qMsgF) inz

     D errorCode       DS                  likeds(errorCode_t) inz
     D rtvm0100        DS                  likeds(rtvm0100_t ) inz
       // ------------------------------------------------------------- *
      /FREE

       If (%parms() >= 2);
          qMsgF = i_qMsgF;
       Else;
          qMsgF = qCPFMSG;
       Endif;

       Clear errorCode;
       errorCode.bytPrv =%size(errorCode);

       QMHRTVM(rtvm0100: %size(rtvm0100): 'RTVM0100'
              : i_errorCode.excID: qMsgF: i_errorCode.excDta
              : %size(i_errorCode.excDta): '*YES': '*NO': errorCode);

       If rtvm0100.lenMsgRet > 0;
          Return %subst(rtvm0100.data: 1: rtvm0100.lenMsgRet);
       Endif;

       Return '';

      /END-FREE
     P                 E

       // ***************************************************************
       //  Send INFO message.
       // ***************************************************************
     P sndInfoMsg...
     P                 B
     D                 PI
     D  i_msgID                       7A   const
     D  i_msgDta                    512A   const  varying

     D errorCode       DS                  likeds(errorCode_t) inz
       // ------------------------------------------------------------- *
      /FREE
       Clear errorCode;
       errorCode.bytPrv =%size(errorCode);

       QMHSNDPM(i_msgID: qJRNMSG: i_msgDta: %size(i_msgDta): '*INFO'
                 : '*PGMBDY': 1: '' : errorCode);

      /END-FREE
     P                 E

       // ***************************************************************
       //  Send DIAG message.
       // ***************************************************************
     P sndDiagMsg...
     P                 B
     D                 PI
     D  i_errorCode                        const  likeds(errorCode_t)

     D errorCode       DS                  likeds(errorCode_t) inz
     D rtvm0100        DS                  likeds(rtvm0100_t ) inz
       // ------------------------------------------------------------- *
      /FREE

       Clear errorCode;
       errorCode.bytPrv =%size(errorCode);

       QMHRTVM(rtvm0100: %size(rtvm0100): 'RTVM0100'
              : i_errorCode.excID: qCPFMSG: i_errorCode.excDta
              : %size(i_errorCode.excDta): '*YES': '*NO': errorCode);

       If rtvm0100.lenMsgRet > 0;
          Logger_basic(rtvMsgText(i_errorCode));
       Endif;

       QMHSNDPM(i_errorCode.excID: qCPFMSG: i_errorCode.excDta
                 : %size(i_errorCode.excDta): '*DIAG'
                 : '*PGMBDY': 1: '': errorCode);

      /END-FREE
     P                 E

       // ***************************************************************
       //  kill
       // ***************************************************************
     P kill...
     P                 B
     D                 PI
     D  i_msgID                       7A   const
     D  i_msgDta                   2048A   const options(*varsize)
     D  i_size                       10I 0 const

     D errorCode       DS                  likeds(errorCode_t) inz
       // ------------------------------------------------------------- *
      /FREE

       Logger_basic('*** ERROR ***');

       Logger_close();

       Clear errorCode;
       errorCode.bytPrv =%size(errorCode);

       QMHSNDPM(i_msgID: qJRNMSG: i_msgDta: i_size: '*ESCAPE'
                 : '*PGMBDY': 1: '': errorCode);

      /END-FREE
     P                 E

       // ***************************************************************
       //  Initializes the API error code to return error information.
       // ***************************************************************
     P inzApiErrorCode...
     P                 B
     D                 PI                  likeds(errorCode_t)

     D errorCode       DS                  likeds(errorCode_t) inz
       // ------------------------------------------------------------- *
      /FREE

       Clear errorCode;
       errorCode.bytPrv =%size(errorCode);

       Return errorCode;

      /END-FREE
     P                 E

       // ***************************************************************
       //  Translates thee1-byte receiver status to a text
       // ***************************************************************
     P getReceiverStatus...
     P                 B
     D                 PI            64A   varying
     D  i_status                      1A   const
       // ------------------------------------------------------------- *
      /FREE

       Select;
       When i_status = '1';
          Return 'attached';
       When i_status = '2';
          Return 'detached / not saved';
       When i_status = '3';
          Return 'detached / saved';
       When i_status = '4';
          Return 'detached / saved and freed';
       When i_status = '5';
          Return 'partial +
           (see: QjoRtvJrnReceiverInformation API)';
       When i_status = '6';
          Return 'empty / never been attached';
       Other;
          Return 'Unknown status: ' + i_status;
       Endsl;

      /END-FREE
     P                 E

       // ***************************************************************
       //  Return true if the receiver has been saved, else false.
       // ***************************************************************
     P receiverWasSaved...
     P                 B
     D                 PI              N
     D  i_status                      1A   const
       // ------------------------------------------------------------- *
      /FREE

       //        3:  'detached / saved'
       //        4:  'detached / saved and freed'
       if i_status = '3'  or
          i_status = '4';
          Return *ON;
       Endif;

       Return *OFF;

      /END-FREE
     P                 E

