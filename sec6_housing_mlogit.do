/* Demographics & difference between measures that include/exclude implicit housing
- multinomial logit regressions for sec 6 (& appendix) */  

clear
*cd "T:\abod"
cd "D:\Home\mbrewer\abi_work\data\working"

set more off

use ../longtimeseries_2015a, clear

* create dummy variables for various demog characteristics
qui do ../demog_indicator_setup
qui do ../bottomdecile_indicator_setup	


cap log close
log using "IHC_vs_XHC", text replace

*ren _educat2 educat2
*ren educat3 _educat3
	
/* old spec
local riskfactors educat* agenr* hohworkless hohselfemp 
*/
*local riskfactors 		educat* agenr* hohworkless hohselfemp couple single 	 kid_dummy /*own_house*/ 
local riskfactors_mike  educat* agenr* hohworkless hohselfemp single multiadult  kid_dummy /*own_house*/

*log using "C:\Users\abigail_a\Dropbox\mikecormac\abi_work\logit\demog_mlogit_ahc_bhcyear.log", replace text
* main text - 2009, income 
foreach thing in inc con {
	local y = 2009
	qui mlogit `thing'_type `riskfactors_mike' if insample == 1 & datayear <= `y' & datayear>= `y'-10, rrr b(1) vce(cl datayear)
	est sto mlogit1
	/*estout mlogit1,  replace eform cells(b(star fmt(3)) se(fmt(3))) ///
	style(tex) s(ll chi2 N) label legend varlabel(_cons Constant) unstack posthead("") prefoot("") postfoot("")
	*/
	di in yellow %33s "Bottom decile by `thing' in `y'" _skip(3) 
	di in yellow %33s "Risk Factor" _continue _skip(3) "{c |}" 
	*di in yellow %12s "BHC Pov." _continue _skip(3) 
	*di in yellow %12s "AHC Pov." _continue _skip(3) 
	di in yellow %12s "IHC Pov." _continue _skip(3) /* mike */ 
	di in yellow %12s "XHC Pov." _continue _skip(3) 
	di in yellow %12s "Diff" _skip(3) 
	di in yellow %12s "F" _skip(3) 
	di in text "{hline 90}" 
	foreach var of varlist `riskfactors_mike' {
		qui: {
			  test [2]`var'
			  if r(p)<=.01            local incsigstars "***" 
			  if r(p)>.01 & r(p)<=.05 local incsigstars "** " 
			  if r(p)>.05 & r(p)>=.1  local incsigstars "*  " 
			  if r(p)>.1 			  local incsigstars "   " 
			  
			  test [3]`var'
			  if r(p)<=.01            local consigstars "***" 
			  if r(p)>.01 & r(p)<=.05 local consigstars "** " 
			  if r(p)>.05 & r(p)>=.1  local consigstars "*  " 
			  if r(p)>.1 			  local consigstars "   " 
			  
			  test [2]`var' = [3]`var'
			  if r(p)<=.01            local diffsigstars "***" 
			  if r(p)>.01 & r(p)<=.05 local diffsigstars "** " 
			  if r(p)>.05 & r(p)>=.1  local diffsigstars "*  " 
			  if r(p)>.1 			  local diffsigstars "   " 
			  local diff = [2]`var' - [3]`var'
			  }/* quietly */
			di in yellow %33s "`:var label `var''" _continue _skip(3) "{c |}" 
			di in yellow %12.2f exp([2]`var')  _continue 
			di in yellow "`incsigstars'" _skip(3) _continue 
			di in yellow %12.2f exp([3]`var') _continue 
			di in yellow "`consigstars'" _skip(3) _continue 
			di in yellow %12.2f exp([2]`var') - exp([3]`var') _continue 
			di in yellow "`diffsigstars'" _skip(3) _continue
			di in yellow %12.2f r(chi2) _skip(3)
			} /*risk factors */
	di in text "{hline 90}" 
}



/*
* appendix
forvalues y = 1989(10)2009{
	foreach thing in inc con {
		qui mlogit `thing'_type `riskfactors' if insample == 1 & datayear <= `y' & datayear>= `y'-10, rrr b(1) vce(cl datayear)
		est sto mlogit1
		estout mlogit1,  replace eform cells(b(star fmt(3)) se(fmt(3))) ///
		style(tex) s(ll chi2 N) label legend varlabel(_cons Constant) unstack posthead("") prefoot("") postfoot("")
	 /*
	  di in yellow %33s "Bottom decile by `thing' in `y'" _skip(3) 
	   di in yellow %33s "Risk Factor" _continue _skip(3) "{c |}" 
	*di in yellow %12s "BHC Pov." _continue _skip(3) 
	*di in yellow %12s "AHC Pov." _continue _skip(3) 
	di in yellow %12s "IHC Pov." _continue _skip(3) /* mike */ 
	di in yellow %12s "XHC Pov." _continue _skip(3) 
		   di in yellow %12s "Diff" _skip(3) 
	   di in yellow %12s "F" _skip(3) 
	   di in text "{hline 90}" 
		foreach var of varlist `riskfactors' {
			qui: {
				  test [2]`var'
				  if r(p)<=.01            local incsigstars "***" 
				  if r(p)>.01 & r(p)<=.05 local incsigstars "** " 
				  if r(p)>.05 & r(p)>=.1  local incsigstars "*  " 
				  if r(p)>.1 			  local incsigstars "   " 
				  
				  test [3]`var'
				  if r(p)<=.01            local consigstars "***" 
				  if r(p)>.01 & r(p)<=.05 local consigstars "** " 
				  if r(p)>.05 & r(p)>=.1  local consigstars "*  " 
				  if r(p)>.1 			  local consigstars "   " 
				  
				  test [2]`var' = [3]`var'
				  if r(p)<=.01            local diffsigstars "***" 
				  if r(p)>.01 & r(p)<=.05 local diffsigstars "** " 
				  if r(p)>.05 & r(p)>=.1  local diffsigstars "*  " 
				  if r(p)>.1 			  local diffsigstars "   " 
				  local diff = [2]`var' - [3]`var'
				  }/* quietly */
				di in yellow %33s "`:var label `var''" _continue _skip(3) "{c |}" 
				di in yellow %12.2f exp([2]`var')  _continue 
				di in yellow "`incsigstars'" _skip(3) _continue 
				di in yellow %12.2f exp([3]`var') _continue 
				di in yellow "`consigstars'" _skip(3) _continue 
				di in yellow %12.2f exp([2]`var') - exp([3]`var') _continue 
				di in yellow "`diffsigstars'" _skip(3) _continue
				di in yellow %12.2f r(chi2) _skip(3)
				} /*risk factors */
				di in text "{hline 90}" */
				} 
		} /*thing */
