DECLARE @BlockedTableIDs TABLE
(
ObjectID INT NOT NULL,
BlockedSession INT NOT NULL
)

INSERT INTO @BlockedTableIDs(ObjectID, BlockedSession)
    SELECT  O.resource_associated_entity_id AS entid  
           ,O.request_session_id            AS resid
    FROM sys.dm_tran_locks AS O
    WHERE O.request_session_id IN ( SELECT O2.request_session_id 
                                    FROM sys.dm_tran_locks O2 
                                    WHERE O.request_session_id = O2.request_session_id 
                                      AND O2.request_status = 'WAIT')
     AND O.resource_type = 'OBJECT'

SELECT  BlockedTableName = OBJECT_NAME(ObjectID)
       ,ObjectID
       ,BlockedSession
FROM @BlockedTableIDs

SELECT  SQ.session_id
       ,SQ.connect_time
       ,SQ.last_read
       ,SQ.last_write
       ,SQ.most_recent_sql_handle
       ,text
FROM    (   SELECT *
            FROM sys.dm_exec_connections
            WHERE session_id IN(SELECT BlockedSession FROM @BlockedTableIDs)) AS SQ
CROSS APPLY sys.dm_exec_sql_text(SQ.most_recent_sql_handle) AS theBlockinMFcode