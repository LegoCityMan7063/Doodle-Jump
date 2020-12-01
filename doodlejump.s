#####################################################################
#
# CSCB58 Fall 2020 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Glenn Qing Yuan Ye, 1006102977
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8					     
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4/5 (choose the one the applies)
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). 
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################

.data
	displayAddress: .word 0x10008000 # display base address
	arraySize: .word 4096 # bitmap display array size
	platformLength: .word 28 # length of a platform
	
	platform1Row: .word 0x10008600# platform 1 starts on row 12
	platform2Row: .word 0x10008B00 # platform 2 starts on row 22
	platform3Row: .word 0x10008F80 # platform 3 starts on row 31
	
	white: .word 0xffffff # white
	green: .word 0x00ff00 # green
	yellow: .word 0xf3ff3d # yellow
	black: .word 0x000000 # black
.text

main:
	mainLoopInit:
		jal drawBackground
		jal drawPlatforms
		
		move $s0, $s3 # calculate initial position of player character
		addi $s0, $s0, 12
		addi $s0, $s0, -128
		
		jal drawPlayer
	mainLoop:
		
		
		li $v0, 32 # sleep for 20 ms
		li $a0, 20
		syscall
		
		j mainLoop # jump back to start of main loop
	mainLoopDone:
		li $v0, 10 # exit program
		syscall 

# draw player character
drawPlayer:
	addi $sp, $sp, -4 # increase stack size
	sw $ra, 0($sp) # push return address of drawPlayer into stack
	
	lw $t0, black # $t1 stores the black colour
	sw $t0, 0($s0) # color the player character black (body)
	move $t1, $s0 # color the player character black (head)
	addi $t1, $t1, -128
	sw $t0, 0($t1) 
	
	lw $t2, 0($sp) # pop return address of drawPlayer and store it in $t2
	addi $sp, $sp, 4 # decrease stack size
	
	jr $t2 # return to main

# randomly generate a platform's location (start point)
generatePlatformStartOffset:
	addi $sp, $sp, -4 # increase stack size
	sw $ra, 0($sp) # push return address of generatePlatformStartOffset into stack
	
	li $v0, 42 # syscall 42 is rng int within 0 <= x < max
	li $a0, 0 # rng id
	li $a1, 26 # 25 * 4 = max starting point for platform
	syscall
	
	li $t6, 4 # each color value is 4 bytes long
	mult $t6, $a0 # random number 0 to 25) * 4 = offset
	mflo $t6 # store offset in $t6
	
	lw $t7, 0($sp) # pop return address of generatePlatformStartOffset and store it in $t7
	addi $sp, $sp, 4 # decrease stack size
	addi $sp, $sp, -4 # increase stack size
	sw $t6, 0($sp) # push randomly generated platform offset into stack
	
	jr $t7 # return to drawPlatform1, drawPlatform2, or drawPlatform3

# draw 3 platforms
drawPlatforms:
	addi $sp, $sp, -4 # increase stack size
	sw $ra, 0($sp) # push return address of drawPlatforms into stack
	
	jal drawPlatform1
	
	lw $s1, 0($sp) # pop location of platform 1 (leftmost platform block) in $s1
	addi $sp, $sp, 4 # decrease stack size
	
	jal drawPlatform2
	
	lw $s2, 0($sp) # pop location of platform 2 (leftmost platform block) in $s2
	addi $sp, $sp, 4 # decrease stack size
	
	jal drawPlatform3
	
	lw $s3, 0($sp) # pop location of platform 3 (leftmost platform block) in $s3
	addi $sp, $sp, 4 # decrease stack size	
	lw $t0, 0($sp) # pop return address of drawPlatforms from stack and store in $t0
	addi $sp, $sp, 4 # decrease stack size	
	
	jr $t0 # return to main

drawPlatform1:
	addi $sp, $sp, -4 # increase stack size
	sw $ra, 0($sp) # push return address of drawPlatform1 into stack
	
	lw $t0, platformLength # $t0 stores the length of the platform
	lw $t1, green # $t1 stores the green colour
	lw $t2, platform1Row # $t2 stores the address of the first display unit on platform 1's row
	
	drawPlatform1LoopInit:
		jal generatePlatformStartOffset # randomly generate platform offset
		
		lw $t3, 0($sp) # pop randomly generated offset and store in $t3
		addi $sp, $sp, 4 # decrease stack size
		
		# li $t3, 100
		add $t0, $t0, $t3 # calculate rightmost platform unit block
		add $t4, $t2, $t3 # $t4 stores the index
		
		lw $t5, 0($sp) # pop return address of drawPlatform1 and store in $t5
		addi $sp, $sp, 4 # decrease stack size
		addi $sp, $sp, -4 # increase stack size
		sw $t2, 0($sp) # push the memory address of the leftmost platform1 unit into stack to save location of platform1
	drawPlatform1Loop:
		sw $t1, 0($t4) # colour the unit green
		addi $t3, $t3, 4 # increase the offset by 4 (each colour is 4 bytes)
		add $t4, $t2, $t3 # $t4 stores the next index
		bne $t0, $t3, drawPlatform1Loop # if offset < platformLength, loop again to continue drawing platform
	drawPlatform1Done:
	
	jr $t5 # return to drawPlatforms
