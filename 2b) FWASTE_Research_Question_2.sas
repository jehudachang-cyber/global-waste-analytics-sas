/* 

Group: 2
Code created on: 15/12/2025 
Objective of program: Research Question 2 

*/ 

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
   DROP Confidence_in_estimate M49_code Source;  /* Drop the variable no needed */ 

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

/* Clean and standardize region names */
data foodwaste_clean;
    set work.fwaste_clean;
    Region_clean = strip(upcase(Region));
run;

/* Count number of countries per region */
proc sql;
    create table region_counts as
    select Region_clean,
           count(distinct Country) as Country_Count
    from foodwaste_clean
    group by Region_clean;
quit;

/* Create region labels with counts (for display only) */
data region_labels;
    set region_counts;
    length Region_label $80;
    Region_label = catx(' ', Region_clean,
                        '(' || strip(put(Country_Count, 8.)) || ')');
run;

/* Convert wide format to long format (sector-level) */
data foodwaste_long;
    set foodwaste_clean;

    Sector = "Household";
    Waste_kg = Household_estimate_kg;
    output;

    Sector = "Retail";
    Waste_kg = Retail_estimate_kg;
    output;

    Sector = "Food Service";
    Waste_kg = Food_service_estimate_kg;
    output;

    keep Region_clean Sector Waste_kg;
run;

/* Merge region labels */
proc sql;
    create table foodwaste_labeled as
    select a.Region_clean,
           b.Region_label,
           a.Sector,
           a.Waste_kg
    from foodwaste_long as a
    left join region_labels as b
    on a.Region_clean = b.Region_clean;
quit;

/* Focus on top 5 regions */
data foodwaste_focus;
    set foodwaste_labeled;
    where Region_clean in (
        "SUB-SAHARAN AFRICA",
        "LATIN AMERICA AND THE CARIBBEAN",
        "WESTERN ASIA",
        "SOUTHERN EUROPE",
        "NORTHERN EUROPE"
    );
run;

/* Calculate percentage contribution per region */
proc sql;
    create table foodwaste_pct as
    select a.Region_label,
           a.Sector,
           a.Waste_kg,
           (a.Waste_kg / b.Total_Waste) * 100 as Waste_pct
    from foodwaste_focus as a
    inner join
    (
        select Region_label,
               sum(Waste_kg) as Total_Waste
        from foodwaste_focus
        group by Region_label
    ) as b
    on a.Region_label = b.Region_label;
quit;

/* Visualization */

/* Chart 1: Clustered bar chart (absolute values) */
proc sgplot data=foodwaste_focus;
    vbar Region_label /
        response=Waste_kg
        group=Sector
        groupdisplay=cluster;

    yaxis label="Per Capita Food Waste (kg/year)";
    xaxis label="Region (Number of Countries)";
    title "Per Capita Food Waste by Sector Across Top Five Regions";
run;

/* Chart 2: Clustered bar chart (percentage contribution) */
proc sgplot data=foodwaste_pct;
    vbar Region_label /
        response=Waste_pct
        group=Sector
        groupdisplay=cluster
        datalabel;

    yaxis label="Sector Contribution (%)"
          values=(0 to 100 by 20)
          grid;
    xaxis label="Region (Number of Countries)";
    title "Percentage Contribution of Food Waste by Sector Across Regions";
run;

/* Summary Statistics */
proc means data=foodwaste_focus mean sum maxdec=1;
    class Region_label Sector;
    var Waste_kg;
    title "Summary Statistics of Food Waste by Region and Sector";
run;

/* END_________________________________________________________________________________________________________________________________________________________________________________________________ */ 




