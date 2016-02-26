* demographic indicators set up

/* Time variables */
gen eighties_0 = (datayear>1979 & datayear <= 1985)
gen eighties_5 = (datayear>1985 & datayear <= 1989)
la var eighties_0 eighties_0
la var eighties_5 eighties_5
gen nineties_0 = (datayear>1989 & datayear <= 1995)
gen nineties_5 = (datayear>1995 & datayear <= 1999)
la var nineties_0 nineties_0
la var nineties_5 nineties_5
gen noughties_0 = (datayear>1999 & datayear <= 2005)
gen noughties_5 = (datayear>2005 & datayear <= 2009)
la var noughties_0 noughties_0
la var noughties_5 noughties_5

/*Family type*/
gen couple = 0
replace couple = 1 if (narrowfam == 4| narrowfam == 5| narrowfam ==8)
la var couple couple
gen single = 0
replace single = 1 if (narrowfam <= 3| narrowfam == 6| narrowfam ==7)
la var single single
gen multiadult = (couple + single==0)
la var multiadult "Multi-adult"
   
/*Education*/
la var educ education
g insample = 1
replace insample = 0 if educ<=1 /* education missing or still in ed */
replace educ = . if educ<=1
tab educ, gen(educat)
rename educat2 _educat2
	
/* Age */
gen age = 10*floor(agefortvlicence/10)
la var age age
tab age, gen(age_)
ren age_3 _age3
replace insample = 0 if age_10 == 1 | age_1 ==1
drop age_10 age_1
replace age_8 = 1 if age_9 == 1
drop age_9
	
gen age_broad = .
replace age_broad = 1 if age<40
replace age_broad = 2 if age >= 40 & age<60
replace age_broad = 3 if age>=60
tab age_broad, gen(agebr)
ren agebr2 _agebr2

gen age_narr = .
replace age_narr = 1 if age<30
replace age_narr = 2 if age >= 30 & age<40
replace age_narr = 3 if age >= 40 & age<50
replace age_narr = 4 if age >= 50 & age<60
replace age_narr = 5 if age >= 60 & age<70
replace age_narr = 6 if age >=70
tab age_narr, gen(agenr)
* mike
la define age_narr 1 "<30" 2 "30-39" 3 "40-49" 4 "50-59" 5 "60-69" 6 "70+"
la values age_narr age_narr
la var agenr1 "<30"
la var agenr2 "30-39"
la var agenr3 "40-49"
la var agenr4 "50-59"
la var agenr5 "60-69"
la var agenr6 "70+"
ren agenr3 _agenr3


gen age_narr5= .
replace age_narr5 = 1 if age <25
local index = 2
forvalues a = 25(5)70 {
	local a_1 = `a'+5
	replace age_narr5 = `index' if agefortvlicence >= `a' & agefortvlicence < `a_1'
	g dumagenr`a' = 0
	replace dumagenr`a' = 1 if age_narr5 == `index'
	local index = `index'+1
}
ren dumagenr40 _dumagenr40
	
/* Pensioner */
gen pension = 0
replace pension = 1 if narrowfam >= 6 & narrowfam <=7
	
/* Kids */
gen kids = 0
la var kids nkids
replace kids = 1 if numkid == 1
replace kids = 2 if numkid == 2
replace kids = 3 if numkid >2
tab kids, gen(kids_)
ren kids_1 _kids1
gen kid_dummy = (kids>0)
la var kid_dummy Children
		
/* Cars */
gen car = 0
replace car = 1 if ncars == 1
replace car = 2 if ncars >1
tab car, gen(car_)
ren car_1 _car1
gen own_car = (ncars>0)

/* Working */
la var hohworkless "Workless"
la var hohselfemp "Self employed"

/* Tenure */
gen housing = .
la var housing tenure
replace housing = 1 if tenure <= 2 
replace housing = 2 if tenure >=3 & tenure <=4
replace housing = 3 if tenure == 5
replace housing = 4 if tenure >=6 & tenure <=7
tab housing, gen(housing_)
ren housing_3 _housing3

	
/* rooms */
gen room = .
la var room rooms
replace room = 1 if nrooms <= 4
replace room = 2 if nrooms == 5
replace room = 3 if nrooms == 6
replace room = 4 if nrooms > 6
tab room, gen(room_)
ren room_2 _room2

gen own_house = 0
replace own_house = 1 if tenure >= 5 & tenure <= 7
la var own_house "Own house"
