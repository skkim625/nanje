
다음에 열거된 파리미터는 각각 데이터베이스 튜닝에 영향을 미치는
    것들이다.

    DB_BLOCK_BUFFERS
    SHARED_POOL_SIZE
    SORT_AREA_SIZE
    DBWR_IO_SLAVES
    ROLLBACK_SEGMENTS
    SORT_AREA_RETAINED_SIZE
    DB_BLOCK_LRU_EXTENDED_STATISTICS
    SHARED_POOL_RESERVE_SIZE

--------------------------------------------------------------------------------
1. DB_BLOCK_BUFFERS

    이 파라미터는 모든 버젼의 오라클에서 사용되며, Oracle block 크기를
    단위로 지정하게 된다. 이 값은 사용자가 요청하는 데이터를, 메모리
    영역에 저장해 둘 수 있는 공간의 크기를 지정하므로 튜닝시 매우 중요
    한 역할을 한다.

    db_block_buffers 값은 SGA 캐쉬 영역에 존재하는 버퍼의 갯수를 지정
    하는데 사용되며, 적절한 캐쉬 크기는 실제 디스크 I/O를 줄이는데 도움
    이 된다. 캐쉬 영역이 적절하게 지정되어 있는지 여부는 buffer cache
    hit ratio로 측정 가능하며, 일반적으로 90% 이상의 값을 유지하도록
    하는 것이 바람직하다. buffer cache hit ratio는 다음 SQL을 사용하여
    조회 가능하다.

    -- 90% 이상을 유지 바람직   
    select round(((1-(sum(decode(name,
    'physical reads', value,0))/
    (sum(decode(name, 'db block gets', value,0))+
    (sum(decode(name, 'consistent gets', value, 0))))))*100),2)
    || '%' "Buffer Cache Hit Ratio"
    from v$sysstat;

    실행 결과는 다음과 같은 형식으로 나타나게 된다.

    Buffer Cache Hit Ratio:
    97.63%

    만약 hit ratio가 90% 미만이라면, hit ratio 가 90% 이상을 유지할 정도로
    buffer cache의 크기를 늘려주는 것이 바람직하다. 이 값이 작을
    경우 사용된 데이터가, 다른 데이터를 처리할 메모리 영역을 확보시키기 위해
    메모리에서 삭제된 후, 다시해당 데이터가 요청될 경우 충분한 cache를
    확보하였을 때 피할 수 있는 물리 I/O 가 발생하게 된다.
    그러나 만약 이 값을 가용한 메모리 크기에 비해 너무 크게 지정할 경우에는
    OS 에서 swapping이 발생하게 되어 시스템이 hang 상태까지 갈 수 있다.


