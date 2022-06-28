data size;
input trt :$15. rep TL YSA;
cards;
Control	1	12.270	7.384
Control	2	13.081	7.794
Control	3	12.658	7.950
Control	4	12.849	7.612
Helicopsychidae	1	12.952	8.170
Helicopsychidae	2	12.672	7.976
Helicopsychidae	3	11.599	7.147
Helicopsychidae	4	13.101	7.610
Isonychiidae	1	12.843	7.524
Isonychiidae	2	11.311	7.467
Isonychiidae	3	11.034	7.727
Isonychiidae	4	12.872	7.788
Perlidae	1	11.351	5.850
Perlidae	2	11.017	6.953
Perlidae	3	11.726	7.100
Perlidae	4	11.235	6.901
Heptageniidae	1	13.490	7.727
Heptageniidae	2	12.433	7.410
Heptageniidae	3	12.670	7.825
Heptageniidae	4	13.002	7.731
;
run;
proc print data=size;
run;

/**********************************Total Length at Hatch*************************/
/*Create a table for manuscript purposes*/
proc means data=size mean stddev stderr min max;
class trt;
var TL;
run;




data ryan;
input trt :$15. rep$ YSA;
cards;
Control	1	7.384
Control	2	7.794
Control	3	7.950
Control	4	7.612
Helicopsychidae	1	8.170
Helicopsychidae	2	7.976
Helicopsychidae	3	7.147
Helicopsychidae	4	7.610
Isonychiidae	1	7.524
Isonychiidae	2	7.467
Isonychiidae	3	7.727
Isonychiidae	4	7.788
Perlidae	1	5.850
Perlidae	2	6.953
Perlidae	3	7.100
Perlidae	4	6.901
Heptageniidae	1	7.727
Heptageniidae	2	7.410
Heptageniidae	3	7.825
Heptageniidae	4	7.731
;
run;
proc print data=ryan;
run;

/*Rep 1 for Predator (Perlidae) was removed due to overdispersion*/
/*Perlidae	1	5.850	0.095	4.00/*
/*Data are analyzed without this replicate*/

/****************************Yolk-sac Area***********************/
/*Create tables for manuscript purposes*/
proc means data=ryan mean stddev stderr min max;
class trt;
var YSA;
run;

/*Egg size as a function of time and treatment*/
/*Will take an initial look at model, df, and calculate residuals*/
proc mixed data=ryan PLOTS=ALL;
class trt;
model YSA = trt / outp=mr;
/*"outp=mr" creates a dataset named "mr" that besides the rest of the data will contain residuals (named "resid" - the PROC MIXED default name)*/
run;

/*Assumption Checking*/
/*1). Checking normality of the residuals*/
proc univariate data=mr normal plot; var resid; run;
/*Data pass Shapiro-Wilk test p=0.0958*/

/*2). Homogeneity of variances*/
/*Must plot residuals versus predicted values*/
proc plot data=mr vpercent=50 hpercent=50; plot resid*pred; run;
/*Scatter plot appears satisfactory based on visual observation (No funneling)*/

/*Side-by-side box plots*/
proc sort data=mr; by trt; run;
proc univariate data=mr normal plot; by trt; var resid; run;
/*Appears homogenous*/
/*Will conduct a Levene's Test as well*/

/*Levene's Test for unequal variance*/
data mr; set mr; res2=resid*resid; run;
/*This creates a new variable "res2" - the squared residuals*/
proc mixed data=mr;
class trt;
model res2=trt;
run;
/*Analysis of squared residuals by Levene's Test indicates homogeneity of variances*/
/*p=0.2376*/

/*Final Analysis assuming normality and equal variances*/
proc mixed data=ryan;
class trt;
model YSA = trt;
lsmeans trt / pdiff adjust=tukey;
run;
/*TRT significant p=0.0046*/
