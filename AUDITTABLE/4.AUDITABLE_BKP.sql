CREATE TABLE SCOTT.AUDITTABLE_BKP
(
  AUDIT_PK           VARCHAR2(36 BYTE)          NOT NULL,
  INSTRUCTIONID      VARCHAR2(50 BYTE)              NULL,
  PAYMENTID          VARCHAR2(60 BYTE)              NULL,
  TYPE               VARCHAR2(50 BYTE)          NOT NULL,
  EVENT              VARCHAR2(50 BYTE)          NOT NULL,
  ACTOR              VARCHAR2(50 BYTE)              NULL,
  RELATIONSHIP       VARCHAR2(50 BYTE)              NULL,
  AUDITTIMESTAMP     TIMESTAMP(6)               NOT NULL,
  DESCRIPTION        VARCHAR2(4000 BYTE)            NULL,
  EXTERNALREFERENCE  VARCHAR2(1000 BYTE)            NULL
)
TABLESPACE "VolpayData"
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING
NOCOMPRESS
NOCACHE
MONITORING;
CREATE INDEX AUD_INDX1_BKP ON SCOTT.AUDITTABLE_BKP
(INSTRUCTIONID)
LOGGING
TABLESPACE "VolpayData"
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );

CREATE INDEX AUD_INDX2_BKP ON SCOTT.AUDITTABLE_BKP
(INSTRUCTIONID, PAYMENTID)
LOGGING
TABLESPACE "VolpayData"
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );

CREATE INDEX AUD_INDX3_BKP ON SCOTT.AUDITTABLE_BKP
(PAYMENTID)
LOGGING
TABLESPACE "VolpayData"
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );
