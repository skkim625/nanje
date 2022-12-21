--  테이블 컨멘트 없는것
SELECT * FROM (
SELECT 
    A.TABLE_NAME, 
    A.TABLE_TYPE,
    A.COMMENTS
FROM  USER_TAB_COMMENTS  A
WHERE INSTR(A.TABLE_NAME,'BIN') = 0
  --a.column_name like 'FOLDER_INDEX%'
  AND INSTR(A.TABLE_NAME,'_ROOT') = 0
  AND INSTR(A.TABLE_NAME,'_VIEW') = 0
  AND INSTR(A.TABLE_NAME,'PLAN') = 0
  AND INSTR(A.TABLE_NAME,'QUEST') = 0
  AND INSTR(A.TABLE_NAME,'TOAD') = 0
  AND INSTR(A.TABLE_NAME,'dTdT') = 0
  AND TABLE_TYPE = 'TABLE'
  --a.table_name not in (select table_name from user_tab_columns where table_name like 'BIN$%')
) WHERE (COMMENTS IS NULL) 
ORDER BY TABLE_NAME

-- 1 컬럼 컨멘트 없는것
SELECT * FROM (
SELECT 
    A.TABLE_NAME, 
    (SELECT COMMENTS FROM USER_TAB_COMMENTS 
    WHERE TABLE_NAME = A.TABLE_NAME 
    --and comments like '%관리번호%'
    ) AS TAB_COMMENTS, 
    A.COLUMN_NAME,
    (SELECT COMMENTS FROM USER_COL_COMMENTS 
    WHERE TABLE_NAME = A.TABLE_NAME 
    AND COLUMN_NAME = A.COLUMN_NAME 
    --and comments like '%관리번호%'
    ) AS COL_COMMENTS, 
    A.DATA_TYPE, 
    --A.DATA_LENGTH, 
    --A.DATA_DEFAULT,
    A.COLUMN_ID
FROM USER_TAB_COLUMNS A
WHERE INSTR(A.TABLE_NAME,'BIN') = 0
  --a.column_name like 'FOLDER_INDEX%'
  AND INSTR(A.TABLE_NAME,'_ROOT') = 0
  AND INSTR(A.TABLE_NAME,'_VIEW') = 0
  AND INSTR(A.TABLE_NAME,'PLAN') = 0
  AND INSTR(A.TABLE_NAME,'QUEST') = 0
  AND INSTR(A.TABLE_NAME,'TOAD') = 0
  AND INSTR(A.TABLE_NAME,'dTdT') = 0
  --a.table_name not in (select table_name from user_tab_columns where table_name like 'BIN$%')
) WHERE (COL_COMMENTS IS NULL) 
ORDER BY TABLE_NAME, COLUMN_ID

-- 2 컬럼 컨멘트 없는것
SELECT DISTINCT TABLE_NAME, TAB_COMMENTS FROM (
SELECT 
    A.TABLE_NAME, 
    (SELECT COMMENTS FROM USER_TAB_COMMENTS 
    WHERE TABLE_NAME = A.TABLE_NAME 
    --and comments like '%관리번호%'
    ) AS TAB_COMMENTS, 
    A.COLUMN_NAME,
    (SELECT COMMENTS FROM USER_COL_COMMENTS 
    WHERE TABLE_NAME = A.TABLE_NAME 
    AND COLUMN_NAME = A.COLUMN_NAME 
    --and comments like '%관리번호%'
    ) AS COL_COMMENTS, 
    A.DATA_TYPE, 
    --A.DATA_LENGTH, 
    --A.DATA_DEFAULT,
    A.COLUMN_ID
FROM USER_TAB_COLUMNS A
WHERE INSTR(A.TABLE_NAME,'BIN') = 0
  --a.column_name like 'FOLDER_INDEX%'
  AND INSTR(A.TABLE_NAME,'_ROOT') = 0
  AND INSTR(A.TABLE_NAME,'_VIEW') = 0
  AND INSTR(A.TABLE_NAME,'PLAN') = 0
  AND INSTR(A.TABLE_NAME,'QUEST') = 0
  AND INSTR(A.TABLE_NAME,'TOAD') = 0
  AND INSTR(A.TABLE_NAME,'dTdT') = 0
  --a.table_name not in (select table_name from user_tab_columns where table_name like 'BIN$%')
) WHERE (TAB_COMMENTS IS NULL)
ORDER BY TABLE_NAME
--임시 table을 만드는 방식으로

create table xxxx as select 

