//////////////////////////////////////////////////
//												                      //
//			Making a simple map in Stata		        //
//			Dave Moyer, Feb. 2016				            //
//												                      //
//////////////////////////////////////////////////

//credit to this stata help site
//http://www.stata.com/support/faqs/graphics/spmap-and-maps/

//install some vital commands (uncomment these if you need them)
//ssc inst spmap
//ssc inst shp2dta
//ssc inst mif2dta

//set directory to place where all my data have been collected
//insert your directory path in the "..."
cd "..."

//import .shp file
//change the "filename" below
//this code generates two stata formatted files: 
//1) a database file (that has any data associated with the shapes called "db"
//and 2) a coordinates file called "coord" that is the spatial information in X and Y format.  
//It also gives each shape an id called "id"
shp2dta using filename.shp, database(db) coordinates(coord) genid(id)
use db, clear
destring, replace
save db, replace

//read in data to attach to the map shaped and save as .dta
//this may or may not be necessary depending on how your data are currently structured
//change the filenames below to your target files
import delimited "wa_2015_grad.csv", clear 
save "wagrad2015", replace

//merge two datasets together to combine data and map info
//replace "wagrad.." with your new stata file, be sure to have an id that matches in both sets
use db, clear
rename GEOID10 nces_id
merge 1:1 nces_id using "wagrad2015.dta", keepusing(grad2015)
drop if _merge ==2
drop _merge
save dbgrad, replace

//make map using grad2015 variable as color and coord.dta as projection
use dbgrad, clear
spmap grad2015 using coord, id(id) legstyle(3) fcolor(Blues) ndfcolor(gs10) ///
title("Washington 2015 Four-Year Adjusted Cohort Graduation Rate, by District", ///
size(*0.9))

graph export "map1.png", width(10000) replace

