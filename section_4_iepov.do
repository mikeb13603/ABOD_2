* compute measures of poverty and inequality (section 4)

* set up
clear
cd "T:\abod"
use "longtimeseries_2015a", clear

global resources equivinc equivcon equivincahc equivconahc

* relative poverty rate and inequality 
matrix relpoverty = J(31,4,.)
matrix inequal50 = J(31,4,.)
matrix inequal90 = J(31,4,.)

forvalues year = 1979(1)2009 {
	local j = 1
	qui su peepweight if datayear == `year'
	local totalN = r(sum)
	local y = `year' - 1978
	foreach resource of varlist $resources {
		qui su `resource' if datayear==`year' [fw=peepweight], detail	
		matrix inequal50[`y', `j'] = r(p50)/r(p10)
		matrix inequal90[`y', `j'] = r(p90)/r(p10)

		gen windic = (`resource' <= 0.6*r(p50))*peepweight if datayear==`year'		
		qui su windic if datayear==`year'
		matrix relpoverty[`y', `j'] = 100*r(sum)/`totalN' 
		drop windic
		
		local j = `j' +1
	}
}
svmat inequal90
svmat inequal50
svmat relpoverty
keep inequal* relpov*
g n = _n
keep if n <=31
egen per = seq(), f(1979) t(2009)
merge 1:1 per using pov_ie_bounds

save pov_ie_bounds, replace

* graphing 
forvalues y = 1/3 {
	use bounds_data_1, clear
	line var3 var6 var2 var4 var5 var7 var1, ///
		ytitle("50-10 Ratio") ///
		xtitle("Year") ///
		ysc(r(0.1 0.3)) ///
		legend(order(1 "Income" 2 "Consumption")) ///
		lpattern(l l dash dash dash dash) ///
		lwidth(medthick medthick) ///
		lcolor(black gs8 black black gs8 gs8)
	graph export ihc_3.png, replace
		
	line var9 var12 var8 var10 var11 var13 var1, ///
		ytitle("50-10 Ratio") ///
		xtitle("Year") ///
		ysc(r(0.1 0.3)) ///
		legend(order(1 "Income" 2 "Consumption")) ///
		lpattern(l l dash dash dash dash) ///
		lwidth(medthick medthick) ///
		lcolor(black gs8 black black gs8 gs8)
	graph export xhc_3.png, replace
	
	
}
/*
* graphing 
forvalues y = 1(2)3 {
	local y=1
	local y_1 = `y'+1
	line inequal90`y' inequal90`y_1' ///
		per if per <= 2009, ///
		ytitle("90-10 Ratio") ///
		xtitle("Year") ///
		legend(label(1 "Income") ///
			label(2 "Consumption")) ///
		lpattern(l l) ///
		lwidth(medthick medthick) ///
		lcolor(black gs8) ///
		ysc(r(3.5 6))
	graph export ie90_`y'.png, replace
		
	line inequal50`y' inequal50`y_1' per, ///
	saving(inequal50_`y', replace) ///
		ytitle("50-10 Ratio") ///
		xtitle("Year") ///
		legend(label(1 "Income") ///
			label(2 "Consumption")) ///
		lpattern(l l) ///
		lwidth(medthick medthick) ///
		ysc(r(1.7 2.7)) ///
		lcolor(black gs8)
	graph export ie50_`y'.png, replace
	
		local y=1
	local y_1 = `y'+1
	line relpoverty`y' relpoverty`y_1' per, ///
	saving(relpov_`y', replace) ///
		ytitle("Relative poverty rate (%)") ///
		xtitle("Year") ///
		legend(label(1 "Income") ///
			label(2 "Consumption")) ///
		lpattern(l l) ///
		lwidth(medthick medthick) ///
		lcolor(black gs8) ///
		ysc(r(11 27))
}
