.data
    #         0  1  2  3  4
    #         0  4  8  12 16
Array: .word  70,6, 51,95,74,7,94,53,58,43,38,81,39,12,79,13,97,62,59,33,17,84,23,63,73,25,52,4,76,77,69,100,68,1,66,44,47,42,18,35,28,96,49,26,83,24,41,65,57,72,5,85,55,54,45,88,27,99,36,15,64,89,20,32,98,37,10,87,11,78,19,48,50,2,91,92,16,29,8,86,61,31,80,93,3,75,67,9,30,46,21,71,40,34,60,22,82,56,14,90
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
	sub $s1, $s1, $s0 
	srl $s1, $s1, 2		#this is a way of quickly getting the array length which will change automatically if I decide to change it (note that this is not null termination, its using the labels which the assembler has access to)
	
	#move $a0, $s0
	#addi $a1, $zero, 1
	#addi $a2, $zero, 2
	#jal swapWords
	
	move $a0, $s0
	move $a1, $s1

	
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



#Quick Sort
#Inputs:
#a0 - starting pointer
#a1 - length (-> ending pointer or one after last element)
#Temps:
#t0 - pointer to the pivot
#t1 - lptr
#t2 - rptr
#t3 - pivot val
#t4 - lptr val
#t5 - rptr val
#t6 - temp
#a[n-1] becomes the pivot always
#terminates if array is length 1
#decrease array length by 1 (because the pivot is there) 
#Then uses pointers lptr and rptr:
#lptr will point to the first element from the left of the array greater than the pivot
#rptr will point to the first element from the right less than the pivot
#	1. If the lptr<rptr then swap the two elements and repeat
#	2. If the lptr>rptr (can't be equal because of how they move) then we swap lptr with the pivot then call the function recursively (lptr becomes the dividing post)
quickSort:
	
	#move $t1, $a0
	sll $a1, $a1, 2		#times 4
	add $a1, $a0, $a1	#Puts $a1 to the position following the last element of the array
	
	#Check if array is length 1 and set up pivot
	subi $a1, $a1, 1
	
	move $t0, $a1 #We can also be more efficent here and set up the pointer for the pivot
	lw $t3, 0($t0) #load in pointer value to temp
	
	bne $a0, $a1, quickSortWeLongerThan1 
		jr $ra		#return back because we are done with this section
	quickSortWeLongerThan1:
	add $a1, $a1, 1
	
	#Now we need to do the scan, swap, and split:
	
	#Intialize pointers (we set them to one before (0->-1)/after (n-2 -> n-1) cause when we increment the frist time through):
	subi $t1, $a0, 1	#lptr will point to each thing on the left that is greater than the pivot
	subi $t2, $t0, 0	#rptr will point to each thing on the right that is less than the pivot
	
	#begin the loop for the entire scan
	quickSort_outerLoop:
		#just the left part we find the first number greater than the pointer 
		#(therefore branch its less than or equalled to)
		quickSort_lptrLoop:
			addi $t1, $t1, 1	#inc
			lw $t4, 0($t1)		#load in the current elements pointed to
			slt $t6, $t3, $t4			#pivot > leftVal
			beq $t6, $zero, quickSort_lptrLoop	#only loop if leftVal <= pivot
		
		#just the right part we find the first number (from the right) less than the pointer 
		#(therefore branch its greater than or equal to) ($t5 >= $t3)
		quickSort_rptrLoop:
			subi $t2, $t2, 1
			lw $t5, 0($t2)
			slt $t6, $t5, $t3 			#pivot < rightVal
			beq $t6, $zero, quickSort_rptrLoop	#only loop if rightVal >= pivot
		
		#Now we check if the position of lptr is greater than the position of right ptr (that means we need to do recursive call)
		#We do it this way to aviod 2 different unconditional jumps
		
		
