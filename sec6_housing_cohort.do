/* Cohort differences between measures that include/exclude implicit housing
- multinomial logit regressions for sec 6 (& appendix) */  

clear
cd "T:\abod"

use longtimeseries, clear

* create dummy variables for various demog characteristics
do demog_indicator_setup
do bottomdecile_indicator_setup	

* cohort 
ren agefortvlicence agefortvlicense
gen yob = .
replace yob = year - agefortvlicense if year<=2002
replace yob = year - agefortvlicense if year>2002 & agefortvlicense<=79 /*age is topcoded at 80 from 2003*/

gen cohort=.
la var cohort cohort
replace cohort = 1 if yob<1900 & yob>0
local index = 2
* cycle over birth cohorts
forvalues yobloc = 1900(10)1980 {
	replace cohort = `index' if yob>=`yobloc' & yob <=`yobloc'+9
	local index = `index'+1
	}
replace cohort =10 if yob>=1980 & yob<2010
tab cohort, gen(cohr)	

* prediction matrix
local nreg = 12
matrix predvalues = J(`nreg', 10, 0)
forvalues index = 1/9 {
	matrix predvalues[`index', `index']=1
	matrix predvalues[10,`index']=1
	matrix predvalues[12,`index']=1
	*matrix predvalues[14,`index']=1
}
local index=10
matrix predvalues[10,`index']=1
matrix predvalues[12,`index']=1
*matrix predvalues[14,`index']=1

local regressors educat* 
forvalue c = 2/10{ 
	foreach thing in bhc ahc {
		qui su agefortvlicense if cohort == `c'
		local mina = r(min)
		logit decinc`thing' dumagenr* `regressors' if cohort==`c'
		matrix coeffs`thing'`c' = get(_b)
		matrix predreg`thing'`c' = coeffs`thing'`c'*predvalues
		forvalues a = 1/9 {
			if coeffs`thing'`c'[1, `a']==0 matrix predreg`thing'`c'[1,`a']=0
		}
		if `mina'>=45 matrix predreg`thing'`c'[1,10]=0
		matrix predval`thing'`c' = J(10, 1, .)
		forvalues a = 1/10{
			if `a'<=3 {
				if predreg`thing'`c'[1,`a'] > 0 | predreg`thing'`c'[1,`a'] < 0 {
					matrix predval`thing'`c'[`a',1]= 1/(1+exp(-predreg`thing'`c'[1,`a'])) 
				}
			}
			if `a'==4 matrix predval`thing'`c'[`a',1]= 1/(1+exp(-predreg`thing'`c'[1,10]))
			if `a'>4 {
				if predreg`thing'`c'[1,`a'-1] > 0 | predreg`thing'`c'[1,`a'-1] < 0 {
					matrix predval`thing'`c'[`a',1]= 1/(1+exp(-predreg`thing'`c'[1,`a'-1]))
				}
			}
		} /* a */
		svmat predval`thing'`c'
		svmat predreg`thing'`c'
		svmat coeffs`thing'`c'
	}
}

/*
* main text - 2009, income 
local thing = "inc"
local y = 2009
qui mlogit `thing'_type `riskfactors' if insample == 1 & datayear <= `y' & datayear>= `y'-10, rrr b(1) vce(cl datayear)
est sto mlogit1
/*estout mlogit1,  replace eform cells(b(star fmt(3)) se(fmt(3))) ///
style(tex) s(ll chi2 N) label legend varlabel(_cons Constant) unstack posthead("") prefoot("") postfoot("")
*/
di in yellow %33s "Bottom decile by `thing' in `y'" _skip(3) 
di in yellow %33s "Risk Factor" _continue _skip(3) "{c |}" 
di in yellow %12s "BHC Pov." _continue _skip(3) 
di in yellow %12s "AHC Pov." _continue _skip(3) 
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
di in text "{hline 90}" 

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
	   di in yellow %12s "BHC Pov." _continue _skip(3) 
	   di in yellow %12s "AHC Pov." _continue _skip(3) 
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
		
*	log close
	
