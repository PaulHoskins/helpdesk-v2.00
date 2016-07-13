/***********************************************************************

    Program:        lib/project.i
    
    Purpose:        Complex Project Library
    
    Notes:
    
    
    When        Who         What
    02/04/2015  phoski      Initial
    
***********************************************************************/

{lib/project-tt.i}

DEFINE VARIABLE gli-Global-Proj-Work AS INTEGER NO-UNDO.

ASSIGN
    gli-Global-Proj-Work = ( 7.5 * 60 ) * 60.
 
FUNCTION prjlib-WorkingDays RETURNS INTEGER 
    (pi-Time      AS INTEGER) FORWARD.

/* **********************  Internal Procedures  *********************** */

PROCEDURE prjlib-AddNewPhase:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-user              AS CHARACTER    NO-UNDO.
    DEFINE INPUT PARAMETER pc-companyCode       AS CHARACTER    NO-UNDO.
    DEFINE INPUT PARAMETER pi-IssueNumber       AS INTEGER      NO-UNDO.
    DEFINE INPUT PARAMETER pc-descr             AS CHARACTER    NO-UNDO.
    DEFINE OUTPUT PARAMETER pi-PhaseID          AS INT64        NO-UNDO.
     
    DEFINE BUFFER issue    FOR Issue.
    DEFINE BUFFER issPhase FOR issPhase.
    
    DEFINE VARIABLE li-DisplayOrder AS INTEGER INITIAL 1 NO-UNDO.
    
    FIND Issue
        WHERE Issue.CompanyCode = pc-CompanyCode
        AND Issue.IssueNumber = pi-IssueNumber NO-LOCK NO-ERROR.
        
    FOR EACH issPhase NO-LOCK
        WHERE IssPhase.CompanyCode = pc-CompanyCode
        AND IssPhase.IssueNumber = pi-IssueNumber 
        BY issPhase.DisplayOrder:
                
        li-DisplayOrder = issPhase.DisplayOrder + 1.
    END.

    ASSIGN
        pi-PhaseID = NEXT-VALUE(projphase).
        
    CREATE issPhase.
    
    ASSIGN
        issPhase.CompanyCode  = Issue.CompanyCode
        issPhase.IssueNumber  = Issue.IssueNumber
        issPhase.Descr        = pc-descr
        issPhase.DisplayOrder = li-DisplayOrder
        issPhase.PhaseID      = pi-Phaseid
        .    

END PROCEDURE.

