0.groupId
    1 : ������
    2 : ���߿�
    3 : �õ�
    4 : �ñ���
    5 : ������
    6 : ������
    7 : ���鵿

1.�������(L_TYPE_ID) 
    1 : ������
    2 : ������
    3 : ������
    4 : �η��İ���
    5 : ������
    6 : ������

2.�������(14)    
    A : ������
    B : ������
    C : ������
    D : �η��İ���
    E : ������
    F : ������

3.��������(ST_PARTICIPANT_STATUS.PARTICIPANT_STATUS_VIEW_MODE, 16)
   -2 = ������(�Ǵ� ���������)
   -1 : APPCANT�� ����, PARTCIPANT���� �� ����
    1 : ����
    2 : ���
    3 : �ߵ�����
    4 : ����Ϸ�(�����Ϸ�)
    5 : Ż��
    6 : �����Ϸ�(COMMON_CODE)
    7 : �ڿ�����

4.����������(WORK_ORG_GUBUN, 15)
    OR01 : ����ü      
    OR02 : �ôϾ�Ŭ��     
    OR03 : ���ѳ���ȸ     
    OR04 : ���κ�����     
    OR05 : ���ջ�ȸ������
    OR06 : ���κ�������     
    OR07 : ������ȭ��     
    OR08 : ��Ÿ
    
5.�δ���(WORK_UPKEEP.WORK_UPKEEP_ITEM), 42
    01 : ���纸���
    02 : �Ǻ���
    03 : ȫ����
    04 : ȸ�Ǻ�
    05 : ������
    06 : �����
    07 : ��������
    08 : ��Ÿ��
    
SELECT * FROM COMMON_CODE WHERE CC_NAME LIKE '%�ߵ�����%' ORDER BY CGROUP_ID, CC_ID         

SELECT * FROM COMMON_CODE WHERE CGROUP_ID = '16' ORDER BY CGROUP_ID, CC_ID
    
6.�������޿���
    (D.PAY_MARKET_VALUE1+DECODE(L_TYPE_ID,4,0,D.PAY_VALUE) + D.PAY_VALUE2 + D.PAY_VALUE3 + D.PAY_VALUE4) AS COST_PAY
    
7.�η��İ���, ������
if("<%=lTypeId%>" == "4" || "<%=lTypeId%>" == "5" || 
"<%=sTypeId%>" == "61040" || "<%=sTypeId%>" == "61050" || "<%=sTypeId%>" == "62010") {

8.history ��ȸ
SELECT WORK_INFO_ID, L_TYPE_ID, REG_DATE, CHANGE_DATE, SEQ,
       ROW_NUMBER() OVER (PARTITION BY WORK_INFO_ID 
       ORDER BY SEQ) SEQ_NUM
FROM   WORK_INFOMATION_HISTORY    
WHERE  TRIGGER_GB = 'UPD OLD'

9.
-- ������ ������ ������ ���
SELECT A.WORK_INFO_ID    AS WORK_INFO_ID, 
     B.APP_ID            AS APP_ID, 
     C.WORK_PART_ID      AS WORK_PART_ID, 
     C.WORK_START        AS WORK_START, 
     C.WORK_END          AS WORK_END, 
     ST_PARTICIPANT_STATUS.PARTICIPANT_STATUS_STAT_MODE ( 
        '20070701', A.WORK_INFO_ID, A.WORK_END, C.WORK_START, C.WORK_END, C.FALLING_REASON, B.RECEIPT_STATUS 
     ) AS APP_STATE 
FROM  WORK_INFOMATION  A, 
      WORK_APPLICANT   B, 
      WORK_PARTICIPANT C,
      WORK_PAY_MASTER D 
WHERE A.WORK_INFO_ID    = B.WORK_INFO_ID (+) 
  AND B.APP_ID          = C.APP_ID       (+)
  AND C.WORK_PART_ID    = D.WORK_PART_ID (+) 
  AND A.BUDGET_YN       = 'Y' 
  AND A.WORK_YEAR_DATE  = '2007'
  AND D.WAGE_MONTH      = '07' 
  AND A.DEL_YN          = 'N' 
  AND A.PASS_YN         = 'Y' 
  AND B.DEL_YN          = 'N'
  -- ����
  AND ST_PARTICIPANT_STATUS.PARTICIPANT_STATUS_STAT_MODE ( 
        '20070701', A.WORK_INFO_ID, A.WORK_END, C.WORK_START, C.WORK_END, C.FALLING_REASON, B.RECEIPT_STATUS 
     ) IN ('1','2','3')
  -- ����
  AND DECODE(A.L_TYPE_ID, 4, D.PAY_VALUE, 5, (D.PAY_MARKET_VALUE1 + D.PAY_MARKET_VALUE2) , 
            (D.PAY_VALUE + D.PAY_VALUE2 + D.PAY_VALUE3 + D.PAY_VALUE4)) > 0
     
--
   and  (--a.work_name like '%���%'
    --or   a.work_name like '%�Ƶ�%'
    --or   a.work_name like '%����%'
    --or   a.work_name like '%������%'
    --or   a.work_name like '%����%'
       a.work_name like '%�̹���%'
    or   a.work_name like '%�ܱ�%'