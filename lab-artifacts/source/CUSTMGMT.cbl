       IDENTIFICATION DIVISION.
       PROGRAM-ID. CUSTMGMT.
       AUTHOR. MAINFRAME-TEAM.
       DATE-WRITTEN. 1998-03-15.
       DATE-COMPILED. 2024-01-10.
      *================================================================
      * CUSTOMER MANAGEMENT SYSTEM - ONLINE/BATCH PROCESSING
      * Handles customer CRUD, account linking, and reporting
      *================================================================

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CUSTOMER-FILE ASSIGN TO 'CUSTMAST'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS CUST-ID
               FILE STATUS IS WS-FILE-STATUS.
           SELECT REPORT-FILE ASSIGN TO 'CUSTRPT'
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-RPT-STATUS.
           SELECT ARCHIVE-FILE ASSIGN TO 'CUSTARCH'
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-ARCH-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD CUSTOMER-FILE.
       01 CUSTOMER-RECORD.
           COPY CUSTREC.

       FD REPORT-FILE.
       01 REPORT-RECORD              PIC X(132).

       FD ARCHIVE-FILE.
       01 ARCHIVE-RECORD             PIC X(500).

       WORKING-STORAGE SECTION.
       01 WS-FILE-STATUS             PIC XX.
       01 WS-RPT-STATUS              PIC XX.
       01 WS-ARCH-STATUS             PIC XX.
       01 WS-RETURN-CODE             PIC S9(4) COMP VALUE 0.
       01 WS-CURRENT-DATE            PIC X(8).
       01 WS-CURRENT-TIME            PIC X(6).
       01 WS-TRANSACTION-ID          PIC X(4).
       01 WS-FUNCTION-CODE           PIC X(2).
           88 FC-ADD                  VALUE 'AD'.
           88 FC-UPDATE               VALUE 'UP'.
           88 FC-DELETE               VALUE 'DL'.
           88 FC-INQUIRY              VALUE 'IQ'.
           88 FC-REPORT               VALUE 'RP'.
           88 FC-ARCHIVE              VALUE 'AR'.
           88 FC-PURGE                VALUE 'PG'.
           88 FC-MIGRATE              VALUE 'MG'.

       01 WS-CUSTOMER-WORK.
           05 WS-CUST-ID             PIC X(10).
           05 WS-CUST-NAME           PIC X(40).
           05 WS-CUST-ADDR           PIC X(60).
           05 WS-CUST-PHONE          PIC X(15).
           05 WS-CUST-EMAIL          PIC X(50).
           05 WS-CUST-STATUS         PIC X(1).
               88 CUST-ACTIVE        VALUE 'A'.
               88 CUST-INACTIVE      VALUE 'I'.
               88 CUST-SUSPENDED     VALUE 'S'.
           05 WS-CUST-TYPE           PIC X(2).
               88 CUST-RETAIL        VALUE 'RT'.
               88 CUST-WHOLESALE     VALUE 'WH'.
               88 CUST-CORPORATE     VALUE 'CP'.
           05 WS-CUST-BALANCE        PIC S9(9)V99 COMP-3.
           05 WS-CUST-CREDIT-LIMIT   PIC S9(9)V99 COMP-3.
           05 WS-CUST-LAST-ACTIVITY  PIC X(8).
           05 WS-CUST-CREATED-DATE   PIC X(8).

       01 WS-COUNTERS.
           05 WS-READ-COUNT          PIC 9(7) VALUE 0.
           05 WS-WRITE-COUNT         PIC 9(7) VALUE 0.
           05 WS-UPDATE-COUNT        PIC 9(7) VALUE 0.
           05 WS-DELETE-COUNT        PIC 9(7) VALUE 0.
           05 WS-ERROR-COUNT         PIC 9(7) VALUE 0.

       01 WS-DB2-SQLCODE             PIC S9(9) COMP.
       01 WS-CICS-RESP               PIC S9(8) COMP.
       01 WS-CICS-RESP2              PIC S9(8) COMP.

       PROCEDURE DIVISION.
       0000-MAIN-CONTROL.
           PERFORM 1000-INITIALIZE
           EVALUATE TRUE
               WHEN FC-ADD
                   PERFORM 2000-ADD-CUSTOMER
               WHEN FC-UPDATE
                   PERFORM 3000-UPDATE-CUSTOMER
               WHEN FC-DELETE
                   PERFORM 4000-DELETE-CUSTOMER
               WHEN FC-INQUIRY
                   PERFORM 5000-INQUIRY-CUSTOMER
               WHEN FC-REPORT
                   PERFORM 6000-GENERATE-REPORT
               WHEN FC-ARCHIVE
                   PERFORM 7000-ARCHIVE-CUSTOMERS
               WHEN FC-PURGE
                   PERFORM 8000-PURGE-INACTIVE
               WHEN FC-MIGRATE
                   PERFORM 9000-MIGRATE-TO-NEW-SYSTEM
               WHEN OTHER
                   MOVE 99 TO WS-RETURN-CODE
           END-EVALUATE
           PERFORM 9900-TERMINATE
           STOP RUN.

       1000-INITIALIZE.
           OPEN I-O CUSTOMER-FILE
           IF WS-FILE-STATUS NOT = '00'
               DISPLAY 'ERROR OPENING CUSTOMER FILE: ' WS-FILE-STATUS
               MOVE 8 TO WS-RETURN-CODE
               PERFORM 9900-TERMINATE
               STOP RUN
           END-IF
           ACCEPT WS-CURRENT-DATE FROM DATE YYYYMMDD
           ACCEPT WS-CURRENT-TIME FROM TIME
           INITIALIZE WS-COUNTERS.

       2000-ADD-CUSTOMER.
           MOVE WS-CUST-ID TO CUST-ID
           READ CUSTOMER-FILE
               INVALID KEY
                   PERFORM 2100-WRITE-NEW-CUSTOMER
               NOT INVALID KEY
                   MOVE 4 TO WS-RETURN-CODE
                   DISPLAY 'CUSTOMER ALREADY EXISTS: ' WS-CUST-ID
           END-READ.

       2100-WRITE-NEW-CUSTOMER.
           MOVE WS-CUSTOMER-WORK TO CUSTOMER-RECORD
           MOVE WS-CURRENT-DATE TO CUST-CREATED-DATE
           MOVE 'A' TO CUST-STATUS
           WRITE CUSTOMER-RECORD
           IF WS-FILE-STATUS = '00'
               ADD 1 TO WS-WRITE-COUNT
           ELSE
               ADD 1 TO WS-ERROR-COUNT
               MOVE 8 TO WS-RETURN-CODE
           END-IF.

       3000-UPDATE-CUSTOMER.
           MOVE WS-CUST-ID TO CUST-ID
           READ CUSTOMER-FILE
               INVALID KEY
                   MOVE 4 TO WS-RETURN-CODE
                   DISPLAY 'CUSTOMER NOT FOUND: ' WS-CUST-ID
               NOT INVALID KEY
                   PERFORM 3100-APPLY-UPDATES
           END-READ.

       3100-APPLY-UPDATES.
           IF WS-CUST-NAME NOT = SPACES
               MOVE WS-CUST-NAME TO CUST-NAME
           END-IF
           IF WS-CUST-ADDR NOT = SPACES
               MOVE WS-CUST-ADDR TO CUST-ADDR
           END-IF
           IF WS-CUST-PHONE NOT = SPACES
               MOVE WS-CUST-PHONE TO CUST-PHONE
           END-IF
           IF WS-CUST-EMAIL NOT = SPACES
               MOVE WS-CUST-EMAIL TO CUST-EMAIL
           END-IF
           MOVE WS-CURRENT-DATE TO CUST-LAST-ACTIVITY
           REWRITE CUSTOMER-RECORD
           IF WS-FILE-STATUS = '00'
               ADD 1 TO WS-UPDATE-COUNT
           ELSE
               ADD 1 TO WS-ERROR-COUNT
           END-IF.

       4000-DELETE-CUSTOMER.
           MOVE WS-CUST-ID TO CUST-ID
           READ CUSTOMER-FILE
               INVALID KEY
                   MOVE 4 TO WS-RETURN-CODE
               NOT INVALID KEY
                   MOVE 'I' TO CUST-STATUS
                   REWRITE CUSTOMER-RECORD
                   ADD 1 TO WS-DELETE-COUNT
           END-READ.

       5000-INQUIRY-CUSTOMER.
           MOVE WS-CUST-ID TO CUST-ID
           READ CUSTOMER-FILE
               INVALID KEY
                   MOVE 4 TO WS-RETURN-CODE
               NOT INVALID KEY
                   MOVE CUSTOMER-RECORD TO WS-CUSTOMER-WORK
                   ADD 1 TO WS-READ-COUNT
           END-READ.

       6000-GENERATE-REPORT.
           OPEN OUTPUT REPORT-FILE
           PERFORM 6100-WRITE-REPORT-HEADER
           MOVE LOW-VALUES TO CUST-ID
           START CUSTOMER-FILE KEY > CUST-ID
           PERFORM UNTIL WS-FILE-STATUS NOT = '00'
               READ CUSTOMER-FILE NEXT
                   AT END
                       MOVE '10' TO WS-FILE-STATUS
                   NOT AT END
                       PERFORM 6200-WRITE-REPORT-DETAIL
               END-READ
           END-PERFORM
           PERFORM 6300-WRITE-REPORT-FOOTER
           CLOSE REPORT-FILE.

       6100-WRITE-REPORT-HEADER.
           MOVE SPACES TO REPORT-RECORD
           STRING 'CUSTOMER MANAGEMENT REPORT - '
                  WS-CURRENT-DATE
                  DELIMITED BY SIZE INTO REPORT-RECORD
           WRITE REPORT-RECORD.

       6200-WRITE-REPORT-DETAIL.
           MOVE SPACES TO REPORT-RECORD
           STRING CUST-ID ' | '
                  CUST-NAME ' | '
                  CUST-STATUS ' | '
                  CUST-TYPE
                  DELIMITED BY SIZE INTO REPORT-RECORD
           WRITE REPORT-RECORD
           ADD 1 TO WS-READ-COUNT.

       6300-WRITE-REPORT-FOOTER.
           MOVE SPACES TO REPORT-RECORD
           STRING 'TOTAL RECORDS: ' WS-READ-COUNT
                  DELIMITED BY SIZE INTO REPORT-RECORD
           WRITE REPORT-RECORD.

      *================================================================
      * DEAD CODE SECTION - ARCHIVE PROCESSING
      * Last executed: 2019-06-15 (per JCL logs)
      * Replaced by DB2 archival process in 2020
      *================================================================
       7000-ARCHIVE-CUSTOMERS.
           OPEN OUTPUT ARCHIVE-FILE
           MOVE LOW-VALUES TO CUST-ID
           START CUSTOMER-FILE KEY > CUST-ID
           PERFORM UNTIL WS-FILE-STATUS NOT = '00'
               READ CUSTOMER-FILE NEXT
                   AT END
                       MOVE '10' TO WS-FILE-STATUS
                   NOT AT END
                       IF CUST-STATUS = 'I'
                           PERFORM 7100-WRITE-ARCHIVE
                       END-IF
               END-READ
           END-PERFORM
           CLOSE ARCHIVE-FILE.

       7100-WRITE-ARCHIVE.
           MOVE CUSTOMER-RECORD TO ARCHIVE-RECORD
           WRITE ARCHIVE-RECORD
           DELETE CUSTOMER-FILE RECORD
           ADD 1 TO WS-DELETE-COUNT.

      *================================================================
      * DEAD CODE SECTION - PURGE PROCESSING
      * Last executed: 2018-12-01 (per JCL logs)
      * Compliance team blocked this in 2019 - data retention policy
      *================================================================
       8000-PURGE-INACTIVE.
           MOVE LOW-VALUES TO CUST-ID
           START CUSTOMER-FILE KEY > CUST-ID
           PERFORM UNTIL WS-FILE-STATUS NOT = '00'
               READ CUSTOMER-FILE NEXT
                   AT END
                       MOVE '10' TO WS-FILE-STATUS
                   NOT AT END
                       IF CUST-STATUS = 'I'
                         AND CUST-LAST-ACTIVITY < '20200101'
                           DELETE CUSTOMER-FILE RECORD
                           ADD 1 TO WS-DELETE-COUNT
                       END-IF
               END-READ
           END-PERFORM.

      *================================================================
      * DEAD CODE SECTION - MIGRATION STUB
      * Never executed in production (per JCL logs)
      * Was planned for 2017 migration that was cancelled
      *================================================================
       9000-MIGRATE-TO-NEW-SYSTEM.
           DISPLAY 'MIGRATION NOT IMPLEMENTED'
           MOVE 12 TO WS-RETURN-CODE.

       9900-TERMINATE.
           CLOSE CUSTOMER-FILE
           DISPLAY 'CUSTMGMT COMPLETE - RC=' WS-RETURN-CODE
           DISPLAY 'READS=' WS-READ-COUNT
                   ' WRITES=' WS-WRITE-COUNT
                   ' UPDATES=' WS-UPDATE-COUNT
                   ' DELETES=' WS-DELETE-COUNT
                   ' ERRORS=' WS-ERROR-COUNT.