PROCEDURE prjlib-AddNewTask:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-user              AS CHARACTER    NO-UNDO.
    DEFINE INPUT PARAMETER pc-companyCode       AS CHARACTER    NO-UNDO.
    DEFINE INPUT PARAMETER pi-IssueNumber       AS INTEGER      NO-UNDO.
    DEFINE INPUT PARAMETER pi-PhaseID           AS INT64        NO-UNDO.
    DEFINE INPUT PARAMETER pi-DisplayOrder      AS INTEGER      NO-UNDO.
   
    DEFINE INPUT PARAMETER pc-descr             AS CHARACTER    NO-UNDO.
    DEFINE INPUT PARAMETER pd-start             AS DATE         NO-UNDO.
    DEFINE INPUT PARAMETER pi-duration          AS INTEGER      NO-UNDO.
    
    DEFINE OUTPUT PARAMETER pi-TaskID           AS INT64        NO-UNDO.
    
    DEFINE BUFFER issue     FOR Issue.
    DEFINE BUFFER issPhase  FOR issPhase.
    DEFINE BUFFER IssAction FOR IssAction.
    DEFINE BUFFER eSched    FOR eSched.
    
    DEFINE VARIABLE lc-rows   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-loop   AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lf-Audit  AS DECIMAL   NO-UNDO.
    DEFINE VARIABLE lr-Action AS ROWID     NO-UNDO.
    
     
    
    FIND Issue
        WHERE Issue.CompanyCode = pc-CompanyCode
        AND Issue.IssueNumber = pi-IssueNumber NO-LOCK NO-ERROR.
        
    FIND issPhase
        WHERE IssPhase.CompanyCode = pc-CompanyCode
        AND IssPhase.IssueNumber = pi-IssueNumber 
        AND issPhase.PhaseID = pi-PhaseID NO-LOCK NO-ERROR.
                      
        
    DO TRANSACTION:
        
        ASSIGN
            pi-TaskID = NEXT-VALUE(projphase).
            
        lc-rows = "".
        /*
        ***
        *** Need to do an insertion at pi-displayOrder
        *** To cope with  gannt chart need to keep taskid in order 
        *** so move the displayOrder and allocate a new taskid 
        ***
        */
        FOR EACH issAction EXCLUSIVE-LOCK 
            WHERE IssAction.CompanyCode = pc-companyCode
            AND IssAction.IssueNumber = pi-IssueNumber
            AND IssAction.PhaseID = issPhase.PhaseID
            AND IssAction.DisplayOrder >= pi-DisplayOrder
            AND IssAction.DisplayOrder <> 0
            AND IssAction.DisplayOrder <> ?
            BY IssAction.DisplayOrder:
           
            IF lc-rows = ""
                THEN lc-rows = STRING(ROWID(issAction)).              
            ELSE lc-rows = lc-rows + "," + string(ROWID(issAction)).              
            
        END.  
        DO li-loop = 1 TO NUM-ENTRIES(lc-rows):
            FIND IssAction 
                WHERE ROWID(issAction) = to-rowid(ENTRY(li-loop,lc-rows)) EXCLUSIVE-LOCK.
            
            ASSIGN 
                IssAction.DisplayOrder = IssAction.DisplayOrder + 1
                IssAction.TaskID       = NEXT-VALUE(projphase).
                 
                
        END.
             
        
        CREATE IssAction.
        ASSIGN 
            IssAction.actionID     = ? /* There's no action */
            IssAction.CompanyCode  = Issue.companyCode
            IssAction.IssueNumber  = issue.IssueNumber
            IssAction.CreateDate   = TODAY
            IssAction.CreateTime   = TIME
            IssAction.CreatedBy    = pc-user
            IssAction.customerview = NO
            .
    
        DO WHILE TRUE:
            RUN lib/makeaudit.p (
                "",
                OUTPUT lf-audit
                ).
            IF CAN-FIND(FIRST IssAction
                WHERE IssAction.IssActionID = lf-audit NO-LOCK)
                THEN NEXT.
            ASSIGN
                IssAction.IssActionID = lf-audit.
            LEAVE.
        END.
        
        ASSIGN 
            IssAction.notes          = pc-descr
            IssAction.ActionStatus   = "OPEN"
            IssAction.ActionDate     = pd-start
            IssAction.AssignTo       = Issue.AssignTo
            IssAction.AssignDate     = TODAY
            IssAction.AssignTime     = TIME
            IssAction.PhaseID        = pi-PhaseID
            IssAction.TaskID         = pi-taskID
            IssAction.DisplayOrder   = pi-DisplayOrder
            IssAction.ActDescription = pc-descr
            IssAction.PlanDuration   = pi-Duration * gli-Global-Proj-Work
            IssAction.workDuration   = IssAction.PlanDuration
            .
       
                
        CREATE eSched.
        ASSIGN
            eSched.eSchedID = NEXT-VALUE(esched).
        BUFFER-COPY IssAction TO eSched.
                    
        
            
        
    END.
            
 

END PROCEDURE.

