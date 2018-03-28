// Function Delegates
// notes

// normally when calling a function, it is immediately executed
// if you set a variable to a function, you are actually storing the output of the function
// function delegates allow you to store a reference to a function, so that you can call it when you need to, later


unset each.									// remove any value set to each

{											// not in the global scope (demonstrating how to reference a function in a nested scope)
											// this effectively creates a library of functions which are hidden from the global scope (no naming conflicts)
											// the library is accessed via the global lexicon() - in this example called Enum
	function each {
		parameter values, operation.			// implicitly accepts a list of values, and some operation to perform on the values (essentially accepts a function delegate)
		for value in values operation(value).	// iterate through the list of values and perform the operation on each element
	}
	
	global Enum is lexicon("each", each@).		// define a lexicon (enumerable of key, value pairs) in the global scope
											// the key of "each" stores a value of each@ - which is a reference to the each() function - a function delegate
}

Enum["each"](list(1,2,3), print@).				// calling the each() function by accessing the "each" key in the Enum lexicon
											// it's value is a reference to the each() function - which accepts a list of values and a function reference