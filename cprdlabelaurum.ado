/* Program for labelling values in CPRD files using CPRD lookups - PWS 2022

Syntax:
	cprdlabelaurum var1 var2 ..., location("path_to_CPRD_lookups")
	e.g. cprdlabelaurum gender, location("D:\Data\Lookups\CPRD Aurum")

*/

capture program drop cprdlabelaurum
program define cprdlabelaurum
	version 17.0
	syntax varlist, LOCation(string)
	
	quietly {
		
		//Save current dataset
		preserve
		
		capture import delimited "`location'/aurum_var_lookup", varnames(1) clear
		if _rc {
			
			display as error "Lookup file not found. Check directory."
			error
		}
		
		keep if available == 1
		drop available
		
		//Define the lookups
		quietly count
		local n = `r(N)'
		
		forvalues i = 1/`n' {
			
			local lookup_`=variable[`i']' = "`=lookup[`i']'"
		}
		
		//Restore dataset
		restore
		
		//For each var sent to the command run cprdlabel using the lookup from 
		//aurum_var_lookup
		foreach var of local varlist {
			
			if "`lookup_`var''" == "" {
				
				noisily display "Lookup not found for `var'."
			}
			else {
				
				noisily cprdlabel `var', lookup(`lookup_`var'') location(`location')
			}
		}
		
	} //End of quietly block

end // End program
	