PROCEDURE prjlib-BuildGanttData:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-user              AS CHARACTER    NO-UNDO.
    DEFINE INPUT PARAMETER pc-companyCode       AS CHARACTER    NO-UNDO.
    DEFINE INPUT PARAMETER pi-IssueNumber       AS INTEGER      NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-proj-tasks.
    
    
    
    DEFINE BUFFER issue     FOR Issue.
    DEFINE BUFFER issPhase  FOR issPhase.
    DEFINE BUFFER IssAction FOR IssAction.
    DEFINE BUFFER eSched    FOR eSched.
    
    DEFINE VARIABLE li-rno   AS INTEGER NO-UNDO.
    DEFINE VARIABLE ld-Start AS DATE    NO-UNDO.
    DEFINE VARIABLE ld-end   AS DATE    NO-UNDO.
    DEFINE VARIABLE lr-row   AS ROWID   NO-UNDO.
    
    
    FIND Issue
        WHERE Issue.CompanyCode = pc-CompanyCode
        AND Issue.IssueNumber = pi-IssueNumber NO-LOCK NO-ERROR.
            
            
    FOR EACH issPhase NO-LOCK
        WHERE IssPhase.CompanyCode = pc-CompanyCode
        AND IssPhase.IssueNumber = pi-IssueNumber 
        BY issPhase.DisplayOrder:
        ASSIGN 
            li-rno = li-rno + 1.
                
        CREATE tt-proj-tasks.
        ASSIGN
            tt-proj-tasks.rno       = li-rno
            tt-proj-tasks.id        = issPhase.PhaseID
            tt-proj-tasks.txt       = /*STRING(issPhase.DisplayOrder) + "." + */ issPhase.Descr 
            tt-proj-tasks.prog      = 0.00
            tt-proj-tasks.startDate = Issue.prj-Start
            tt-proj-tasks.EndDate   = Issue.prj-Start
            tt-proj-tasks.duration  = 1
            tt-proj-tasks.parentID  = 0
            tt-proj-tasks.datatype  = "PH"
            tt-proj-tasks.cRow      = STRING(ROWID(issPhase))
            .
            
        ASSIGN
            lr-row   = ROWID(tt-proj-tasks)
            ld-start = ?
            ld-end   = ?.
        
        FOR EACH IssAction NO-LOCK
            WHERE IssAction.CompanyCode = pc-CompanyCode
            AND IssAction.IssueNumber = pi-IssueNumber
            AND IssAction.PhaseID = issPhase.PhaseID
            BY IssAction.DisplayOrder:
            ASSIGN 
                li-rno = li-rno + 1.    
            CREATE tt-proj-tasks.
            ASSIGN
                tt-proj-tasks.rno       = li-rno
                tt-proj-tasks.id        = IssAction.Taskid
                tt-proj-tasks.txt       = /* STRING(issAction.DisplayOrder) + "." + */ IssAction.ActDescription 
                /*+ "." + string(IssAction.Taskid) */
                tt-proj-tasks.prog      = 0.00
                tt-proj-tasks.startDate = IssAction.ActionDate
                tt-proj-tasks.duration  = DYNAMIC-FUNCTION("prjlib-WorkingDays",IssAction.PlanDuration)
                tt-proj-tasks.EndDate   = tt-proj-tasks.startDate + tt-proj-tasks.duration - 1
                tt-proj-tasks.parentID  = issPhase.PhaseID
                tt-proj-tasks.cDuration = DYNAMIC-FUNCTION("com-TimeToString",IssAction.workDuration)
                tt-proj-tasks.datatype  = "TA"
                tt-proj-tasks.cRow      = STRING(ROWID(issAction))
                .
         
            IF ld-end = ?
                THEN ASSIGN ld-end = tt-proj-tasks.EndDate. 
            IF ld-start = ?
                THEN ASSIGN ld-start = tt-proj-tasks.StartDate.
            
            IF ld-start > tt-proj-tasks.StartDate
                THEN ASSIGN ld-start = tt-proj-tasks.StartDate.
            IF ld-end < tt-proj-tasks.EndDate
                THEN ASSIGN ld-end = tt-proj-tasks.endDate.
            
            FOR EACH eSched NO-LOCK
                WHERE eSched.IssActionID = IssAction.IssActionID:
                
                IF tt-proj-tasks.EngCode = "" 
                    THEN ASSIGN
                        tt-proj-tasks.EngCode = eSched.AssignTo
                        tt-proj-tasks.EngName = DYNAMIC-FUNCTION("com-UserName",eSched.AssignTo).
                ELSE ASSIGN
                        tt-proj-tasks.EngCode = tt-proj-tasks.EngCode + "," +  eSched.AssignTo
                        tt-proj-tasks.EngName = tt-proj-tasks.EngName + "," + DYNAMIC-FUNCTION("com-UserName",eSched.AssignTo).    
            END.
                   
        END.  
        
        FIND tt-proj-tasks WHERE ROWID(tt-proj-tasks) = lr-row EXCLUSIVE-LOCK.
        
        /*
        ***
        *** No tasks for this phase so it starts/end on project day
        ***
        */
        IF ld-Start = ?
            OR ld-end = ? 
            THEN ASSIGN ld-start = Issue.prj-Start
                ld-end   = Issue.prj-Start.
                             
        ASSIGN
            tt-proj-tasks.startDate = ld-start
            tt-proj-tasks.EndDate   = ld-end
            tt-proj-tasks.duration  = ( ld-end - ld-start ) + 1
          
            .
                
    END.
               

