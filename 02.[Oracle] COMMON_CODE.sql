0.groupId
    1 : 복지부
    2 : 개발원
    3 : 시도
    4 : 시군구
    5 : 수행기관
    6 : 관리자
    7 : 읍면동

1.사업유형(L_TYPE_ID) 
    1 : 공익형
    2 : 교육형
    3 : 복지형
    4 : 인력파견형
    5 : 시장형
    6 : 통합형

2.사업유형(14)    
    A : 공익형
    B : 교육형
    C : 복지형
    D : 인력파견형
    E : 시장형
    F : 통합형

3.참여상태(ST_PARTICIPANT_STATUS.PARTICIPANT_STATUS_VIEW_MODE, 16)
   -2 = 참여전(또는 사업시작전)
   -1 : APPCANT는 접수, PARTCIPANT에는 값 없음
    1 : 참여
    2 : 대기
    3 : 중도포기
    4 : 사업완료(참여완료)
    5 : 탈락
    6 : 참여완료(COMMON_CODE)
    7 : 자원봉사

4.수행기관유형(WORK_ORG_GUBUN, 15)
    OR01 : 지자체      
    OR02 : 시니어클럽     
    OR03 : 대한노인회     
    OR04 : 노인복지관     
    OR05 : 종합사회복지관
    OR06 : 노인복지센터     
    OR07 : 지역문화원     
    OR08 : 기타
    
5.부대비용(WORK_UPKEEP.WORK_UPKEEP_ITEM), 42
    01 : 산재보험료
    02 : 피복비
    03 : 홍보비
    04 : 회의비
    05 : 교육비
    06 : 수용비
    07 : 사업진행비
    08 : 기타비
    
SELECT * FROM COMMON_CODE WHERE CC_NAME LIKE '%중도포기%' ORDER BY CGROUP_ID, CC_ID         

SELECT * FROM COMMON_CODE WHERE CGROUP_ID = '16' ORDER BY CGROUP_ID, CC_ID
    
6.보수지급여부
    (D.PAY_MARKET_VALUE1+DECODE(L_TYPE_ID,4,0,D.PAY_VALUE) + D.PAY_VALUE2 + D.PAY_VALUE3 + D.PAY_VALUE4) AS COST_PAY
    
7.인력파견형, 시장형
if("<%=lTypeId%>" == "4" || "<%=lTypeId%>" == "5" || 
"<%=sTypeId%>" == "61040" || "<%=sTypeId%>" == "61050" || "<%=sTypeId%>" == "62010") {

8.history 조회
SELECT WORK_INFO_ID, L_TYPE_ID, REG_DATE, CHANGE_DATE, SEQ,
       ROW_NUMBER() OVER (PARTITION BY WORK_INFO_ID 
       ORDER BY SEQ) SEQ_NUM
FROM   WORK_INFOMATION_HISTORY    
WHERE  TRIGGER_GB = 'UPD OLD'

9.
-- 보수를 지급한 참여자 목록
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
  -- 상태
  AND ST_PARTICIPANT_STATUS.PARTICIPANT_STATUS_STAT_MODE ( 
        '20070701', A.WORK_INFO_ID, A.WORK_END, C.WORK_START, C.WORK_END, C.FALLING_REASON, B.RECEIPT_STATUS 
     ) IN ('1','2','3')
  -- 보수
  AND DECODE(A.L_TYPE_ID, 4, D.PAY_VALUE, 5, (D.PAY_MARKET_VALUE1 + D.PAY_MARKET_VALUE2) , 
            (D.PAY_VALUE + D.PAY_VALUE2 + D.PAY_VALUE3 + D.PAY_VALUE4)) > 0
     
--
   and  (--a.work_name like '%어린이%'
    --or   a.work_name like '%아동%'
    --or   a.work_name like '%새싹%'
    --or   a.work_name like '%폴리스%'
    --or   a.work_name like '%경찰%'
       a.work_name like '%이민자%'
    or   a.work_name like '%외국%'