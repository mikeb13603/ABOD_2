* compute ci for measures of poverty and inequality (section 4)

* set up
clear
set more off
cd "T:\abod"


* define bootstrap program
global resources equivinc equivcon equivincahc equivconahc
capture program drop myboot
program define myboot, rclass
args equivinc equivcon equivincahc equivconahc peepweight
	preserve
		bsample, w(`peepweight')
		qui su `peepweight'
		local totalN = r(sum)
		return scalar sum = r(sum)
		
		* equivinc
		su `equivinc' [fw=`peepweight'], detail			
		return scalar ie50_equivinc = r(p50)/r(p10)
		return scalar ie90_equivinc = r(p90)/r(p10)
		gen windic = (`equivinc' <= 0.6*r(p50))*`peepweight'
		qui su windic			
		return scalar pov_equivinc = 100*r(sum)/`totalN' 
		drop windic
		
		* equivcon
		su `equivcon' [fw=`peepweight'], detail			
		return scalar ie50_equivcon = r(p50)/r(p10)
		return scalar ie90_equivcon = r(p90)/r(p10)
		gen windic = (`equivcon' <= 0.6*r(p50))*`peepweight'
		qui su windic			
		return scalar pov_equivcon = 100*r(sum)/`totalN' 
		drop windic
		
		* equivincahc
		su `equivincahc' [fw=`peepweight'], detail			
		return scalar ie50_equivincahc = r(p50)/r(p10)
		return scalar ie90_equivincahc = r(p90)/r(p10)
		gen windic = (`equivincahc' <= 0.6*r(p50))*`peepweight'
		qui su windic			
		return scalar pov_equivincahc = 100*r(sum)/`totalN' 
		drop windic
		
		* equivconahc
		su `equivconahc' [fw=`peepweight'], detail			
		return scalar ie50_equivconahc = r(p50)/r(p10)
		return scalar ie90_equivconahc = r(p90)/r(p10)
		gen windic = (`equivconahc' <= 0.6*r(p50))*`peepweight'
		qui su windic			
		return scalar pov_equivconahc = 100*r(sum)/`totalN' 
		drop windic

	restore
end	

* 1000 draws of statistics 
forvalues y = 1979/2009 {
	use "longtimeseries_2015a", clear
	keep if datayear == `y'
	
	bootstrap  ie50_equivinc = r(ie50_equivinc) ie90_equivinc = r(ie90_equivinc) pov_equivinc = r(pov_equivinc) ///
	ie50_equivcon = r(ie50_equivcon) ie90_equivcon = r(ie90_equivcon) pov_equivcon = r(pov_equivcon) ///
	ie50_equivincahc = r(ie50_equivincahc) ie90_equivincahc = r(ie90_equivincahc) pov_equivincahc = r(pov_equivincahc) ///
	ie50_equivconahc = r(ie50_equivconahc) ie90_equivconahc = r(ie90_equivconahc) pov = r(pov_equivconahc), ///
	reps(1000) saving(bootstrap_iepov_`y', replace): myboot equivinc equivcon equivincahc equivconahc peepweight

} 


* into one file
local bootstrapdir "T:abod\bootstrap"
forvalues y = 1979/2009 {
	use bootstrap_iepov_`y', clear
	ren pov pov_equivconahc
	gen id = _n
	gen t = `y'
	save bootstrap_iepov_`y', replace
} 

use bootstrap_iepov_1979
forvalues y = 1980/2009 {
	app using bootstrap_iepov_`y'
}
save bootstrap_all, replace 

foreach thing in equivinc equivcon equivincahc equivconahc {
	foreach meas in ie50 ie90 pov {
		matrix bounds_`thing'_`meas' = J(31, 2, .)
		forvalues y = 1/31 {
			local yr = 1978+`y'
			su `meas'_`thing' if t==`yr', detail
			matrix bounds_`thing'_`meas'[`y', 1] = r(p1)
			matrix bounds_`thing'_`meas'[`y', 2] = r(p99)
		}
		svmat bounds_`thing'_`meas'
	}
}

egen per = seq(), f(1979) t(2009)
keep per bounds*
drop if missing(bounds_equivinc_pov1)
save pov_ie_bounds, replace