END PROCEDURE.

PROCEDURE prjlib-BuildScheduleData:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-user          AS CHARACTER    NO-UNDO.
    DEFINE INPUT PARAMETER pc-companyCode   AS CHARACTER    NO-UNDO.
    DEFINE INPUT PARAMETER pc-engList       AS CHARACTER    NO-UNDO.
    DEFINE INPUT PARAMETER pd-from          AS DATE         NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE           FOR tt-schedule.
    
        
    DEFINE BUFFER issue     FOR Issue.
    DEFINE BUFFER WebUser   FOR WebUser.
    DEFINE BUFFER issPhase  FOR issPhase.
    DEFINE BUFFER IssAction FOR IssAction.
    DEFINE BUFFER eSched    FOR eSched.
    
    DEFINE VARIABLE li-rno    AS INTEGER NO-UNDO.
    DEFINE VARIABLE ld-Start  AS DATE    NO-UNDO.
    DEFINE VARIABLE ld-end    AS DATE    NO-UNDO.
    DEFINE VARIABLE lr-row    AS ROWID   NO-UNDO.
    DEFINE VARIABLE li-loop   AS INTEGER NO-UNDO.
    DEFINE VARIABLE li-sect   AS INTEGER NO-UNDO.
    DEFINE VARIABLE li-ecount AS INTEGER NO-UNDO.
    
    

    
    DO li-loop = 1 TO NUM-ENTRIES(pc-EngList):
        
        FIND WebUser WHERE WebUser.LoginID = entry(li-loop,pc-engList) NO-LOCK NO-ERROR.
        IF NOT AVAILABLE WebUser 
            THEN NEXT.
        
        ASSIGN
         li-ecount = 0.
         
        FOR EACH eSched NO-LOCK
            WHERE eSched.CompanyCode = pc-companyCode
            AND eSched.AssignTo = WebUser.LoginID
            AND eSched.ActionDate >= pd-from
            ,
            FIRST IssAction NO-LOCK 
            WHERE IssAction.IssActionID = eSched.IssActionID   
            BY eSched.ActionDate
            BY eSched.IssueNumber
            :
          
            IF li-ecount = 0 
            THEN li-sect  = li-sect + 1.
            
            li-ecount = li-ecount + 1.
            
                  
            FIND Issue OF IssAction NO-LOCK NO-ERROR.
            
            FIND Customer OF Issue NO-LOCK NO-ERROR.
            
                
            ASSIGN
                li-rno = li-rno + 1.
                
            CREATE tt-schedule.
            ASSIGN
                tt-schedule.rno         = li-rno
                tt-schedule.id          = li-rno
                tt-schedule.startDate   = eSched.ActionDate 
                tt-schedule.endDate     = tt-schedule.startDate + DYNAMIC-FUNCTION("prjlib-WorkingDays",IssAction.PlanDuration) - 1
                tt-schedule.txt         = IssAction.ActDescription + " Issue " + string(Issue.IssueNumber)  
                              
                
                tt-schedule.EngCode     = eSched.AssignTo
                tt-schedule.EngName     = DYNAMIC-FUNCTION("com-UserName",eSched.AssignTo)
                tt-schedule.cRow        = STRING(ROWID(eSched))
                tt-schedule.IssueNumber = Issue.IssueNumber
                tt-schedule.custName    = Customer.Name
                tt-schedule.bdesc       = Issue.BriefDescription
                tt-schedule.section_id  = li-sect
                
                .
                 
                     
                    
        END.     
        
    END.
    
END PROCEDURE.