drawPlatform2:
	addi $sp, $sp, -4 # increase stack size
	sw $ra, 0($sp) # push return address of drawPlatform2 into stack
	
	lw $t0, platformLength # $t0 stores the length of the platform
	lw $t1, green # $t1 stores the green colour
	lw $t2, platform2Row # $t2 stores the address of the first display unit on platform 2's row
	
	drawPlatform2LoopInit:
		jal generatePlatformStartOffset # randomly generate platform offset
		
		lw $t3, 0($sp) # pop randomly generated offset and store in $t3
		addi $sp, $sp, 4 # decrease stack size
		
		# li $t3, 100
		add $t0, $t0, $t3 # calculate rightmost platform unit block
		add $t4, $t2, $t3 # $t4 stores the index
		
		lw $t5, 0($sp) # pop return address of drawPlatform1 and store in $t5
		addi $sp, $sp, 4 # increase stack size
		addi $sp, $sp, -4 # increase stack size
		sw $t2, 0($sp) # push the memory address of the leftmost platform2 unit into stack to save location of platform2
	drawPlatform2Loop:
		sw $t1, 0($t4) # colour the unit green
		addi $t3, $t3, 4 # increase the offset by 4 (each colour is 4 bytes)
		add $t4, $t2, $t3 # $t4 stores the next index
		bne $t0, $t3, drawPlatform2Loop # if offset < platformLength, loop again to continue drawing platform
	drawPlatform2Done:
	
	jr $t5 # return to drawPlatforms

drawPlatform3:
	addi $sp, $sp, -4 # increase stack size
	sw $ra, 0($sp) # push return address of drawPlatform3 into stack
	
	lw $t0, platformLength # $t0 stores the length of the platform
	lw $t1, green # $t1 stores the green colour
	lw $t2, platform3Row # $t2 stores the address of the first display unit on platform 3's row
	
	drawPlatform3LoopInit:
		jal generatePlatformStartOffset # randomly generate platform offset
		
		lw $t3, 0($sp) # pop randomly generated offset and store in $t3
		addi $sp, $sp, 4 # decrease stack size
		
		# li $t3, 100
		add $t0, $t0, $t3 # calculate rightmost platform unit block
		add $t4, $t2, $t3 # $t4 stores the index
		
		lw $t5, 0($sp) # pop return address of drawPlatform1 and store in $t5
		addi $sp, $sp, 4 # decrease stack size
		addi $sp, $sp, -4 # increase stack size
		sw $t4, 0($sp) # push the memory address of the leftmost platform3 unit into stack to save location of platform3
	drawPlatform3Loop:
		sw $t1, 0($t4) # colour the unit green
		addi $t3, $t3, 4 # increase the offset by 4 (each colour is 4 bytes)
		add $t4, $t2, $t3 # $t4 stores the next index
		bne $t0, $t3, drawPlatform3Loop # if offset < platformLength, loop again to continue drawing platform
	drawPlatform3Done:
	
	jr $t5 # return to drawPlatforms


# colour the background white
drawBackground:
	addi $sp, $sp, -4 # increase stack size
	sw $ra, 0($sp) # push return address of drawBackground into stack 
	
	backgroundLoopInit:
		add $t0, $zero, $zero # $t0 stores the offset (starting at 0)
		lw $t1, arraySize # $t1 stores the array size
		lw $t2, displayAddress # $t2 stores the base address for the display
		lw $t3, white # $t3 stores the colour code for white
		add $t4, $t2, $t0 # $t4 stores the index 
	backgroundLoop:
		sw $t3, 0($t4) # color the unit white
		addi $t0, $t0, 4 # increase the offset by 4 (each color is 4 bytes)
		add $t4, $t2, $t0 # $t4 stores the next index
		bne $t0, $t1, backgroundLoop # if index < 4096, loop again
	backgroundLoopDone:
	
	lw $t5, 0($sp) # # pop return address of drawPlatform1 and store in $t5
	addi $sp, $sp, 4 # decrease stack size
	
	jr $t5 # return to main
	
