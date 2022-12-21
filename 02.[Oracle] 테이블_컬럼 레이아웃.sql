--  ���̺� ����Ʈ ���°�
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

-- 1 �÷� ����Ʈ ���°�
SELECT * FROM (
SELECT 
    A.TABLE_NAME, 
    (SELECT COMMENTS FROM USER_TAB_COMMENTS 
    WHERE TABLE_NAME = A.TABLE_NAME 
    --and comments like '%������ȣ%'
    ) AS TAB_COMMENTS, 
    A.COLUMN_NAME,
    (SELECT COMMENTS FROM USER_COL_COMMENTS 
    WHERE TABLE_NAME = A.TABLE_NAME 
    AND COLUMN_NAME = A.COLUMN_NAME 
    --and comments like '%������ȣ%'
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

-- 2 �÷� ����Ʈ ���°�
SELECT DISTINCT TABLE_NAME, TAB_COMMENTS FROM (
SELECT 
    A.TABLE_NAME, 
    (SELECT COMMENTS FROM USER_TAB_COMMENTS 
    WHERE TABLE_NAME = A.TABLE_NAME 
    --and comments like '%������ȣ%'
    ) AS TAB_COMMENTS, 
    A.COLUMN_NAME,
    (SELECT COMMENTS FROM USER_COL_COMMENTS 
    WHERE TABLE_NAME = A.TABLE_NAME 
    AND COLUMN_NAME = A.COLUMN_NAME 
    --and comments like '%������ȣ%'
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
--�ӽ� table�� ����� �������

create table xxxx as select 

-- �÷� ���̾ƿ�
select 
    a.table_name, 
    (select comments from user_tab_comments 
    where table_name = a.table_name 
    --and comments like '%������ȣ%'
    ) AS tab_comments, 
    a.column_name,
    (select comments from user_col_comments 
    where table_name = a.table_name 
    and column_name = a.column_name 
    --and comments like '%������ȣ%'
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

-- ���̺� ����Ʈ
select *--TABLE_NAME, '--'||COMMENTS 
from user_tab_comments 
where table_name like '%EVENT%'  
    --and comments like '%������ȣ%'
ORDER BY TABLE_NAME    
 
-- �÷� ����Ʈ
select *--','||COLUMN_NAME, '--'||COMMENTS 
from user_col_comments 
    where column_name LIKE 'ETC%'
	--table_name like 'WORK_ORG_ID%' 
    --and comments like '%������ȣ%'

-- 
select *--TABLE_NAME, '--'||COMMENTS 
from user_tab_comments 
where TABLE_NAME NOT IN(SELECT TABLE_NAME FROM USER_TAB_COMMENTS WHERE table_name like 'HOME%' OR table_name like 'WORK%')  
	
SELECT * FROM HOMEPAGE_MEMBER WHERE RESNO LIKE '380219%'--NAME = '������'


COMMENT ON TABLE APPLICANT_MANAGE IS '�������������';
COMMENT ON COLUMN APPLICANT_MANAGE.INFO_TYPE IS '1:�Ϲݱ��α���,2:�������ڸ����';

-- ��ȭ PJT ���� �ٲ� �÷�
SELECT *--','||COLUMN_NAME, '--'||COMMENTS 
FROM ALL_COL_COMMENTS 
WHERE OWNER = 'SJP'
  AND COLUMN_NAME NOT IN (SELECT COLUMN_NAME FROM ALL_COL_COMMENTS WHERE OWNER = 'SJP_070211')
ORDER BY TABLE_NAME


--���̺��� ������ ���� SQL ���
ALTER TABLE SIDO_CHARGE_MANAGER_BACKUP RENAME TO SIDO_CHARGE_MANAGER_20070817

ALTER TABLE [TABLE NAME] RENAME COLUMN [COLUMN NAME] TO [NEW COLUMN NAME];

--���� ���̺� �÷� �߰�
ALTER TABLE ���̺�� ADD �÷��� �÷�Ÿ��;

--���̺� �÷� ����
ALTER TABLE ���̺�� DROP COLUMN �÷���;

--���̺��� �÷� �����ϱ�
ALTER TABLE ���̺�� MODIFY �÷��� �÷�Ÿ��;

--SAMPLE���̺� EMAIL �÷��߰��Ұ��
ALTER TABLE SAMPLE ADD EMAIL VARCHAR2(50);

--SAMPLE���̺� EMAIL �÷�ũ�⸦ �����Ұ��
ALTER TABLE SJP_070410.DETACHMENT_PLACE MODIFY DETACHMENT_PLACE_NAME VARCHAR2(200);

--SAMPLE���̺� EMAIL �÷������Ұ��
ALTER TABLE SAMPLE DROP COLUMN EMAIL;
 
-- ���� �ϳ������ϱ�
(SELECT *
FROM  (SELECT WORK_INFO_ID, SEQ, BEF_WORK_NUM, BEF_TOTAL_BUDGET, BEF_BUDGET_GUKBI, BEF_BUDGET_SIDO, BEF_BUDGET_SIGUNGU, BEF_BUDGET_MINGAN, BEF_L_TYPE_ID, BEF_M_TYPE_ID, BEF_S_TYPE_ID, WORK_NUM, TOTAL_BUDGET, BUDGET_GUKBI, BUDGET_SIDO, BUDGET_SIGUNGU, BUDGET_MINGAN, FILE_SIZE_9, FILE_NAME_9, L_TYPE_ID, M_TYPE_ID, S_TYPE_ID, REG_ID, REG_DATE, CHANGE_ID, CHANGE_DATE, CHG_MEMO, SIGUNGU_DATE, SIDO_DATE, KORDI_DATE,
			  ROW_NUMBER() OVER (PARTITION BY WORK_INFO_ID 
			  ORDER BY SEQ desc) SEQ_NUM
	   FROM   WORK_INFOMATION_CHG_2) 
WHERE  SEQ_NUM = 1) ic     