PROCEDURE prjlib-ChangeProjectEngineer:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    DEFINE INPUT PARAMETER pc-user              AS CHARACTER    NO-UNDO.
    DEFINE INPUT PARAMETER pc-companyCode       AS CHARACTER    NO-UNDO.
    DEFINE INPUT PARAMETER pi-IssueNumber       AS INTEGER      NO-UNDO.
    DEFINE INPUT PARAMETER pc-From              AS CHARACTER    NO-UNDO.
    DEFINE INPUT PARAMETER pc-To                AS CHARACTER    NO-UNDO.
    
    DEFINE BUFFER issue     FOR Issue.
    DEFINE BUFFER IssAction FOR IssAction.
    DEFINE BUFFER eSched    FOR eSched.
    
    FIND Issue
        WHERE Issue.CompanyCode = pc-CompanyCode
        AND Issue.IssueNumber = pi-IssueNumber NO-LOCK NO-ERROR.
        
    DO TRANSACTION:
        
        /*
        *** Remove any existing schedule for the *To engineer as
        *** he will get new records
        ***
        */
        FOR EACH eSched EXCLUSIVE-LOCK 
            WHERE eSched.CompanyCode = pc-companyCode
            AND eSched.IssueNumber = pi-IssueNumber
            AND eSched.AssignTo = pc-to:
            DELETE eSched.
        END.       
                         
        FOR EACH IssAction EXCLUSIVE-LOCK
            WHERE issAction.CompanyCode = Issue.companyCode
            AND IssAction.IssueNumber = Issue.IssueNumber
            AND IssAction.AssignTo = pc-from
            BY IssAction.issActionID
            :
            ASSIGN
                IssAction.AssignTo   = pc-to
                IssAction.AssignDate = TODAY
                IssAction.AssignTime = TIME.
            
            FIND FIRST eSched 
                WHERE esched.issActionID = IssAction.IssActionID
                AND eSched.AssignTo = pc-from
                EXCLUSIVE-LOCK NO-ERROR.
                  
            IF AVAILABLE eSched
                THEN ASSIGN eSched.AssignTo = pc-to .      
            
                 
        END.        
    END.             
END PROCEDURE.

PROCEDURE prjlib-DeleteTask:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-user              AS CHARACTER    NO-UNDO.
    DEFINE INPUT PARAMETER pc-companyCode       AS CHARACTER    NO-UNDO.
    DEFINE INPUT PARAMETER pi-IssueNumber       AS INTEGER      NO-UNDO.
    DEFINE INPUT PARAMETER pi-PhaseID           AS INT64        NO-UNDO.
    DEFINE INPUT PARAMETER pi-TaskID            AS INT64        NO-UNDO.
    
    DEFINE BUFFER issue     FOR Issue.
    DEFINE BUFFER issPhase  FOR issPhase.
    DEFINE BUFFER IssAction FOR IssAction.
    DEFINE BUFFER eSched    FOR eSched.
    
    FIND Issue
        WHERE Issue.CompanyCode = pc-CompanyCode
        AND Issue.IssueNumber = pi-IssueNumber NO-LOCK NO-ERROR.
        
    FIND issPhase
        WHERE IssPhase.CompanyCode = pc-CompanyCode
        AND IssPhase.IssueNumber = pi-IssueNumber 
        AND issPhase.PhaseID = pi-PhaseID NO-LOCK NO-ERROR.
     
    DO TRANSACTION:
                         
        FIND FIRST IssAction
            WHERE issAction.CompanyCode = Issue.companyCode
            AND IssAction.IssueNumber = Issue.IssueNumber
            AND IssAction.TaskID = pi-taskid EXCLUSIVE-LOCK NO-ERROR.  
            
        /*
        ***
        *** Also remove Engineer scheduled records
        ***
        */       
        IF AVAILABLE IssAction THEN
        DO:
            FOR EACH eSched EXCLUSIVE-LOCK
                WHERE eSched.IssActionID = IssAction.IssActionID:
                DELETE eSched.
            END.
            DELETE IssAction.
        END.        
                               
    END.
    
END PROCEDURE.

