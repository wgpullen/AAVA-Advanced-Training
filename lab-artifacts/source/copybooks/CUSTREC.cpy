      *================================================================
      * CUSTREC - CUSTOMER RECORD COPYBOOK
      * Used by: CUSTMGMT, CUSTRPT, CUSTINQ
      *================================================================
       01 CUSTOMER-RECORD-LAYOUT.
           05 CUST-ID                PIC X(10).
           05 CUST-NAME              PIC X(40).
           05 CUST-ADDR              PIC X(60).
           05 CUST-PHONE             PIC X(15).
           05 CUST-EMAIL             PIC X(50).
           05 CUST-STATUS            PIC X(1).
               88 CUST-ACTIVE        VALUE 'A'.
               88 CUST-INACTIVE      VALUE 'I'.
               88 CUST-SUSPENDED     VALUE 'S'.
           05 CUST-TYPE              PIC X(2).
               88 CUST-RETAIL        VALUE 'RT'.
               88 CUST-WHOLESALE     VALUE 'WH'.
               88 CUST-CORPORATE     VALUE 'CP'.
           05 CUST-BALANCE           PIC S9(9)V99 COMP-3.
           05 CUST-CREDIT-LIMIT      PIC S9(9)V99 COMP-3.
           05 CUST-LAST-ACTIVITY     PIC X(8).
           05 CUST-CREATED-DATE      PIC X(8).
           05 CUST-ACCOUNT-COUNT     PIC 9(3).
           05 CUST-REGION-CODE       PIC X(4).
           05 FILLER                 PIC X(35).
