data walquist;
input trt :$15. rep$ time$ simp shan;
cards;
Control	1	2	0.557	1.453
Control	2	2	0.546	1.430
Control	3	2	0.520	1.360
Control	4	2	0.508	1.305
Heptageniidae	1	2	0.454	1.148
Heptageniidae	2	2	0.478	1.199
Heptageniidae	3	2	0.516	1.336
Heptageniidae	4	2	0.440	1.057
Isonychiidae	1	2	0.494	1.232
Isonychiidae	2	2	0.562	1.418
Isonychiidae	3	2	0.621	1.377
Isonychiidae	4	2	0.435	1.071
Perlidae	1	2	0.584	1.516
Perlidae	2	2	0.583	1.402
Perlidae	3	2	0.602	1.715
Perlidae	4	2	0.592	1.388
Helicopsychidae	1	2	0.451	1.054
Helicopsychidae	2	2	0.631	1.705
Helicopsychidae	3	2	0.464	1.172
Helicopsychidae	4	2	0.459	1.133
;
run;
proc print data = walquist;
run;

proc means data=walquist stderr mean min max;
class trt;
var shan;
run;

/*Assumption checking - Normality for Shannon Diversity Index*/
proc mixed data=walquist;
class trt;
model shan = trt/ outp=mr;
/*"outp=mr" creates a dataset named "mr" that besides the rest of the data will contain residuals (named "resid" - the PROC MIXED default name)*/
run;
/*Checking normality of the residuals*/

proc univariate data=mr normal plot; var resid; run;
/*Data appear normal based on 4 of 4 Tests for normality as well as stem and leaf and normality plots*/

/*Checking for unequal variances*/
/*Must plot residuals versus predicted values*/
proc plot data=mr vpercent=50 hpercent=50; plot resid*pred; run;
/*Scatter plot appears satisfactory*/

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


/*Will analyze data assuming homogeneity in variance*/ 
proc mixed data=walquist;
class trt;
model shan = trt;
run;
