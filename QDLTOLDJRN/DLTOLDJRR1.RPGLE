**free
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
//     >>PARM<< OPTION(*EVENTF);                                       *
//   >>END-IMPORTANT<<                                                 *
//   >>EXECUTE<<                                                       *
//   >>CMD<<    CRTPGM       PGM(&LI/DLTOLDJRNR) +                     *
//                           MODULE(&LI/&OB  +                         *
//                                  &LI/DLTOLDJRR2  +                  *
//                                  &LI/DLTOLDJRR3) +                  *
//                           DETAIL(*BASIC) +                          *
//                           ACTGRP(*NEW);                             *
// >>END-PRE-COMPILER<<                                                *
//=====================================================================*
/copy QDLTOLDJRN,H_SPEC
/copy QDLTOLDJRN,COPYRIGHT

// ***************************************************************
//  External Prototypes
// ***************************************************************
dcl-pr qjoRtvJrnInf extproc('QjoRetrieveJournalInformation');
  rcvVar    char(2048) options(*varsize);
  rcvVarLen int(10) const;
  qJrnNme   char(20) const;
  format    char(8) const;
  jrnInfRtv char(2048) options(*varsize) const;
  errorCode char(272) options(*varsize: *omit);
end-pr;

dcl-pr qjoRtvJrnRcvInf extproc('QjoRtvJrnReceiverInformation');
  rcvVar     char(2048) options(*varsize);
  rcvVarLen  int(10) const;
  qJrnRcvNme char(20) const;
  format     char(8) const;
  errorCode  char(272) options(*varsize: *omit);
end-pr;

dcl-pr QMHSNDPM extpgm('QMHSNDPM');
  msgID      char(7) const;
  qMsgF      char(20) const;
  msgDta     char(2048) options(*varsize) const;
  msgDtaLen  int(10) const;
  msgType    char(10) const;
  callStkEnt char(10) const;
  callStkCnt int(10) const;
  msgKey     char(4) const;
  errorCode  char(272) options(*varsize);
end-pr;

dcl-pr QMHRTVM extpgm('QMHRTVM');
  o_msgInf      char(65535) options(*varsize);
  i_msgInfLen   int(10) const;
  i_format      char(8) const;
  i_msgID       char(7) const;
  i_qMsgF       char(20) const;
  i_rplData     char(65535) options(*varsize) const;
  i_rpldataLen  int(10) const;
  i_rplVars     char(10) const;
  i_rtnCtrlChrs char(10) const;
  io_ErrCode    char(65535) options(*varsize);
end-pr;

dcl-ds rtvm0100_t qualified based(pDummy);
  bytRet     int(10);
  bytAvl     int(10);
  lenMsgRet  int(10);
  lenMsgAvl  int(10);
  lenHelpRet int(10);
  lenHelpAvl int(10);
  data       char(2048);
end-ds;

// ***************************************************************
//  External Prototypes
// ***************************************************************
/define PROTOTYPE
/copy QDLTOLDJRN,DLTOLDJRR2
/undefine PROTOTYPE

dcl-pr DLTOLDJRR1 extpgm('DLTOLDJRNR');
  i_qJrnNme   likeds(qObj_t) const;
  i_ageInDays packed(3) const;
  i_detach    char(10) const;
  i_savOpt    char(10) const;
  i_ds_dltOpt likeds(ds_dltOpt_t) const;
  i_logLvl    int(5) const;
end-pr;

// ***************************************************************
//  Internal Prototypes
// ***************************************************************

dcl-pr main;
end-pr;

dcl-pr apiTimeStmp_to_timeStmp timestamp;
  i_timeStamp13 char(13) value;
end-pr;

dcl-pr execSysCmd ind;
  i_cmd       char(1024) value;
  o_errorCode likeds(errorCode_t);
end-pr;

dcl-pr rtvJrnRcvInf ind;
  i_jrnRcvNme char(10) value;
  i_jrnRcvLib char(10) value;
  o_rcvVar    char(2048);