PROCEDURE prjlib-MoveProjectStart:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-user              AS CHARACTER    NO-UNDO.
    DEFINE INPUT PARAMETER pc-companyCode       AS CHARACTER    NO-UNDO.
    DEFINE INPUT PARAMETER pi-IssueNumber       AS INTEGER      NO-UNDO.
    DEFINE INPUT PARAMETER pi-Days              AS INTEGER      NO-UNDO.
    
    DEFINE BUFFER issue     FOR Issue.
    DEFINE BUFFER IssAction FOR IssAction.
    DEFINE BUFFER eSched    FOR eSched.
    
    
    FIND Issue
        WHERE Issue.CompanyCode = pc-CompanyCode
        AND Issue.IssueNumber = pi-IssueNumber NO-LOCK NO-ERROR.
        
    DO TRANSACTION:
                         
        FOR EACH IssAction EXCLUSIVE-LOCK
            WHERE issAction.CompanyCode = Issue.companyCode
            AND IssAction.IssueNumber = Issue.IssueNumber
            BY IssAction.issActionID
            :
            
            ASSIGN 
                IssAction.ActionDate = IssAction.ActionDate + pi-Days.
      
            FOR EACH eSched EXCLUSIVE-LOCK
                WHERE eSched.IssActionID = IssAction.IssActionID:
               
                ASSIGN
                    eSched.ActionDate = IssAction.ActionDate.
                     
               
            END.
          
        END.        
                               
    END.
        

END PROCEDURE.

PROCEDURE prjlib-NewProject:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-user              AS CHARACTER    NO-UNDO.
    DEFINE INPUT PARAMETER pc-companyCode       AS CHARACTER    NO-UNDO.
    DEFINE INPUT PARAMETER pi-IssueNumber       AS INTEGER      NO-UNDO.
    
    DEFINE BUFFER issue     FOR Issue.
    DEFINE BUFFER ptp_proj  FOR ptp_proj.
    DEFINE BUFFER ptp_phase FOR ptp_phase.
    DEFINE BUFFER ptp_task  FOR ptp_task.
    
    DEFINE VARIABLE li-count AS INTEGER NO-UNDO.
    
        
    this_block:
    REPEAT TRANSACTION ON ERROR UNDO, LEAVE:
        FIND Issue
            WHERE Issue.CompanyCode = pc-CompanyCode
            AND Issue.IssueNumber = pi-IssueNumber EXCLUSIVE-LOCK NO-ERROR.
              
        FIND ptp_proj WHERE ptp_proj.CompanyCode = Issue.CompanyCode
            AND ptp_proj.ProjCode = Issue.projCode
            NO-LOCK NO-ERROR.
        FOR EACH ptp_phase NO-LOCK OF ptp_proj BY ptp_phase.displayOrder:
            ASSIGN 
                li-Count = li-Count + 1.
            RUN prjlib-ProcessPhase ( pc-user, pc-companyCode, pi-issueNumber, ptp_phase.phaseid , li-Count).
            
        END.              
        LEAVE this_block.
    END.
    


END PROCEDURE.

PROCEDURE prjlib-ProcessPhase:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-user              AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER pc-companyCode       AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER pi-IssueNumber       AS INTEGER  NO-UNDO.
    DEFINE INPUT PARAMETER pi-phaseid           AS INT64    NO-UNDO.
    DEFINE INPUT PARAMETER pi-count             AS INTEGER  NO-UNDO.
    
    
    DEFINE BUFFER issue     FOR Issue.
    DEFINE BUFFER issPhase  FOR issPhase.
    
    DEFINE BUFFER ptp_proj  FOR ptp_proj.
    DEFINE BUFFER ptp_phase FOR ptp_phase.
    DEFINE BUFFER ptp_task  FOR ptp_task.
    
    DEFINE VARIABLE li-count AS INTEGER NO-UNDO.
     
    this_block:
    REPEAT TRANSACTION ON ERROR UNDO, LEAVE:
        FIND Issue
            WHERE Issue.CompanyCode = pc-CompanyCode
            AND Issue.IssueNumber = pi-IssueNumber EXCLUSIVE-LOCK NO-ERROR.
              
        FIND ptp_proj WHERE ptp_proj.CompanyCode = Issue.CompanyCode
            AND ptp_proj.ProjCode = Issue.projCode
            NO-LOCK NO-ERROR.
        FIND ptp_phase WHERE ptp_phase.PhaseID = pi-phaseid NO-LOCK.
        
        CREATE issPhase.
        BUFFER-COPY ptp_phase TO issPhase
            ASSIGN
            issPhase.IssueNumber = Issue.IssueNumber
            issPhase.PhaseID =  NEXT-VALUE(projphase)
            .
                
        FOR EACH ptp_task NO-LOCK 
            WHERE ptp_task.CompanyCode = Issue.CompanyCode
            AND ptp_task.ProjCode = Issue.projCode
            AND ptp_task.PhaseID = pi-phaseid
            BY ptp_task.displayOrder:
            ASSIGN
                li-count = li-count + 1.
                                    
            RUN prjlib-ProcessTask 
                ( pc-user, pc-companyCode, pi-issueNumber,     
                ptp_phase.phaseid, ptp_task.TaskID, issPhase.PhaseID, li-count  ).                
        END.           
    
        LEAVE this_block.
    END.
    


