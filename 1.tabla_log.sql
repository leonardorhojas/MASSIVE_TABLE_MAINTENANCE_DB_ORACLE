CREATE TABLE SCOTT.DEPURACION_LOG
(
  ID                              NUMBER,
  COD_ERROR                       NUMBER,
  DESC_ERROR                      VARCHAR2(255 BYTE),
  FECHA_INICIO                    VARCHAR2(19 BYTE),
  FECHA_FIN                       VARCHAR2(19 BYTE),
  REGISTROS_XML_DATA_INICIO     NUMBER,
  REGISTROS_XML_DATA_FIN        NUMBER,
  BLOQUES_XML_DATA_INICIO          NUMBER,
  BLOQUES_XML_DATA_FIN             NUMBER,
  EXCEPTIONS                    VARCHAR2(255 BYTE)
);
CREATE UNIQUE INDEX ID_PK ON SCOTT.DEPURACION_LOG (ID);
ALTER TABLE SCOTT.DEPURACION_LOG ADD (
  CONSTRAINT ID_PK
  PRIMARY KEY
  (ID)
  USING INDEX ID_PK
  ENABLE VALIDATE);

GRANT SELECT ON SCOTT.DEPURACION_LOG TO READ_ROLE;

CREATE SEQUENCE SCOTT.SEQ_DEPURACION_LOG
    INCREMENT BY 1
    START WITH 1
    MINVALUE 1
    MAXVALUE 100000000
    CYCLE
    CACHE 2;
