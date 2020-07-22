declare
    hora_inicio VARCHAR(19);
    hora_fin VARCHAR(19);

    xml_data_ini NUMBER;
    bloques_xml_data_ini NUMBER;
    xml_data_fin NUMBER;
    bloques_xml_data_fin NUMBER;

    o_count number;
    b_count number;
    exec_enable number;
    err_num NUMBER;
    err_msg VARCHAR2(255);
    tbl_exist  PLS_INTEGER;
    v_index_names varchar2(200);
    exep_msg VARCHAR2(255);


BEGIN
    --check Control Table
    select VALUE INTO exec_enable from SCOTT.DEPURACION_ENABLED where ID=1;


	-- HORA INICIO
    SELECT TO_CHAR(CURRENT_TIMESTAMP, 'DD/MM/YYYY HH24:MI:SS') INTO hora_inicio FROM DUAL;
IF (exec_enable = 1) THEN



	-- ANALIZE ACTUAL TABLE REGISTERS
  EXECUTE IMMEDIATE 'ANALYZE TABLE SCOTT.AUDITTABLE COMPUTE STATISTICS';
  SELECT COUNT(*) INTO xml_data_ini FROM SCOTT.AUDITTABLE;
  SELECT BLOCKS INTO bloques_xml_data_ini FROM user_TABLES WHERE TABLE_NAME='AUDITTABLE';


  -- PREPRATE BACKUP TABLE
  EXECUTE IMMEDIATE 'TRUNCATE TABLE SCOTT.AUDITTABLE_BKP';
  EXECUTE IMMEDIATE 'INSERT INTO  SCOTT.AUDITTABLE_BKP  SELECT * FROM SCOTT.AUDITTABLE AU
  WHERE NOT EXISTS( SELECT INSTRUCTIONID FROM SCOTT.PWRCNTR_INSTRUCTIONID PI WHERE AU.INSTRUCTIONID = PI.INSTRUCTIONID )';

	-- START MAINTENANCE
  SELECT COUNT(*) INTO o_count FROM SCOTT.AUDITTABLE_BKP ;
  dbms_output.put_line('BKP: ' ||o_count);

			-- CHECK IF BACKUP IS SUCCESSFUL
            IF ( o_count >0) THEN
           dbms_output.put_line('.::BACKUP TABLE COMPLETE::.');
 	         dbms_output.put_line('.::TRUNCATING TABLE::.');

           EXECUTE IMMEDIATE('TRUNCATE TABLE  SCOTT.AUDITTABLE DROP STORAGE ');
			    -- DISABLE CONSTRAINTS
              	begin
              	    dbms_output.put_line('.::START DISABLING CONSTRAINTS::.');
                    for cur in (select owner, constraint_name , table_name
                        from all_constraints
                        where owner = 'SCOTT' and
                        TABLE_NAME = 'AUDITTABLE') loop
                      execute immediate 'ALTER TABLE '||cur.owner||'.'||cur.table_name||'
                      MODIFY CONSTRAINT "'||cur.constraint_name||'" DISABLE ';
                   end loop;
                    dbms_output.put_line('.::END DISABLING CONSTRAINTS::.');
                 EXCEPTION WHEN others THEN
 	             dbms_output.put_line('.::EXCEPTION DISABLING  INDEXES::.');
 	             exep_msg := 'PROBLEM DISABLING CONSTRAINTS, CHECK IT AND MANUALY UPDATE DEPURACION_ENABLED TABLE';
 	              	 BEGIN
                         EXECUTE IMMEDIATE ('UPDATE DEPURACION_ENABLED SET VALUE = 0 WHERE ID = 1');
                         commit;
                     EXCEPTION WHEN others THEN
      	             dbms_output.put_line('.::FAIL UPDATING EXECUTION CONTROL TABLE, CHECK AS SOON AS POSSIBLE::.');
       	             exep_msg := 'PROBLEM DISABLING CONSTRAINTS AND EXECUTION CONTROL TABLE, CHECK AS SOON AS POSSIBLE';
                     null;
                  END;
                 NULL;

                END;

			  -- DROP INDEXES
			 BEGIN
	             dbms_output.put_line('.::START DROPPING indexes::.');
                 for r_c1 in (select * from ALL_INDEXES where TABLE_NAME='AUDITTABLE' and TABLE_OWNER ='SCOTT') loop
                 v_index_names:= 'DROP INDEX '||r_c1.INDEX_NAME;
                 execute immediate v_index_names;
                 end loop;
                 dbms_output.put_line('END DROP INDEXES');
             EXCEPTION WHEN others THEN
 	             dbms_output.put_line('.::EXCEPTION DROPPING INDEXES::.');
 	             exep_msg := 'PROBLEM DROPING INDEXES , CHECK IT AND MANUALY UPDATE DEPURACION_ENABLED TABLE';
 	             BEGIN
                     EXECUTE IMMEDIATE ('UPDATE DEPURACION_ENABLED SET VALUE = 0 WHERE ID = 1');
                     commit;
                 EXCEPTION WHEN others THEN
      	             dbms_output.put_line('.::FAIL UPDATING EXECUTION CONTROL TABLE::.');
                     BEGIN
                        EXECUTE IMMEDIATE ('UPDATE DEPURACION_ENABLED SET VALUE = 0 WHERE ID = 1');
                        COMMIT;
                      EXCEPTION WHEN others THEN
                        dbms_output.put_line('.::FAIL UPDATING EXECUTION CONTROL TABLE CHECK AS SOON AS POSSIBLE::.');
                        exep_msg := 'PROBLEM DROPING INDEXES AND  EXECUTION CONTROL TABLE, CHECK AS SOON AS POSSIBLE';
                        null;
                      END;
                     NULL;
                  END;
                 NULL;

             END;




			  -- CHECK table truncated succesfull
              SELECT COUNT(*) INTO b_count FROM SCOTT.AUDITTABLE ;
              dbms_output.put_line( b_count );

					-- REPOBLAR TABLA FUENTE
                            dbms_output.put_line('.::START REPOPULATING TABLE::.');
                            EXECUTE IMMEDIATE('INSERT INTO  SCOTT.AUDITTABLE SELECT * FROM
                            SCOTT.AUDITTABLE_BKP');
                            COMMIT;
                            dbms_output.put_line('.::END REPOPULATING TABLE::.');

                    -- ENABLE CONSTRAINTS

                        BEGIN
                              dbms_output.put_line('.::START ENABLING CONSTRAINTS::.');
                            for cur in (select owner, constraint_name , table_name
                                from all_constraints
                                where owner = 'SCOTT' and
                                TABLE_NAME = 'AUDITTABLE') loop
                              execute immediate 'ALTER TABLE '||cur.owner||'.'||cur.table_name||'
                              MODIFY CONSTRAINT "'||cur.constraint_name||'" ENABLE ';
                           end loop;
                            dbms_output.put_line('.::END ENABLING CONSTRAINTS::.');
                        EXCEPTION WHEN others THEN
                            dbms_output.put_line('.::EXCEPTION ENABLING CONSTRAINTS::.');
                            exep_msg := 'PROBLEM ENABLING CONSTRAINTS, CHECK IT AND MANUALY UPDATE DEPURACION_ENABLED TABLE';
                             BEGIN
                                     EXECUTE IMMEDIATE ('UPDATE DEPURACION_ENABLED SET VALUE = 0 WHERE ID = 1');
                                     commit;
                                 EXCEPTION WHEN others THEN
                                 dbms_output.put_line('.::FAIL UPDATING EXECUTION CONTROL TABLE CHECK AS SOON AS POSSIBLE::.');
                                 exep_msg := 'PROBLEM ENABLING CONSTRAINTS AND CONTROL TABLE, CHECK AS SOON AS POSSIBLE';
                                 null;
                              END;
                            NULL;
                        END;


					-- CREATE INDEXES

					    BEGIN
                  dbms_output.put_line('.::Starting to CRETING indexes::.');
                  EXECUTE IMMEDIATE('CREATE INDEX SCOTT.AUD_INDX1 ON SCOTT.AUDITTABLE(INSTRUCTIONID)
                  TABLESPACE TBS_VOLPAY_INDEX');
                  EXECUTE IMMEDIATE('CREATE INDEX SCOTT.AUD_INDX2 ON SCOTT.AUDITTABLE(INSTRUCTIONID, PAYMENTID)
                   TABLESPACE TBS_VOLPAY_INDEX');
                  EXECUTE IMMEDIATE('CREATE INDEX SCOTT.AUD_INDX3 ON SCOTT.AUDITTABLE(PAYMENTID)
                  TABLESPACE TBS_VOLPAY_INDEX');
                dbms_output.put_line('.::INDEXES CREATED::.');


                        EXCEPTION WHEN others THEN
                            dbms_output.put_line('.::EXCEPTION CREATING INDEXES::.');
                            exep_msg := 'PROBLEM CREATING INDEXES, CHECK IT AND MANUALY UPDATE DEPURACION_ENABLED TABLE';
                             BEGIN
                                     EXECUTE IMMEDIATE ('UPDATE DEPURACION_ENABLED SET VALUE = 0 WHERE ID = 1');
                                     commit;
                                 EXCEPTION WHEN others THEN
                                 dbms_output.put_line('.::FAIL UPDATING EXECUTION CONTROL TABLE::.');
                                 exep_msg := 'PROBLEM CREATING INDEXES AND CONTROL TABLE, CHECK AS SOON AS POSSIBLE';
                                 null;
                              END;
                             NULL;
                         END;

                             --FIN MANTENIMIENTO
                             err_num := 0;
                             err_msg := 'AUDITTABLE: Proceso de depuración exitoso';

            ELSE
                dbms_output.put_line('NO ROWS TO DELETE');
            END IF;

--  ANALICE TABLE & CHECK REGISTERS AND FINAL BLOCKS
EXECUTE IMMEDIATE 'ANALYZE TABLE SCOTT.AUDITTABLE COMPUTE STATISTICS';
SELECT COUNT(*) INTO xml_data_fin FROM SCOTT.AUDITTABLE;
SELECT BLOCKS INTO bloques_xml_data_fin FROM USER_TABLES WHERE TABLE_NAME='AUDITTABLE';

ELSE
    dbms_output.put_line('EXECUTION DISABLED');
    err_num := 1;
    err_msg := 'AUDITTABLE: EXECUTION DISABLED';
    dbms_output.put_line('err value assinged: ' || err_msg);
    exep_msg := 'A PREVIOUS ERROR EXIST, CHECK IT AND MANUALY UPDATE DEPURACION_ENABLED TABLE';


END IF;

--HORA FIN
SELECT TO_CHAR(CURRENT_TIMESTAMP, 'DD/MM/YYYY HH24:MI:SS') INTO hora_fin FROM DUAL;
DBMS_OUTPUT.PUT_LINE('Hora de inicio de la ejecucion ' || hora_inicio);
DBMS_OUTPUT.PUT_LINE('Hora de final de la ejecucion ' || hora_fin);

-- STORE FINAL HOUR OF MANITENANCE
INSERT INTO DEPURACION_LOG VALUES (SEQ_DEPURACION_LOG.NEXTVAL, err_num, err_msg, hora_inicio, hora_fin, xml_data_ini,
xml_data_fin, bloques_xml_data_ini, bloques_xml_data_fin , exep_msg);
COMMIT;



-- EXCEPTIONS
        EXCEPTION
        WHEN OTHERS THEN
            BEGIN
                err_num := SQLCODE;
                err_msg := 'AUDITTABLE' || SQLERRM;
                exep_msg := 'FAIL BACKINGUP, OR REPOPULATING TABLE';
                dbms_output.put_line(err_num ||' -> Error encontrado');
                dbms_output.put_line(err_msg ||' -> Mensaje Error encontrado');
                SELECT COUNT(*) INTO xml_data_fin FROM AUDITTABLE;
                -- STORE FINAL HOUR OF MANITENANCE
                SELECT TO_CHAR(CURRENT_TIMESTAMP, 'DD/MM/YYYY HH24:MI:SS') INTO hora_fin FROM DUAL;
                INSERT INTO DEPURACION_LOG VALUES (SEQ_DEPURACION_LOG.NEXTVAL, err_num, err_msg, hora_inicio, hora_fin,
                xml_data_ini, xml_data_fin, bloques_xml_data_ini, bloques_xml_data_fin, exep_msg );
                COMMIT;
                EXECUTE IMMEDIATE ('UPDATE DEPURACION_ENABLED SET VALUE = 0 WHERE ID = 1');
                commit;
              EXCEPTION WHEN others THEN
      	            dbms_output.put_line('.::FAIL UPDATING EXECUTION CONTROL TABLE::.');
                    null;
              END;
END;
