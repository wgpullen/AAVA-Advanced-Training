       IDENTIFICATION DIVISION.
       PROGRAM-ID. ACCTPROC.
       AUTHOR. MAINFRAME-TEAM.
       DATE-WRITTEN. 2001-07-22.
       DATE-COMPILED. 2024-01-10.
      *================================================================
      * ACCOUNT PROCESSING - BATCH NIGHTLY CYCLE
      * Processes transactions, calculates interest, generates statements
      *================================================================

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT TRANSACTION-FILE ASSIGN TO 'TRANSIN'
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-TRAN-STATUS.
           SELECT ACCOUNT-FILE ASSIGN TO 'ACCTMAST'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS ACCT-ID
               FILE STATUS IS WS-ACCT-STATUS.
           SELECT STATEMENT-FILE ASSIGN TO 'STMTOUT'
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-STMT-STATUS.
           SELECT ERROR-FILE ASSIGN TO 'ERRLOG'
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-ERR-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD TRANSACTION-FILE.
       01 TRANSACTION-RECORD.
           05 TRAN-ACCT-ID           PIC X(10).
           05 TRAN-TYPE              PIC X(2).
               88 TRAN-DEPOSIT       VALUE 'DP'.
               88 TRAN-WITHDRAWAL    VALUE 'WD'.
               88 TRAN-TRANSFER      VALUE 'TR'.
               88 TRAN-FEE           VALUE 'FE'.
               88 TRAN-INTEREST      VALUE 'IN'.
               88 TRAN-REVERSAL      VALUE 'RV'.
           05 TRAN-AMOUNT            PIC S9(9)V99 COMP-3.
           05 TRAN-DATE              PIC X(8).
           05 TRAN-TIME              PIC X(6).
           05 TRAN-REF-NUM           PIC X(12).
           05 TRAN-DESCRIPTION       PIC X(40).

       FD ACCOUNT-FILE.
       01 ACCOUNT-RECORD.
           COPY ACCTREC.

       FD STATEMENT-FILE.
       01 STATEMENT-RECORD           PIC X(200).

       FD ERROR-FILE.
       01 ERROR-RECORD               PIC X(200).

       WORKING-STORAGE SECTION.
       01 WS-TRAN-STATUS             PIC XX.
       01 WS-ACCT-STATUS             PIC XX.
       01 WS-STMT-STATUS             PIC XX.
       01 WS-ERR-STATUS              PIC XX.
       01 WS-EOF-FLAG                PIC X VALUE 'N'.
           88 END-OF-FILE            VALUE 'Y'.
       01 WS-CURRENT-DATE            PIC X(8).
       01 WS-INTEREST-RATE           PIC 9V9(4) VALUE 0.0325.
       01 WS-DAILY-RATE              PIC 9V9(8).
       01 WS-CALCULATED-INTEREST     PIC S9(9)V99 COMP-3.

       01 WS-COUNTERS.
           05 WS-TRAN-READ           PIC 9(9) VALUE 0.
           05 WS-TRAN-PROCESSED      PIC 9(9) VALUE 0.
           05 WS-TRAN-REJECTED       PIC 9(9) VALUE 0.
           05 WS-ACCT-UPDATED        PIC 9(9) VALUE 0.
           05 WS-STMT-GENERATED      PIC 9(9) VALUE 0.
           05 WS-INTEREST-CALC       PIC 9(9) VALUE 0.

       PROCEDURE DIVISION.
       0000-MAIN-CONTROL.
           PERFORM 1000-INITIALIZE
           PERFORM 2000-PROCESS-TRANSACTIONS
           PERFORM 3000-CALCULATE-INTEREST
           PERFORM 4000-GENERATE-STATEMENTS
           PERFORM 9000-TERMINATE
           STOP RUN.

       1000-INITIALIZE.
           OPEN INPUT TRANSACTION-FILE
           OPEN I-O ACCOUNT-FILE
           OPEN OUTPUT STATEMENT-FILE
           OPEN OUTPUT ERROR-FILE
           ACCEPT WS-CURRENT-DATE FROM DATE YYYYMMDD
           COMPUTE WS-DAILY-RATE = WS-INTEREST-RATE / 365.

       2000-PROCESS-TRANSACTIONS.
           PERFORM UNTIL END-OF-FILE
               READ TRANSACTION-FILE
                   AT END
                       SET END-OF-FILE TO TRUE
                   NOT AT END
                       ADD 1 TO WS-TRAN-READ
                       PERFORM 2100-VALIDATE-TRANSACTION
               END-READ
           END-PERFORM.

       2100-VALIDATE-TRANSACTION.
           MOVE TRAN-ACCT-ID TO ACCT-ID
           READ ACCOUNT-FILE
               INVALID KEY
                   PERFORM 2900-LOG-ERROR
               NOT INVALID KEY
                   PERFORM 2200-APPLY-TRANSACTION
           END-READ.

       2200-APPLY-TRANSACTION.
           EVALUATE TRUE
               WHEN TRAN-DEPOSIT
                   ADD TRAN-AMOUNT TO ACCT-BALANCE
                   ADD 1 TO ACCT-TRAN-COUNT
               WHEN TRAN-WITHDRAWAL
                   IF TRAN-AMOUNT > ACCT-BALANCE
                       PERFORM 2900-LOG-ERROR
                   ELSE
                       SUBTRACT TRAN-AMOUNT FROM ACCT-BALANCE
                       ADD 1 TO ACCT-TRAN-COUNT
                   END-IF
               WHEN TRAN-TRANSFER
                   SUBTRACT TRAN-AMOUNT FROM ACCT-BALANCE
                   ADD 1 TO ACCT-TRAN-COUNT
               WHEN TRAN-FEE
                   SUBTRACT TRAN-AMOUNT FROM ACCT-BALANCE
                   ADD 1 TO ACCT-FEE-COUNT
               WHEN TRAN-INTEREST
                   ADD TRAN-AMOUNT TO ACCT-BALANCE
                   ADD 1 TO ACCT-TRAN-COUNT
               WHEN TRAN-REVERSAL
                   PERFORM 2300-PROCESS-REVERSAL
               WHEN OTHER
                   PERFORM 2900-LOG-ERROR
           END-EVALUATE
           MOVE WS-CURRENT-DATE TO ACCT-LAST-ACTIVITY
           REWRITE ACCOUNT-RECORD
           ADD 1 TO WS-TRAN-PROCESSED.

       2300-PROCESS-REVERSAL.
           ADD TRAN-AMOUNT TO ACCT-BALANCE
           ADD 1 TO ACCT-TRAN-COUNT
           ADD 1 TO WS-TRAN-PROCESSED.

       2900-LOG-ERROR.
           MOVE SPACES TO ERROR-RECORD
           STRING 'ERROR: ACCT=' TRAN-ACCT-ID
                  ' TRAN=' TRAN-TYPE
                  ' AMT=' TRAN-AMOUNT
                  ' DATE=' WS-CURRENT-DATE
                  DELIMITED BY SIZE INTO ERROR-RECORD
           WRITE ERROR-RECORD
           ADD 1 TO WS-TRAN-REJECTED.

       3000-CALCULATE-INTEREST.
           MOVE LOW-VALUES TO ACCT-ID
           START ACCOUNT-FILE KEY > ACCT-ID
           PERFORM UNTIL WS-ACCT-STATUS NOT = '00'
               READ ACCOUNT-FILE NEXT
                   AT END
                       MOVE '10' TO WS-ACCT-STATUS
                   NOT AT END
                       IF ACCT-STATUS = 'A'
                         AND ACCT-BALANCE > 0
                           PERFORM 3100-CALC-DAILY-INTEREST
                       END-IF
               END-READ
           END-PERFORM.

       3100-CALC-DAILY-INTEREST.
           COMPUTE WS-CALCULATED-INTEREST =
               ACCT-BALANCE * WS-DAILY-RATE
           ADD WS-CALCULATED-INTEREST TO ACCT-INTEREST-ACCRUED
           REWRITE ACCOUNT-RECORD
           ADD 1 TO WS-INTEREST-CALC.

       4000-GENERATE-STATEMENTS.
           MOVE LOW-VALUES TO ACCT-ID
           START ACCOUNT-FILE KEY > ACCT-ID
           PERFORM UNTIL WS-ACCT-STATUS NOT = '00'
               READ ACCOUNT-FILE NEXT
                   AT END
                       MOVE '10' TO WS-ACCT-STATUS
                   NOT AT END
                       IF ACCT-STMT-FLAG = 'Y'
                           PERFORM 4100-WRITE-STATEMENT
                       END-IF
               END-READ
           END-PERFORM.

       4100-WRITE-STATEMENT.
           MOVE SPACES TO STATEMENT-RECORD
           STRING 'STMT|' ACCT-ID '|'
                  ACCT-CUST-ID '|'
                  ACCT-BALANCE '|'
                  ACCT-INTEREST-ACCRUED '|'
                  WS-CURRENT-DATE
                  DELIMITED BY SIZE INTO STATEMENT-RECORD
           WRITE STATEMENT-RECORD
           MOVE 'N' TO ACCT-STMT-FLAG
           MOVE 0 TO ACCT-INTEREST-ACCRUED
           REWRITE ACCOUNT-RECORD
           ADD 1 TO WS-STMT-GENERATED.

      *================================================================
      * DEAD CODE - LEGACY FEE CALCULATION
      * Replaced by real-time fee engine (FEECALC program) in 2021
      * Last batch execution: 2021-03-31
      *================================================================
       5000-CALCULATE-MONTHLY-FEES.
           MOVE LOW-VALUES TO ACCT-ID
           START ACCOUNT-FILE KEY > ACCT-ID
           PERFORM UNTIL WS-ACCT-STATUS NOT = '00'
               READ ACCOUNT-FILE NEXT
                   AT END
                       MOVE '10' TO WS-ACCT-STATUS
                   NOT AT END
                       IF ACCT-BALANCE < 1000
                           PERFORM 5100-APPLY-LOW-BALANCE-FEE
                       END-IF
                       IF ACCT-TRAN-COUNT > 50
                           PERFORM 5200-APPLY-EXCESS-TRAN-FEE
                       END-IF
               END-READ
           END-PERFORM.

       5100-APPLY-LOW-BALANCE-FEE.
           SUBTRACT 12.50 FROM ACCT-BALANCE
           ADD 1 TO ACCT-FEE-COUNT.

       5200-APPLY-EXCESS-TRAN-FEE.
           COMPUTE TRAN-AMOUNT =
               (ACCT-TRAN-COUNT - 50) * 0.25
           SUBTRACT TRAN-AMOUNT FROM ACCT-BALANCE
           ADD 1 TO ACCT-FEE-COUNT.

      *================================================================
      * DEAD CODE - PAPER STATEMENT GENERATION
      * Replaced by electronic statements in 2020
      * Last execution: 2020-06-30
      *================================================================
       6000-GENERATE-PAPER-STATEMENTS.
           DISPLAY 'PAPER STATEMENTS DEPRECATED - USE ESTMT SYSTEM'.

      *================================================================
      * DEAD CODE - Y2K REMEDIATION CHECK
      * Was critical in 1999, never removed
      * Last execution: 2000-01-15
      *================================================================
       7000-Y2K-DATE-CHECK.
           IF WS-CURRENT-DATE(1:2) = '19'
               DISPLAY 'Y2K WARNING: DATE IN 1900s DETECTED'
               MOVE 16 TO WS-RETURN-CODE
           END-IF.

       9000-TERMINATE.
           CLOSE TRANSACTION-FILE
           CLOSE ACCOUNT-FILE
           CLOSE STATEMENT-FILE
           CLOSE ERROR-FILE
           DISPLAY 'ACCTPROC COMPLETE'
           DISPLAY 'TRANS READ=' WS-TRAN-READ
                   ' PROCESSED=' WS-TRAN-PROCESSED
                   ' REJECTED=' WS-TRAN-REJECTED
           DISPLAY 'ACCOUNTS UPDATED=' WS-ACCT-UPDATED
                   ' INTEREST CALC=' WS-INTEREST-CALC
                   ' STMTS=' WS-STMT-GENERATED.
