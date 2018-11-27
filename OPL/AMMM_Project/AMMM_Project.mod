/*********************************************
 * OPL 12.6.0.0 Model
 * Author: Sana Jabeen
 * Creation Date: Nov 8, 2018 at 7:14:48 PM
 *********************************************/
 int nServices = ...;
 int nBuses = ...;
 int nDrivers = ...;

 range S = 1..nServices;
 range B = 1..nBuses;
 range D = 1..nDrivers;
 
 // ********************************
 //           INPUT DATA
 // ********************************
 // data about services
 int start[s in S] = ...; // minutes after 0:00 (i.e. 510 is 8:30am)
 int minutes[s in S] = ...;
 int kms[s in S] = ...;
 int passengers[s in S] = ...;
 
 // data about buses
 int capacity[b in B] = ...;
 float costKm[b in B] = ...;     // in euros
 float costMinute[b in B] = ...; // in euros
 
 // data about drivers
 int maxDrivingMinutes[d in D] = ...;
 
 // IMPORTANT HINT!!!!!!!!!!
 // overlapping not input data, but should be computed in the first execute block using input data
 // overlapping[s1][s2] == 1 if and only if services s1 and s2 overlap in time
 // However, if you solve the problem without using "overlapping", you can remove the first execute block
// int overlapping[s1 in S][s2 in S];
 
 int maxBuses = ...;
 int baseMinutes = ...;
 float costBaseMinute = ...;  // in euros
 float costExtraMinute = ...; // in euros. It always holds that costExtraMinute > costBaseMinute
 
 // ********************************
 //        DECISION VARIABLES
 // ********************************
 
 // Mandatory variables. However, feel free to use more if appropriate.
 dvar boolean ds[d in D][s in S]; // whether driver d is assigned to service s
 dvar boolean bs[b in B][s in S]; // whether bus b is assigned to service s
 
// execute {
// for (var s1 in S)
// 	for (var s2 in S) 
// 		if (s1 < s2 && true ){ // CHANGE!!!!!!!!! true should be replaced by the corresponding expression
// 			overlapping[s1][s2] = 1; 
// 	}	
//}	

 minimize sum(s in S, b in B) bs[b][s]*costKm[b]+sum(s in S, b in B) bs[b][s]*costMinute[b]; // This should be changed!!!!!
 
 subject to {
	 	
	 	// Capacity of the bus and services
	 	forall (b in B)
	 	  	sum(s in S) bs[b][s]*passengers[s] <= capacity[b];
	 	  	
	    // the Duration and maxDriver minutes
		forall(d in D)
	   	   sum(s in S) ds[d][s]*minutes[s] <= maxDrivingMinutes[d];
}  	


 execute {
 	for (var s in S) {
 		var countBuses = 0;
 		var bus; 
 		for (var b in B) if (bs[b][s] == 1) {++countBuses; bus = b;}	
 		if (countBuses == 0) writeln("ERROR: Service " + s + " has no bus!!!!!");
 		if (countBuses > 1) writeln("ERROR: Service " + s + " has more than one bus!!!!!");

 		var countDrivers = 0;
 		var driver; 
 		for (var d in D) if (ds[d][s] == 1) {++countDrivers; driver = d;}	
 		if (countDrivers == 0) writeln("ERROR: Service " + s + " has no driver!!!!!");
 		if (countDrivers > 1) writeln("ERROR: Service " + s + " has more than one driver!!!!!");
	
		writeln("Service " + s + ": bus " + bus + ", driver " + driver)			 		
 	}
 	
 	writeln("");
 	for (d in D) {
		var mins = 0;
		write("Driver " + d + " has services: ");		
		for (s in S) if (ds[d][s] == 1) {write(s + " [" + start[s] + "," + (start[s] + minutes[s]) + "] "); mins += minutes[s];}
		writeln("");
		for (var s1 in S) 
			for (var s2 in S)
				if (ds[d][s1] == 1 && ds[d][s2] == 1 && s1 < s2 && start[s1] + minutes[s1] > start[s2] && start[s1] < start[s2] + minutes[s2])
					writeln("ERROR: Services " + s1 + " and " + s2 + " overlap in time!!!!!");
		writeln("\tThat requires " + mins + " working minutes of a maximum of " + maxDrivingMinutes[d]);
		if (mins > maxDrivingMinutes[d]) writeln("ERROR: maxDrivingMinutes exceeded");				
	} 	 	
 
 	writeln("");
 	for (b in B) {
 		write("Bus " + b + " (size " + capacity[b] + ") has services: ");
 	 	for (s in S) if (bs[b][s] == 1) write(s + " [" + start[s] + "," + (start[s] + minutes[s]) + "] (pass. " + passengers[s] + "), ");
 	 	writeln("");
 	 	for (var s1 in S) 
			for (var s2 in S)
				if (bs[b][s1] == 1 && bs[b][s2] == 1 && s1 < s2 && start[s1] + minutes[s1] > start[s2] && start[s1] < start[s2] + minutes[s2])
					writeln("ERROR: Services " + s1 + " and " + s2 + " overlap in time!!!!!");
			for (s in S) if (bs[b][s] == 1 && passengers[s] > capacity[b]) 
					writeln("ERRROR: service " + s + " has " + passengers[s] + " passengers and bus " + b + " has capacity " + capacity[b]);
			 	 	
 	}
}  
 