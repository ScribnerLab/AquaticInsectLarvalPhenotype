data ryan;
input trt :$15. rep$ time$ size;
cards;
Control	1	1	3.0195
Control	2	1	3.1409
Control	3	1	3.1625
Control	4	1	3.2641
Helicopsychidae	1	1	3.1550
Helicopsychidae	2	1	3.0791
Helicopsychidae	3	1	3.2241
Helicopsychidae	4	1	3.2038
Isonychiidae	1	1	3.1393
Isonychiidae	2	1	3.1863
Isonychiidae	3	1	3.2020
Isonychiidae	4	1	3.1577
Perlidae	1	1	3.1495
Perlidae	2	1	3.1567
Perlidae	3	1	3.1158
Perlidae	4	1	3.1306
Heptageniidae	1	1	3.1677
Heptageniidae	2	1	3.2105
Heptageniidae	3	1	3.2258
Heptageniidae	4	1	3.1153
Control	1	2	3.6958
Control	2	2	3.8720
Control	3	2	3.6008
Control	4	2	3.7060
Helicopsychidae	1	2	3.6850
Helicopsychidae	2	2	3.6378
Helicopsychidae	3	2	3.6178
Helicopsychidae	4	2	3.6734
Isonychiidae	1	2	3.4458
Isonychiidae	2	2	3.5676
Isonychiidae	3	2	3.5913
Isonychiidae	4	2	3.5658
Perlidae	1	2	3.3970
Perlidae	2	2	3.4693
Perlidae	3	2	3.4848
Perlidae	4	2	3.3190
Heptageniidae	1	2	3.6132
Heptageniidae	2	2	3.6690
Heptageniidae	3	2	3.6128
Heptageniidae	4	2	3.6558
;
run;
proc print data=ryan;
run;

/****************************Egg size***********************/
/*Create tables for manuscript purposes*/
proc means data=ryan mean stddev stderr min max;
class trt time;
var size;
run;

/*Egg size as a function of time and treatment*/
/*Will take an initial look at model, df, and calculate residuals*/
proc mixed data=ryan PLOTS=ALL;
class trt time;
model size = trt|time / outp=mr;
/*"outp=mr" creates a dataset named "mr" that besides the rest of the data will contain residuals (named "resid" - the PROC MIXED default name)*/
run;

/*Assumption Checking*/
/*1). Checking normality of the residuals*/
proc univariate data=mr normal plot; var resid; run;
/*Data pass Shapiro-Wilk test p=0.1279*/

/*2). Homogeneity of variances*/
/*Must plot residuals versus predicted values*/
proc plot data=mr vpercent=50 hpercent=50; plot resid*pred; run;
/*Scatter plot appears satisfactory based on visual observation (No funneling)*/

/*Side-by-side box plots*/
proc sort data=mr; by trt; run;
proc univariate data=mr normal plot; by trt; var resid; run;
/*Appears homogenous*/
/*Will conduct a Levene's Test as well*/

/*Side-by-side box plots*/
proc sort data=mr; by time; run;
proc univariate data=mr normal plot; by time; var resid; run;
/*Appears homogenous*/
/*Will conduct a Levene's Test as well*/

/*Levene's Test for unequal variance*/
data mr; set mr; res2=resid*resid; run;
/*This creates a new variable "res2" - the squared residuals*/
proc mixed data=mr;
class trt time;
model res2=trt|time;
run;
/*Analysis of squared residuals by Levene's Test indicates homogeneity of variances*/

proc sgpanel data=ryan;
  panelby time /columns=2 rows= 1;
  scatter y = size x = trt;
run;
/*This is just an additional look at the residuals*/

/*Final Analysis assuming normality and equal variances*/
proc mixed data=ryan;
class trt time rep;
model size = trt|time;
run;
/*Interaction term significant p=0.0012*/

proc mixed data=ryan;
class trt time;
model size = trt|time;
lsmeans trt*time / pdiff adjust=tukey slice=(trt time);
run;