end-pr;

dcl-pr getReceiverStatus varchar(64);
  i_status char(1) const;
end-pr;

dcl-pr receiverWasSaved ind;
  i_status char(1) const;
end-pr;

dcl-pr rtvMsgText varchar(256) extproc('rtvMsgText');
  i_errorCode likeds(errorCode_t) const;
  i_qMsgF     likeds(qObj_t) options(*nopass) const;
end-pr;

dcl-pr sndDiagMsg extproc('sndDiagMsg');
  i_errorCode likeds(errorCode_t) const;
end-pr;

dcl-pr sndInfoMsg extproc('sndInfoMsg');
  i_msgID  char(7) const;
  i_msgDta varchar(512) const;
end-pr;

dcl-pr kill extproc('kill');
  i_msgID  char(7) const;
  i_msgDta char(2048) options(*varsize) const;
  i_size   int(10) const;
end-pr;

dcl-pr inzApiErrorCode likeds(errorCode_t) extproc('inzApiErrorCode');
end-pr;

// ***************************************************************
//  Type Definitions
// ***************************************************************

dcl-ds qObj_t qualified based(pDummy);
  name char(10);
  lib  char(10);
end-ds;

dcl-ds ds_dltOpt_t qualified based(pDummy);
  numE  int(5);
  value char(11) dim(3);
end-ds;

dcl-ds errorCode_t based(pDummy);
  bytPrv int(10); // Bytes provided
  bytAvl int(10); // Bytes availabl
  excID  char(7); // Exception ID
  res_01 char(1); // Reserved
  excDta char(256); // Exception data
end-ds;

// ***************************************************************
//  Global constants
// ***************************************************************
dcl-c cErrMsg 'Programm fehlerhaft beendet.';

dcl-ds qCPFMSG qualified;
  name char(10) inz('QCPFMSG');
  lib  char(10) inz('QSYS');
end-ds;

dcl-ds qJRNMSG qualified;
  name char(10) inz('DLTOLDJRNR');
  lib  char(10) inz;
end-ds;

// ***************************************************************
//  *ENTRY - Parameter defined as global
// ***************************************************************

// Prototype for 'QCAPCMD'
dcl-pr QCAPCMD extpgm('QCAPCMD');
  i_cmd         char(32702) options(*varsize) const;
  i_cmdLen      int(10) const;
  i_ctrlBlk     char(32767) options(*varsize) const;
  i_ctrlBlkLen  int(10) const;
  i_ctrlBlkFmt  char(8) const;
  o_chgCmd      char(32702) options(*varsize);
  i_chgCmdLnPrv int(10) const;
  o_chgCmdLnAvl int(10);
  io_errorCode  char(32767) options(*varsize);
end-pr;

// Option control block
dcl-ds cpop0100_t qualified based(pDummy);
  typeCmdPrc   int(10);
  DBCS_data    char(1);
  prmtAction   char(1);
  cmdStrSyntax char(1);
  msgRtvKey    char(4);
  res_01       char(9);
end-ds;

/define SDS_EXTENDED
/copy QDLTOLDJRN,SDS

// ***************************************************************
//              EXECUTABLE CODE STARTS HERE
// ***************************************************************
dcl-pi DLTOLDJRR1;
  i_qJrnNme   likeds(qObj_t) const;
  i_ageInDays packed(3) const;
  i_detach    char(10) const;
  i_savOpt    char(10) const;
  i_ds_dltOpt likeds(ds_dltOpt_t) const;
  i_logLvl    int(5) const;
end-pi;

main();

*inlr = *on;


