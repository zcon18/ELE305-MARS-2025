.data
    #         0  1  2  3  4
    #         0  4  8  12 16
Array: .word  70,6,51,95,74,7,94,53,58,43,38,81,39,12,79,13,97,62,59,33,17,84,23,63,73,25,52,4,76,77,69,100,68,1,66,44,47,42,18,35,28,96,49,26,83,24,41,65,57,72,5,85,55,54,45,88,27,99,36,15,64,89,20,32,98,37,10,87,11,78,19,48,50,2,91,92,16,29,8,86,61,31,80,93,3,75,67,9,30,46,21,71,40,34,60,22,82,56,14,90

.text
main:
    la $s0, Array
    li $s1, 100
    
    #move $a0, $s0
    #addi $a1, $zero, 1
    #addi $a2, $zero, 2
    #jal swapWords
    
    move $a0, $s0
    move $a1, $s1
    jal selectionSort
    
        #this loop just prints out the whole array of numbers located at "Array"
    addi $t0, $zero, 0
    loop:
        sll $t1, $t0, 2
        add $t1, $s0, $t1
        lw $t1, 0($t1)
        li    $v0, 1                # syscall 1: print_int
        move    $a0, $t1
        syscall                    # print $t1
        li $v0, 11    #syscall 11: print char
        li $a0, 32    #loads 32 (space) into argument
        syscall
        addi $t0, $t0, 1
        bne $t0, $s1, loop
    
    
    
    li $v0, 10    #exit program
    syscall
    

#Selection Sort
#inputs:
#a0 - start of array
#a1 - length of array (-> turns into end (position after final slot) of the array)
#temps:
#t0 - slowPointer
#t1 - fastPointer
#t2 - storeData1 (running min)
#t3 - storeData2 (current index value)
#t4 - set less than pointer
#t5 - runningMinPtr
#Traverse the unsorted part of the array, searching for the minimum nunmber
#Then add swap the minimum number with the current position of $t0, inc $t0, and set $t1 to $t0
selectionSort:
    #Set up initial values of pointers
    move $t0, $a0
    #move $t1, $a0
    sll $a1, $a1, 2 #times 4
    add $a1, $a0, $a1
    #Outer loop
    selectionSortOuterLoop:
        move $t1, $t0
        
        lw $t2, 0($t0)
        move $t5, $t0 #set the pointer to the position of our runningMin
        #Because of the way this is set up we always make one comparison with the first value and itself so it could be made more effecient by move over one but we can't terminate as easily
        selectionSortInnerLoop:
            lw $t3, 0($t1)    #store current index
            
            slt $t4, $t3, $t2    #If the current one that we are on is less than the runningMin then we need to update it and its pointer
            beq $t4, $zero, selectionSortDontUpdate
                #If we are here then we need to update running min
                move $t2, $t3 #value update
                move $t5, $t1 #ptr update
                
            selectionSortDontUpdate:
            addi $t1,$t1,4
            bne $t1, $a1, selectionSortInnerLoop #jump back if we haven't gotten to the end of the array yet
        #selectionSortExitInnerLoop:
        #slectionSortSwap: #($t5 -> $t2 [runningMin]) so we only need to get the value of $t0 and put it into $t3
        lw $t3, 0($t0)
        sw $t2, 0($t0)
        sw $t3,    0($t5)
        
        addi $t0, $t0, 4    #Inc by 4 to point to next word
        bne  $t0, $a1, selectionSortOuterLoop    #If we haven't gotten to the end pointer yet then go back
    jr $ra #return back to program