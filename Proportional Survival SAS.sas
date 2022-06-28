data hatch;
input trt :$15. rep$ perclive;
cards;
Control	1	0.560
Control	2	0.818
Control	3	0.409
Control	4	0.318
Helicopsychidae	1	0.696
Helicopsychidae	2	0.476
Helicopsychidae	3	0.217
Helicopsychidae	4	0.476
Isonychiidae	1	0.750
Isonychiidae	2	0.167
Isonychiidae	3	0.125
Isonychiidae	4	0.700
Perlidae	1	0.095
Perlidae	2	0.091
Perlidae	3	0.450
Perlidae	4	0.458
Heptageniidae	1	0.895
Heptageniidae	2	0.174
Heptageniidae	3	0.667
Heptageniidae	4	0.583
;
run;
proc print data=hatch;
run;

/*******************************Hatch Success as Proportional Survival***************/
/*Create a table for manuscript purposes*/
proc means data=hatch mean stddev stderr min max;
class trt;
var perclive;
run;

proc sgpanel data=hatch;
  panelby trt /columns=5 rows= 1;
  scatter y = perclive x = trt;
run;
/*This is just an additional look at the residuals*/

/*Final Analysis*/
/*Analysis assuming homogenous variance*/
proc glimmix data=hatch PLOTS=ALL;
class trt;
model perclive = trt / dist=beta s;
lsmeans trt / pdiff adjust=tukey lines ilink;
run;
/*AIC 4.15, BIC 10.13*/

/*Analysis assuming homogenous variance*/
proc glimmix data=hatch PLOTS=ALL;
class trt;
model perclive = trt / dist=beta s;
random _residual_ / GROUP=trt;
lsmeans trt / pdiff adjust=tukey lines ilink;
run;
/*Did not appear to be a better model*/

/*Analysis assuming hetergeneous variances for guild group*/
data hatch; set hatch; 
	if trt='Control' then gr='1';
	if trt='Helicopsychidae' then gr='2';
	if trt='Heptageniidae' then gr='2';
	if trt='Isonychiidae' then gr='3';
	if trt='Perlidae' then gr='4';
run;
proc print data=hatch;
run;
/*Created groups based on guild ("gr").*/

proc glimmix data=hatch PLOTS=ALL;
class trt gr;
model perclive = trt / dist=beta s;
random _residual_ / GROUP=gr;
lsmeans trt / pdiff adjust=tukey lines ilink;
run;
/*Did not appear to be a better model*/

/*Final Analysis*
/*Analysis assuming homogenous variance and beta-distribution*/
proc glimmix data=hatch PLOTS=ALL;
class trt;
model perclive = trt / dist=beta;
lsmeans trt / pdiff adjust=tukey lines ilink;
run;
/*AIC 4.15, BIC 10.13*/
/*Proportional hatch success is equal among treatments*/

