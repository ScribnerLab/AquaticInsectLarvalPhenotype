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

/*Size at Hatch*/
/*Will take an initial look at model, degrees of freedom, and get residuals calculated*/
proc mixed data=size PLOTS=ALL;
class trt;
model TL = trt / outp=mr;
/*"outp=mr" creates a dataset named "mr" that besides the rest of the data will contain residuals (named "resid" - the PROC MIXED default name)*/
run;


/*Assumption Checking*/
/*1). Checking normality of the residuals*/
proc univariate data=mr normal plot; var resid; run;
/*Data pass Shapiro-Wilk test p=0.6802*/

/*2). Homogeneity of variances*/
/*Must plot residuals versus predicted values*/
proc plot data=mr vpercent=50 hpercent=50; plot resid*pred; run;
/*Scatter plot appears satisfactory based on visual observation (No funneling or overdispersion)*/

/*Side-by-side box plots*/
proc sort data=mr; by trt; run;
proc univariate data=mr normal plot; by trt; var resid; run;
/*Appears there may be some heterogeneity in variance*/
/*Will conduct a Levene's Test as well*/

/*Levene's Test for unequal variance*/
data mr; set mr; res2=resid*resid; run;
/*This creates a new variable "res2" - the squared residuals*/
proc mixed data=mr;
class trt;
model res2=trt;
run;
/*Analysis of squared residuals by Levene's Test indicates Heterogeneity of variances*/
/*Results p=0.0053*/

proc sgpanel data=size;
  panelby trt /columns=5 rows= 1;
  scatter y = TL x = trt;
run;
/*This is just an additional look at the residuals*/

/*Here is a quick way to view plots of normality as well as varaince in residuals*/
/*An examination of the degrees of freedom, normality, and homogeneity of variances*/
proc mixed data=size plots=all;
class trt rep;
model TL=trt/ s ;
/*The "PLOTS=all" and repeated statement can evaluate the normality and homogeneity of residuals similar to a Levene's Test*/
run;
/*AIC 36.5, BIC 37.2*/
/*Based on Covariance Parameter Estimates, will try analysis two ways*/
/*1).  Compare using hetergeneous variances for each treatment*/
/*2).  Compare using heterogeneous variances for certian treatments*/
/*Will evaluate best model based on AIC and BIC values*/

/*Analysis assuming heterogeneous variances for treatment*/
proc mixed data=size;
class trt;
model TL = trt / ddfm=satterthwaite;
repeated / GROUP=trt;
run;
/*AIC=38.7 BIC=43.6*/

/*Analysis assuming hetergeneous variances for guild group*/
data size; set size; 
	if trt='Control' then gr='1';
	if trt='Helicopsychidae' then gr='2';
	if trt='Heptageniidae' then gr='2';
	if trt='Isonychiidae' then gr='3';
	if trt='Perlidae' then gr='4';
run;
proc print data=size;
run;
proc mixed data=size;
class trt gr;
model TL = trt / ddfm=satterthwaite;
repeated / GROUP=gr;
run;
/*AIC=37.1 BIC=41.1*/
/*This does not appear to be a better model*/
/*Will analyze data assuming homogeneity in variances*/

proc mixed data=size;
class trt;
model TL = trt;
lsmeans trt / pdiff adjust=tukey;
run;




