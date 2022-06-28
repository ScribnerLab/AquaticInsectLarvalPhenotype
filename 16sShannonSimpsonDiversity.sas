DATA walquist;
input trt :$15. time$ rep$ simp shan;
cards;
Control	2	1	0.9402	4.3
Control	2	2	0.9398	4.216
Control	2	3	0.9554	4.251
Control	2	4	0.9593	4.472
Helicopsychidae	2	1	0.9322	4.007
Helicopsychidae	2	2	0.9472	4.361
Helicopsychidae	2	3	0.9449	4.1
Helicopsychidae	2	4	0.9361	4.08
Heptageniidae	2	2	0.9644	4.579
Heptageniidae	2	3	0.9687	4.663
Heptageniidae	2	4	0.97	4.759
Isonychiidae	2	1	0.9488	4.295
Isonychiidae	2	2	0.9227	4.022
Isonychiidae	2	3	0.9402	4.183
Isonychiidae	2	4	0.9498	4.166
Perlidae	2	1	0.8609	3.408
Perlidae	2	2	0.8939	3.801
Perlidae	2	4	0.9301	3.937
;
run;
proc print data=walquist;
run;

proc means data=walquist stderr mean min max;
class trt;
var shan;
run;

proc mixed data=walquist;
class trt;
model shan=trt / outp=mr;
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

data mr; set mr; res2=resid*resid; /*This creates a new variable "res2" - the squared residuals*/
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
/*trt p<0.0001, F = 14.72, DF 4,13*/
/*Reject the null: An effect of treatment on 16 Shannon Diversity at Time 2*/

proc glimmix data=walquist;
class trt;
model shan = trt;
lsmeans trt / adjust=tukey lines pdiff;
run;
