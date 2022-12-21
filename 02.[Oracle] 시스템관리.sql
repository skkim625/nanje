SELECT * FROM USER_PASSWORD_LIMITS

-- ���̺� ����Ʈ
SELECT *--TABLE_NAME, '--'||COMMENTS 
FROM ALL_TAB_COMMENTS 
WHERE TABLE_NAME LIKE '%SQL%'  
--AND COMMENTS LIKE '%������ȣ%'

SELECT * FROM USER_SEGMENTS
 
SELECT * FROM V_$DATAFILE

SELECT * FROM TAB WHERE TNAME LIKE '%RECYCLE%'

-- ���̺� ������ ����(1)
SELECT * FROM USER_RECYCLEBIN

-- ORACLE VERSION
SELECT * FROM V$VERSION

-- 
SELECT VERSIONS_STARTTIME, VERSIONS_ENDTIME, VERSIONS_XID, VERSIONS_OPERATION
FROM CODE_GROUP VERSIONS BETWEEN TIMESTAMP MINVALUE AND MAXVALUE

-- ROLLBACK ����(2)
SELECT * FROM SYS.V_$SESSION_LONGOPS
SELECT TIME_REMAINING FROM SYS.V_$SESSION_LONGOPS WHERE SID =< OO 

-- 
SELECT * FROM V$SQL

-- TABLESPACE ����(3)
SELECT * FROM DATABASE_PROPERTIES WHERE PROPERTY_NAME = 'DEFAULT_PERMANENT_TABLESPACE'

------------------------------------------------------------------------------------------------
-- ���̺� �����̽�
------------------------------------------------------------------------------------------------
-- DEFAULT TABLESPACE ����
ALTER DATABASE DEFAULT TABLESPACE <TSNAME>

--
ALTER TABLESPACE <OLDNAME> RENAME TO <NEWNAME>

-- 
ALTER DATABASE DATAFILE '/ora_data/ORCL/sjp.dbf' AUTOEXTEND ON;

SELECT * FROM TABLESPACE

CREATE TABLESPACE TABLESPACE
[DATAFILE CLAUSE]
[MINIMUM EXTENT INTEGER[K|M]]
[BLOCKSIZE INTEGER [K]]
[LOGGING|NOLOGGING]
[DEFAULT STORAGE_CLAUSE ]
[ONLINE|OFFLINE]
[PERMANENT|TEMPORARY]

-- SJP_DEV ���̺����̽� ����
CREATE TABLESPACE SJP_MONITER
--DATAFILE '/ora_data/ORCL/sjp_moniter.dbf' SIZE 100M
DATAFILE '/data/moniter_db/sjp_moniter.dbf' SIZE 100M
AUTOEXTEND ON NEXT 5M MAXSIZE 1000M;

CREATE TEMPORARY TABLESPACE TEMP_PJT
  TEMPFILE '/ora_data/ORCL/temp01_pjt.dbf'
  SIZE 32M
  AUTOEXTEND ON
  NEXT 32M MAXSIZE 2048M
  EXTENT MANAGEMENT LOCAL;
           
-- 
DROP TABLESPACE sjp_pjt INCLUDING CONTENTS AND DATAFILES

DROP TABLESPACE TEMP01_070210 INCLUDING CONTENTS AND DATAFILES 

------------------------------------------------------------------------------------------------
-- ����
------------------------------------------------------------------------------------------------
-- ���� ����
CREATE USER SJP_MONITER
IDENTIFIED BY DHFKZMF
DEFAULT TABLESPACE SJP_MONITER;
--TEMPORARY TABLESPACE TEMP_PJT;

--�����ֱ�
GRANT CONNECT, RESOURCE TO SAERO;

-- user ����
ALTER USER SCOTT IDENTIFIED BY TIGER

-- user ����
--DROP USER SJP_070210 CASCADE;
 
-- user ��ȸ
SELECT * FROM DBA_USERS

-- user lock Ǯ��
ALTER USER SJP ACCOUNT UNLOCK

-- user index ����
USER_INDEXES

-- view ���
SELECT * FROM USER_VIEWS

-- ����,����,������ �� �ִ� ���θ� �� �� �ִ� ��ųʸ� ��
SELECT * FROM USER_UPDATABLE_COLUMNS WHERE TABLE_NAME IN (SELECT VIEW_NAME FROM USER_VIEWS)

------------------------------------------------------------------------------------------------
-- ��� DATA DICTIONARY
------------------------------------------------------------------------------------------------
    DBA_TABLES
    DBA_TAB_HISTOGRAMS
    DBA_OBJECT_TABLES
    DBA_TAB_COL_STATISTICS
    DBA_INDEXES
    DBA_CLUSTERS
    DBA_TAB_PARTITIONS
    DBA_TAB_SUBPARTITIONS
    DBA_TAB_STATISTICS

