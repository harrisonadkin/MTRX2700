# MTRX2700
MTRX2700 Central Code Storage

Lab group 1:
	- Harrison Adkin
	- James Allen
	- Shigita Aje

Roles and Responsibilities:
	- Harrison
		• Main program writer
		• Testing of code
		• Modularity
	- James
		• Commenting and documentation
		• Testing of code
	- Shigita
		• Commenting and documentation
		• Testing of code

Code information:


	- Exercise 1
		• Program takes an inputted 'FLAG' set to 1,2,3,4 to determine which
		function to run. 
		• The program also takes an inputted string to be modified
		• The four functions are broken into modules. 
		• The program takes the inputted string and runs through each character,
		then checking its value and determining whether to store it plainly (for
		special characters or numbers) or turn it from upper to lower / vice versa
		• If the end of the string isn't detected, it will start spitting out
		random memory bits that are stored.
		• Incrementing can cause problems and sometimes spit every second letter, 		etc
		• The function selection is through a flag character.
		
	- Exercise 2
		• The program takes an inputted FLAG set to 1,2,3 to determine the 			function to run.
		• The program also takes an inputted string of numbers (note for task 2 		only 4 digits is logical) 
		• The first function gets caught in an infinite loop that only breaks and 		writes the value of the string to the 7seg once the button is pressed. 
		Note that the dip switch must be on to power the button!! 
		• The second function takes a string of the hex values that switch each	
		7 seg on and increments through it, writing each number to each 7seg 			incredibly fast.
		• The third function uses the stack to recall inputted characters, and 			scrolls through the values in the string.
		• If the inputted digits include letters, the mapping function will never 		branch if equal and will simply iterate on itself and skip to the next
		character in the string, until a number is reached.
		• Our scroll rate runs through each character every 1/4th of a second. 			This is calculated through our delay, which runs 6000 x 100 iterations in 		a 10 E clock cycle. Thus using the function (time x 24MHz)/E clock = 			iterations, we can solve for time. 

	- Exercise 3
		• This program takes an inputted flag set to 1,2,3 to determine which 			function to run.
		• It also takes an inputted string to print to serial
		• The first function prints this inputted string in serial, printing a 			letter every second.
		• The second function reads from serial and prints to memory only when a 		carriage return is inputted. (Note 128 bits were reserved)
		• The third function reads from serial and writes to serial when a 			carriage return is hit.
		• Polling can cause more data than is reserved to be pushed to memory.
		• Polling rates can cause unsynced reading of the data and not read 			properly.
		• Inputting more characters than what is reserved for in memory may 
		start overflow writing into unreserved sections of memory. This has 
		several negative implications. Furthermore, it is more likely to become
		out of sync. 
		
	- Exercise 4
		• The integration module combines previous functions to take an input 			string from serial and decipher based on the switch whether to capitalise 
		or capital case the string. The string is then sent to serial output on 		the input of a carriage return.
		• 
		• 
		•

