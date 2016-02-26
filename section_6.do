/* risk of falling into poverty by age and cohort
----- cell means by age and cohort
----- rooms by age and cohort */

clear
*cd "T:\abod"
cd "D:\Home\mbrewer\abi_work\data\working"

set more off
use ../longtimeseries_2015a, clear

* create dummy variables for various demog characteristics
qui do ../demog_indicator_setup
qui do ../bottomdecile_indicator_setup	
ren agefortvlicence age_exact

local if "if inrange(age_exact,25,74)" 

/* cohort */
gen dob = datayear - age_exact
forvalues c = 20(10)80 {
	local c1 = `c'+10
	gen cohort`c' = (dob>= 19`c' & dob < 19`c1')
}

/* age, cohort and risk of being in bottom decile */
foreach r in inc con {
	foreach ms in ahc bhc {
		matrix agerisk_`ms'_`r' = J(51, 7, .)
		local counter=1
		forvalues c = 20(10)80{		
			forvalues a = 1/51 {
				qui su dec`r'`ms' if age_exact == `a'+24 & cohort`c' == 1 [fw=weight], detail
				matrix agerisk_`ms'_`r'[`a', `counter'] = r(mean)
			} /* age */
			local counter = `counter'+1
		} /* cohort */
		svmat agerisk_`ms'_`r'
	}/* measure */
}/* res*/
egen ageindex = seq(), f(25)

* graphs
* - 1. by resource measure, all cohorts on one graph
foreach r in inc con {
	foreach ms in ahc bhc {
		twoway ///
				(lpoly agerisk_`ms'_`r'1 ageindex `if' & agerisk_`ms'_`r'1<0.2, ///
					bw(1) lcolor(black) lpattern(dot) lwidth(thick)) ///
				(lpoly agerisk_`ms'_`r'2 ageindex `if' & agerisk_`ms'_`r'2<0.2, ///
					bw(1) lcolor(black) lpattern(l) lwidth(thick)) ///
				(lpoly agerisk_`ms'_`r'3 ageindex `if' & agerisk_`ms'_`r'3<0.2, ///
					bw(1) lcolor(gs2) lpattern(longdash) lwidth(thick)) ///
				(lpoly agerisk_`ms'_`r'4 ageindex `if' & agerisk_`ms'_`r'4<0.2, ///
					bw(1) lcolor(gs4) lpattern(shortdash_dot) lwidth(thick)) ///
				(lpoly agerisk_`ms'_`r'5 ageindex `if' & agerisk_`ms'_`r'5<0.2, ///
					bw(1) lcolor(gs6) lpattern(dot) lwidth(thick)) ///
				(lpoly agerisk_`ms'_`r'6 ageindex `if' & agerisk_`ms'_`r'6<0.2, ///
					bw(1) lcolor(gs8) lpattern(longdash_dot) lwidth(thick))  ///
			, saving(cohortagerisksmooth_`ms'_`r', replace) ///
			xlabel(25(5)75) ///
			ylabel(0(0.02)0.2) ///
			ytitle("Proportion in bottom decile") ///
			xtitle("Age") ///
			legend ( ///
				label(1 "1920-1929") ///
				label(2 "1930-1939") ///
				label(3 "1940-1949") ///
				label(4 "1950-1959") ///
				label(5 "1960-1969") ///
				label(6 "1970-1979") ///
				) 
			graph export cohortagerisksmooth_`ms'_`r'.png, replace
			
			/* line agerisk_`ms'_`r'1 agerisk_`ms'_`r'2 agerisk_`ms'_`r'3 agerisk_`ms'_`r'4 ///
			agerisk_`ms'_`r'5 agerisk_`ms'_`r'6 /// */
		
	}
}

* mike


/* Mike 
forvalues c = 2/3 {
	foreach r in inc con {
		twoway (lpoly agerisk_ahc_`r'`c' ageindex, ///
					bw(1) lcolor(black) lpattern(l) lwidth(thick)) ///
				(lpoly agerisk_bhc_`r'`c' ageindex, ///
					bw(1) lcolor(gs2) lpattern(longdash) lwidth(thick)), ///
			ytitle("Proportion in bottom decile") ///
			xtitle("Age") ///
			legend(label(1 "Ex. implicit housing") ///
			label(2 "Inc. implicit housing")) 			
			graph export cohort`c'_agerisksmooth_`r'.png, replace
	}
}

*/

/* ******************* */
* cohort, age and housing *
/* ******************* */

matrix cohort_owner = J(51, 7, .)
local counter =1
forvalues c = 20(10)80 {
	forvalues a = 1/51 {
		qui su own_house if age_exact == `a'+24 & cohort`c'==1 [fw=weight]
		if r(N) > 50 {
			matrix cohort_owner[`a', `counter'] = r(mean)
		}
	}
	local counter = `counter'+1
}
svmat cohort_owner

/* mike changed a line below which used to say 
ytitle("Proportion in bottom decile") /// 
*/

line cohort_owner1 cohort_owner2 cohort_owner3 cohort_owner4 cohort_owner5 cohort_owner6 ///
	ageindex if ageindex<=75, saving(cohort_howner, replace) ///
	ytitle("Proportion who own their home") ///
	xtitle("Age") ///
	xlabel(25(5)75) ///
	ylabel(0(0.05)0.8) ///
	legend( ///
	label(1 "1920-1929") ///
	label(2 "1930-1939") ///
	label(3 "1940-1949") ///
	label(4 "1950-1959") ///
	label(5 "1960-1969") ///
	label(6 "1970-1979")) ///
	lpattern(l shortdash_dot dash l longdash_dot dash) ///
	lcolor(black gs2 gs4 gs6 gs8 gs10) ///
	lwidth(medthick medthick medthick medthick medthick medthick)
	graph export cohort_howner.png, replace

* average rooms per person
g roompp = nrooms/numpeeps

*matrix roompp = J(51, 7, .)
matrix rooms= J(51, 7, .)
local counter=1
forvalues c = 20(10)80{		
	forvalues a = 1/51 {
		/*qui su roompp if age_exact == `a'+24 & cohort`c' == 1 [fw=weight], detail
		matrix roompp[`a', `counter'] = r(mean)
		*/
		qui su nrooms if age_exact == `a'+24 & cohort`c' == 1 [fw=weight], detail
		matrix rooms[`a', `counter'] = r(mean)
	} /* age */
	local counter = `counter'+1
} /* cohort */
*svmat roompp
svmat rooms
	
/* mike changed a line below which used to say 
ytitle("Proportion in bottom decile") /// 
*/
line rooms1 rooms2 rooms3 rooms4 rooms5 rooms6 ///
	ageindex if ageindex<=75, saving(cohort_rooms, replace) ///
	ytitle("Rooms per person") ///
	xtitle("Age") ///
	xlabel(25(5)75) ///
	ylabel(0(0.5)6) ///
	legend( ///
	label(1 "1920-1929") ///
	label(2 "1930-1939") ///
	label(3 "1940-1949") ///
	label(4 "1950-1959") ///
	label(5 "1960-1969") ///
	label(6 "1970-1979")) ///
	lpattern(l shortdash_dot dash l longdash_dot dash) ///
	lcolor(black gs2 gs4 gs6 gs8 gs10) ///
	lwidth(medthick medthick medthick medthick medthick medthick)
	graph export cohort_rooms.png, replace
	
* average hhld size

matrix npeep= J(51, 7, .)
matrix medpeep = J(51, 7, .)
local counter=1
forvalues c = 20(10)80{		
	forvalues a = 1/51 {
		qui su numpeeps if age_exact == `a'+24 & cohort`c' == 1 [fw=weight], detail
		matrix npeep[`a', `counter'] = r(mean)
		matrix medpeep[`a', `counter'] = r(p50)
	} /* age */
	local counter = `counter'+1
} /* cohort */
*svmat roompp
svmat npeep
svmat medpeep
	
line npeep1 npeep2 npeep3 npeep4 npeep5 npeep6 ///
	ageindex if ageindex<=75, saving(av_peep, replace) ///
	ytitle("Mean Household Size") ///
	xtitle("Age") ///
	xlabel(25(5)75) ///
	ylabel(0(0.5)4) ///
	legend( ///
	label(1 "1920-1929") ///
	label(2 "1930-1939") ///
	label(3 "1940-1949") ///
	label(4 "1950-1959") ///
	label(5 "1960-1969") ///
	label(6 "1970-1979")) ///
	lpattern(l shortdash_dot dash l longdash_dot dash) ///
	lcolor(black gs2 gs4 gs6 gs8 gs10) ///
	lwidth(medthick medthick medthick medthick medthick)
	graph export av_peep.png, replace
	

	
/*
/* age, cohort and risk of being in bottom decile - by housing tenure */
* cohort 20, 30, 40
foreach r in inc con {
	foreach ms in ahc bhc {
		matrix agerisk_`ms'_`r'_nonowner = J(26, 3, .)
		matrix agerisk_`ms'_`r'_owner = J(26, 3, .)
		local counter=1
		forvalues c = 20(10)40 {
			forvalues a = 1/26 {
				qui su dec`r'`ms' if age_exact == `a'+49 & cohort`c' == 1 & own_house==1 [fw=weight], detail
				matrix agerisk_`ms'_`r'_owner[`a', `counter'] = r(mean)
				
				qui su dec`r'`ms' if age_exact == `a'+49 & cohort`c' == 1 & own_house==0 [fw=weight], detail
				matrix agerisk_`ms'_`r'_nonowner[`a', `counter'] = r(mean)
			} /* age */
		local counter = `counter'+1
		} /* cohort*/
		svmat agerisk_`ms'_`r'_nonowner
		svmat agerisk_`ms'_`r'_owner
	}/* measure */
}/* res*/

egen ageindex_old = seq(), f(50)
foreach r in con inc {
		forvalues c = 1/3 {
			line agerisk_ahc_`r'_owner`c' agerisk_ahc_`r'_nonowner`c' ///
				agerisk_bhc_`r'_owner`c' agerisk_bhc_`r'_nonowner`c' ///
				ageindex_old if ageindex<=80, saving(agerisk_byhousing_`r'_`c', replace) ///
				ytitle("Proportion in bottom decile") ///
				xtitle("Age") ///
				legend(label(1 "Home Owners exc. housing") ///
				label(2 "Non Home Owners exc. housing") ///
				label(3 "Home Owners inc. housing") ///
				label(4 "Non Home Owners inc. housing")) ///
				lpattern(l dash l dash) ///
				lcolor(black black gs8 gs8) ///
				lwidth(medthick medthick medthick medthick) 
			
		}
}
	
	