-- 컬럼 레이아웃
select 
    a.table_name, 
    (select comments from user_tab_comments 
    where table_name = a.table_name 
    --and comments like '%관리번호%'
    ) AS tab_comments, 
    a.column_name,
    (select comments from user_col_comments 
    where table_name = a.table_name 
    and column_name = a.column_name 
    --and comments like '%관리번호%'
    ) AS col_comments, 
    a.data_type, 
    a.data_length, 
    --a.data_default,
    a.column_id
from user_tab_columns a
where
  --a.column_name like 'FOLDER_INDEX%'
  --a.table_name like '%WORK_%'
  a.table_name not in (select table_name from user_tab_columns where table_name like 'BIN$%')
  AND a.table_name not in (select table_name from user_tab_columns where table_name like 'BK%')
order by a.table_name, a.column_id

-- 테이블 리스트
select *--TABLE_NAME, '--'||COMMENTS 
from user_tab_comments 
where table_name like '%EVENT%'  
    --and comments like '%관리번호%'
ORDER BY TABLE_NAME    
 
-- 컬럼 리스트
select *--','||COLUMN_NAME, '--'||COMMENTS 
from user_col_comments 
    where column_name LIKE 'ETC%'
	--table_name like 'WORK_ORG_ID%' 
    --and comments like '%관리번호%'

-- 
select *--TABLE_NAME, '--'||COMMENTS 
from user_tab_comments 
where TABLE_NAME NOT IN(SELECT TABLE_NAME FROM USER_TAB_COMMENTS WHERE table_name like 'HOME%' OR table_name like 'WORK%')  
	
SELECT * FROM HOMEPAGE_MEMBER WHERE RESNO LIKE '380219%'--NAME = '이점난'


COMMENT ON TABLE APPLICANT_MANAGE IS '사업참여자정보';
COMMENT ON COLUMN APPLICANT_MANAGE.INFO_TYPE IS '1:일반구인구직,2:노인일자리사업';

-- 고도화 PJT 에서 바뀐 컬럼
SELECT *--','||COLUMN_NAME, '--'||COMMENTS 
FROM ALL_COL_COMMENTS 
WHERE OWNER = 'SJP'
  AND COLUMN_NAME NOT IN (SELECT COLUMN_NAME FROM ALL_COL_COMMENTS WHERE OWNER = 'SJP_070211')
ORDER BY TABLE_NAME


--테이블의 구조를 변경 SQL 명령
ALTER TABLE SIDO_CHARGE_MANAGER_BACKUP RENAME TO SIDO_CHARGE_MANAGER_20070817

ALTER TABLE [TABLE NAME] RENAME COLUMN [COLUMN NAME] TO [NEW COLUMN NAME];

--기존 테이블에 컬럼 추가
ALTER TABLE 테이블명 ADD 컬럼명 컬럼타입;

--테이블에 컬럼 삭제
ALTER TABLE 테이블명 DROP COLUMN 컬럼명;

--테이블의 컬럼 변경하기
ALTER TABLE 테이블명 MODIFY 컬럼명 컬럼타입;

--SAMPLE테이블에 EMAIL 컬럼추가할경우
ALTER TABLE SAMPLE ADD EMAIL VARCHAR2(50);

--SAMPLE테이블에 EMAIL 컬럼크기를 변경할경우
ALTER TABLE SJP_070410.DETACHMENT_PLACE MODIFY DETACHMENT_PLACE_NAME VARCHAR2(200);

--SAMPLE테이블에 EMAIL 컬럼삭제할경우
ALTER TABLE SAMPLE DROP COLUMN EMAIL;
 
-- 순위 하나추출하기
(SELECT *
FROM  (SELECT WORK_INFO_ID, SEQ, BEF_WORK_NUM, BEF_TOTAL_BUDGET, BEF_BUDGET_GUKBI, BEF_BUDGET_SIDO, BEF_BUDGET_SIGUNGU, BEF_BUDGET_MINGAN, BEF_L_TYPE_ID, BEF_M_TYPE_ID, BEF_S_TYPE_ID, WORK_NUM, TOTAL_BUDGET, BUDGET_GUKBI, BUDGET_SIDO, BUDGET_SIGUNGU, BUDGET_MINGAN, FILE_SIZE_9, FILE_NAME_9, L_TYPE_ID, M_TYPE_ID, S_TYPE_ID, REG_ID, REG_DATE, CHANGE_ID, CHANGE_DATE, CHG_MEMO, SIGUNGU_DATE, SIDO_DATE, KORDI_DATE,
			  ROW_NUMBER() OVER (PARTITION BY WORK_INFO_ID 
			  ORDER BY SEQ desc) SEQ_NUM
	   FROM   WORK_INFOMATION_CHG_2) 
WHERE  SEQ_NUM = 1) ic     
