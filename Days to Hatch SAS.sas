data ryan;
input trt :$15. rep$ D2H;
Cards;
Control	1	7.00
Control	2	7.00
Control	3	7.00
Control	4	6.00
Helicopsychidae	1	7.00
Helicopsychidae	2	6.00
Helicopsychidae	3	5.00
Helicopsychidae	4	7.00
Isonychiidae	1	7.00
Isonychiidae	2	5.00
Isonychiidae	3	5.00
Isonychiidae	4	7.00
Perlidae	1	5.00
Perlidae	2	5.00
Perlidae	3	6.00
Perlidae	4	5.00
Heptageniidae	1	7.00
Heptageniidae	2	7.00
Heptageniidae	3	7.00
Heptageniidae	4	7.00
;
run;
proc print data=ryan;
run;


/****************************Days to Hatch***********************/
/*Create tables for manuscript purposes*/
proc means data=ryan mean stddev stderr min max;
class trt;
var D2H;
run;

/*Days to hatch as a function of treatment*/
/*Will take an initial look at model, df, and calculate residuals*/
proc mixed data=ryan PLOTS=ALL;
class trt;
model D2H = trt / outp=mr;
/*"outp=mr" creates a dataset named "mr" that besides the rest of the data will contain residuals (named "resid" - the PROC MIXED default name)*/
run;

/*Assumption Checking*/
/*1). Checking normality of the residuals*/
proc univariate data=mr normal plot; var resid; run;
/*Data pass Shapiro-Wilk test p=0.2812*/

/*2). Homogeneity of variances*/
/*Must plot residuals versus predicted values*/
proc plot data=mr vpercent=50 hpercent=50; plot resid*pred; run;
/*Scatter plot appears satisfactory based on visual observation (No funneling)*/

/*Side-by-side box plots*/
proc sort data=mr; by trt; run;
proc univariate data=mr normal plot; by trt; var resid; run;
/*Appears homogenous, except Heptageniidae*/
/*Will conduct a Levene's Test as well*/


/*Levene's Test for unequal variance*/
data mr; set mr; res2=resid*resid; run;
/*This creates a new variable "res2" - the squared residuals*/
proc mixed data=mr;
class trt;
model res2=trt;
run;
/*Analysis of squared residuals by Levene's Test indicates heterogeneity of variances*/
/*p=0.0028, likely due to heptageniidae variance of zero*/

/*Will analyze data assuming homo- and heterogenous variances for trt*/
proc mixed data=ryan;
class trt;
model D2H = trt;
lsmeans trt / pdiff adjust=tukey;
run;
/*AIC 42.5  BIC 43.2*/

/*Will analyze data assuming homo- and heterogenous variances for trt*/
proc mixed data=ryan;
class trt;
model D2H = trt;
repeated / GROUP=trt;
lsmeans trt / pdiff adjust=tukey;
run;
/*No Convergence*/
/*Will try with separate variance for Heptageniidae*/

data ryan; set ryan; 
	if trt='Heptageniidae' then gr='1';
	else gr='2';
run;

proc mixed data=ryan;
class trt gr;
model D2H = trt;
repeated / GROUP=gr;
lsmeans trt / pdiff adjust=tukey;
run;
/*Model did not converge*/

/*Final Analysis*/
/*Will analyze data assuming normality and homogenous variances for trt*/
proc mixed data=ryan;
class trt;
model D2H = trt;
lsmeans trt / pdiff adjust=tukey;
run;
/*AIC 32.2  BIC 32.7*/