-- rollback segment ���� üũ���
SELECT  BEGIN_TIME, MAXQUERYLEN, 
        TRUNC(ACTIVEBLKS*8*1024/1024/1024+UNEXPIREDBLKS*8*1024/1024/1024) USED_SIZE,
        TRUNC(EXPIREDBLKS*8*1024/1024/1024) AVAILABLE_SIZE  ,
        TUNED_UNDORETENTION 
FROM V$UNDOSTAT;

-- ������� �ͽ���Ʈ ���� ��ȸ(DBA_EXTENTS)
SELECT * --extent_id, file_id, block_id, blocks
       --distinct segment_type 
         FROM  DBA_EXTENTS
         WHERE OWNER='SJP'
   AND   SEGMENT_NAME= 'WORK_INFOMATION';

--��� ������ �ͽ���Ʈ ������ ��ȸ(DBMS_FREE_SPACE)
SELECT COUNT(*), MAX(BLOCKS), SUM(BLOCKS), TABLESPACE_NAME
        FROM  DBA_FREE_SPACE
        GROUP BY TABLESPACE_NAME;

--------------------------------------------------------------------------------
-- db link
--------------------------------------------------------------------------------
1. SYSTEM���� �α����Ͽ� SJP ������ �����ֱ�
GRANT CREATE DATABASE LINK TO SAERO;

2.DB LINK �����ϱ�
CREATE DATABASE LINK NEW CONNECT TO SJP IDENTIFIED BY DHFKZMF USING 'new';

SELECT * FROM USER_DB_LINKS;

3.TNSNAMES.ORA�� �߰��ϱ�(���DB)
ORG =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 58.120.225.243)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ORCL)
    )
  )

4.����ϱ�
SELECT * FROM WORK_INFOMATION@NEW;

/*------------------------------------------------------------------------------
object�� extent�� �Ҵ�Ǹ�, ������ ���� �� ����ִ�, �� ������ �ٸ� �뵵�� ����� �� ����.
�ᱹ, table/index�� ũ�⿹���� �߸��Ͽ� �ʹ� ũ�� ������ �Ҵ��ߴٸ�, ������ ���̴�. 
����, �ʱ��� ������� �޸� ���� �����Ͱ� �������� ����ɼ��� �ִ�. 
 �̷��� ���� �����ϱ� ���� �Ʒ��� ����� ����ϸ� �ȴ�. ���� free block�� ��ü ��� 
���� �ִٸ�, reorg�� �Ͽ� ������ reclaim�Ͽ� �ٸ� �뵵�� ����Ҽ� �ִ�.
------------------------------------------------------------------------------*/

SET SERVEROUTPUT ON
DECLARE
 SEGMENT_OWNER                  VARCHAR2(10);
 SEGMENT_NAME                   VARCHAR2(10);
 SEGMENT_TYPE                   VARCHAR2(10);
 TOTAL_BLOCKS                   NUMBER(30);
 TOTAL_BYTES                    NUMBER(30);
 UNUSED_BLOCKS                  NUMBER(30);
 UNUSED_BYTES                   NUMBER(30);
 LAST_USED_EXTENT_FILE_ID       NUMBER(30);
 LAST_USED_EXTENT_BLOCK_ID      NUMBER(30);
 LAST_USED_BLOCK                NUMBER(30);
BEGIN
 SEGMENT_OWNER := 'SCOTT';
 SEGMENT_NAME  := 'EMP';
 SEGMENT_TYPE  := 'TABLE';
 DBMS_SPACE.UNUSED_SPACE(SEGMENT_OWNER,SEGMENT_NAME,SEGMENT_TYPE,
 TOTAL_BLOCKS,TOTAL_BYTES, UNUSED_BLOCKS,UNUSED_BYTES,LAST_USED_EXTENT_FILE_ID,
LAST_USED_EXTENT_BLOCK_ID, LAST_USED_BLOCK);
 DBMS_OUTPUT.PUT_LINE('total_blocks             :'||TO_CHAR(TOTAL_BLOCKS));
 DBMS_OUTPUT.PUT_LINE('total_bytes              :'||TO_CHAR(TOTAL_BYTES));
 DBMS_OUTPUT.PUT_LINE('unused_blocks            :'||TO_CHAR(UNUSED_BLOCKS));
 DBMS_OUTPUT.PUT_LINE('unused_bytes             :'||TO_CHAR(UNUSED_BYTES));
 DBMS_OUTPUT.PUT_LINE('last_used_extent_file_id :'||TO_CHAR(LAST_USED_EXTENT_FILE_ID));
 DBMS_OUTPUT.PUT_LINE('last_used_extent_block_id:'||TO_CHAR(LAST_USED_EXTENT_BLOCK_ID));
 DBMS_OUTPUT.PUT_LINE('last_used_block          :'||TO_CHAR(LAST_USED_BLOCK));
