/* 

Group: 2
Code created on: 15/12/2025 
Objective of program: Research Question 3

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

*______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________ ; 


/* Import Raw Dataset(Food_waste) */ 
LIBNAME mydata '/home/u64347364/Assignment'; 
 DATA work.fwaste_raw; 
  INFILE '/home/u64347364/Assignment/raw-dataset/Food Waste data and research - by country.csv' 
  DSD                /* Comma-separated values */
  FIRSTOBS=2         /* Skip header row */
  TRUNCOVER;         /* Prevent line truncation */
   INPUT  Country : $50.                    /* Name of the country */
          Combined_figures_food: comma.     /* Total food waste (all sectors combined, in kg/year) */ 
          Household_estimate_kg: comma.     /* Food waste from households (in kg/year) */
          Household_estimate_t: comma.      /* Food waste from households (in tonnes/year) */
          Retail_estimate_kg: comma.        /* Food waste from retail sector (in kg/year) */
          Retail_estimate_t: comma.         /* Food waste from retail sector (in tonnes/year) */
          Food_service_estimate_kg: comma.  /* Food waste from food service sector (in kg/year) */
          Food_service_estimate_t: comma.   /* Food waste from food service sector (in tonnes/year) */
          Confidence_in_estimate : $50.     /* Confidence estimates */
          M49_code : 32.                    /* United nations */
          Region : $50.                     /* Geographical region of the country */
          Source : $50.  ;                  /* Information source */ 
   FORMAT Household_estimate_t Retail_estimate_t Food_service_estimate_t comma32.; /* Apply the comma32. format: adds commas (Separator), 32. (Total Width) */
   DROP Confidence_in_estimate M49_code Source Region;  /* Drop the variable no needed */ 

/* Replaces every 0 with a missing value (.) in the four specific columns listed */
   ARRAY nums(*) Household_estimate_kg Household_estimate_t Retail_estimate_kg Retail_estimate_t Food_service_estimate_kg Food_service_estimate_t;
    DO i = 1 to DIM(nums);
        if nums(i) = 0 then nums(i) = .;
    END;
  DROP i;
RUN; 

/* Re-orders the rows alphabetically based on the Country name */
PROC SORT data = work.fwaste_raw
          out= fwaste_clean;
     BY Country;
RUN;

/* Displays the "table of contents" for fwaste_clean dataset */ 
PROC CONTENTS data = fwaste_clean; 
 title 'Data structure and variable properties of fwaste_clean dataset';
RUN; 
 
/* Prints the actual rows and columns of fwaste_clean to the results window */ 
PROC PRINT data = fwaste_clean; 
 title 'Actual data observations of fwaste_clean dataset'; 
RUN; 
  
/* Calculates descriptive statistics for the four variables listed */ 
PROC MEANS data = fwaste_clean
  N          /* Calculate and show number of values */
  NMISS      /* Calculate and show number of missing values */ 
  MEAN       /* Calculate and show the average value */
  MIN        /* Calculate and show the lowest values */
  MAX        /* Calculate and show the highest values */ 
  MAXDEC=2;  /* Ensures these numbers are rounded to 2 decimal places */ 
  VAR Household_estimate_kg /* Select the variables that needed */
      Household_estimate_t
      Retail_estimate_kg
      Retail_estimate_t
      Food_service_estimate_kg
      Food_service_estimate_t 
      Combined_figures_food ; 
 title 'Descriptive Statistics for Food Waste Variables'; 
RUN; 

*______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________ ; 
 
 
/* Merge two cleaned dataset */ 
DATA work.food_plastic;
    MERGE fwaste_clean(IN=a) 
          pwaste_clean(IN=b);
    BY Country;
    
/* Delete the observation that have missing value */  
       ARRAY nums(*) Combined_figures_food Combined_figures_food Total_Mismanaged_P_2010 Total_Mismanaged_P_2019 PerCapita_P_2010 PerCapita_P_2019 Household_estimate_kg Household_estimate_t Retail_estimate_kg Retail_estimate_t Food_service_estimate_kg Food_service_estimate_t;
    DO i = 1 to DIM(nums);
        if nums(i) = . then delete;
    END;
  DROP i;
RUN;

/* Re-orders the rows alphabetically based on the Country name */
PROC SORT data = work.food_plastic
          out= work.food_plastic_clean;
     BY Country;
RUN;

/* Displays the "table of contents" for food_plastic_clean dataset */ 
PROC CONTENTS data = work.food_plastic_clean; 
 title 'Data structure and variable properties of food_plastic_clean dataset';
RUN; 
 
/* Prints the actual rows and columns of food_plastic_clean to the results window */ 
PROC PRINT data = work.food_plastic_clean; 
 title 'Actual data observations of food_plastic_clean dataset'; 
RUN; 
  
/* Calculates descriptive statistics for the four variables listed */ 
PROC MEANS data = work.food_plastic_clean 
  N          /* Calculate and show number of values */
  NMISS      /* Calculate and show number of missing values */ 
  MEAN       /* Calculate and show the average value */
  MIN        /* Calculate and show the lowest values */
  MAX        /* Calculate and show the highest values */ 
  MAXDEC=2;  /* Ensures these numbers are rounded to 2 decimal places */ 
  VAR Total_Mismanaged_P_2010 /* Select the variables that needed */ 
      Total_Mismanaged_P_2019
      PerCapita_P_2010   
      PerCapita_P_2019
      Household_estimate_kg
      Household_estimate_t
      Retail_estimate_kg
      Retail_estimate_t
      Food_service_estimate_kg
      Food_service_estimate_t 
      Combined_figures_food ; 
  title 'Descriptive Statistics for Food and Plastic Waste Variables'; 
RUN;  

*______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________ ; 
 
/* Correlation analysis */
proc corr data= work.food_plastic_clean pearson;
    var Combined_figures_food PerCapita_P_2019;
    title "Correlation Between Per Capita Food Waste and Mismanaged Plastic Waste (2019)";
run;

/* Scatter plot with regression line */
proc sgplot data= work.food_plastic_clean;
    scatter x=Combined_figures_food y=PerCapita_P_2019;
    reg x=Combined_figures_food y=PerCapita_P_2019;

    xaxis label="Per Capita Food Waste (kg/year)";
    yaxis label="Per Capita Mismanaged Plastic Waste (kg/year)";
    title "Relationship Between Food Waste and Mismanaged Plastic Waste (2019)";
run;

/* Regression analysis */
proc reg data= work.food_plastic_clean;
    model PerCapita_P_2019 = Combined_figures_food;
    title "Regression of Mismanaged Plastic Waste on Food Waste (2019)";
run;
quit;

/* END_________________________________________________________________________________________________________________________________________________________________________________________________ */ 


