public class RandomLeaveReportController {

    

    public Date startdate {get;set;}
    public Date enddate {get;set;}
    public Boolean isApprovedLeave {get;set;}
    public Boolean isUnApprovedLeave {get;set;}
    public Boolean isPlannedLeave {get;set;}
    public Boolean isTrainingLeave {get;set;}
    public Boolean isSickLeave {get;set;}
    
    public Date sdate, edate; 
    public String resourcename {get;set;}
    public Integer smindex{get;set;}
    public Integer emindex{get;set;}
    
    public Integer totalsickleaves{get;set;}
    public Integer totalapprovedleaves{get;set;}
    public Integer totalunapprovedleaves{get;set;}
    public Integer totalplannedleaves{get;set;}
    public Integer totaltrainingleaves{get;set;}
    public Integer totalleaves{get;set;}
    
    public Decimal slpercentage{get;set;}
    public Decimal alpercentage{get;set;}
    public Double ulpercentage{get;set;}
    public Decimal plpercentage{get;set;}
    public Decimal tlpercentage{get;set;}
    
                    

    public List<Leave__c> lstLeaves{get;set;}
    public List<Leave__c> lstLeavesForView{get;set;}
    public List<Resources__c> lstResources{get;set;}
    public List<WrapperResourceForView> lstWrapper {get;set;}
    public Resources__c selectedResource {get;set;}
    
    public String selectedItem{get;set;}
    public String SelectedItemValue{get;set;}
    public Boolean allResources{get;set;}
    
    public Map<String,String> mapResIdName = new Map<String,String>();

    public RandomLeaveReportController(){
        if(startdate == null ) startdate = system.today().addDays(-30);
    
        if(enddate == null ) enddate = system.today().addDays(30);
        
        sdate = startdate;
        edate = enddate; 
        smindex = sdate.month();
        emindex = edate.month();
        
        lstLeavesForView = new List<JavaForce__Leave__c>();
        lstLeaves = new List<JavaForce__Leave__c>();
        
        totalsickleaves = 0; 
        totalapprovedleaves = 0; 
        totalunapprovedleaves = 0; 
        totalplannedleaves = 0; 
        totaltrainingleaves = 0; 
        totalleaves = 0; 
        
        
        //SelectedItem = ApexPages.currentPage().getParameters().get('SelectedItemValue');
        /*
        if(!isApprovedLeave){
            isApprovedLeave = false;
        }
        else{
            isApprovedLeave = true;            
        }
        
        if(!isUnApprovedLeave){
           isUnApprovedLeave = false; 
        }
        else{
            isUnApprovedLeave = true; 
        }
        
        if(!isSickLeave){
            isSickLeave = false;
        }
        else{
            isSickLeave = true;
        }
        
        if(!isPlannedLeave){
            isPlannedLeave = false;
        }
        else{
            isPlannedLeave = true;
        }
        
        if(!isTrainingLeave){
            isTrainingLeave = false;
        }
        else{
            isTrainingLeave = true;
        }
        */
        isApprovedLeave = true;
        isUnApprovedLeave = true; 
        isSickLeave = true;
        isPlannedLeave = true;
        isTrainingLeave = true;
        
        lstResources = [Select Id, Name from Resources__c where JavaForce__IsOnBoarded__c = true];
        
        lstLeaves = [ Select Id,JavaForce__Resource_Name__r.Name,JavaForce__Leave_Type__c,JavaForce__Leave_Start_Date__c,JavaForce__Leave_End_Date__c,JavaForce__Absent_Total_Days__c,
                        JavaForce__Absolute_Leave_Days__c,JavaForce__Monthly_Leaves_Count__c 
                        from JavaForce__Leave__c 
                        where 
                            Calendar_Month(JavaForce__Leave_Start_Date__c) >= :smindex or 
                            (Calendar_Month(JavaForce__Leave_End_Date__c) <= :emindex and Calendar_Month(JavaForce__Leave_End_Date__c) >= :smindex)
                            order by JavaForce__Resource_Name__r.Name, JavaForce__Leave_Start_Date__c  ];
        

        if(!lstLeaves.isEmpty()){
            for(JavaForce__Leave__c leave : lstLeaves){
                  if(((leave.JavaForce__Leave_Start_Date__c <= startdate) && (leave.JavaForce__Leave_End_Date__c >= startdate) && (leave.JavaForce__Leave_End_Date__c <= enddate)) 
                    || ((leave.JavaForce__Leave_Start_Date__c >= startdate) && (leave.JavaForce__Leave_End_Date__c <= enddate)) 
                    || ((leave.JavaForce__Leave_Start_Date__c >= startdate) && (leave.JavaForce__Leave_Start_Date__c <= enddate) && (leave.JavaForce__Leave_End_Date__c >= enddate)) 
                    || ((leave.JavaForce__Leave_Start_Date__c <= startdate) && (leave.JavaForce__Leave_End_Date__c >= enddate))){
                    
                              if(isApprovedLeave && leave.JavaForce__Leave_Type__c == 'Approved'){
                                  lstLeavesForView.add(leave);
                                  totalapprovedleaves += (Integer)leave.JavaForce__Absolute_Leave_Days__c;
                              }
                              
                              if(isUnApprovedLeave && leave.JavaForce__Leave_Type__c == 'UnApproved'){
                                  lstLeavesForView.add(leave);
                                  totalunapprovedleaves += (Integer)leave.JavaForce__Absolute_Leave_Days__c;
                              }
                              
                              if(isPlannedLeave && leave.JavaForce__Leave_Type__c == 'Planned'){
                                  lstLeavesForView.add(leave);
                                  totalplannedleaves += (Integer)leave.JavaForce__Absolute_Leave_Days__c;
                              }
                              
                              if(isSickLeave && leave.JavaForce__Leave_Type__c == 'Sick'){
                                  lstLeavesForView.add(leave);
                                  totalsickleaves += (Integer)leave.JavaForce__Absolute_Leave_Days__c;
                              } 
                              
                              if(isTrainingLeave && leave.JavaForce__Leave_Type__c == 'Training'){
                                  lstLeavesForView.add(leave);
                                  totaltrainingleaves += (Integer)leave.JavaForce__Absolute_Leave_Days__c;
                              } 
                         
                  }                                 
            }
            
            totalleaves  = totaltrainingleaves + totalsickleaves + totalplannedleaves + totalapprovedleaves + totalunapprovedleaves ; 
        
            if(totalleaves > 0){
                slpercentage= (Decimal)((totalsickleaves * 100) / totalleaves );
                alpercentage= (Decimal)((totalapprovedleaves * 100) / totalleaves );
                ulpercentage= (Double)((totalunapprovedleaves * 100) / totalleaves );
                plpercentage= (Decimal)((totalplannedleaves * 100) / totalleaves );
                tlpercentage= (Decimal)((totaltrainingleaves * 100) / totalleaves );
            }
            
            System.debug('**** +++++ **** : totalleaves : ' + totalleaves );
            System.debug('**** +++++ **** : totalsickleaves : ' + totalsickleaves );
            
            System.debug('**** +++++ **** : slpercentage: ' + slpercentage);            

            lstWrapper = new List<WrapperResourceForView> ();
            allResources = true;
            for(Resources__c r : lstResources){
                lstWrapper.add(new WrapperResourceForView(true,r.id,r.name));
            }
             
        }
        
        
    }
    
    public void searchLeaves(){
    
        if(startdate == null ) startdate = system.today().addDays(-30);
    
        if(enddate == null ) enddate = system.today().addDays(10);
    
        sdate = startdate;
        edate = enddate; 
        smindex = sdate.month();
        emindex = edate.month();
        lstLeavesForView = new List<JavaForce__Leave__c>();
        
        totalsickleaves = 0; 
        totalapprovedleaves = 0; 
        totalunapprovedleaves = 0; 
        totalplannedleaves = 0; 
        totaltrainingleaves = 0; 
        totalleaves = 0;
        
        
        slpercentage= 0.0;
        alpercentage= 0.0;
        ulpercentage= 0.0;
        plpercentage= 0.0;
        tlpercentage= 0.0;

    
        lstLeaves = [ Select Id,JavaForce__Resource_Name__r.Name,JavaForce__Leave_Type__c,JavaForce__Leave_Start_Date__c,JavaForce__Leave_End_Date__c,JavaForce__Absent_Total_Days__c,
                        JavaForce__Absolute_Leave_Days__c,JavaForce__Monthly_Leaves_Count__c 
                        from JavaForce__Leave__c 
                       /* where 
                            Calendar_Month(JavaForce__Leave_Start_Date__c) >= :smindex or 
                            (Calendar_Month(JavaForce__Leave_End_Date__c) <= :emindex and Calendar_Month(JavaForce__Leave_End_Date__c) >= :smindex) */
                            order by JavaForce__Resource_Name__r.Name, JavaForce__Leave_Start_Date__c ];
        

        if(!lstLeaves.isEmpty()){
            for(JavaForce__Leave__c leave : lstLeaves){                  
                if(((leave.JavaForce__Leave_Start_Date__c <= startdate) && (leave.JavaForce__Leave_End_Date__c >= startdate) && (leave.JavaForce__Leave_End_Date__c <= enddate)) 
                    || ((leave.JavaForce__Leave_Start_Date__c >= startdate) && (leave.JavaForce__Leave_End_Date__c <= enddate)) 
                    || ((leave.JavaForce__Leave_Start_Date__c >= startdate) && (leave.JavaForce__Leave_Start_Date__c <= enddate) && (leave.JavaForce__Leave_End_Date__c >= enddate)) 
                    || ((leave.JavaForce__Leave_Start_Date__c <= startdate) && (leave.JavaForce__Leave_End_Date__c >= enddate))){
              
                        if(isApprovedLeave && leave.JavaForce__Leave_Type__c == 'Approved'){
                            lstLeavesForView.add(leave);
                            totalapprovedleaves += (Integer)leave.JavaForce__Absolute_Leave_Days__c;
                        }
                          
                        if(isUnApprovedLeave && leave.JavaForce__Leave_Type__c == 'UnApproved'){
                            lstLeavesForView.add(leave);
                            totalunapprovedleaves += (Integer)leave.JavaForce__Absolute_Leave_Days__c;
                        }
                          
                        if(isPlannedLeave && leave.JavaForce__Leave_Type__c == 'Planned'){
                            lstLeavesForView.add(leave);
                            totalplannedleaves += (Integer)leave.JavaForce__Absolute_Leave_Days__c;
                        }
                          
                        if(isSickLeave && leave.JavaForce__Leave_Type__c == 'Sick'){
                            lstLeavesForView.add(leave);
                             totalsickleaves += (Integer)leave.JavaForce__Absolute_Leave_Days__c;
                        } 
                          
                        if(isTrainingLeave && leave.JavaForce__Leave_Type__c == 'Training'){
                            lstLeavesForView.add(leave);
                            totaltrainingleaves += (Integer)leave.JavaForce__Absolute_Leave_Days__c;
                        }
                }
                
                
                                         
            }
            
            totalleaves  = totaltrainingleaves + totalsickleaves + totalplannedleaves + totalapprovedleaves + totalunapprovedleaves ; 
            if(totalleaves > 0){
                slpercentage= (Decimal)((totalsickleaves * 100) / totalleaves );
                alpercentage= (Decimal)((totalapprovedleaves * 100) / totalleaves );
                ulpercentage= (Double)((totalunapprovedleaves * 100) / totalleaves );
                plpercentage= (Decimal)((totalplannedleaves * 100) / totalleaves );
                tlpercentage= (Decimal)((totaltrainingleaves * 100) / totalleaves );
            }
            
        }
        
    
    }
    
    public List<SelectOption> getResourcesByName(){
        List<SelectOption> lstResourceNames = new List<SelectOption>();
        if(!lstResources.isEmpty()){
            lstResourceNames.add(new SelectOption('001000000000000','Show All'));
            for(Resources__c rs : lstResources){
                lstResourceNames.add(new SelectOption(rs.Id,rs.Name));
                mapResIdName.put(rs.Id,rs.Name);
            }
        }
        return lstResourceNames;
    }
 
    public PageReference printSelectedResource() {
        selectedResource = new Resources__c();
        selectedItem = mapResIdName.get(selectedItem);
        return null;
    }

    public class WrapperResourceForView {
        public Boolean isSelected {get;set;}
        public Id resId {get;set;}
        public String resName{get;set;}
        
        public WrapperResourceForView(Boolean bool, Id rid, String rname){
            this.isSelected = bool;
            this.resId = rid;
            this.resName= rname;
        }
        
    }



}