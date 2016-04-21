//////////////////////////////////////////////////
//												//
//			Making a simple map in Stata		//
//			Dave Moyer, Feb. 2016				//
//												//
//////////////////////////////////////////////////

//credit to this stata help site
//http://www.stata.com/support/faqs/graphics/spmap-and-maps/

//install some vital commands (uncomment these if you need them)
//ssc inst spmap
//ssc inst shp2dta
//ssc inst mif2dta

//set directory to place where all my data have been collected
cd "G:\Visualization Resources\Maps\stata"

//import .shp file
shp2dta using unsd10.shp, database(db) coordinates(coord) genid(id)
use db, clear
destring, replace
save db, replace

//read in graduation data and save as .dta
import delimited "wa_2015_grad.csv", clear 
rename (agencyname statename agencyid stateagency) (nces_name state nces_id state_id)
save "wagrad2015", replace

//merge two datasets together to combine data and map info
use db, clear
rename GEOID10 nces_id

merge 1:1 nces_id using "wagrad2015.dta", keepusing(grad2015)
drop if _merge ==2
drop _merge

save dbgrad, replace

//use pre-existing shape file for schools
shp2dta using hs.shp, database(dbhs) coordinates(coordhs) genid(id)
use dbhs, clear
format schl_d_n %16.0g
save dbhs, replace

//merge in enrollment data
use coordhs, clear
rename _ID id
merge 1:1 id using "dbhs.dta", keepusing(enr2014)
drop _merge
rename id _ID


//make map using grad2015 variable as color and coord.dta as projection without points
use dbgrad, clear
spmap grad2015 using coord, id(id) legstyle(3) fcolor(Blues) ndfcolor(gs10) ///
title("Washington 2015 Four-Year Adjusted Cohort Graduation Rate, by District", ///
size(*0.9))

graph export "map1.png", width(10000) replace

//make map using above with points layered on
use dbgrad, clear
spmap grad2015 using "coord.dta", id(id) legstyle(3) fcolor(Blues) ndfcolor(gs10) ///
title("Washington 2015 Four-Year Adjusted Cohort Graduation Rate, by District",  ///
size(*0.9)) ///
point(data("coordhs.dta") x(_X) y(_Y))

//export image
graph export "map.png", width(10000) replace