END PROCEDURE.

PROCEDURE prjlib-ProcessTask:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-user              AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER pc-companyCode       AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER pi-IssueNumber       AS INTEGER NO-UNDO.
    DEFINE INPUT PARAMETER pi-phaseid           AS INT64 NO-UNDO.
    DEFINE INPUT PARAMETER pi-taskid            AS INT64 NO-UNDO.
    DEFINE INPUT PARAMETER pi-issPhaseid        AS INT64 NO-UNDO.
    DEFINE INPUT PARAMETER pi-Count             AS INT   NO-UNDO.
    
        
    DEFINE BUFFER issue     FOR Issue.
    DEFINE BUFFER issPhase  FOR issPhase.
    DEFINE BUFFER ptp_proj  FOR ptp_proj.
    DEFINE BUFFER ptp_phase FOR ptp_phase.
    DEFINE BUFFER ptp_task  FOR ptp_task.
    DEFINE BUFFER IssAction FOR IssAction.
    DEFINE BUFFER eSched    FOR eSched.
    
    DEFINE VARIABLE lf-Audit  AS DECIMAL NO-UNDO.
    DEFINE VARIABLE lr-Action AS ROWID   NO-UNDO.
       
    
    
    this_block:
    REPEAT TRANSACTION ON ERROR UNDO, LEAVE:
        FIND Issue
            WHERE Issue.CompanyCode = pc-CompanyCode
            AND Issue.IssueNumber = pi-IssueNumber EXCLUSIVE-LOCK NO-ERROR.
              
        FIND IssPhase
            WHERE IssPhase.CompanyCode = pc-CompanyCode
            AND IssPhase.IssueNumber = pi-IssueNumber 
            AND issPhase.phaseid = pi-issPhaseid 
            EXCLUSIVE-LOCK NO-ERROR.
              
                    
        FIND ptp_proj WHERE ptp_proj.CompanyCode = Issue.CompanyCode
            AND ptp_proj.ProjCode = Issue.projCode
            NO-LOCK NO-ERROR.
        FIND ptp_phase WHERE ptp_phase.PhaseID = pi-phaseid NO-LOCK.
        
        FIND ptp_task WHERE ptp_task.taskID = pi-taskid NO-LOCK.
                   
        /**/
        
        CREATE IssAction.
        ASSIGN 
            IssAction.actionID     = ? /* There's no action */
            IssAction.CompanyCode  = Issue.companyCode
            IssAction.IssueNumber  = issue.IssueNumber
            IssAction.CreateDate   = TODAY
            IssAction.CreateTime   = TIME
            IssAction.CreatedBy    = pc-user
            IssAction.customerview = NO
            .
    
        DO WHILE TRUE:
            RUN lib/makeaudit.p (
                "",
                OUTPUT lf-audit
                ).
            IF CAN-FIND(FIRST IssAction
                WHERE IssAction.IssActionID = lf-audit NO-LOCK)
                THEN NEXT.
            ASSIGN
                IssAction.IssActionID = lf-audit.
            LEAVE.
        END.
        ASSIGN 
            IssAction.notes        = ptp_task.descr
            IssAction.ActionStatus = "OPEN"
            IssAction.ActionDate   = ( Issue.prj-Start + ptp_task.StartDay ) - 1 
            IssAction.AssignTo     = Issue.AssignTo
            IssAction.AssignDate   = TODAY
            IssAction.AssignTime   = TIME.
       
        BUFFER-COPY ptp_task TO IssAction.
        
        CREATE eSched.
        ASSIGN
            eSched.eSchedID = NEXT-VALUE(esched).
        BUFFER-COPY IssAction TO eSched.
                    
                 
        ASSIGN
            IssAction.ActDescription = ptp_task.Descr
            IssAction.phaseid        = issPhase.PhaseID
            IssAction.PlanDuration   = ptp_task.EstDuration
            IssAction.workDuration   = ptp_task.estDuration
            IssAction.taskID         = NEXT-VALUE(projphase)
            .
            
        LEAVE this_block.
    END.
    


