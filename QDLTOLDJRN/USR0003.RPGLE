**free
//---------------------------------------------------------------
// Datenstruktur für Message-ID : USR0003

// Anzahl gelöschter Journalempfänger &1 von &2.

dcl-ds USR0003;
  USR00031 packed(010) inz(*zeros);
  USR00032 packed(010) inz(*zeros);
end-ds;
dcl-s USR0003# bindec(8) inz(0012);

