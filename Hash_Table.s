		.text
		.globl main

main:  lw $t1,z # keys = 0 
	   lw $t3,z # pos=0
	   lw $t4,z # choice = 0


			
WHILE_LOOP:	la $a0,promptMenu	#print Menu
			li $v0,4
			syscall
			
			la $a0,promptInsertKey	#print 1.Insert Key
			li $v0,4
			syscall
			
			la $a0,promptFindKey	#print 2.Find Key
			li $v0,4
			syscall
			
			la $a0,promptDisplayHash	# print 3.Display Hash Table
			li $v0,4
			syscall
			
			la $a0,promptExit	#print 4.Exit
			li $v0,4
			syscall
			
			la $a0,promptChoice	#print Choice?
			li $v0,4
			syscall
			
			li $v0,5	#pairno input
			syscall
			move $t6,$v0
			
			# labels
			beq $t6,1,INSERT_KEY
			beq $t6,2,FIND_KEY
			beq $t6,3,DISPLAY_HASH
			beq $t6,4,EXIT
			
WRONGEXIT:  la $a0,promtExitError #print Error. Wrong number
			li $v0,4
			syscall
			j EXIT 

INSERT_KEY: la $a0,messageInsertKey #print Give new key (greater than zero):
			li $v0,4
			syscall	
			
			li $v0,5		#get key from user
			syscall
			
			move $t6,$v0	# move key to t6
			bgtz $t6,not_error
			
            la $a0,messageInsertKeyError #print  key must be greater than zero
			li $v0,4
			syscall
			
not_error:	#keys
			lw $a0,table #array
			#key
			jal insertkey
			
			j WHILE_LOOP
			
FIND_KEY:   la $a0,messageFindKey #print Give new key (greater than zero):
			li $v0,4
			syscall	
			
			li $v0,5	#input
			syscall
			move $t6,$v0
			
			lw $a0,table #pass array
			#key
			jal findkey
			
			move $t3,$v0
			
			beq $t3,-1,error_position
			
			
			la $a0,messageKeyValue #print Key value = 
			li $v0,4
			syscall
			
			la $t0, table
			move $t8,$t3
			add $t8, $t8, $t8 
			add $t8, $t8, $t8    
			add $t9,$t8,$t0
			lw $t7,0($t9)
			move $v0,$t7
			li $v0,1		#print to value
			syscall
			
			sub $t8, $t8, $t8 
			sub $t8, $t8, $t8
			move $t3,$t8
			
			la $a0,messageTablePosition #print Table position = 
			li $v0,4
			syscall
			
			move $v0,$t3  
			li $v0,1		#print to position 
			syscall
			
			j WHILE_LOOP
			
error_position: la $a0,messageErrorPosition #print Key not in hash table.
				li $v0,4
				syscall	
				j WHILE_LOOP
			
		
DISPLAY_HASH: li $t7,0
			  la $a0,messageDisplayHash #print  pos key 
			  li $v0,4
			  syscall
			  
			  
WHILE_LOOP3:lw $t0, table($t7)
			beq $t7,10,enddisplay

			li $a0, 32	#prints space
			li $v0, 11  
			syscall
			
			move $a0,$t7	#prints pos
			li $v0,1
			syscall
			
			li $a0, 32	#prints space
			li $v0, 11  
			syscall
			
			move $a0,$t0 #prints key 
			li $v0,1
			syscall
			
			addi $t7,$t7,1
			j WHILE_LOOP3
			
enddisplay:	j WHILE_LOOP

findkey: 	li $t8,0 #i=0
			li $t9,0 #found=0
			li $t7,0 #temp_position=0
			rem $t7,$t6,10	#t7= key mod 10
			
			lw $t0, table($t7)
LOOP:       bge $t8, 10, END1   #  if i>=10 go to the end
			addi $t8,$t8,1
            bne $t0, $t6, INCR   
            addi $t9,$t9,1
			j END
			
INCR:       addi $t8, $t8, 1     # i++ 
			rem $t7,$t7,10
			
            j LOOP               # back to top of loop 
			
END1:		li $t7,-1


END2:		move $v0, $t7        # return position 
            jr $ra               # return 		 
			

		 
		 


insertkey:	li $t7,0 #temp_position=0
			#pass array
			#pass key
			jal findkey
			move $v0, $t7
			
			
			bne $t7,-1,ALREADY_IN
			
			blt $t1,10,NOT_FULL
			la $a0,messageTableFull #print hash table is full
			li $v0,4
			syscall	
			j END_INSERT
	   
ALREADY_IN: la $a0,messageAlreadyIn #print Key is already in hash table.
			li $v0,4
			syscall	

NOT_FULL:	#pass array
			#pass key
			jal hashfunction
			move $t7, $v0
			sw $t6,table($t7)#table{position}=k
			addi $t1,$t1,1#keys++
	   
END_INSERT:	jr $ra
	 

hashfunction:	li $t7,0 #temp_position=0 
				rem $t7,$t6,10 # t7=key mod 10 
LOOP2:			lw $t0, table($t7)
				bne $t0, 0, INCR2
				j END3
INCR2:			addi $t7,$t7,1
				rem $t7,$t7,10
				j LOOP2
				
END3: 			move $v0, $t7
				jr $ra

EXIT: 	 li $v0,10 #exit program
         syscall 

	  .data
z: .word 0
table: .word 0,0,0,0,0,0,0,0,0,0
promptMenu:.asciiz "Menu"
promptInsertKey:.asciiz "\n 1.Insert Key"
promptFindKey:.asciiz "\n 2.Find Key"
promptDisplayHash:.asciiz "\n 3.Display Hash Table"
promptExit:.asciiz "\n 4.Exit"
promptChoice: .asciiz "\n Choice? \n"
promtExitError: .asciiz "\n Error. Wrong number."
messageInsertKey: .asciiz "\n Give new key (greater than zero):  "
messageInsertKeyError: .asciiz "\n key must be greater than zero"
messageFindKey:.asciiz "\n Give key to search for: "
messageDisplayHash: .asciiz "\n pos key \n"
messageErrorPosition: .asciiz "Key not in hash table."
messageAlreadyIn: .asciiz "Key is already in hash table."
messageTableFull:.asciiz "hash table is full"
messageKeyValue: .asciiz "Key value = "
messageTablePosition: .asciiz "Table position = "
