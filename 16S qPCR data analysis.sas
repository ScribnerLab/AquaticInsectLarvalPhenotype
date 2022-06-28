Data qpcr;
input trt $:15. logcn;
cards;
Control	7.685
Control	7.666
Control	7.781
Control	7.718
Helicopsychidae	7.741
Helicopsychidae	7.834
Helicopsychidae	7.404
Helicopsychidae	7.742
Heptageniidae	7.801
Heptageniidae	7.723
Heptageniidae	7.814
Heptageniidae	7.794
Isonychiidae	7.753
Isonychiidae	7.957
Isonychiidae	7.990
Isonychiidae	7.832
Perlidae	8.238
Perlidae	7.983
Perlidae	7.812
Perlidae	8.148
;
run;
proc print data=qpcr;
run;

/*Data are expressed as log copy number per egg*/
proc means data=qpcr stderr mean min max;
class trt;
var logcn;
run;

/*Assumption checking - Normality for qPCR Time 2 Copy Number per Egg*/
proc mixed data=qpcr;
class trt;
model logcn = trt/ outp=mr;
/*"outp=mr" creates a dataset named "mr" that besides the rest of the data will contain residuals (named "resid" - the PROC MIXED default name)*/
run;
/*Checking normality of the residals*/

proc univariate data=mr normal plot; var resid; run;
/*Data appear normal based on 4 of 4 Tests for normality as well as stem and leaf and normality plots*/

/*Checking for unequal variances*/
/*Must plot residuals versus predicted values*/
proc plot data=mr vpercent=50 hpercent=50; plot resid*pred; run;
/*Scatter plot appears satisfactory, slight fanning*/

/*Side-by-side box plots*/
proc sort data=mr; by trt; run;
proc univariate data=mr normal plot; by trt; var resid; run;
/*Appears satisfactory*/

data mr; 
set mr; 
res2=resid*resid; /*This creates a new variable "res2" - the squared residuals*/
run;
proc mixed data=mr;
class trt;
model res2=trt;
run;
/*Analysis of squared residuals by Levene's Test indicates homogeneity of variances*/

/*Model assuming homogenity in variance*/
proc mixed data=qpcr;
class trt;
model logcn = trt;
run;

/*Results:
Type 3 Tests of Fixed Effects 
Effect Num DF Den DF F Value Pr > F 
trt 4 15 4.98 0.0093 
*/

proc mixed data=qpcr;
class trt;
model logcn = trt;
lsmeans trt;
run;
