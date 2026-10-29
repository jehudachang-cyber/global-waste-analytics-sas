/* 

Group: 2
Code created on: 15/12/2025 
Objective of program: Research Question 1 

*/ 

/* Import Raw Dataset(Plastic_waste) */ 
LIBNAME mydata '/home/u64347364/Assignment'; 
 DATA work.pwaste_raw; 
  INFILE '/home/u64347364/Assignment/raw-dataset/mismanaged_plasticwaste.csv' 
  DSD                /* Comma-separated values */
  FIRSTOBS=2         /* Skip header row */
  TRUNCOVER          /* Prevent line truncation */
  lrecl=32767;       /* Allow long lines */
   INPUT  Country : $50.                        /* Country name */
          Total_Mismanaged_P_2010 : comma32.    /* Total mismanaged plastic waste in 2010 (tonnes) */
          Total_Mismanaged_P_2019 : comma32.    /* Total mismanaged plastic waste in 2019 (tonnes) */
          PerCapita_P_2010 : 8.3                /* Per capita mismanaged plastic waste in 2010 (kg/year) */
          PerCapita_P_2019 : 8.3 ;              /* Per capita mismanaged plastic waste in 2019 (kg/year) */
   FORMAT Total_Mismanaged_P_2010 Total_Mismanaged_P_2019 comma32. /* Apply the comma32. format: adds commas (Separator), 32. (Total Width) */
          PerCapita_P_2010 PerCapita_P_2019 8.3 ;                  /* Apply the 8.3 numeric format: 8 (Total Width).3 (Decimal Places) */
   
/* Replaces every 0 with a missing value (.) in the four specific columns listed */
   ARRAY nums(*) Total_Mismanaged_P_2010 Total_Mismanaged_P_2019 PerCapita_P_2010 PerCapita_P_2019;
    DO i = 1 to DIM(nums);
        if nums(i) = 0 then nums(i) = .;
    END;
  DROP i;
RUN; 

/* Re-orders the rows alphabetically based on the Country name */
PROC SORT data = work.pwaste_raw
          out= pwaste_clean;
     BY Country;
RUN;

/* Displays the "table of contents" for pwaste_clean dataset */ 
PROC CONTENTS data = pwaste_clean; 
 title 'Data structure and variable properties of pwaste_clean dataset';
RUN; 

/* Prints the actual rows and columns of pwaste_clean to the results window */ 
PROC PRINT data = pwaste_clean; 
 title 'Actual data observations of pwaste_clean dataset'; 
RUN; 

/* Calculates descriptive statistics for the four variables listed */ 
PROC MEANS data = pwaste_clean 
  N          /* Calculate and show number of values */
  NMISS      /* Calculate and show number of missing values */ 
  MEAN       /* Calculate and show the average value */
  MIN        /* Calculate and show the lowest values */
  MAX        /* Calculate and show the highest values */ 
  MAXDEC=2;  /* Ensures these numbers are rounded to 2 decimal places */ 
  VAR Total_Mismanaged_P_2010 /* Select the variables that needed */ 
      Total_Mismanaged_P_2019 
      PerCapita_P_2010    
      PerCapita_P_2019;
 title 'Descriptive Statistics for Plastic Waste Variables'; 
RUN; 

/* Create change variable (2019 – 2010) */
data work.plastic_change_clean;
    set work.pwaste_clean;
    if PerCapita_P_2010 ne . and PerCapita_P_2019 ne .; /* Keep only complete records */
    Plastic_Change = PerCapita_P_2019 - PerCapita_P_2010;
run;

/* Sort by largest increase */
proc sort data=work.plastic_change_clean;
    by descending Plastic_Change;
run;

/* Print Top 10 countries with highest increase */
proc print data=work.plastic_change_clean(obs=10);
    var Country PerCapita_P_2010 PerCapita_P_2019 Plastic_Change;
    format PerCapita_P_2010 PerCapita_P_2019 Plastic_Change 8.2;
    title "Top 10 Countries with Highest Increase in Mismanaged Plastic Waste Per Capita (2010 vs 2019)";
run;

/* Visualisation of Top 10 countries */
proc sgplot data=work.plastic_change_clean(obs=10);
    vbar Country / response=Plastic_Change datalabel fillattrs=(color=steelblue);
    xaxis discreteorder=data label="Country";
    yaxis label="Change in Per Capita Plastic Waste (kg)";
    title "Increase in Mismanaged Plastic Waste Per Capita (2010 vs 2019)";
run;

/* END_________________________________________________________________________________________________________________________________________________________________________________________________ */ 




