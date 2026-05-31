**free
//---------------------------------------------------------------
// Datenstruktur für Message-ID : USR0002

// Gelöschter Journalempfänger: &2/&1.

dcl-ds USR0002;
  USR00021 char(010) inz(*blanks);
  USR00022 char(010) inz(*blanks);
end-ds;
dcl-s USR0002# bindec(8) inz(0020);