END PROCEDURE.

PROCEDURE prjlib-UpdateTask:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-user              AS CHARACTER    NO-UNDO.
    DEFINE INPUT PARAMETER pc-companyCode       AS CHARACTER    NO-UNDO.
    DEFINE INPUT PARAMETER pi-IssueNumber       AS INTEGER      NO-UNDO.
    DEFINE INPUT PARAMETER pi-PhaseID           AS INT64        NO-UNDO.
    DEFINE INPUT PARAMETER pi-TaskID            AS INT64        NO-UNDO.
    
    DEFINE INPUT PARAMETER pc-descr             AS CHARACTER    NO-UNDO.
    DEFINE INPUT PARAMETER pd-start             AS DATE         NO-UNDO.
    DEFINE INPUT PARAMETER pi-duration          AS INTEGER      NO-UNDO.
    
    DEFINE BUFFER issue     FOR Issue.
    DEFINE BUFFER issPhase  FOR issPhase.
    DEFINE BUFFER IssAction FOR IssAction.
    DEFINE BUFFER eSched    FOR eSched.
    
    FIND Issue
        WHERE Issue.CompanyCode = pc-CompanyCode
        AND Issue.IssueNumber = pi-IssueNumber NO-LOCK NO-ERROR.
        
    FIND issPhase
        WHERE IssPhase.CompanyCode = pc-CompanyCode
        AND IssPhase.IssueNumber = pi-IssueNumber 
        AND issPhase.PhaseID = pi-PhaseID NO-LOCK NO-ERROR.
     
    DO TRANSACTION:
                         
        FIND FIRST IssAction
            WHERE issAction.CompanyCode = Issue.companyCode
            AND IssAction.IssueNumber = Issue.IssueNumber
            AND IssAction.TaskID = pi-taskid EXCLUSIVE-LOCK NO-ERROR.  
            
              
        IF AVAILABLE IssAction THEN
        DO:
            ASSIGN 
                IssAction.notes          = pc-descr
                IssAction.ActDescription = pc-descr
                IssAction.ActionDate     = pd-start
                IssAction.PlanDuration   = pi-Duration * gli-Global-Proj-Work.
            
             
            /*
            ***
            *** Also update Engineer scheduled records
            ***
            */
            FOR EACH eSched EXCLUSIVE-LOCK
                WHERE eSched.IssActionID = IssAction.IssActionID:
                
                ASSIGN 
                    eSched.ActionDate = IssAction.ActionDate.
                    
            END.
           
        END.        
                               
    END.

END PROCEDURE.

/* ************************  Function Implementations ***************** */

FUNCTION prjlib-WorkingDays RETURNS INTEGER 
    ( pi-Time      AS INTEGER  ):
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE li-1day AS INTEGER NO-UNDO.
    DEFINE VARIABLE li-day  AS INTEGER NO-UNDO.
    
    
    ASSIGN 
        li-1day = gli-Global-Proj-Work. 
    
    IF pi-time <= li-1day
        THEN RETURN 1.
    
    ASSIGN 
        li-day = TRUNCATE( pi-time / li-1Day ,0).
        		
    IF pi-time MOD li-1day > 0
        THEN li-day = li-day + 1.
    
    RETURN li-day.
		
END FUNCTION.
