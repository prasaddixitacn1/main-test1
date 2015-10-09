public class CalendarUtils {

    public static void createCalMonths(String yearvalue, Id yearid){
        
        String calMonthName, calMonthVal; 
        Integer calMonthIndex;
        JavaForce__Calendar_Month__c calMonth; 
        List<JavaForce__Calendar_Month__c> lstMonths = new List<JavaForce__Calendar_Month__c>();
        
        String [] strArrCalNames = new String [] {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'}; 
        String [] strArrCalValues = new String [] {'January','February','March','April','May','June','July','August','September','October','November','December'}; 
        
        for(Integer i =0; i<12; i++ ){
            calMonth = new JavaForce__Calendar_Month__c();
            calMonth.JavaForce__Calendar_Year__c = yearid;
            calMonth.JavaForce__Month_Value__c = strArrCalValues[i];
            calMonth.JavaForce__Month_Index__c = i+1;
            calMonth.Name = strArrCalNames[i] + '-' + yearvalue;        
            lstMonths.add(calMonth);
        }
        
        if(!lstMonths.isEmpty()){
            insert lstMonths;
        }      
        
    }

    
    // this method must be called from the After Insert Trigger on Calendar Months
    public static void createCalDays(List<JavaForce__Calendar_Month__c> lstNewMonths){
        
        String [] strArrWeekDayValues = new String [] {'Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'};
        
        //Integer [] intArrWeekDayIndex = new
        JavaForce__Calendar_Days__c nextdayobj;
        List<JavaForce__Calendar_Days__c> lstNextDay = new List<JavaForce__Calendar_Days__c>();
    
        Integer [] intArrMonthDaysNLY = new Integer [] {31,28,31,30,31,30,31,31,30,31,30,31};
        Integer [] intArrMonthDaysLY = new Integer [] {31,29,31,30,31,30,31,31,30,31,30,31};
    
        String strYearFirstDay = 'Thursday'; /*[Select Id, JavaForce__Day_1st_Jan__c from JavaForce__Calendar_Year__c 
                        where JavaForce__Year_Value__c =:lstNewMonths[0].JavaForce__Calendar_Year__c ].JavaForce__Day_1st_Jan__c;*/
    
        Integer nextdayindex; 
        Integer firstdayindex, currdayindex; 
        boolean isLeapYear = false;
        
        Map<String,Id> mapCalMonthNameID = new Map<String,Id>();
        for(JavaForce__Calendar_Month__c calmonth : lstNewMonths){
            mapCalMonthNameID.put(calmonth.JavaForce__Month_Value__c, calmonth.Id);        
        }
        
        for(Integer i=0; i<=strArrWeekDayValues.size();i++ ){
            if(strYearFirstDay.equals(strArrWeekDayValues[i])){
                firstdayindex = i;
                System.debug('FirstDayIndex : ' + i);
                break;            
            }        
        }
        
        Integer monthvalue;
        String monthname, yearval, monthval, dayval, weekdayval; 
        Id monthid;
        nextdayindex = getNextWeekDay(firstdayindex);
        currdayindex = firstdayindex;
        yearval = '2015'; // lstNewMonths[0].JavaForce__Calendar_Year__r.JavaForce__Year_Value__c;

        Integer daydate=1;
        
        for(Integer i=1; i<=365; i++){
            
            if(!isLeapYear){
                nextdayobj = new JavaForce__Calendar_Days__c();
                if(i>= 1 && i <=31) { monthname = 'January'; monthval = '01';}
                else if (i>=32 && i<=59 ){ monthname = 'February'; monthval = '02';}
                else if (i>=60 && i<=90 ){ monthname = 'March'; monthval = '03';}
                else if (i>=91 && i<=120 ){ monthname = 'April'; monthval = '04';}
                else if (i>=121 && i<=151 ){ monthname = 'May'; monthval = '05';}
                else if (i>=152 && i<=181 ) {monthname = 'June'; monthval = '06';}
                else if (i>=182 && i<=212 ) {monthname = 'July'; monthval = '07';}
                else if (i>=213 && i<=243 ) {monthname = 'August'; monthval = '08';}
                else if (i>=244 && i<=273 ) {monthname = 'September'; monthval = '09';}
                else if (i>=274 && i<=304 ) {monthname = 'October'; monthval = '10';}
                else if (i>=305 && i<=334 ) {monthname = 'November'; monthval = '11';}
                else { monthname = 'December'; monthval = '12';}
                
                
                monthid = mapCalMonthNameID.get(monthname);
                
                nextdayobj.JavaForce__Calendar_Month__c = monthid;
                //monthval = Trigger.NewMap().get(monthid).JavaForce__Month_Index__c;
                if(i==32 || i==60 || i == 91 || i == 121 || i== 152 ||i == 182 || i==213 || i==244 || i==274 || i==305 || i== 335){
                    daydate = 1;
                    dayval = String.valueOf(daydate);
                }    
                else {
                    dayval = String.valueOf(daydate);
                    daydate++;    
                    
                }

                nextdayobj.JavaForce__Date_Value__c = Date.valueOf( yearval + '-' + monthval + '-' + dayval);
                nextdayobj.JavaForce__Day_of_Year__c = i;
                
                weekdayval = strArrWeekDayValues[currdayindex];    
                nextdayobj.JavaForce__Day_Value__c = weekdayval;
                
                nextdayobj.JavaForce__Is_Holiday__c = false;
                
                /*if(currdayindex==5 || currdayindex ==6 ) nextdayobj.JavaForce__Is_WeekEnd__c = true;                                    
                else nextdayobj.JavaForce__Is_WeekEnd__c = false;                                                    
                */
                nextdayindex = getNextWeekDay(currdayindex);
                currdayindex = nextdayindex;
                lstNextDay.add(nextdayobj);
            }
            
            
        }
        
        insert lstNextDay; 
    
    
    
    
    } // end of method 
    
    
    
    public static Integer getOverlappingHolidays(Date sdate, Date edate){
        Integer overlappingholidays =0;
        Date csdate;  
        //DateTime startdatetime;
        Map<String,JavaForce__Holidays__c> mapHolidaysAll = JavaForce__Holidays__c.getAll();
        Set<Date> setHolidayDates = new Set<Date>();
        
        if(!mapHolidaysAll.isEmpty()){
            for(String s : mapHolidaysAll.keySet()){
                csdate = mapHolidaysAll.get(s).JavaForce__Holiday_Date__c;
                setHolidayDates.add((Date)(csdate));
            }
        }
        
        while(sdate <= edate){
            if(setHolidayDates.contains(sdate)){
               overlappingholidays++; 
            }            
            sdate = sdate.addDays(1);
        }   
    

        return overlappingholidays;        
    }
    
    public static Integer getNextWeekDay(Integer currday){
       
        Integer nextdayindex;
      
        if(currday != null && currday>=0 && currday <=6 ){
        
            if(currday==6 ){
                nextdayindex = 0;
            }
            else{
                nextdayindex = currday + 1;
            }        
        }
                    
        return nextdayindex;    
        
    } // end of getNextWeekDay
    
    
    /*public static Integer getFirstDayIndex(String str){
        
        Integer firstdayindex ; 
        if(str!= null && str != ''){
            if(str.equals('Sunday')
                firstdayindex = 0;
        }
    
    }*/
    
    
    // Leaves Processing Methods 
    
    /* To be called from Leave Before Insert and Before Update trigger  */
    public static void calculateLeaveDays(List<JavaForce__Leave__c> lstLeaves){
    
        
        //String yearval = String.valueOf(((JavaForce__Leave__c)Trigger.New[0]).JavaForce__Leave_Start_Date__c);
        Integer monthindex, yearval, holidaycount=0; 
        String weekdayval; 
        String startingweekdayval, endingweekdayval; 
        if(Trigger.isBefore){
           /*List<JavaForce__Calendar_Days__c> lstcaldays = [ Select Id,JavaForce__Date_Value__c,JavaForce__Is_WeekEnd__c,
                                                         JavaForce__Day_Value__c,JavaForce__Is_Holiday__c,JavaForce__Calendar_Month__c 
                                                         from JavaForce__Calendar_Days__c ];
           */
            
            if(Trigger.isInsert){
           
               for(JavaForce__Leave__c lv : lstLeaves){
                   holidaycount = getOverlappingHolidays(lv.JavaForce__Leave_Start_Date__c,lv.JavaForce__Leave_End_Date__c);
                   lv.JavaForce__Absolute_Leave_Days__c = getNumberOfDaysBetween(lv.JavaForce__Leave_Start_Date__c,lv.JavaForce__Leave_End_Date__c)[0] - holidaycount;
                   lv.JavaForce__Overlapping_WeekEnd_Days__c = getNumberOfDaysBetween(lv.JavaForce__Leave_Start_Date__c,lv.JavaForce__Leave_End_Date__c)[1];
                   lv.JavaForce__Monthly_Leaves_Count__c = getMonthIndexesFromVacation(lv.JavaForce__Leave_Start_Date__c,lv.JavaForce__Leave_End_Date__c);
                   lv.JavaForce__Monthly_Leaves_Count_All__c = getMonthIndexesFromVacationAll(lv.JavaForce__Leave_Start_Date__c,lv.JavaForce__Leave_End_Date__c);
                   lv.JavaForce__Overlapping_Holidays__c = holidaycount; 
                   startingweekdayval = ((DateTime)lv.JavaForce__Leave_Start_Date__c).addDays(1).format('EEEE');
                   endingweekdayval = ((DateTime)lv.JavaForce__Leave_End_Date__c).addDays(1).format('EEEE');    
                   lv.JavaForce__Leave_Starts_On__c = startingweekdayval;
                   lv.JavaForce__Leave_Ends_On__c = endingweekdayval;
                   if(startingweekdayval.equalsIgnoreCase('Saturday') || startingweekdayval.equalsIgnoreCase('Sunday') 
                       ||endingweekdayval.equalsIgnoreCase('Saturday') || endingweekdayval.equalsIgnoreCase('Sunday') ){
                           lv.addError('Leave Cannot Start or End on a Weekend');
                       }
                       
               }                
            
            }
        
        
            if(Trigger.isUpdate){
                //if() // check what is changed here ... 
               for(JavaForce__Leave__c lv : lstLeaves){
                   holidaycount = getOverlappingHolidays(lv.JavaForce__Leave_Start_Date__c,lv.JavaForce__Leave_End_Date__c);
                   lv.JavaForce__Absolute_Leave_Days__c = getNumberOfDaysBetween(lv.JavaForce__Leave_Start_Date__c,lv.JavaForce__Leave_End_Date__c)[0] - holidaycount;
                   lv.JavaForce__Overlapping_WeekEnd_Days__c = getNumberOfDaysBetween(lv.JavaForce__Leave_Start_Date__c,lv.JavaForce__Leave_End_Date__c)[1];
                   lv.JavaForce__Monthly_Leaves_Count__c = getMonthIndexesFromVacation(lv.JavaForce__Leave_Start_Date__c,lv.JavaForce__Leave_End_Date__c);
                   lv.JavaForce__Monthly_Leaves_Count_All__c = getMonthIndexesFromVacationAll(lv.JavaForce__Leave_Start_Date__c,lv.JavaForce__Leave_End_Date__c);
                   lv.JavaForce__Overlapping_Holidays__c = holidaycount;
                   startingweekdayval = ((DateTime)lv.JavaForce__Leave_Start_Date__c).addDays(1).format('EEEE');
                   endingweekdayval = ((DateTime)lv.JavaForce__Leave_End_Date__c).addDays(1).format('EEEE');    
                   lv.JavaForce__Leave_Starts_On__c = startingweekdayval;
                   lv.JavaForce__Leave_Ends_On__c = endingweekdayval;
                   if(startingweekdayval.equalsIgnoreCase('Saturday') || startingweekdayval.equalsIgnoreCase('Sunday') 
                       ||endingweekdayval.equalsIgnoreCase('Saturday') || endingweekdayval.equalsIgnoreCase('Sunday') ){
                           lv.addError('Leave Cannot Start or End on a Weekend');
                       }
               }
            }
    
        }
    } // calculateLeaveDays
    
    // this method just returns number of weekdays[0] and weekends[1] from sdate to edate
    public static Integer[] getNumberOfDaysBetween(Date startdate, Date enddate){
        Integer [] arrDiff = new Integer[2];
        Integer weekdayscount = 0, weekendscount = 0;
        Integer grossdiff = startdate.daysBetween(enddate) + 1;
        String dayval; 
        Datetime startdttime; 
        while(startdate <= enddate){
            System.debug('+++***+++ Start Date : ' + startdate + ' ==== End Date : ' + enddate);
            startdttime = (DateTime)(startdate).addDays(1);
            dayval = startdttime.format('EEEE'); 
            if(dayval.equals('Saturday') || (dayval.equals('Sunday'))){
                weekendscount++;                
            }
            else{
                System.debug('+++***+++ WeekDaysCount Incremented !');
                weekdayscount++;
            }
            startdate = startdate.addDays(1);
        }
        arrDiff[0]= weekdayscount; 
        arrDiff[1]= weekendscount; 
        return arrDiff; 
    }

    public static String getMonthIndexesFromVacation(Date startdate, Date enddate){
        
        String monthindexcount = '';
        String strMonthIndex;
        String dayval; 
        Datetime startdttime; 
        Integer count =0, oldcount, holidaycount =0;
        Map<String,Integer> mapMonthLeaveCount = new Map<String,Integer>();
        //holidaycount = getOverlappingHolidays(startdate,enddate); 
        while(startdate <= enddate){
            strMonthIndex = String.valueOf(startdate.month());

            System.debug('***** Start Date : ' + startdate);
            System.debug('***** End Date : ' + enddate);
            startdttime = (DateTime)(startdate).addDays(1);
            dayval = startdttime.addSeconds(60).format('EEEE'); 
            if(!mapMonthLeaveCount.containsKey(strMonthIndex)){
                
                if(!(dayval.equals('Saturday')) && !(dayval.equals('Sunday'))){
                    System.debug('**** 1. strMonthIndex : ' + strMonthIndex + ' --- ' + dayval);
                    count=0;
                    mapMonthLeaveCount.put(strMonthIndex,count+1);
                }
            }
            else{
                if(!(dayval.equals('Saturday')) && !(dayval.equals('Sunday'))){
                    System.debug('**** 2. strMonthIndex : ' + strMonthIndex + ' --- ' + dayval);
                    oldcount = mapMonthLeaveCount.get(strMonthIndex);
                    mapMonthLeaveCount.put(strMonthIndex,oldcount+1 );
                }    
            }            
            startdate = startdate.addDays(1);
        }
        
        for(String str : mapMonthLeaveCount.keySet()){
            monthindexcount += str + ':' + String.valueOf(mapMonthLeaveCount.get(str)) + ';';
        }

        return monthindexcount;
    }
    
    public static String getMonthIndexesFromVacationAll(Date startdate, Date enddate){
        
        String monthindexcount = '';
        String strMonthIndex;
        String dayval; 
        Datetime startdttime; 
        Integer count =0, oldcount;
        Map<String,Integer> mapMonthLeaveCount = new Map<String,Integer>();
        while(startdate <= enddate){
            strMonthIndex = String.valueOf(startdate.month());

            System.debug('***** Start Date : ' + startdate);
            System.debug('***** End Date : ' + enddate);
            startdttime = (DateTime)(startdate).addDays(1);
            dayval = startdttime.addSeconds(60).format('EEEE'); 
            if(!mapMonthLeaveCount.containsKey(strMonthIndex)){
                
                //if(!(dayval.equals('Saturday')) && !(dayval.equals('Sunday'))){
                    System.debug('**** 1. strMonthIndex : ' + strMonthIndex + ' --- ' + dayval);
                    count=0;
                    mapMonthLeaveCount.put(strMonthIndex,count+1);
                //}
            }
            else{
                //if(!(dayval.equals('Saturday')) && !(dayval.equals('Sunday'))){
                    System.debug('**** 2. strMonthIndex : ' + strMonthIndex + ' --- ' + dayval);
                    oldcount = mapMonthLeaveCount.get(strMonthIndex);
                    mapMonthLeaveCount.put(strMonthIndex,oldcount+1 );
                //}    
            }            
            startdate = startdate.addDays(1);
        }
        
        for(String str : mapMonthLeaveCount.keySet()){
            monthindexcount += str + ':' + String.valueOf(mapMonthLeaveCount.get(str)) + ';';
        }
        
        return monthindexcount;
    }

} // end of class