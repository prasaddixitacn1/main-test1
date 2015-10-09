public class ResourceLeavesAggregate {
    
    public Id resourceId; 
    public String resourceName; 
    public String monthYearName;
    public Integer monthindex; 
    public List<JavaForce__Leave__c> lstResourceLeaves; 
    public Integer sickLeaveCount; 
    public Integer approvedLeaveCount;
    public Integer unapprovedLeaveCount;
    public Integer trainingLeaveCount;
    public Integer plannedLeaveCount;
    public decimal totalAvailability;
    public Integer totalLeaves; 

    public Map<String,Map<String,Integer>> mapWeekDayToLeaveTypeToLeaveCount = new Map<String,Map<String,Integer>>();

    public ResourceLeavesAggregate(JavaForce__Resources__c resource, Integer monthindex){
        this.resourceId = resource.Id;
        this.resourceName = resource.Name;
        lstResourceLeaves = new List<JavaForce__Leave__c>();
        this.monthindex = monthindex;
        this.totalAvailability = 90.00;
    
    } // constructor   
    
    public String getResourceId(){
        return this.resourceId;
    }
    
    public String getResourceName(){
        return this.resourceName;
    }
    
    public Integer getApprovedLeaveCount(){
        return this.approvedLeaveCount;
    }
    
    public Integer getUnApprovedLeaveCount(){
        return this.unapprovedLeaveCount;
    }
    
    public Integer getPlannedLeaveCount(){
        return this.plannedLeaveCount;
    }
    
    public Integer getSickLeaveCount(){
        return this.sickLeaveCount;
    }
    
    public Integer getTrainingLeaveCount(){
        return this.trainingLeaveCount;
    }
    
    public Integer getTotalLeaves(){
        return this.totalLeaves;
    }

    public Decimal getTotalAvailability(){
        return this.totalAvailability;
    }
    
    public Integer getMonthindex(){
        return this.monthindex; 
    }
    
    public Map<String,Map<String,Integer>> getMapWeekDayToLeaveTypeToLeaveCount(){
        return this.mapWeekDayToLeaveTypeToLeaveCount;    
    } 
    
    public ResourceLeavesAggregate(JavaForce__Resources__c resource, List<JavaForce__Leave__c> lstLeaves, Integer monthindex){
    
        this.resourceId = resource.Id;
        this.resourceName = resource.Name;
        this.lstResourceLeaves = lstLeaves;
        this.monthindex = monthindex;
        this.mapWeekDayToLeaveTypeToLeaveCount.put('Monday',new Map<String,Integer>{'Approved' => 0, 'Sick' => 0, 'UnApproved' => 0, 'Planned' => 0, 'Training' => 0});
        this.mapWeekDayToLeaveTypeToLeaveCount.put('Tuesday',new Map<String,Integer>{'Approved' => 0, 'Sick' => 0, 'UnApproved' => 0, 'Planned' => 0, 'Training' => 0});
        this.mapWeekDayToLeaveTypeToLeaveCount.put('Wednesday',new Map<String,Integer>{'Approved' => 0, 'Sick' => 0, 'UnApproved' => 0, 'Planned' => 0, 'Training' => 0});
        this.mapWeekDayToLeaveTypeToLeaveCount.put('Thursday',new Map<String,Integer>{'Approved' => 0, 'Sick' => 0, 'UnApproved' => 0, 'Planned' => 0, 'Training' => 0});
        this.mapWeekDayToLeaveTypeToLeaveCount.put('Friday',new Map<String,Integer>{'Approved' => 0, 'Sick' => 0, 'UnApproved' => 0, 'Planned' => 0, 'Training' => 0});
        
        calculateRatios();

    
    } // constructor

    public void addResourceLeaves(JavaForce__Resources__c resource, JavaForce__Leave__c leaverecord){
    
    
    }
    
    private void calculateRatios(){
        Date lvstartdate, lvenddate; 
        String lvtype;
        Integer tempcount, tempcountall;
        Integer slcount=0,alcount=0,plcount=0,pcount=0,trncount=0,ulcount=0, totalcount=0;
        Map<String,Integer> maplvTypeCount = new Map<String,Integer>();
        
        if((this.lstResourceLeaves!= null) && !(this.lstResourceLeaves).isEmpty()){
            for(JavaForce__Leave__c lv : this.lstResourceLeaves){
                 tempcount = getThisMonthLeaveCount( lv,this.monthindex);
                 tempcountall = getThisMonthLeaveCountAll( lv,this.monthindex);
                 if(lv.JavaForce__Leave_Type__c.equalsIgnoreCase('Sick')){
                     slcount += tempcount;
                 }
                 
                 if(lv.JavaForce__Leave_Type__c.equalsIgnoreCase('Planned')){
                     plcount += tempcount;
                 }
                 
                 if(lv.JavaForce__Leave_Type__c.equalsIgnoreCase('Training')){
                     trncount += tempcount;
                 }
                 
                 if(lv.JavaForce__Leave_Type__c.equalsIgnoreCase('Approved')){
                     alcount += tempcount;
                 }
                 
                 if(lv.JavaForce__Leave_Type__c.equalsIgnoreCase('UnApproved')){
                     ulcount += tempcount;
                 }
                 totalcount+= tempcount;
                 System.debug('***&&&*** lv : ' + lv + ' -- TempCount : ' + tempcount);
                 setDayWiseLeaveCount(lv,tempcountall);
            }
            this.sickLeaveCount = slcount;
            this.plannedLeaveCount = plcount;
            this.trainingLeaveCount = trncount;
            this.approvedLeaveCount = alcount;            
            this.unapprovedLeaveCount = ulcount;
            this.totalLeaves= totalcount;
        }
        if(this.lstResourceLeaves== null || this.lstResourceLeaves.isEmpty()){
            this.sickLeaveCount = 0;
            this.plannedLeaveCount = 0;
            this.trainingLeaveCount = 0;
            this.approvedLeaveCount = 0;            
            this.unapprovedLeaveCount = 0;
            this.totalLeaves= 0;                    
        }
        
    
    } // calculateRatios

    public static Integer getThisMonthLeaveCount(JavaForce__Leave__c leaverecord, Integer monthindex){
        Integer leavecount = 0;  
        String thismonthleavedata, tempstr;
        String [] arrtempstr = new String[2];
        String monthlydistribution = leaverecord.JavaForce__Monthly_Leaves_Count__c; 
        String [] arrStrSplit = monthlydistribution.split(';');
        if(arrStrSplit.size()> 0){
            for(Integer i=0; i< arrStrSplit.size(); i++){
            
                tempstr = arrStrSplit[i];
                arrtempstr = tempstr.split(':');
                if(arrtempstr[0].equals(String.valueOf(monthindex))){
                    leavecount = Integer.valueOf(arrtempstr[1]); //     
                }
            
            }            
        }
        return leavecount;
    }
    
    public static Integer getThisMonthLeaveCountAll(JavaForce__Leave__c leaverecord, Integer monthindex){
        Integer leavecount = 0;  
        String thismonthleavedata, tempstr;
        String [] arrtempstr = new String[2];
        String monthlydistribution = leaverecord.JavaForce__Monthly_Leaves_Count_All__c; 
        String [] arrStrSplit = monthlydistribution.split(';');
        if(arrStrSplit.size()> 0){
            for(Integer i=0; i< arrStrSplit.size(); i++){
            
                tempstr = arrStrSplit[i];
                arrtempstr = tempstr.split(':');
                if(arrtempstr[0].equals(String.valueOf(monthindex))){
                    leavecount = Integer.valueOf(arrtempstr[1]); //     
                }
            
            }            
        }
        return leavecount;
    }

    public void setDayWiseLeaveCount(JavaForce__Leave__c leaverecord, Integer thismonthleavecount){
        Integer leavecount = 0;
        Date enddate = (leaverecord.JavaForce__Leave_Start_Date__c).addDays(thismonthleavecount) -1 ; // we dont want actual enddate if it falls outside this month  
        Date startdate = (leaverecord.JavaForce__Leave_Start_Date__c);
        String thismonthleavedata, tempstr;
        String [] arrtempstr = new String[2];
        Datetime startdttime;       // .addDays(1).format('EEEE');
        String weekdayvalue; 
        Map<String,Integer> tempInnerMap; 
        String leavetype = leaverecord.JavaForce__Leave_Type__c; 
        // 1. run a loop from startdate to enddate 
        // 2. for each day in between get the weekday value
        // 3. for each value increment its counter in the map
        // 4. 
        System.debug('*** Calculating DayWise Leaves Pattern ' );
        while(startdate <= enddate){
            weekdayvalue = ((DateTime)startdate).addDays(1).format('EEEE');
            System.debug('### Start Date : ' + startdate +  ' -- ' + this.resourceName + ' --- End Date : ' + enddate );
            if(!weekdayvalue.equals('Saturday') && !weekdayvalue.equals('Sunday')){
                if(!(this.mapWeekDayToLeaveTypeToLeaveCount).containsKey(weekdayvalue)){
                    System.debug('***^^*** WeekdayValue : ' + weekdayvalue);
                    if(!(this.mapWeekDayToLeaveTypeToLeaveCount).get(weekdayvalue).containsKey(leavetype)){
                        System.debug('***^^*** Resource Name 1 : ' + this.resourceName);
                        (this.mapWeekDayToLeaveTypeToLeaveCount).put(weekdayvalue, new Map<String,Integer> {leavetype => 1});
                    }
                    else{
                        System.debug('***^^*** Resource Name 2 : ' + this.resourceName);
                        leavecount = this.mapWeekDayToLeaveTypeToLeaveCount.get(weekdayvalue).get(leavetype) + 1; 
                        tempInnerMap = new Map<String,Integer>();
                        tempInnerMap.put(leavetype,leavecount);
                        (this.mapWeekDayToLeaveTypeToLeaveCount).put(weekdayvalue, tempInnerMap);
                    }
                }
                else{
                    
                    if(!(this.mapWeekDayToLeaveTypeToLeaveCount).get(weekdayvalue).containsKey(leavetype)){
                        System.debug('***^^*** Resource Name 3 : ' + this.resourceName + ' === Leave Type : ' + leavetype + ' === '  + this.mapWeekDayToLeaveTypeToLeaveCount );
                        tempInnerMap = this.mapWeekDayToLeaveTypeToLeaveCount.get(weekdayvalue);
                        tempInnerMap.put(leavetype,leavecount);
                        (this.mapWeekDayToLeaveTypeToLeaveCount).put(weekdayvalue, new Map<String,Integer> {leavetype => 1});
                    }
                    else{
                        System.debug('***^^*** Resource Name 4 : ' + this.resourceName + ' === Leave Type : ' + leavetype + ' === '  + this.mapWeekDayToLeaveTypeToLeaveCount );
                        leavecount = this.mapWeekDayToLeaveTypeToLeaveCount.get(weekdayvalue).get(leavetype) + 1; 
                        tempInnerMap = this.mapWeekDayToLeaveTypeToLeaveCount.get(weekdayvalue);
                        tempInnerMap.put(leavetype,leavecount);
                        System.debug('**^^** Map from Aggregate : ' + tempInnerMap + ' : ' + weekdayvalue);
                        (this.mapWeekDayToLeaveTypeToLeaveCount).put(weekdayvalue, tempInnerMap);
                    }           
                }
            }
            startdate = startdate.addDays(1);
            
        }
        
        
        
        
    }




} // end of main class