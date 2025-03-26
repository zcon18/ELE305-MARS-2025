.data
    #         0  1  2  3  4
    #         0  4  8  12 16
Array: .word  70,6, 51,95,74,7,94,53,58,43,38,81,39,12,79,13,97,62,59,33,17,84,23,63,73,25,52,4,76,77,69,100,68,1,66,44,47,42,18,35,28,96,49,26,83,24,41,65,57,72,5,85,55,54,45,88,27,99,36,15,64,89,20,32,98,37,10,87,11,78,19,48,50,2,91,92,16,29,8,86,61,31,80,93,3,75,67,9,30,46,21,71,40,34,60,22,82,56,14,90,0
Array_Length_Cheating: .word 0


#point in time A (cycle Count n_A)
#count how many cycles i have gone through (n_x)
#get to point B
#do the count number of cycles again (n_x again)

#Cyrptograhic algrothim doing something in a TPM
.text
main:
	la $s0, Array
	la $s1, Array_Length_Cheating
	sub $s1, $s1, $s0 #this is a way of quickly getting the array length which will change automatically if I decide to change it (note that this is not null termination, its using the labels which the assembler has access to)
	li $s1, 101
	
	#move $a0, $s0
	#addi $a1, $zero, 1
	#addi $a2, $zero, 2
	#jal swapWords
	
	move $a0, $s0
	move $a1, $s1
	jal insertionSort
	
	addi $t0, $zero, 0
	loop:
		sll $t1, $t0, 2
		add $t1, $s0, $t1
		lw $t1, 0($t1)
		li	$v0, 1				# syscall 1: print_int
		move    $a0, $t1
		syscall					# print $t1
		li $v0, 11	#syscall 11: print char
		li $a0, 32	#loads 32 (space) into argument
		syscall
		addi $t0, $t0, 1
		bne $t0, $s1, loop
	
	
	li $v0, 10	#exit program
	syscall
	
#insertionSort helper procedure
#Loop through a sorted array to find the memory address of the first number greater than some value
#a0 - arrayPtr
#a1 - arrayEndPtr (one after the last last element)
#a2 - value to compare
#Return:
#v0 - return the pointer to the first value thats greater than $a2 (or the end if not found)
#temps:
#t0 - loop ptr inc
#t1 - array[$t0]
#t2 - slt
#Use loop with 2 branch points: 
#1. to see if we made it to the end without finding a max
#2. to see if we found it
findGreaterThanPtr:
	beq $a0, $a1, findGreaterThanPtrLargerThanAll #if we start $a0 and $a1 equalled to eachother than we automatically return
	move $t0, $a0
	findGreaterThanPtrLoop:
		lw $t1, 0($t0)		
		slt $t2, $a2, $t1	#this is true when : $a0<$t1
		bne $t2, $zero, findGreaterThanPtrWeFoundIt	#We exit if we found it  (b/c we want $a0<$t1 (== 1) !=0
		addi $t0, $t0, 4	#inc ptr by 4 to get next word
		bne $t0, $a1, findGreaterThanPtrLoop #only nove on when they are equal
	findGreaterThanPtrLargerThanAll:
	move $v0, $a1	#if we made it to this point then that means we didn't find anything (value is greater than everything in list)
	jr $ra	#return back to caller
	findGreaterThanPtrWeFoundIt:
	move $v0, $t0	#b/c we found the location of the first element	that is greater than $a2
	jr $ra
	
			
#Insertion Sort
#a0 - start pointer
#a1 - length of string (-> turns into end (position after final cell) of the array)
#temp:
#t0 - frontPtr
#v0 - swapPtr (conga) 
#t1 - Array @ forntPtr 
#t2 - Array @ swapPtr
#One outerloop that will keep track of 
insertionSort:
	#Set up initial values of pointers
	move $t0, $a0
	#move $t1, $a0
	sll $a1, $a1, 2		#times 4
	add $a1, $a0, $a1	#Puts $a1 to the position following the array
	
	#Outer loop
	insertionSortOuterLoop:
		#Save a0,a1,t0,t1,t2,$ra to the stack (the whole point of the subroutine is to change $v0 so we don't need to save it):
		addi $sp, $sp, -24	#We need to save 6 registers so we move the stack down by 6 words
		sw $ra, 20($sp) #The start of the first word is 4 behind the we the stack pointer rests
		sw $a0, 16($sp)
		sw $a1, 12($sp)
		sw $t0, 8($sp)
		sw $t1, 4($sp)
		sw $t2, 0($sp)
		
		#Do findGreaterThanPtr subroutine that will return the pointer for the swap
		move $a1, $t0	 #load the current value of the frontPtr into $a1 to mark the end of the sorted part of the list
		#addi $a1, $a1, 4 #to make it the point after
		lw $a2, 0($t0)	 #load the value we want to compare into $a2
		jal findGreaterThanPtr	#Do the subroutine
		
		#reload all the data we saved from the stack back into registers
		lw $ra, 20($sp) #The start of the first word is 4 behind the we the stack pointer rests
		lw $a0, 16($sp)
		lw $a1, 12($sp)
		lw $t0, 8($sp)
		lw $t1, 4($sp)
		lw $t2, 0($sp)
		addi $sp, $sp, 24 #reset stack pointer to where we were
		
		beq $v0, $t0, insertionSortSkipConga	#Check if $v0 equalled to $t0 then skip the conga-line
		
		
		#if we made it to here then we need to do the swap conga line
		intertionSortConga:
			#do the swap:
			lw $t1, 0($t0)
			lw $t2, 0($v0)
			sw $t2, 0($t0)
			sw $t1, 0($v0)
			
			#loop operation:
			addi $v0, $v0, 4	#update position of $v0 which is used as our inc pointer
			bne $t0, $v0, intertionSortConga	#only move on to the next part of the function once the swap pointer has reached the outer pointer
		insertionSortSkipConga:
		#loop operation:
		addi $t0, $t0, 4	#inc frontPtr
		bne $t0, $a1, insertionSortOuterLoop 	#jump back if we aren't at the end yet
	jr $ra

