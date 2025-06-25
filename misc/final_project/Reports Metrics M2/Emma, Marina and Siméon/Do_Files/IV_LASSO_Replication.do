*Set path to export results and access data
cd "C:\Users\KLEIN\Documents\0 - M2 ENS\Topics in econometrics\Project\119513-V1"
global path "C:\Users\KLEIN\Documents\0 - M2 ENS\Topics in econometrics\Project\119513-V1"

*Packages needed: lassopack, ranktest, ivreg2.

*Import ERCOT Data
use ERCOT_Final.dta, clear
set more off
set matsize 10000
global totaldmg tot_d_elec
global localdmg local_d_elec
global co2damage co2_damage_elec
global so2damage so2_damage_elec
global noxdamage nox_damage_elec
global pm25damage pm25_damage_elec

*Run IV LASSO - Code here creates column 6 in Table 2 and columns 3 and 4 in Table 3 of the main text.
*Set up interaction variables for IV-LASSO Procedure
*WindDirX - wind direction from monitor X, CloudCoverX - cloud cover measure at monitor X, onehrPrcpX - precip measure at monitor X
gen d01 = 0
replace d01 = 1 if year==2011 & month==1 & day==1 & hour==0
local vlist "TempCelsius1 WindDir1 WindSpd1 CloudCover1 onehrPrcp1 TempCelsius2 WindDir2 WindSpd2 CloudCover2 onehrPrcp2 TempCelsius3 WindDir3 WindSpd3 CloudCover3 onehrPrcp3 TempCelsius4 WindDir4 WindSpd4 CloudCover4 onehrPrcp4 TempCelsius5 WindDir5 WindSpd5 CloudCover5 onehrPrcp5 TempCelsius6 WindDir6 WindSpd6 CloudCover6 onehrPrcp6 TempCelsius7 WindDir7 WindSpd7 CloudCover7 onehrPrcp7 TempCelsius8 WindDir8 WindSpd8 CloudCover8 onehrPrcp8 TempCelsius9 WindDir9 WindSpd9 CloudCover9 onehrPrcp9 TempCelsius10 WindDir10 WindSpd10 CloudCover10 onehrPrcp10 TempCelsius11 WindDir11 WindSpd11 CloudCover11 onehrPrcp11 TempCelsius12 WindDir12 WindSpd12 CloudCover12 onehrPrcp12 TempCelsius13 WindDir13 WindSpd13 CloudCover13 onehrPrcp13 TempCelsius14 WindDir14 WindSpd14 CloudCover14 onehrPrcp14 TempCelsius15 WindDir15 WindSpd15 CloudCover15 onehrPrcp15 TempCelsius16 WindDir16 WindSpd16 CloudCover16 onehrPrcp16 TempCelsius17 WindDir17 WindSpd17 CloudCover17 onehrPrcp17 TempCelsius18 WindDir18 WindSpd18 CloudCover18 onehrPrcp18 TempCelsius19 WindDir19 WindSpd19 CloudCover19 onehrPrcp19 TempCelsius20 WindDir20 WindSpd20 CloudCover20 onehrPrcp20 TempCelsius21 WindDir21 WindSpd21 CloudCover21 onehrPrcp21 TempCelsius22 WindDir22 WindSpd22 CloudCover22 onehrPrcp22 TempCelsius23 WindDir23 WindSpd23 CloudCover23 onehrPrcp23 TempCelsius24 WindDir24 WindSpd24 CloudCover24 onehrPrcp24 TempCelsius25 WindDir25 WindSpd25 CloudCover25 onehrPrcp25 TempCelsius26 WindDir26 WindSpd26 CloudCover26 onehrPrcp26 TempCelsius27 WindDir27 WindSpd27 CloudCover27 onehrPrcp27 TempCelsius28 WindDir28 WindSpd28 CloudCover28 onehrPrcp28 TempCelsius29 WindDir29 WindSpd29 CloudCover29 onehrPrcp29 TempCelsius30 WindDir30 WindSpd30 CloudCover30 onehrPrcp30 TempCelsius31 WindDir31 WindSpd31 CloudCover31 onehrPrcp31"
foreach i of local vlist {
gen crez_`i' = CREZ_voltmiles*`i'
}


*Run IV-LASSO & Test 1st stage with LASSO-selected variables
*NOTE: We noted that slight discrepencies in coefficient estimates may occur accross different versions of Stata (e.g. 19.90 in Stata 14 vs 20.20 in Stata 16)
gen wind_seg = wind*segmented
ivlasso $totaldmg wind c.load_h##c.load_h c.load_n##c.load_n  c.load_s##c.load_s  c.load_w##c.load_w c.fuelratio##c.fuelratio c.TempCelsius##c.TempCelsius c.spp_wind##c.spp_wind c.spp_load##c.spp_load i.hour#i.month i.dow i.month#i.year i.hour#i.month i.dow i.month#i.year (wind_seg segmented= c.CREZ_voltmiles##c.CREZ_voltmiles c.CREZ_voltmiles#c.CREZ_voltmiles#c.CREZ_voltmiles c.CREZ_voltmiles#c.tot_load c.CREZ_voltmiles#c.wind TempCelsius1-loadt_PrecipSQ31 crez_TempCelsius1-crez_onehrPrcp31) if d01!=1, idstats first
global ivlist `=e(zselected)' 

reg wind_seg $ivlist wind c.load_h##c.load_h c.load_n##c.load_n  c.load_s##c.load_s  c.load_w##c.load_w c.fuelratio##c.fuelratio c.TempCelsius##c.TempCelsius c.spp_wind##c.spp_wind c.spp_load##c.spp_load i.hour#i.month i.dow i.month#i.year i.hour#i.month  if d01!=1, cl(monthyear)
predict ws_hat, xb
reg segmented ws_hat wind c.load_h##c.load_h c.load_n##c.load_n  c.load_s##c.load_s  c.load_w##c.load_w c.fuelratio##c.fuelratio c.TempCelsius##c.TempCelsius c.spp_wind##c.spp_wind c.spp_load##c.spp_load i.hour#i.month i.dow i.month#i.year i.hour#i.month if d01!=1, cl(monthyear)
predict e_seg, residual
reg e_seg  $ivlist if d01!=1, cl(monthyear)
test $ivlist

*Run IV LASSO and store instruments, then run IV with selected instruments - column 6 of Table 2 in main text.
ivlasso $totaldmg wind c.load_h##c.load_h c.load_n##c.load_n  c.load_s##c.load_s  c.load_w##c.load_w c.fuelratio##c.fuelratio c.TempCelsius##c.TempCelsius c.spp_wind##c.spp_wind c.spp_load##c.spp_load i.hour#i.month i.dow i.month#i.year i.hour#i.month i.dow i.month#i.year (wind_seg segmented= c.CREZ_voltmiles##c.CREZ_voltmiles c.CREZ_voltmiles#c.CREZ_voltmiles#c.CREZ_voltmiles c.CREZ_voltmiles#c.tot_load c.CREZ_voltmiles#c.wind TempCelsius1-loadt_PrecipSQ31 crez_TempCelsius1-crez_onehrPrcp31) if d01!=1, idstats first
global ivlist `=e(zselected)' 