// ***************************************************************
//  main program control
//  (This ensures to have local variables in main stream, too.)
// ***************************************************************
dcl-proc main;
  dcl-pi *n;
  end-pi;

  // ---------------------------------------------------------------
  //  Definitions for QjoRetrieveJournalInformation
  // ---------------------------------------------------------------
  dcl-ds RJRN0100 qualified;
    bytRet    int(10) inz; // Bytes Returned
    bytAvl    int(10) inz; // Bytes Availabl
    ofsKeyInf int(10) inz; // Offset Key Inf
    jrnNme    char(10) inz; // Journal Name
    jrnLib    char(10) inz; // Journal Librar
    auxSP     int(10) inz; // Aux Stg Pool
    msgQNme   char(10) inz; // Message Queue
    msgQLib   char(10) inz; // Message Queue
    mgeRcvOpt char(1) inz; // Manage Receive
    dltRcvOpt char(1) inz; // Delete Receive
    rcvSizRmv char(1) inz; // RcvSizOpt *RMV
    rcvSizMin char(1) inz; // RcvSizOpt *MIN
    res_01    char(5) inz; // Reserved 01
    jrnTyp    char(1) inz; // Journal Type
    rmtJrnTyp char(1) inz; // Rmt Journal Ty
    jrnState  char(1) inz; // Journal State
    jrnDlvMde char(1) inz; // Journal Delive
    lclJrnNme char(10) inz; // Local Journal
    lclJrnLib char(10) inz; // Local Journal
    lclJrnSys char(8) inz; // Local Journal
    srcJrnNme char(10) inz; // Source Journal
    srcJrnLib char(10) inz; // Source Journal
    srcJrnSys char(8) inz; // Source Journal
    rdrRcvLib char(10) inz; // Redirected Rcv
    jrnTxt    char(50) inz; // Journal Text
    res_02    char(11) inz; // Reserved 02
    nbrAttRcv int(10) inz; // Nbr attached R
    attRcvNme char(10) inz; // Attached Rcv N
    attRcvLib char(10) inz; // Attached Rcv L
    lclJnSyAR char(8) inz; // Lcl Jrn Sys at
    srcJnSyAR char(8) inz; // Src Jrn Sys at
    att2RcvNm char(10) inz; // Attached dual
    att2RcvLb char(10) inz; // Attached dual
    res_03    char(192) inz; // Reserved 03
    nbrKeys   int(10) inz; // Nbr Keys in Ke
  end-ds;

  dcl-ds jrnInfRtv qualified;
    nbrVarLenRec int(10) inz; // Jrn Inf to ret
  end-ds;

  // ---------------------------------------------------------------
  //  Definitions for rtvJrnRcvInf
  // ---------------------------------------------------------------
  dcl-ds RRCV0100 len(2048) qualified;
    bytRet     int(10) inz; // Bytes Returned
    bytAvl     int(10) inz; // Bytes Availabl
    jrnRcvNme  char(10) inz; // Journal Receiv
    jrnRcvLib  char(10) inz; // Journal Receiv
    jrnNme     char(10) inz; // Journal Nme
    jrnLib     char(10) inz; // Journal Lib
    thrhld     int(10) inz; // Threshold
    size       int(10) inz; // Size
    auxSP      int(10) inz; // Aux Stg Pool
    nbrJrnEnt  int(10) inz; // Nbr Jrn Entrie
    maxEntLen  int(10) inz; // Max ent-spc le
    maxNulInd  int(10) inz; // Max Null val i
    fstSeqNbr  int(10) inz; // First sequence
    res_01     char(4) inz; // Reserved 01
    lstSeqNbr  int(10) inz; // Last sequence
    res_02     char(4) inz; // Reserved 02
    stat       char(1) inz; // Status
    minLenVal  char(1) inz; // Min fixed len
    res_03     char(5) inz; // Reserved 03
    attDatTim  char(13) inz; // Attached date
    detDatTim  char(13) inz; // Detached date
    savDatTim  char(13) inz; // Saved    date
    rcvTxt     char(50) inz; // Text
    pndTrans   char(1) inz; // Pending Transa
    rmtJrnTyp  char(1) inz; // Remote Journal
    lclJrnNme  char(10) inz; // Local Journal
    lclJrnLib  char(10) inz; // Local Journal
    lclJrnSys  char(8) inz; // Local Journal
    lclRcvLib  char(10) inz; // Local Receiver
    srcJrnNme  char(10) inz; // Source Journal
    srcJrnLib  char(10) inz; // Source Journal
    srcJrnSys  char(8) inz; // Source Journal
    srcRcvLib  char(10) inz; // Source Receive
    rdrRcvLib  char(10) inz; // Redirected Rcv
    dualRcvNme char(10) inz; // Dual Rcv Name
    dualRcvLb  char(10) inz; // Dual Rcv Lib
    prvRcvNme  char(10) inz; // Prv Jrn Rcv Na
    prvRcvLib  char(10) inz; // Prv Jrn Rcv Li
    prv2RcvNm  char(10) inz; // Prv Dual Jrn R
    prv2RcvLb  char(10) inz; // Prv Dual Jrn R
    nxtRcvNme  char(10) inz; // Nxt Jrn Rcv Na
    nxtRcvLib  char(10) inz; // Nxt Jrn Rcv Li
    nxt2RcvNm  char(10) inz; // Nxt Dual Jrn R
    nxt2RcvLb  char(10) inz; // Nxt Dual Jrn R
    res_04     char(140) inz; // Reserved 04
  end-ds;

  // ---------------------------------------------------------------
  //  API error structure
  // ---------------------------------------------------------------
  dcl-ds errorCode likeds(errorCode_t) inz;

  // ---------------------------------------------------------------
  //  Definitions for QMHSNDPM
  // ---------------------------------------------------------------

