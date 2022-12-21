SELECT * FROM USER_PASSWORD_LIMITS

-- 테이블 리스트
SELECT *--TABLE_NAME, '--'||COMMENTS 
FROM ALL_TAB_COMMENTS 
WHERE TABLE_NAME LIKE '%SQL%'  
--AND COMMENTS LIKE '%관리번호%'

SELECT * FROM USER_SEGMENTS
 
SELECT * FROM V_$DATAFILE

SELECT * FROM TAB WHERE TNAME LIKE '%RECYCLE%'

-- 테이블 휴지통 관련(1)
SELECT * FROM USER_RECYCLEBIN

-- ORACLE VERSION
SELECT * FROM V$VERSION

-- 
SELECT VERSIONS_STARTTIME, VERSIONS_ENDTIME, VERSIONS_XID, VERSIONS_OPERATION
FROM CODE_GROUP VERSIONS BETWEEN TIMESTAMP MINVALUE AND MAXVALUE

-- ROLLBACK 관련(2)
SELECT * FROM SYS.V_$SESSION_LONGOPS
SELECT TIME_REMAINING FROM SYS.V_$SESSION_LONGOPS WHERE SID =< OO 

-- 
SELECT * FROM V$SQL

-- TABLESPACE 관리(3)
SELECT * FROM DATABASE_PROPERTIES WHERE PROPERTY_NAME = 'DEFAULT_PERMANENT_TABLESPACE'

------------------------------------------------------------------------------------------------
-- 테이블 스페이스
------------------------------------------------------------------------------------------------
-- DEFAULT TABLESPACE 변경
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

-- SJP_DEV 테이블스페이스 생성
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
-- 유저
------------------------------------------------------------------------------------------------
-- 유저 생성
CREATE USER SJP_MONITER
IDENTIFIED BY DHFKZMF
DEFAULT TABLESPACE SJP_MONITER;
--TEMPORARY TABLESPACE TEMP_PJT;

--권한주기
GRANT CONNECT, RESOURCE TO SAERO;

-- user 변경
ALTER USER SCOTT IDENTIFIED BY TIGER

-- user 삭제
--DROP USER SJP_070210 CASCADE;
 
-- user 조회
SELECT * FROM DBA_USERS

-- user lock 풀기
ALTER USER SJP ACCOUNT UNLOCK

-- user index 보기
USER_INDEXES

-- view 목록
SELECT * FROM USER_VIEWS

-- 삽입,삭제,수정할 수 있는 여부를 알 수 있는 딕셔너리 뷰
SELECT * FROM USER_UPDATABLE_COLUMNS WHERE TABLE_NAME IN (SELECT VIEW_NAME FROM USER_VIEWS)

------------------------------------------------------------------------------------------------
-- 통계 DATA DICTIONARY
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

-- rollback segment 부족 체크방법
SELECT  BEGIN_TIME, MAXQUERYLEN, 
        TRUNC(ACTIVEBLKS*8*1024/1024/1024+UNEXPIREDBLKS*8*1024/1024/1024) USED_SIZE,
        TRUNC(EXPIREDBLKS*8*1024/1024/1024) AVAILABLE_SIZE  ,
        TUNED_UNDORETENTION 
FROM V$UNDOSTAT;

-- 사용중인 익스텐트 정보 조회(DBA_EXTENTS)
SELECT * --extent_id, file_id, block_id, blocks
       --distinct segment_type 
         FROM  DBA_EXTENTS
         WHERE OWNER='SJP'
   AND   SEGMENT_NAME= 'WORK_INFOMATION';

--사용 가능한 익스텐트 정보의 조회(DBMS_FREE_SPACE)
SELECT COUNT(*), MAX(BLOCKS), SUM(BLOCKS), TABLESPACE_NAME
        FROM  DBA_FREE_SPACE
        GROUP BY TABLESPACE_NAME;

--------------------------------------------------------------------------------
-- db link
--------------------------------------------------------------------------------
1. SYSTEM으로 로그인하여 SJP 유저에 권한주기
GRANT CREATE DATABASE LINK TO SAERO;

2.DB LINK 생성하기
CREATE DATABASE LINK NEW CONNECT TO SJP IDENTIFIED BY DHFKZMF USING 'new';

SELECT * FROM USER_DB_LINKS;

3.TNSNAMES.ORA에 추가하기(대상DB)
ORG =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 58.120.225.243)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ORCL)
    )
  )

4.사용하기
SELECT * FROM WORK_INFOMATION@NEW;

