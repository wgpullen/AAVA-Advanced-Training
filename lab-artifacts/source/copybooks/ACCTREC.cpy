      *================================================================
      * ACCTREC - ACCOUNT RECORD COPYBOOK
      * Used by: ACCTPROC, ACCTRPT, ACCTINQ
      *================================================================
       01 ACCOUNT-RECORD-LAYOUT.
           05 ACCT-ID               PIC X(10).
           05 ACCT-CUST-ID          PIC X(10).
           05 ACCT-TYPE             PIC X(2).
               88 ACCT-CHECKING     VALUE 'CK'.
               88 ACCT-SAVINGS      VALUE 'SV'.
               88 ACCT-MONEY-MKT    VALUE 'MM'.
               88 ACCT-CD           VALUE 'CD'.
           05 ACCT-STATUS           PIC X(1).
               88 ACCT-ACTIVE       VALUE 'A'.
               88 ACCT-CLOSED       VALUE 'C'.
               88 ACCT-FROZEN       VALUE 'F'.
           05 ACCT-BALANCE          PIC S9(11)V99 COMP-3.
           05 ACCT-INTEREST-RATE    PIC 9V9(4).
           05 ACCT-INTEREST-ACCRUED PIC S9(9)V99 COMP-3.
           05 ACCT-OPEN-DATE        PIC X(8).
           05 ACCT-LAST-ACTIVITY    PIC X(8).
           05 ACCT-TRAN-COUNT       PIC 9(5).
           05 ACCT-FEE-COUNT        PIC 9(3).
           05 ACCT-STMT-FLAG        PIC X(1).
               88 ACCT-STMT-DUE     VALUE 'Y'.
               88 ACCT-STMT-SENT    VALUE 'N'.
           05 ACCT-OVERDRAFT-LIMIT  PIC S9(7)V99 COMP-3.
           05 FILLER                PIC X(20).
