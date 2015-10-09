public class ResourceLeavesYearlyAggregate {
    
    public Id resourceId; 
    public String resourceName; 
    public String monthYearName; 
    public List<JavaForce__Leave__c> lstResourceLeaves; 
    public Integer sickLeaveCount; 
    public Integer approvedLeaveCount;
    public Integer unapprovedLeaveCount;
    public Integer trainingLeaveCount;
    public Integer plannedLeaveCount;
    public decimal totalAvailability;
    public Integer totalLeaves;
    public Integer sickLeaveCountJan; 
    public Integer sickLeaveCountFeb;
    public Integer sickLeaveCountMar;
    public Integer sickLeaveCountApr;
    public Integer sickLeaveCountMay;
    public Integer sickLeaveCountJun;                

    public ResourceLeavesYearlyAggregate (JavaForce__Resources__c resource){
        this.resourceId = resource.Id;
        this.resourceName = resource.Name;
        lstResourceLeaves = new List<JavaForce__Leave__c>();
        this.totalAvailability = 90.00;
        sickLeaveCountJan = 3;
        sickLeaveCountFeb = 2;
    
    } // constructor   
    
    public String getResourceName(){
        return this.resourceName;
    }
    
    public Integer getSickLeaveCountJan(){
        return this.sickLeaveCountJan;
    }
    
    public Integer getSickLeaveCountFeb(){
        return this.sickLeaveCountFeb;
    }
    public Integer getSickLeaveCountMar(){
        return this.sickLeaveCountMar;
    }
    public Integer getSickLeaveCountApr(){
        return this.sickLeaveCountApr;
    }
    public Integer getSickLeaveCountMay(){
        return this.sickLeaveCountMay;
    }
    
    
    
}