*/


* Mike and now interactions between age and single-ness. Remember omitted category is couple aged 40-50


gen byte single_old   = single * (age_narr>=5)
gen byte single_young = single * ~(age_narr>=5)
la var single_old "Single & age 60+"
la var single_young "Single & age <60"



*local riskfactors 		educat* agenr* hohunemp hohselfemp couple single_* kid_dummy /*own_house*/
local riskfactors_mike  educat* agenr* hohworkless hohselfemp single_* multiadult  kid_dummy /*own_house*/
		
foreach thing in inc con {
	local y = 2009
	qui mlogit `thing'_type `riskfactors_mike' if insample == 1 & datayear <= `y' & datayear>= `y'-10, rrr b(1) vce(cl datayear)
	est sto mlogit1
	/*estout mlogit1,  replace eform cells(b(star fmt(3)) se(fmt(3))) ///
	style(tex) s(ll chi2 N) label legend varlabel(_cons Constant) unstack posthead("") prefoot("") postfoot("")
	*/
	di in yellow %33s "Bottom decile by `thing' in `y'" _skip(3) 
	di in yellow %33s "Risk Factor" _continue _skip(3) "{c |}" 
	*di in yellow %12s "BHC Pov." _continue _skip(3) 
	*di in yellow %12s "AHC Pov." _continue _skip(3) 
	di in yellow %12s "IHC Pov." _continue _skip(3) /* mike */ 
	di in yellow %12s "XHC Pov." _continue _skip(3) 
	di in yellow %12s "Diff" _skip(3) 
	di in yellow %12s "F" _skip(3) 
	di in text "{hline 90}" 
	foreach var of varlist `riskfactors_mike' {
		qui: {
			  test [2]`var'
			  if r(p)<=.01            local incsigstars "***" 
			  if r(p)>.01 & r(p)<=.05 local incsigstars "** " 
			  if r(p)>.05 & r(p)>=.1  local incsigstars "*  " 
			  if r(p)>.1 			  local incsigstars "   " 
			  
			  test [3]`var'
			  if r(p)<=.01            local consigstars "***" 
			  if r(p)>.01 & r(p)<=.05 local consigstars "** " 
			  if r(p)>.05 & r(p)>=.1  local consigstars "*  " 
			  if r(p)>.1 			  local consigstars "   " 
			  
			  test [2]`var' = [3]`var'
			  if r(p)<=.01            local diffsigstars "***" 
			  if r(p)>.01 & r(p)<=.05 local diffsigstars "** " 
			  if r(p)>.05 & r(p)>=.1  local diffsigstars "*  " 
			  if r(p)>.1 			  local diffsigstars "   " 
			  local diff = [2]`var' - [3]`var'
			  }/* quietly */
			di in yellow %33s "`:var label `var''" _continue _skip(3) "{c |}" 
			di in yellow %12.2f exp([2]`var')  _continue 
			di in yellow "`incsigstars'" _skip(3) _continue 
			di in yellow %12.2f exp([3]`var') _continue 
			di in yellow "`consigstars'" _skip(3) _continue 
			di in yellow %12.2f exp([2]`var') - exp([3]`var') _continue 
			di in yellow "`diffsigstars'" _skip(3) _continue
			di in yellow %12.2f r(chi2) _skip(3)
			} /*risk factors */
	di in text "{hline 90}" 
}





* Mike: now repeat the expanded specification that we had in previous section

/* Interactions to disentangle permanent v. temp reductions in resources */

* interact between ue and education, ue and age, national ue and un
g hohunemp = hohworkless
la var  hohunemp "Workless"
gen educat1_hohunemp = educat1*hohunemp
la var educat1_hohunemp lowed_unemp
gen educat3_hohunemp = educat3*hohunemp
la var educat3_hohunemp highed_unemp

gen agenr1_hohunemp = agenr1*hohunemp
la var agenr1_hohunemp "<30_unemp"
gen agenr2_hohunemp = agenr2*hohunemp
la var agenr2_hohunemp "30-39_unemp"
gen agenr4_hohunemp = agenr4*hohunemp
la var agenr4_hohunemp "50-59_unemp"
gen agenr5_hohunemp = agenr5*hohunemp
la var agenr5_hohunemp "60-69_unemp"
gen agenr6_hohunemp = agenr6*hohunemp
la var agenr6_hohunemp "pensioner_unemp"

*log using "C:\Users\abigail_a\Dropbox\mikecormac\abi_work\logit\mlogit_interact.log", replace text
*local riskfactors 		educat* agenr* hohunemp hohselfemp couple single kid_dummy /*own_house*/
local riskfactors_mike 	educat* agenr* hohunemp hohselfemp single_* multiadult kid_dummy /*own_house*/
		
foreach thing in inc con {
	local y = 2009
	qui mlogit `thing'_type `riskfactors_mike' if insample == 1 & datayear <= `y' & datayear>= `y'-10, rrr b(1) vce(cl datayear)
	est sto mlogit1
	/*estout mlogit1,  replace eform cells(b(star fmt(3)) se(fmt(3))) ///
	style(tex) s(ll chi2 N) label legend varlabel(_cons Constant) unstack posthead("") prefoot("") postfoot("")
	*/
	di in yellow %33s "Bottom decile by `thing' in `y'" _skip(3) 
	di in yellow %33s "Risk Factor" _continue _skip(3) "{c |}" 
	*di in yellow %12s "BHC Pov." _continue _skip(3) 
	*di in yellow %12s "AHC Pov." _continue _skip(3) 
	di in yellow %12s "IHC Pov." _continue _skip(3) /* mike */ 
	di in yellow %12s "XHC Pov." _continue _skip(3) 
	di in yellow %12s "Diff" _skip(3) 
	di in yellow %12s "F" _skip(3) 
	di in text "{hline 90}" 
	foreach var of varlist `riskfactors_mike' {
		qui: {
			  test [2]`var'
			  if r(p)<=.01            local incsigstars "***" 
			  if r(p)>.01 & r(p)<=.05 local incsigstars "** " 
			  if r(p)>.05 & r(p)>=.1  local incsigstars "*  " 
			  if r(p)>.1 			  local incsigstars "   " 
			  
			  test [3]`var'
			  if r(p)<=.01            local consigstars "***" 
			  if r(p)>.01 & r(p)<=.05 local consigstars "** " 
			  if r(p)>.05 & r(p)>=.1  local consigstars "*  " 
			  if r(p)>.1 			  local consigstars "   " 
			  
			  test [2]`var' = [3]`var'
			  if r(p)<=.01            local diffsigstars "***" 
			  if r(p)>.01 & r(p)<=.05 local diffsigstars "** " 
			  if r(p)>.05 & r(p)>=.1  local diffsigstars "*  " 
			  if r(p)>.1 			  local diffsigstars "   " 
			  local diff = [2]`var' - [3]`var'
			  }/* quietly */
			di in yellow %33s "`:var label `var''" _continue _skip(3) "{c |}" 
			di in yellow %12.2f exp([2]`var')  _continue 
			di in yellow "`incsigstars'" _skip(3) _continue 
			di in yellow %12.2f exp([3]`var') _continue 
			di in yellow "`consigstars'" _skip(3) _continue 
			di in yellow %12.2f exp([2]`var') - exp([3]`var') _continue 
			di in yellow "`diffsigstars'" _skip(3) _continue
			di in yellow %12.2f r(chi2) _skip(3)
			} /*risk factors */
	di in text "{hline 90}" 
}




*	log close
	
cap log close