--------------------------------------------------------------------------------
2. SHARED_POOL_SIZE
    shared_pool_size는 모든 버젼의 오라클에서 사용되는 파라미터로, 단위는
    byte 단위이다. 이 영역은 data dictionary나, stored procedure, 그리고
    각종 SQL statement가 저장된다. SGA 영역가운데 많은 비중을 차지하는
    shared_pool_size는 다시 dictionary cache 및 library cache 영역으로
    나뉘어 지며, db_block_buffers와 마찬가지로 너무 크거나, 작게 잡지
    않도록 하여야 한다.

    shared_pool_size 값이 적절한지 여부는 data dictionary cache 및 library
    cache 의 hitratio로 측정할 수 있다.

    SQL 처리에는 data dictionary가 여러차례 참조되므로, data dictionary
    조회시 디스크 I/O가 적게 발생하도록 하면, 성능 향상에 도움이 된다.

    Data dictionary cache hit ratio는 다음 SQL에 의해 측정 가능하다.

    -- 90% 이상을 유지 바람직(대략 85%이상)   
    select (1-(sum(getmisses)/sum(gets))) * 100 "Hit Ratio"
    from v$rowcache;

    결과는 다음과 같이 생성된다.

    Hit Ratio
      95.40%

    Data dictionary cache hit ratio는 90% 이상을 유지하는 것이 바람직
    하지만, 인스턴스 구동 직후에는 캐쉬영역에 데이터가 저장되지
    않으므로 대략 85% 가량을 유지 하도록 하는 것이 바람직하다.

    Library cahce 영역은 공유 SQL 영역 및 PL/SQL 영역으로 나뉘어 진다.
    SQL이 실행될 경우, 문장은 먼저 parsing 되어야 하는데, library cache는
    SQL 및 PL/SQL을 미리 저장해 두어, 실제 parsing이 발생하는 빈도를
    줄이는 역할을 한다. OLTP 업무의 경우, 동일한 SQL이 여러차례 수행되므로
    적절한 cache 영역을 확보함으로써 성능 향상을 기대할 수 있다. - 물론
    bind variable을 사용하여야만 공유가능한 SQL이 생성된다.

    shared_pool_size 값이 적을 경우는 물론이거니와, 너무 이 값을 크게
    지정해도 문제가 된다. shared_pool_size가 너무 클 경우, 새로운 SQL
    수행시 가용한 메모리 영역을 찾아 내기 위한 latch contention 의
    가능성이 높아지게 된다.

    v$sgastat을 조회하여 free memory를 조사할 수 있으며, 메모리가
    낭비되고 있는지 여부도 확인 가능하다.

      -- 낭비 메모리  
      select name, bytes/1024/1024 "Size in MB"
      from v$sgastat
      where name='free memory';

    실행 결과는 다음과 같다.

      NAME Size in MB
      Free memory 39.6002884

    이 결과는 shared pool에 39M 공간이 사용되지 않고 있으며, 만약
    shared pool의 크기를 70M 로 지정하였다면, 절반 이상의 메모리
    공간이 사용되지 않고 낭비되고 있음을 의미한다.

--------------------------------------------------------------------------------
3. SORT_AREA_SIZE

    SORT_AREA_SIZE에 대해서는 흔히 잘못된 이해를 하게된다. 대부분의
    사용자들은 이 값이 모든 사용자들이 sort 작업에 사용하게 되는
    공용 메모리 영역의 크기로 이해를 하는데, 실제로는 사용자 프로세스
    별로 사용하게 되는 sort 영역의 크기를 나타낸다. 앞에서 살펴본
    두개의 파라미터와 달리, SORT_AREA_SIZE는 SGA영역에 속하지 않는다.
    만약 sort_area_size 값이 너무 작다면, sort 작업 대부분이 사용자의
    temporary tablespace에서 디스크를 사용하여 이루어 지게 된다.

    SQL 처리시 order by 나, group by 등을 사용할 경우에는 sort 작업이
    발생하나. index 생성등에도 sort가 발생한다.

    메모리 sort는 디스크 sort에 비해 훨씬 좋은 성능을 보이므로,
    지속적으로 SORT_AREA_SIZE 값을 모니터하여 튜닝을 하는것이 바람직하다.
    하지만, 이 값을 너무 크게 지정할 경우, swapping이 발생하면서
    시스템 성능이 급격하게 저하될 수 있다.

    * SORT_AREA_SIZE는 세션별로도 지정가능하며, 지정하기 위해서는
        ALTER SESSION 권한이 있어야 한다. 특정 세션에서 시스템상의
        모든 메모리를 사용하도록 할 경우 시스템 성능이 급격히 저하
        될 수도 있다.

