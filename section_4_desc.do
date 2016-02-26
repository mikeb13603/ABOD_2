* This .do computes the descriptive statistics on income and consumption 
* distributions (Section 4)
*  ---- Underlies Table of Summary Statistics (Table 1)
* --- Growth Incidence Curves (Figures 1 and 2)

* set up
clear
cd "T:\abod"
local datadir "T:\abod"
local picdir "T:\abod"

use "`datadir'\longtimeseries", clear

/* remove variables not analysed  */
drop bhcpoor50 -nondurpoor70 rent-ctax
save "data_small.dta", replace

* resources looked at --- ask Cormac for precise definitions
global resources equivinc equivcon equivincahc equivconahc
/*
/* FOR TABLE OF SUMMARY STATS IN 1979,1989,1999,2009 */
forvalues y = 1979(10)2009 {	
	matrix summary_`y' = J(4, 11, .)
	local counter =1
	foreach resource of varlist $resources {
		qui su `resource' if datayear==`y' [fw=peepweight], detail	
		matrix summary_`y'[`counter', 1] = r(mean)
		matrix summary_`y'[`counter', 2] = r(sd)
		matrix summary_`y'[`counter', 3] = r(p5)
		matrix summary_`y'[`counter', 4] = r(p10)
		matrix summary_`y'[`counter', 5] = r(p25)
		matrix summary_`y'[`counter', 6] = r(p50)
		matrix summary_`y'[`counter', 7] = r(p75)
		matrix summary_`y'[`counter', 8] = r(p90)
		matrix summary_`y'[`counter', 9] = r(p95)
		matrix summary_`y'[`counter', 10] = r(skewness)
		matrix summary_`y'[`counter', 11] = r(Var)
		local counter = `counter'+1 
	}
}


/* 	EQUALITY OF VARIANCE */
foreach resource of varlist $resources {
		gen log_`resource' = log(`resource')
	}
matrix test_=J(2, 8, .)
local counter=1
forvalues y = 1979(30)2009 {	
	g tmp1 = log_equivinc if datayear == `y'
	g tmp2 = log_equivcon if datayear == `y'
	sdtest tmp1 == tmp2
	matrix test_[`counter', 1] = r(p)
	matrix test_[`counter', 2] = r(F)
	matrix test_[`counter', 3] = r(df_1)
	matrix test_[`counter', 4] = r(df_2)
	drop tmp*
	g tmp1 = log_equivincahc if datayear == `y'
	g tmp2 = log_equivconahc if datayear == `y'
	sdtest tmp1 == tmp2
	matrix test_[`counter', 5] = r(p)
	matrix test_[`counter', 6] = r(F)
	matrix test_[`counter', 7] = r(df_1)
	matrix test_[`counter', 8] = r(df_2)
	drop tmp*
	local counter = `counter'+1
}


/* KS TESTS */
gen dset = 1
append using "data_small.dta"
replace dset = 2 if missing(dset)
replace equivinc = equivcon if dset ==2 /* for ks test */
replace equivincahc = equivconahc if dset ==2 /* for ks test */

matrix kstest_D=J(4, 2, .)
matrix kstest_p=J(4, 2, .)
local counter=1
forvalues y = 1979(10)2009 {	
	ksmirnov equivinc if datayear == `y', by(dset)
	matrix kstest_D[`counter', 1] = r(D)
	matrix kstest_p[`counter', 1] = r(p)
	
	ksmirnov equivincahc if datayear==`y', by(dset)
	matrix kstest_D[`counter', 2] = r(D)
	matrix kstest_p[`counter', 2] = r(p)
	
	local counter = `counter'+1
}		
drop if dset==2
drop dset
*/
/* GROWTH INCIDENCE CURVES */
* 1981-1985, 1986-1990, 1991-1995, 1996-2000, 2001-2005, 2006-2009
foreach resource of varlist $resources {
	foreach y of num 1979 1981 1985 1986 1990 1991 1995 1996 2000 2001 2005 2006 2009 {
		pctile pct_`resource'_`y'=`resource' if datayear ==`y' [fw=peepweight], nq(100)
	}
}

* calculate growth rate 
local counter = 0
foreach resource of varlist $resources {
	local `counter' = `counter'+1
	forvalue y = 1/7 {
	
		if `y'==1 {
			local s_ = 1981
			local e_ = 1985
		}
		if `y'==2 {
			local s_ = 1986
			local e_ = 1990
		}
		if `y'==3 {
			local s_ = 1991
			local e_ = 1995
		}
		if `y'==4 {
			local s_ = 1996
			local e_ = 2000
		}
		if `y'==5 {
			local s_ = 2001
			local e_ = 2005
		}
		if `y'==6 {
			local s_ = 2006
			local e_ = 2009
		}
		if `y'==7 {
			local s_ = 1979
			local e_ = 2009
		}
		local N = `e_' - `s_'
		gen growth_`resource'_`y' =100*((pct_`resource'_`e_'/pct_`resource'_`s_')^(1/`N') - 1) 
		if `counter' == 1 la var growth_`resource'_`y' "Income inc. imputed housing, `s_' - `e_'"
		if `counter' == 2 la var growth_`resource'_`y' "Consumption inc. imputed housing, `s_' - `e_'"
		if `counter' == 3 la var growth_`resource'_`y' "Income exc. imputed housing, `s_' - `e_'"
		if `counter' == 4 la var growth_`resource'_`y' "Consumption exc. imputed housing, `s_' - `e_'"
		
	}
}


* graphing 
keep if growth_equivinc_1 ~= .
egen perc = seq(), f(1) t(99)

forvalue y = 1/7 { /* at each time period */
	
		if `y'==1 {
			local s_ = 1981
			local e_ = 1985
		}
		if `y'==2 {
			local s_ = 1986
			local e_ = 1990
		}
		if `y'==3 {
			local s_ = 1991
			local e_ = 1995
		}
		if `y'==4 {
			local s_ = 1996
			local e_ = 2000
		}
		if `y'==5 {
			local s_ = 2001
			local e_ = 2005
		}
		if `y'==6 {
			local s_ = 2006
			local e_ = 2009
		}
		if `y'==7 {
			local s_ = 1979
			local e_ = 2009
		}
		line growth_equivinc_`y' growth_equivcon_`y' growth_equivincahc_`y' ///
				growth_equivconahc_`y' perc if perc>=5 & perc<=95, ///
				saving(gic_`y', replace) ///
		ytitle("Average annual growth rate (%)") ///
		xtitle("Percentile of resource distribution") ///
		legend(label(1 "Income inc. housing") ///
			label(2 "Consumption inc. housing") ///
			label(3 "Income exc. housing") ///
			label(4 "Consumption exc. housing")) ///
		lpattern(l l _ _) ///
		lwidth(medthick medthick medthick medthick) ///
		lcolor(black gs8 black gs8)
		graph export gic_`y'.png, replace
}




/* NUMBER OF ROOMS */
g roompp = nrooms/numpeeps
matrix roompp =J(31, 1, .)
local counter=1
forvalue y = 1979/2009 {
	qui su roompp if datayear==`y' [fw=peepweight]
	matrix roompp[`counter', 1]= r(mean)
	local counter=`counter'+1
}
svmat roompp

egen prd = seq(), f(1979) t(2009)
line roompp1 prd if prd <= 2000, ///
	saving(rooms, replace) ///
		ytitle("Average rooms per person") ///
		xtitle("Year") ///
		lpattern(l) ///
		lwidth(medthick) ///
		lcolor(black)
graph export rooms_pp.png
