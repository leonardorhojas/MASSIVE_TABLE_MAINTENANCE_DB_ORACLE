BEGIN
    BEGIN
    dbms_output.put_line('.::START DISABLING CONSTRAINTS::.');
        for cur in (select owner, constraint_name , table_name
            from all_constraints
            where owner = 'SCOTT' and
            TABLE_NAME = 'PAYMENTCONTROLDATA') loop
          execute immediate 'ALTER TABLE '||cur.owner||'.'||cur.table_name||'
          MODIFY CONSTRAINT "'||cur.constraint_name||'" DISABLE ';
        end loop;
    END;

EXECUTE IMMEDIATE('DROP INDEX USERDBA.PCD_INDX18') ;
EXECUTE IMMEDIATE('DROP INDEX USERDBA.PCD_INDX19') ;
EXECUTE IMMEDIATE('CREATE INDEX SCOTT.PCD_INDX18 ON SCOTT.PAYMENTCONTROLDATA (INSTRUCTIONID, PAYMENTID, PARTYSERVICEASSOCIATIONCODE, STATUS, AMOUNT) LOGGING TABLESPACE TBS_VOLPAY_INDEX');
EXECUTE IMMEDIATE('CREATE INDEX SCOTT.PCD_INDX19 ON SCOTT.PAYMENTCONTROLDATA (INSTRUCTIONID, PAYMENTID, RECEIVEDDATE, STATUS, AMOUNT) LOGGING TABLESPACE TBS_VOLPAY_INDEX ');

    BEGIN
    dbms_output.put_line('.::START ENABLING CONSTRAINTS::.');
        for cur in (select owner, constraint_name , table_name
            from all_constraints
            where owner = 'SCOTT' and
            TABLE_NAME = 'PAYMENTCONTROLDATA') loop
            execute immediate 'ALTER TABLE '||cur.owner||'.'||cur.table_name||'
            MODIFY CONSTRAINT "'||cur.constraint_name||'" ENABLE ';
        end loop;
    END;
END;