--------------------------------------------------------------------------------
4. DBWR_IO_SLAVES

    DBWR_IO_SLAVES는 SORT_AREA_SIZE와 마찬가지로 사용자들이 흔히
    잘못 이해하는 파라미터로, Oracle 8 이후 버젼에서 사용된다.
    이 파라미터는 Oracle 8 이전에 사용되던 DB_WRITERS 파라미터를
    대체한다. Oracle 8에서는 DB_WRITER_PROCESSES 라는 파라미터가
    DB_WRITERS를 대체하지만, DBWR_IO_SLAVES 파라미터와 함께 사용할
    경우 아직까지도 문제점들이 발생한다.

    DBWR_IO_SLAVES는 slave writer process가 - OS에서 지원할 경우 -
    asynchronous I/O를 수행하도록 허용한다.

    DB_WRITERS 및 DBWR_IO_SLAVES 관련 자료는 METALINK에 많이
    올라와 있으며, DB_WRITERS 와 DBWR_IO_SLAVES 는 동시에 사용하
    지 못한다는 것을 이해하는 것이 중요하다.

    * <Bulletin : 11699> 참조

--------------------------------------------------------------------------------
5. ROLLBACK_SEGMENTS

    이 파라미터는 모든 버젼의 오라클에서 사용되며, 인스턴스 기동중에
    온라인 상태로 사용할 rollback segment를 지정한다.
    만약 파라미터에서 지정한 rollback segment가 존재하지 않는 것이라면
    ora-1534 에러가 발생하며, 데이터베이스는 mount까지만 되고 open 되
    지는 않는다.

    Rollback segment는 트랜잭션에서 발생하는 변경사항을 기록하여,
    트랜잭션이 rollback 되어야 할 경우 이전 상태로 돌리기 위한 각종
    정보를 저장하는 영역이다. - Windows 의 undo 기능과 유사함.
    Rollback segment는 여러 extent들로 구성되는데, extent는 round-robin
    방식으로 순환되며 사용된다. 즉, 현재 사용되는 extent가 full이
    나는 경우 다음 extent를 사용하는 식으로 사용된다.

    Rollback segment는 read consistency를 제공해 주고, 트랜잭션을 undo
    시킬수 있고, recovery에 사용되는 등, 데이터베이스에서 매우 중요한
    역할을 수행한다.
    Read consistency는 업무적으로도 매우 중요한데, 한 사용자 (1번 사용자)
    가 데이터를 읽는동안, 다른 사용자가 (2번 사용자) 그 데이터에 변경을
    가한다면, 2번 사용자가 데이터 변경을 일관성 있게 종료하기 전가지
    1번 사용자는 이전 상태의 데이터, 즉 이전에 commit 된 상태의 데이터를
    사용하여야만 데이터 일관성및 정합성이 보장된다.

    RBS의 적정 크기는 다른 문제와 마찬가지로 데이터베이스 내에서
    사용되는 일반적인 트랜잭션 레벨에 따라 다르다. RBS extent의 크기와
    관련해서는 오라클에서는 extent size와 관련된 ( initial , next 값 )
    권고 사항이 존재한다.

    Rollback segment의 갯수와 관련해서는, rollback segment간의 contention
    이 발생하지 않도록 조정해 주는 것이 중요하다. 모든 트랜잭션은 RBS의
    헤더에 존재하는 트랜잭션 테이블에 정보가 저장된다. 모든 트랜잭션이
    이 테이블의 내용을 변경하여야 하므로, contention이 발생할 수 있다.
    한 시점에 한개의 트랜잭션이 한개의 rollback segment를 사용하도록 하는
    것이 일반적인 원칙이다. 오라클에서는 4개의 트랜잭션당 한개의 rollback
    segment를 사용하는 것을 권고하지만, 절대적인 기준이 아니라 상대적인
    기준으로 보는 것이 바람직하다.

    rollback segment간 contention을 조사하기 위해서는 v$waitstat을
    조회하면 된다. 다음 query로 rollback segment간 contention을
    조회해 볼 수 있다.

    Select a. name, b.extents, b.rssize, b.xacts, b.waits,
    b. gets, optsize, status
    From v$rollname a, v$rollstat b
    Where a.usn = b.usn;

    실행결과는 대략 다음과 같은 형식으로 나타난다.

    NAME EXTENTS RSSIZE XACTS WAITS GETS OPTSIZE STATUS
    SYSTEM 4 540672 1 0 51 ONLINE
    RB1 2 10240000 0 0 427
    10240000 ONLINE
    RB2 2 10240000 1 0 425
    10240000 ONLINE
    RB3 2 10240000 1 0 422
    10240000 ONLINE
    RB4 2 10240000 0 0 421
    10240000 ONLINE

    위의 질의를 처리한 결과로 "xacts" ( 트랜잭션의 줄임말 ) 가
    계속해서 1 이상이 경우, rollback segment의 갯수를 늘려주는
    것이 contention이 발생할 가능성을 줄여준다. 만약 wait 갯수가
    0보다 크고, 특별한 사항에서만 나타나는 것이 아니라 항상
    비슷한 상황이라면, 이 경우에도 rollback segment의 갯수를
    늘려주는 편이 낫다.

    * Rollback segment의 적정 갯수 도출관련 자료는 <bulletin: 10802>, <NOTE:10579.1> 참조
    * Rollback segment의 생성, 최적화 관련 자료는 <bulletin: 11715,10072>, <NOTE:62005.1> 참조


