/* 
	This do file records classes households according to whether poor by an income 
	measure, consumption or both. 	
	Then looks at demographic differences of these groups
	-- statistcial sig in correlation of measures 
*/

* set up
clear
cd "T:\abod"
use "longtimeseries_2015a", clear

global resources equivinc equivcon equivincahc equivconahc

do bottomdecile_indicator_setup

/*
/* KENDALL's TAU */
forvalues y = 1979(30)2009 {
	ktau $resources if datayear==`y', mat stats(taua p)
}

/* OVERLAP IN GROUPS FIG */
matrix dectype_ahc_rates = J(31,4, .)
matrix dectype_bhc_rates = J(31,4, .)
forvalues yr = 1/31 {
	local y = `yr' + 1978
	foreach type in dectype_bhc  dectype_ahc {
		forvalues i = 1/4 {
			qui su _`type'`i' if year == `y' [fw=peepweight]
			matrix `type'_rates[`yr', `i'] = 100*r(mean)
		}
	}
	
}
svmat dectype_ahc_rates
svmat dectype_bhc_rates
egen prd = seq(), f(1979)
line dectype_bhc_rates4 dectype_ahc_rates4 prd if prd <= 2009, ///
saving(overlap, replace) ///
		ytitle("Percentage in bottom decile (%)") ///
		xtitle("Year") ///
		legend(label(1 "inc. Housing") ///
			label(2 "exc. Housing")) ///
		lpattern(l _) ///
		lwidth(medthick medthick) ///
		lcolor(black gs8 )
graph export overlap.png, replace
drop dectype_ahc_rates* dectype_bhc_rates*	
*/
/* MOTIVATING FIGURES */
g kidweight = numkid*weight
g waweight = numwa*weight
g penweight = numpen*weight
g adultweight = waweight+penweight

foreach type in inc con {
	foreach meas in bhc ahc {
		matrix dec`type'`meas'_comp = J(31,4, .)
	}
}
	
forvalues yr = 1/31 {
	local y = `yr' + 1978
	foreach type in inc con {
		foreach meas in bhc ahc {
		
			qui su peepweight if dec`type'`meas'==1 & year == `y'
			local totpeep = r(sum)
			
			local place = 1
			foreach group in kid wa pen {
				qui su `group'weight if dec`type'`meas'==1 & year == `y'
				matrix dec`type'`meas'_comp[`yr',`place'] = r(sum)/`totpeep'	
				local place = `place' + 1
			} /* group */
			
			qui su waweight if dec`type'`meas'==1 & year == `y' & educ>2
			matrix dec`type'`meas'_comp[`yr',4] = r(sum)/`totpeep'	
			
		} /* values 2/3 */
	} /* type */
} /* year */

* graphing 
foreach type in inc con {
	foreach meas in bhc ahc {
		svmat dec`type'`meas'_comp
	}
}


* kid, wa, pen, low ed, high ed
foreach type in inc con {
	foreach meas in bhc ahc {
		line dec`type'`meas'_comp1 dec`type'`meas'_comp2 dec`type'`meas'_comp3 prd if prd<=2009, ///
				saving(dec`type'`meas'_comp, replace) ///
				ytitle("Proportion of bottom decile") ///
				xtitle("Year") ///
				legend(label(1 "Children") ///
					label(2 "Working Age") ///
					label(3 "Pensioner")) ///
				lpattern(_ l l) ///
				lwidth(medthick medthick medthick) ///
				lcolor(black black gs8)
		graph export dec`type'`meas'_comp.png, replace
	}
}	

forvalue s = 1/4 {
	line decincbhc_comp`s' decconbhc_comp`s' decincahc_comp`s' decconahc_comp`s' prd if prd<=2009, ///
				saving(dec`type'`meas'_comp`s', replace) ///
				ytitle("Proportion of bottom decile") ///
				xtitle("Year") ///
				legend(label(1 "Income inc. housing") ///
					label(2 "Consumption inc. housing") ///
					label(3 "Income exc. housing") ///
					label(4 "Consumption exc. housing")) ///
				lpattern(l l _ _) ///
				lwidth(medthick medthick medthick medthick) ///
				lcolor(black gs8 black gs8)
	graph export dec`type'`meas'_comp`s'.png, replace
}