/*------------------------------------------------------------------------------
object에 extent가 할당되면, 꽉차게 쓰던 텅 비어있던, 그 공간은 다른 용도로 사용할 수 없다.
결국, table/index의 크기예상을 잘못하여 너무 크게 공간을 할당했다면, 낭비일 것이다. 
또한, 초기의 예상과는 달리 많은 데이터가 지워져서 낭비될수도 있다. 
 이러한 것을 조사하기 위해 아래의 방법을 사용하면 된다. 만약 free block이 전체 대비 
많이 있다면, reorg를 하여 공간을 reclaim하여 다른 용도로 사용할수 있다.
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
통계정보 생성(System Statistics)
---------------------------------------------------------------------------------------------*/

-- 확인
SELECT * FROM SYS.AUX_STATS$

-- 바로적용
EXEC DBMS_STATS.GATHER_SYSTEM_STATS('INTERVAL',10);

/*---------------------------------------------------------------------------------------------
통계정보 생성(Fixed Objects Statistics)
---------------------------------------------------------------------------------------------*/
EXEC DBMS_STATS.GATHER_FIXED_OBJECTS_STATS

SELECT TABLE_NAME, TO_CHAR(LAST_ANALYZED,'yyyymmdd hh24:mi:ss hh24:mi:ss')
FROM DBA_TAB_STATISTICS
WHERE TABLE_NAME LIKE 'X$%'

/*---------------------------------------------------------------------------------------------
통계정보 생성(Dictionary Statistics)
---------------------------------------------------------------------------------------------*/
EXEC DBMS_STATS.GATHER_DICTIONARY_STATS

SELECT TABLE_NAME, TO_CHAR(LAST_ANALYZED, 'yyyymmdd hh24:mi:ss hh24:mi:ss')
FROM DBA_TAB_STATISTICS
WHERE TABLE_NAME LIKE '%$';

/*---------------------------------------------------------------------------------------------
통계정보 생성(User Schema Statistics)
---------------------------------------------------------------------------------------------*/
EXEC DBMS_STATS.GATHER_TABLE_STATS('SAENURI','PROJECT',dbms_stats.auto_sample_size,'FOR ALL COLUMNS SIZE AUTO',TRUE);
/*<TOAD_FILE_CHUNK>*/

/*
emp table을 예제로 본것. 
전체 8 block중에, unused block이 없이 다 쓰고 있다... 
여러분의 큰 table도 해보시길.....
 
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
INDEX 사용현황 확인 하는 방법
------------------------------------------------------------------------------*/
/*
오라클에서 필요에 의해서 인덱스를 만들어 놓고 이후에 이 인덱스를 사용하는지 안하는지 
알 수가 없어서 필요없는 인덱스에 의해서 사용되어지는 디스크 공간을 회수 하지 못하고 있는 
경우가 많이 있다.
이 경우 인덱스 사용여부를 확인해서 사용하지 않는 인덱스의 경우 drop 하여 
불필요한 디스크 공간을 줄여주는게 좋다.
Oracle 9i 부터 제공되는 Monitoring 기능에 대해서 간단하게 설명하고자 한다.
모니터링 하고자 하는 인덱스가 test_pk 라면
모니터링을 시작하기 위해서는 alter index test_pk monitoring usage;
모니터링을 중단하기 위해서는 alter index test_pk nomonitoring usage;
그리고 모니터링 결과를 확인하기위해서 
*/
SELECT * FROM V$OBJECT_USAGE;
/* 
로 확인하면 된다.
하지만 v$object_usage 로 데이터가 없을 경우
*/ 
SELECT * FROM SYS.OBJECT_USAGE
 
를 조회하면 된다.
SELECT O.OWNER, O.OBJECT_NAME, O.OBJECT_TYPE, DECODE(BITAND(U.FLAGS, 1), 0, 'NO', 'YES'),
U.START_MONITORING, U.END_MONITORING FROM SYS.OBJECT_USAGE U, ALL_OBJECTS O WHERE
O.OBJ# = O.OBJECT_ID;

여기서 DECODE(BITAND(U.FLAGS, 1), 0, 'NO', 'YES') 부분이 YES 이면 인덱스가 사용되는것이고
NO 상태로 계속 유지된다면 사용하지 않는 인덱스라고 보면 된다.
그리고 인덱스 모니터링 기간은 테이블에 따라서 조금 다르겠지만 일주일 정도 두고 보는게 좋다.