6. SORT_AREA_RETAINED_SIZE

    init.ora 파일에서 지정하는 sort 작업 관련된 파라미터로
    SORT_AREA_RETAINED_SIZE 도 있다. 이 값은 sort 가 끝난 후에도
    유지하고자 하는 SORT_AREA_SIZE를 나타낸다. 이 파라미터는
    SORT_AREA_SIZE 값과 같거나 적게 지정되어야 한다.

    SORT_AREA_RETAINED_SIZE는 SORT_AREA_SIZE와 마찬가지로 적절한
    값이 지정되어야 하는데, 소트작업을 수행하기 위해 할당된
    메모리 영역이 소트 작업이 끝난 후가 아니라 세션이 종료될 때
    까지 유지될 수 있기 때문이다. SORT_AREA_SIZE 값은 다른 파라미터와
    마찬가지로 시스템에 가용한 실제 메모리 크기 이내에서 조정되어야
    한다. 일반적으로 권고되는 SORT_AREA_SIZE 값은 65k 에서 1M 사이
    에서 결정된다.


7. DB_BLOCK_LRU_EXTENDED_STATISTICS

    Oracle 8i 부터는 사용되지 않는 파라미터로, SGA의 buffer cache
    값을 증가시키거나 감소시킬 경우 미치는 영향을 예측하기 위한
    각종 통계 정보를 수집하는 작업을 활성화 시키거나 비 활성화
    시킬 수 있다.
    사용자는 DB_BLOCK_BUFFERS 값을 바꾸어 시스템을 재 기동 시키지
    않고도, alter system 명령으로 buffer cache 크기를 조정할 수
    있게 해 주시만, 내부적으로는 DB_BLOCK_BUFFERS 값은 데이터
    베이스 재 기동시에만 바뀔 수 있다. 통계정보는
    X$KCBRBH 테이블에 저장된다.

    이 값을 0 이상으로 지정하면 DB_BLOCK_BUFFERS 값을 추가하거나
    혹은 추가한 것처럼 simulate 시킬 수 있다. 기능상으로는 튜닝에
    많은 도움을 줄 것 처럼 보이나, 많은 문제점을 안고 있는 것으로
    알려져 있으므로 오라클에서는 production 환경에서는 사용하지
    않도록 권고하고 있다.


8. SHARED_POOL_RESERVE_SIZE

    sahred pool의 일정 부분을 larget object을 위해 할당하도록
    지정하는 파라미터로, 기본적으로는 shared_pool_size의 5%
    정도가 사용된다. 파라미터 값은 byte 단위로 지정한다.

    이 파라미터를 지정할 때 유의해야 할 점은 shared pool의
    대부분의 영역이 large object에 의해 사용되지 않도록
    하고, large object는 별도의 영역에서 처리되도록 지정하는
    것이 관건이다.