END FIND;
/

/*---------------------------------------------------------------------------------------------
������� ����(System Statistics)
---------------------------------------------------------------------------------------------*/

-- Ȯ��
SELECT * FROM SYS.AUX_STATS$

-- �ٷ�����
EXEC DBMS_STATS.GATHER_SYSTEM_STATS('INTERVAL',10);

/*---------------------------------------------------------------------------------------------
������� ����(Fixed Objects Statistics)
---------------------------------------------------------------------------------------------*/
EXEC DBMS_STATS.GATHER_FIXED_OBJECTS_STATS

SELECT TABLE_NAME, TO_CHAR(LAST_ANALYZED,'yyyymmdd hh24:mi:ss hh24:mi:ss')
FROM DBA_TAB_STATISTICS
WHERE TABLE_NAME LIKE 'X$%'

/*---------------------------------------------------------------------------------------------
������� ����(Dictionary Statistics)
---------------------------------------------------------------------------------------------*/
EXEC DBMS_STATS.GATHER_DICTIONARY_STATS

SELECT TABLE_NAME, TO_CHAR(LAST_ANALYZED, 'yyyymmdd hh24:mi:ss hh24:mi:ss')
FROM DBA_TAB_STATISTICS
WHERE TABLE_NAME LIKE '%$';

/*---------------------------------------------------------------------------------------------
������� ����(User Schema Statistics)
---------------------------------------------------------------------------------------------*/
EXEC DBMS_STATS.GATHER_TABLE_STATS('SAENURI','PROJECT',dbms_stats.auto_sample_size,'FOR ALL COLUMNS SIZE AUTO',TRUE);
/*<TOAD_FILE_CHUNK>*/

/*
emp table�� ������ ����. 
��ü 8 block�߿�, unused block�� ���� �� ���� �ִ�... 
�������� ū table�� �غ��ñ�.....
 
-- output.
total_blocks             :8
total_bytes              :65536
unused_blocks            :0
unused_bytes             :0
last_used_extent_file_id :4
last_used_extent_block_id:9
last_used_block          :8

PL/SQL procedure successfully completed.
*/


/*------------------------------------------------------------------------------
INDEX �����Ȳ Ȯ�� �ϴ� ���
------------------------------------------------------------------------------*/
/*
����Ŭ���� �ʿ信 ���ؼ� �ε����� ����� ���� ���Ŀ� �� �ε����� ����ϴ��� ���ϴ��� 
�� ���� ��� �ʿ���� �ε����� ���ؼ� ���Ǿ����� ��ũ ������ ȸ�� ���� ���ϰ� �ִ� 
��찡 ���� �ִ�.
�� ��� �ε��� ��뿩�θ� Ȯ���ؼ� ������� �ʴ� �ε����� ��� drop �Ͽ� 
���ʿ��� ��ũ ������ �ٿ��ִ°� ����.
Oracle 9i ���� �����Ǵ� Monitoring ��ɿ� ���ؼ� �����ϰ� �����ϰ��� �Ѵ�.
����͸� �ϰ��� �ϴ� �ε����� test_pk ���
����͸��� �����ϱ� ���ؼ��� alter index test_pk monitoring usage;
����͸��� �ߴ��ϱ� ���ؼ��� alter index test_pk nomonitoring usage;
�׸��� ����͸� ����� Ȯ���ϱ����ؼ� 
*/
SELECT * FROM V$OBJECT_USAGE;
/* 
�� Ȯ���ϸ� �ȴ�.
������ v$object_usage �� �����Ͱ� ���� ���
*/ 
SELECT * FROM SYS.OBJECT_USAGE
 
�� ��ȸ�ϸ� �ȴ�.
SELECT O.OWNER, O.OBJECT_NAME, O.OBJECT_TYPE, DECODE(BITAND(U.FLAGS, 1), 0, 'NO', 'YES'),
U.START_MONITORING, U.END_MONITORING FROM SYS.OBJECT_USAGE U, ALL_OBJECTS O WHERE
O.OBJ# = O.OBJECT_ID;

���⼭ DECODE(BITAND(U.FLAGS, 1), 0, 'NO', 'YES') �κ��� YES �̸� �ε����� ���Ǵ°��̰�
NO ���·� ��� �����ȴٸ� ������� �ʴ� �ε������ ���� �ȴ�.
�׸��� �ε��� ����͸� �Ⱓ�� ���̺� ���� ���� �ٸ������� ������ ���� �ΰ� ���°� ����.