/copy QDLTOLDJRN,USR0001
/copy QDLTOLDJRN,USR0002
/copy QDLTOLDJRN,USR0003

  // ---------------------------------------------------------------
  //  Various fields
  // ---------------------------------------------------------------
  dcl-s curRcvNme char(10) inz;
  dcl-s curRcvLib char(10) inz;

  dcl-s lastRcvNme char(10) inz;
  dcl-s lastRcvLib char(10) inz;

  dcl-s tgtTimeStamp timestamp inz;

  dcl-s dltCounter int(10) inz;
  dcl-s rcvCounter int(10) inz;
  dcl-s dltOpts char(100) inz;
  dcl-s idx int(10) inz;

  dcl-s LEFT_MARGIN char(18) inz;

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

end-proc;

// ***************************************************************
//  apiTimeStmp_to_timeStmp
// ***************************************************************
dcl-proc apiTimeStmp_to_timeStmp;
  dcl-pi *n timestamp;
    i_timeStamp13 char(13) value;
  end-pi;

  //  CYYMMDDHHMMSS
  dcl-ds datTim13 qualified;
    cyymmdd char(7) inz;
    hhmmss  char(6) inz;
  end-ds;

  dcl-s date date inz;
  dcl-s time time inz;
  dcl-s timeStamp timestamp inz;
  // ------------------------------------------------------------- *

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

end-proc;

// ***************************************************************
//  execSysCmd
// ***************************************************************
dcl-proc execSysCmd;
  dcl-pi *n ind;
    i_cmd       char(1024) value;
    o_errorCode likeds(errorCode_t);
  end-pi;

  dcl-s isOK ind inz;

  dcl-s srcCmdStrLen int(10) inz(%size(i_cmd));
  dcl-ds optCtlBlk likeds(cpop0100_t) inz;
  dcl-s optCtlBlkLen int(10) inz(%size(optCtlBlk));
  dcl-s optCtlBlkFmt char(8) inz('CPOP0100');
  dcl-s chgCmdStr char(1024) inz;
  dcl-s chgCmdStrAvl int(10) inz(%size(chgCmdStr));
  dcl-s chgCmdStrRet int(10) inz;

  dcl-ds errorCode likeds(errorCode_t) inz;
  // ------------------------------------------------------------- *

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

end-proc;

// ***************************************************************
//  rtvJrnRcvInf
// ***************************************************************

dcl-proc rtvJrnRcvInf;
  dcl-pi *n ind;
    i_jrnRcvNme char(10) value;
    i_jrnRcvLib char(10) value;
    o_rcvVar    char(2048);
  end-pi;

  dcl-s isOK ind inz;

  //  Definitions for QjoRetrieveJournalInformation
  dcl-s rcvVar char(2048) inz; // Receiver var

  dcl-ds qJrnRcv qualified;
    name char(10) inz; // Journal Receiv
    lib  char(10) inz; // Journal Receiv
  end-ds;

  dcl-ds errorCode likeds(errorCode_t) inz;

/copy QDLTOLDJRN,USR0001
  // ------------------------------------------------------------- *

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

end-proc;

// ***************************************************************
//  Retrieve message text.
// ***************************************************************
dcl-proc rtvMsgText;
  dcl-pi *n varchar(256);
    i_errorCode likeds(errorCode_t) const;
    i_qMsgF     likeds(qObj_t) options(*nopass) const;
  end-pi;

  dcl-ds qMsgF likeds(i_qMsgF) inz;

  dcl-ds errorCode likeds(errorCode_t) inz;
  dcl-ds rtvm0100 likeds(rtvm0100_t) inz;
  // ------------------------------------------------------------- *

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

end-proc;

// ***************************************************************
//  Send INFO message.
// ***************************************************************
dcl-proc sndInfoMsg;
  dcl-pi *n;
    i_msgID  char(7) const;
    i_msgDta varchar(512) const;
  end-pi;

  dcl-ds errorCode likeds(errorCode_t) inz;
  // ------------------------------------------------------------- *
  Clear errorCode;
  errorCode.bytPrv =%size(errorCode);

  QMHSNDPM(i_msgID: qJRNMSG: i_msgDta: %size(i_msgDta): '*INFO'
            : '*PGMBDY': 1: '' : errorCode);

end-proc;

// ***************************************************************
//  Send DIAG message.
// ***************************************************************
dcl-proc sndDiagMsg;
  dcl-pi *n;
    i_errorCode likeds(errorCode_t) const;
  end-pi;

  dcl-ds errorCode likeds(errorCode_t) inz;
  dcl-ds rtvm0100 likeds(rtvm0100_t) inz;
  // ------------------------------------------------------------- *

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

end-proc;

// ***************************************************************
//  kill
// ***************************************************************
dcl-proc kill;
  dcl-pi *n;
    i_msgID  char(7) const;
    i_msgDta char(2048) options(*varsize) const;
    i_size   int(10) const;
  end-pi;

  dcl-ds errorCode likeds(errorCode_t) inz;
  // ------------------------------------------------------------- *

  Logger_basic('*** ERROR ***');

  Logger_close();

  Clear errorCode;
  errorCode.bytPrv =%size(errorCode);

  QMHSNDPM(i_msgID: qJRNMSG: i_msgDta: i_size: '*ESCAPE'
            : '*PGMBDY': 1: '': errorCode);

end-proc;

// ***************************************************************
//  Initializes the API error code to return error information.
// ***************************************************************
dcl-proc inzApiErrorCode;
  dcl-pi *n likeds(errorCode_t);
  end-pi;

  dcl-ds errorCode likeds(errorCode_t) inz;
  // ------------------------------------------------------------- *

  Clear errorCode;
  errorCode.bytPrv =%size(errorCode);

  Return errorCode;

end-proc;

// ***************************************************************
//  Translates thee1-byte receiver status to a text
// ***************************************************************
dcl-proc getReceiverStatus;
  dcl-pi *n varchar(64);
    i_status char(1) const;
  end-pi;
  // ------------------------------------------------------------- *

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

end-proc;

// ***************************************************************
//  Return true if the receiver has been saved, else false.
// ***************************************************************
dcl-proc receiverWasSaved;
  dcl-pi *n ind;
    i_status char(1) const;
  end-pi;
  // ------------------------------------------------------------- *

  //        3:  'detached / saved'
  //        4:  'detached / saved and freed'
  if i_status = '3'  or
     i_status = '4';
    Return *ON;
  Endif;

  Return *OFF;

end-proc;

