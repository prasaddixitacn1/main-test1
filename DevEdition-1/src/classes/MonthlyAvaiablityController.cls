public class MonthlyAvaiablityController {
    
    public Calendar_Month__c thisMonth{get;set;}
    public String monthid{get;set;}
    public String monthname{get;set;}
    transient public List<JavaForce__Leave__c> lstLeaves{get;set;}
    public Integer monthindex{get;set;}
    transient public List<JavaForce__Calendar_Days__c> lstCalDays{get;set;}
    transient public List<JavaForce__Resources__c> lstResources{get;set;}
    transient public Map<Id,List<JavaForce__Leave__c>> mapResourceIdLeaves{get;set;}
    transient public List<ResourceLeavesAggregate> lstResourceLeavesAggregate {get;set;}
    transient public ResourceLeavesAggregate rsagr{get;set;}
    public Integer resourcecount{get;set;}
    public Integer totalworkingdays{get;set;}
    public Integer totalholidays{get;set;}
    public Integer totalweekends{get;set;}
    public Integer totalworkinghours{get;set;}
    public String showing{get;set;}
    transient public List<ResourceLeavesYearlyAggregate> lstResourceYearAggregate{get;set;}
    public ResourceLeavesYearlyAggregate rsyragr{get;set;}
    
    public boolean refreshParent {get;set;}
    public Integer totalsickleaves{get;set;}
    public Integer totalapprovedleaves{get;set;}
    public Integer totalunapprovedleaves{get;set;}
    public Integer totaltrainingleaves{get;set;}
    public Integer totalplannedleaves{get;set;}            
    public Integer totalteamavailability{get;set;} // totalteamavailability totalteamavailablepercentage
    public double totalteamavailablepercentage {get;set;}
    public List<String> lstWeekDaysForMap{get;set;}
    public List<String> lstLeaveTypesForMap{get;set;}
    public Integer yearindex{get;set;}
    public Date firstday {get;set;}
    public Date  lastday {get;set;}
    
    public Date startdate {get;set;}
    public Date  enddate {get;set;}
    public Date sdateh{get;set;}
    public Date edateh{get;set;}
    public DateTime startdatetime;
    public String dayval; 
    
    
        
    public MonthlyAvaiablityController(ApexPages.StandardController stdcontroller){
        List<String> fields = new List<String>();

        fields.add('Name');
        fields.add('JavaForce__Month_Index__c');
        fields.add('JavaForce__Calendar_Year__r.JavaForce__Year_Value__c');
        // add more fields as needed here 
        
        stdcontroller.addFields(fields);
        refreshParent = false;
        this.thisMonth = (Calendar_Month__c)stdController.getRecord();
        this.monthid = thisMonth.Id;
        this.monthname = thisMonth.Name;
        this.monthindex = (Integer)thisMonth.JavaForce__Month_Index__c;
        this.yearindex = Integer.valueOf(thisMonth.JavaForce__Calendar_Year__r.JavaForce__Year_Value__c); 
        
        totalweekends = 0;
        totalholidays = 0;
        totalworkingdays = 0;
        
        lstLeaves = [   Select Id,JavaForce__Resource_Name__r.Name,JavaForce__Leave_Type__c,JavaForce__Leave_Start_Date__c,JavaForce__Leave_End_Date__c,JavaForce__Absent_Total_Days__c,
                        JavaForce__Absolute_Leave_Days__c,JavaForce__Monthly_Leaves_Count__c,JavaForce__Monthly_Leaves_Count_All__c 
                        from JavaForce__Leave__c 
                        where 
                            Calendar_Month(JavaForce__Leave_Start_Date__c) = :monthindex or 
                            Calendar_Month(JavaForce__Leave_End_Date__c) = :monthindex 
                    ];
        
        
        
        
        firstday = Date.newInstance(yearindex,this.monthindex,1);
        lastday = firstday.addDays(Date.daysInMonth(yearindex,monthindex)-1);
        startdate = firstday; 
        enddate = lastday; 
        sdateh = firstday;
        edateh = lastday;
        totalholidays = CalendarUtils.getOverlappingHolidays(sdateh,edateh);
        while(startdate  <= enddate){
            startdatetime = (DateTime)(startdate).addDays(1);
            dayval = startdatetime.addSeconds(60).format('EEEE'); 
            if(!(dayval.equals('Saturday')) && !(dayval.equals('Sunday'))){
                totalworkingdays++;
            }
            else{
                totalweekends++;
            }
            startdate = startdate.addDays(1);
        }
        
        /*
        lstCalDays = [  Select Id,JavaForce__Calendar_Month__c,JavaForce__Date_Value__c,JavaForce__Day_of_Year__c,JavaForce__Day_Value__c,JavaForce__Is_Holiday__c,JavaForce__Is_WeekEnd__c 
                          from JavaForce__Calendar_Days__c
                          where JavaForce__Calendar_Month__c = :monthid                         
                          ];
                          
        
                           
        for(JavaForce__Calendar_Days__c caldays : lstCalDays){
            
            if(caldays.JavaForce__Is_WeekEnd__c) totalweekends++; 
            else if(caldays.JavaForce__Is_Holiday__c)totalholidays++;
            else totalworkingdays++; 
            
        }                  
        
        */                   
        
        lstResources = [    Select Id, Name from JavaForce__Resources__c where JavaForce__IsOnBoarded__c = true and JavaForce__Level__c Not In ('AM','M') ];

        if(!lstResources.isEmpty()){
            resourcecount = lstResources.size();
            totalworkinghours = resourcecount * (totalworkingdays - totalholidays) * 9;
        }
        
        mapResourceIdLeaves = new Map<Id,List<JavaForce__Leave__c>>();
        
        if(!lstLeaves.isEmpty()){
            for(JavaForce__Leave__c lv : lstLeaves){
                if(!mapResourceIdLeaves.containsKey(lv.JavaForce__Resource_Name__c)){
                    mapResourceIdLeaves.put(lv.JavaForce__Resource_Name__c,new List<JavaForce__Leave__c>{lv});
                }
                else{
                    mapResourceIdLeaves.get(lv.JavaForce__Resource_Name__c).add(lv);
                }            
            }        
        }

        if(!lstResources.isEmpty()){
            lstResourceLeavesAggregate = new List<ResourceLeavesAggregate>();
            lstResourceYearAggregate = new List<ResourceLeavesYearlyAggregate>();
            for(JavaForce__Resources__c rs : lstResources){
                rsagr = new ResourceLeavesAggregate(rs,mapResourceIdLeaves.get(rs.Id),this.monthindex);
                System.debug('*** resourceName : ' + rsagr.resourceName);
                lstResourceLeavesAggregate.add(rsagr);
                rsyragr = new ResourceLeavesYearlyAggregate(rs);
                lstResourceYearAggregate.add(rsyragr);
            }
        }

        System.debug(' Record Map For : ' +  lstResourceLeavesAggregate.get(5).getResourceName() + '  ----  '  + lstResourceLeavesAggregate.get(5).mapWeekDayToLeaveTypeToLeaveCount);

        totalsickleaves = 0;
        totalapprovedleaves = 0;
        totalunapprovedleaves = 0;
        totaltrainingleaves = 0;
        totalplannedleaves = 0; 
        
        if(!lstResourceLeavesAggregate.isEmpty()){
            for(ResourceLeavesAggregate ragr : lstResourceLeavesAggregate){
                totalsickleaves += ragr.getSickLeaveCount();
                totalapprovedleaves += ragr.getApprovedLeaveCount();
                totalunapprovedleaves += ragr.getUnApprovedLeaveCount();
                totaltrainingleaves += ragr.getTrainingLeaveCount();
                totalplannedleaves += ragr.getPlannedLeaveCount();
            }
            totalteamavailability = totalworkinghours - ((totalsickleaves + totalapprovedleaves +totalunapprovedleaves + totaltrainingleaves + totalplannedleaves)*9);
            totalteamavailablepercentage = ((totalteamavailability * 100)/totalworkinghours);

        }


    lstWeekDaysForMap = 'Monday,Tuesday,Wednesday,Thursday,Friday'.split(',');
    lstLeaveTypesForMap = 'Approved,Sick,UnApproved'.split(',');

   
    }

    public PageReference refresh(){
        /*PageReference pg = new PageReference ('/' + this.thisMonth.Id );
        pg.setRedirect(true);
        */
        refreshParent = true;
        return null;
    }

  
    public PageReference showAgain(){
        Datetime dt = System.Now();
        showing = String.valueOf(dt);    
        return null;    
    }

}