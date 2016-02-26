* create indicator for bottom decile 

/* bottom decile */
	foreach res in inc incahc con conahc {
		gen dec`res' = .
		forvalues y = 1979/2009 {
			qui su equiv`res' if datayear == `y' [fw=peepweight], detail
			replace dec`res' = 1 if datayear == `y' & equiv`res' <= r(p10)
			replace dec`res' = 0 if datayear == `y' & equiv`res' > r(p10)
		}
	}
	ren decinc decincbhc
	ren deccon decconbhc

	* mike
	la define inccon 1 "Neither" 2 "Inc poor" 3 "Con poor" 4 "Inc & Con poor"
	
	foreach res in bhc ahc {
		gen dectype_`res' = .
		replace dectype_`res' = 1 if decinc`res' == 0 & deccon`res' == 0
		replace dectype_`res' = 2 if decinc`res' == 1 & deccon`res' == 0
		replace dectype_`res' = 3 if decinc`res' == 0 & deccon`res' == 1
		replace dectype_`res' = 4 if decinc`res' == 1 & deccon`res' == 1
		tab dectype_`res', gen(_dectype_`res')
		la values dectype_`res' inccon
	}
	
	gen dectype_all = 0
	replace dectype_all = 1 if decincahc == 1 & decconahc == 1 & decincbhc == 1 & decconbhc == 1

	* mike
	la define ahcbhc 1 "Neither" 2 "IHC poor" 3 "XHC poor" 4 "IHC & XHC poor"

	
	foreach res in inc con {
		gen `res'_type = .
		replace `res'_type = 1 if dec`res'bhc == 0 & dec`res'ahc == 0
		replace `res'_type = 2 if dec`res'bhc == 1 & dec`res'ahc == 0
		replace `res'_type = 3 if dec`res'bhc == 0 & dec`res'ahc == 1
		replace `res'_type = 4 if dec`res'bhc == 1 & dec`res'ahc == 1
		la values `res'_type ahcbhc
	}
