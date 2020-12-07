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
	newPlatformLength: .word 28 # length of new platforms (fragment platforms)
	maxJumpHeight: .word 14 # maximum height of a single jump
	newPlatformsRow: .word 0x10008480 # row which triggers platform change on contact
	minimumHeightForPoint: .word 0x10008B80 # lowest row for a platform hit to count as a point (row 25)
	score: .word 0 # player game score
	backgroundColour: .word 0xffffff # background colour of game screen
	notificationColour: .word 0xF3A72B
	
	platform1Row: .word 0x10008600# platform 1 starts on row 12
	platform2Row: .word 0x10008B00 # platform 2 starts on row 22
	platform3Row: .word 0x10008F80 # platform 3 starts on row 31
	
	white: .word 0xffffff # white
	green: .word 0x00ff00 # green
	yellow: .word 0xf3ff3d # yellow
	black: .word 0x000000 # black 
	blue: .word 0x0472FE # blue
	greyLevel1: .word 0xDADADA # grey
	greyLevel2: .word 0xCDCDCD# grey
	greyLevel3: .word 0xAFAFAF # grey
	greyLevel4: .word 0x9C9C9C # grey
	greyLevel5: .word 0x7D7C7C # grey
	greyLevel6: .word 0x5B5B5B # grey
	greyLevel7: .word 0x343434 # grey
	greyLevel8: .word 0x282828 # grey
	orange: .word 0xF3A72B # orange
	red: .word 0xEE2020 # red
.text

main:
	jal startScreen
	
	mainLoopInit:
		jal drawBackgroundInitial
		jal drawScoreboard
		jal drawPlatforms
		
		move $s0, $s3 # calculate initial position of player character
		addi $s0, $s0, 12
		addi $s0, $s0, -128
		
		move $s4, $zero # $s4 stores the jump/fall counter
		
		jal drawPlayer
		
	mainLoop:
		jal drawBackground
		jal undrawScoreboard
		jal drawScoreboard
		jal keyboardInput
		jal drawPlayer
		jal checkCollisions
		jal changePlatforms
		jal changeDifficulty
						
		li $v0, 32 # sleep for 100 ms
		li $a0, 100
		syscall
		
		j mainLoop # jump back to start of main loop
	mainLoopDone:
		jal gameOver

startScreen:
	addi $sp, $sp, -4 # increase stack size
	sw $ra, 0($sp) # push return address of drawPlayer into stack
	
	jal drawBackgroundInitial # draw start screen background
	
	# draw "Doodle Jump"
	addi $sp, $sp, -4 # increase stack size
	li $t0, 0x10008284
	sw $t0, 0($sp) # push top left pixel
	addi $sp, $sp, -4 # increase stack size
	lw $t1, black
	sw $t1, 0($sp) # push colour 
	jal drawD
	
	li $v0, 32 # sleep for 500 ms
	li $a0, 500
	syscall
	
	addi $sp, $sp, -4 # increase stack size
	li $t0, 0x10008294
	sw $t0, 0($sp) # push top left pixel
	addi $sp, $sp, -4 # increase stack size
	lw $t1, black
	sw $t1, 0($sp) # push colour 
	jal drawZero
	
	li $v0, 32 # sleep for 500 ms
	li $a0, 500
	syscall
	
	addi $sp, $sp, -4 # increase stack size
	li $t0, 0x100082A4
	sw $t0, 0($sp) # push top left pixel
	addi $sp, $sp, -4 # increase stack size
	lw $t1, black
	sw $t1, 0($sp) # push colour 
	jal drawZero
	
	li $v0, 32 # sleep for 500 ms
	li $a0, 500
	syscall
	
	addi $sp, $sp, -4 # increase stack size
	li $t0, 0x100082B4
	sw $t0, 0($sp) # push top left pixel
	addi $sp, $sp, -4 # increase stack size
	lw $t1, black
	sw $t1, 0($sp) # push colour 
	jal drawD
	
	li $v0, 32 # sleep for 500 ms
	li $a0, 500
	syscall

	addi $sp, $sp, -4 # increase stack size
	li $t0, 0x100082C4
	sw $t0, 0($sp) # push top left pixel
	addi $sp, $sp, -4 # increase stack size
	lw $t1, black
	sw $t1, 0($sp) # push colour 
	jal drawOne
	
	li $v0, 32 # sleep for 500 ms
	li $a0, 500
	syscall
	
	addi $sp, $sp, -4 # increase stack size
	li $t0, 0x100082D4
	sw $t0, 0($sp) # push top left pixel
	addi $sp, $sp, -4 # increase stack size
	lw $t1, black
	sw $t1, 0($sp) # push colour 
	jal drawE
	
	li $v0, 32 # sleep for 500 ms
	li $a0, 500
	syscall
	
	addi $sp, $sp, -4 # increase stack size
	li $t0, 0x10008584
	sw $t0, 0($sp) # push top left pixel
	addi $sp, $sp, -4 # increase stack size
	lw $t1, black
	sw $t1, 0($sp) # push colour 
	jal drawJ
	
	li $v0, 32 # sleep for 500 ms
	li $a0, 500
	syscall
	
	addi $sp, $sp, -4 # increase stack size
	li $t0, 0x10008594
	sw $t0, 0($sp) # push top left pixel
	addi $sp, $sp, -4 # increase stack size
	lw $t1, black
	sw $t1, 0($sp) # push colour 
	jal drawU
	
	li $v0, 32 # sleep for 500 ms
	li $a0, 500
	syscall
	
	addi $sp, $sp, -4 # increase stack size
	li $t0, 0x100085A4
	sw $t0, 0($sp) # push top left pixel
	addi $sp, $sp, -4 # increase stack size
	lw $t1, black
	sw $t1, 0($sp) # push colour 
	jal drawM
	
	li $v0, 32 # sleep for 500 ms
	li $a0, 500
	syscall
	
	addi $sp, $sp, -4 # increase stack size
	li $t0, 0x100085B4
	sw $t0, 0($sp) # push top left pixel
	addi $sp, $sp, -4 # increase stack size
	lw $t1, black
	sw $t1, 0($sp) # push colour 
	jal drawP
	
	li $v0, 32 # sleep for 500 ms
	li $a0, 500
	syscall
	
	
	# press p to play game
	sw $zero, 0xffff0004
	startLoopInit:
		lw $t1, 0xffff0004
	startLoop:				
		addi $sp, $sp, -4 # increase stack size
		# li $t1, 0x100087B8 # $t1 stores the top left pixel of the letter
		li $t1, 0x10008AB8 # $t1 stores the top left pixel of the letter
		sw $t1, 0($sp) # push top left pixel
		addi $sp, $sp, -4 # increase stack size
		lw $t0, green # $t0 stores black
		sw $t0, 0($sp) # push colour into stack
		jal drawP						
					
		lw $t1, 0xffff0004
		bne $t1, 0x070, startLoop # wait until player presses p
	startLoopDone:
	
	addi $sp, $sp, -4 # increase stack size
	# li $t1, 0x100087B8 # $t1 stores the top left pixel of the letter
	li $t1, 0x10008AB8 # $t1 stores the top left pixel of the letter
	sw $t1, 0($sp) # push top left pixel
	addi $sp, $sp, -4 # increase stack size
	lw $t0, white # $t0 stores black
	sw $t0, 0($sp) # push colour into stack
	jal drawP
					
	sw $zero, 0xffff0004
	
	lw $t0, 0($sp) # pop returh address of startScreen and store in $t0
	addi $sp, $sp, 4 # decrease stack size
		
	jr $t0 # jump back to main	

drawJ:
	lw $t3, 0($sp) # pop colour and store in $t3
	addi $sp, $sp, 4 # decrease stack size 
	lw $t4, 0($sp) # pop location of left pixel and store in $t4
	addi $sp, $sp, 4 # decrease stack size
	
	addi $t4, $t4, 512
	sw $t3, 0($t4)
	addi $t4, $t4, 4
	sw $t3, 0($t4)
	addi $t4, $t4, 4
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	
	jr $ra # jump back
	
drawU:
	lw $t3, 0($sp) # pop colour and store in $t3
	addi $sp, $sp, 4 # decrease stack size 
	lw $t4, 0($sp) # pop location of left pixel and store in $t4
	addi $sp, $sp, 4 # decrease stack size
	
	sw $t3, 0($t4)
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	addi $t4, $t4, 4
	sw $t3, 0($t4)
	addi $t4, $t4, 4
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	
	jr $ra # jump back

drawM:
	lw $t3, 0($sp) # pop colour and store in $t3
	addi $sp, $sp, 4 # decrease stack size 
	lw $t4, 0($sp) # pop location of left pixel and store in $t4
	addi $sp, $sp, 4 # decrease stack size
	
	sw $t3, 0($t4)
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	addi $t4, $t4, 8
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, -4
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	
	jr $ra # jump back
	
gameOver:
	lw $t0, red # $t0 stores the colour red
	
	addi $sp, $sp, -4 # increase stack size
	li $t1, 0x100087A8 # $t1 stores the top left pixel of the ltter
	sw $t1, 0($sp) # push top left pixel
	addi $sp, $sp, -4 # increase stack size
	sw $t0, 0($sp) # push colour red into stack
	jal drawR
	
	# fully coloured message stays on for 500ms
	li $v0, 32 
	li $a0, 500
	syscall
	
	addi $sp, $sp, -4 # increase stack size
	li $t1, 0x100087B8 # $t1 stores the top left pixel of the ltter
	sw $t1, 0($sp) # push top left pixel
	addi $sp, $sp, -4 # increase stack size
	sw $t0, 0($sp) # push colour red into stack
	jal drawOne
	
	# fully coloured message stays on for 500ms
	li $v0, 32 
	li $a0, 500
	syscall
	
	addi $sp, $sp, -4 # increase stack size
	li $t1, 0x100087C8 # $t1 stores the top left pixel of the ltter
	sw $t1, 0($sp) # push top left pixel
	addi $sp, $sp, -4 # increase stack size
	sw $t0, 0($sp) # push colour red into stack
	jal drawP
	
	sw $zero, score # reset score to zero
	li $v0, 10 # exit program
	syscall 

drawP:
	lw $t3, 0($sp) # pop colour and store in $t3
	addi $sp, $sp, 4 # decrease stack size 
	lw $t4, 0($sp) # pop location of left pixel and store in $t4
	addi $sp, $sp, 4 # decrease stack size
	
	addi $t4, $t4, 512
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, 4
	sw $t3, 0($t4)
	addi $t4, $t4, 4
	sw $t3, 0($t4)
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	addi $t4, $t4, -4
	sw $t3, 0($t4)
	
	jr $ra # jump back

drawG:
	lw $t3, 0($sp) # pop colour and store in $t3
	addi $sp, $sp, 4 # decrease stack size 
	lw $t4, 0($sp) # pop location of left pixel and store in $t4
	addi $sp, $sp, 4 # decrease stack size
	
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, 4
	sw $t3, 0($t4)
	addi $t4, $t4, 4
	sw $t3, 0($t4)
	addi $t4, $t4, 256
	sw $t3, 0($t4)
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	addi $t4, $t4, -4
	sw $t3, 0($t4)
	addi $t4, $t4, -4
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t5, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, 4
	sw $t3, 0($t4)
	
	jr $ra # jump back

drawE:
	lw $t3, 0($sp) # pop colour and store in $t3
	addi $sp, $sp, 4 # decrease stack size 
	lw $t4, 0($sp) # pop location of left pixel and store in $t4
	addi $sp, $sp, 4 # decrease stack size
	
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, 4
	sw $t3, 0($t4)
	addi $t4, $t4, 4
	sw $t3, 0($t4)
	addi $t4, $t4, 256
	sw $t3, 0($t4)
	addi $t4, $t4, 256
	sw $t3, 0($t4)
	addi $t4, $t4, -4
	sw $t3, 0($t4)
	addi $t4, $t4, -4
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, 4
	sw $t3, 0($t4)	
	
	jr $ra # jump back

drawR:
	lw $t3, 0($sp) # pop colour and store in $t3
	addi $sp, $sp, 4 # decrease stack size 
	lw $t4, 0($sp) # pop location of left pixel and store in $t4
	addi $sp, $sp, 4 # decrease stack size
	
	addi $t4, $t4, 512
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, 4
	sw $t3, 0($t4)
	addi $t4, $t4, 4
	sw $t3, 0($t4)
	
	jr $ra # jump back

drawW:
	lw $t3, 0($sp) # pop colour and store in $t3
	addi $sp, $sp, 4 # decrease stack size 
	lw $t4, 0($sp) # pop location of left pixel and store in $t4
	addi $sp, $sp, 4 # decrease stack size
	
	sw $t3, 0($t4)
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	addi $t4, $t4, 4
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, 128
	addi $t4, $t4, 4
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	
	jr $ra # jump back

drawH:
	lw $t3, 0($sp) # pop colour and store in $t3
	addi $sp, $sp, 4 # decrease stack size 
	lw $t4, 0($sp) # pop location of left pixel and store in $t4
	addi $sp, $sp, 4 # decrease stack size
	
	sw $t3, 0($t4)
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	addi $t4, $t4, 4
	addi $t4, $t4, -256
	sw $t3, 0($t4)
	addi $t4, $t4, 256
	addi $t4, $t4, 4
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	
	jr $ra # jump back

drawA:
	lw $t3, 0($sp) # pop colour and store in $t3
	addi $sp, $sp, 4 # decrease stack size 
	lw $t4, 0($sp) # pop location of left pixel and store in $t4
	addi $sp, $sp, 4 # decrease stack size
	
	addi $t4, $t4, 512
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, 4
	sw $t3, 0($t4)
	addi $t4, $t4, 4
	sw $t3, 0($t4)
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	addi $t4, $t4, -256
	addi $t4, $t4, -4
	sw $t3, 0($t4)
	
	jr $ra # jump back

drawD:
	lw $t3, 0($sp) # pop colour and store in $t3
	addi $sp, $sp, 4 # decrease stack size 
	lw $t4, 0($sp) # pop location of left pixel and store in $t4
	addi $sp, $sp, 4 # decrease stack size
	
	addi $t4, $t4, 8
	sw $t3, 0($t4)
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	addi $t4, $t4, 128
	sw $t3, 0($t4)
	addi $t4, $t4, -4
	sw $t3, 0($t4)
	addi $t4, $t4, -4
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, -128
	sw $t3, 0($t4)
	addi $t4, $t4, 4
	sw $t3, 0($t4)
	
	jr $ra # jump back


# show congratulatory message every 10th point
showPoggers:
	addi $sp, $sp, -4 # increase stack size
	sw $ra, 0($sp) # push return address of showPoggers into stack
	
	lw $t0, backgroundColour # $t0 stores the background colour
	lw $t1, notificationColour # $t1 stores the notification colour
	

	addi $sp, $sp, -4 # increase stack size 
	li $t2, 0x10008384 # push top left pixel of letter into stack
	sw $t2, 0($sp) 
	addi $sp, $sp, -4 # increase stack size
	sw $t1, 0($sp) # push notification colour into stack
	jal drawP 

	addi $sp, $sp, -4
	li $t2, 0x10008394 	
	sw $t2, 0($sp)
	addi $sp, $sp, -4 
	sw $t1, 0($sp)
	jal drawZero

	addi $sp, $sp, -4
	li $t2, 0x100083A4
	sw $t2, 0($sp)	
	addi $sp, $sp, -4 
	sw $t1, 0($sp)
	jal drawG

	addi $sp, $sp, -4
	li $t2, 0x100083B4	
	sw $t2, 0($sp)
	addi $sp, $sp, -4 
	sw $t1, 0($sp)
	jal drawG

	addi $sp, $sp, -4
	li $t2, 0x100083C4	
	sw $t2, 0($sp)
	addi $sp, $sp, -4 
	sw $t1, 0($sp)
	jal drawE

	addi $sp, $sp, -4
	li $t2, 0x100083D4	
	sw $t2, 0($sp)
	addi $sp, $sp, -4 
	sw $t1, 0($sp)
	jal drawR

	addi $sp, $sp, -4
	li $t2, 0x100083E4
	sw $t2, 0($sp)
	addi $sp, $sp, -4 
	sw $t1, 0($sp)
	jal drawFive
	
	# fully coloured message stays on for 200ms
	li $v0, 32 
	li $a0, 200
	syscall
	
	addi $sp, $sp, -4 # increase stack size 
	li $t2, 0x10008384 # push top left pixel of letter into stack	
	sw $t2, 0($sp) 
	addi $sp, $sp, -4 # increase stack size
	sw $t0, 0($sp) # push notification colour into stack
	jal drawP 

	addi $sp, $sp, -4
	li $t2, 0x10008394 	
	sw $t2, 0($sp)
	addi $sp, $sp, -4 
	sw $t0, 0($sp)
	jal drawZero

	addi $sp, $sp, -4
	li $t2, 0x100083A4	
	sw $t2, 0($sp)
	addi $sp, $sp, -4 
	sw $t0, 0($sp)
	jal drawG

	addi $sp, $sp, -4
	li $t2, 0x100083B4	
	sw $t2, 0($sp)
	addi $sp, $sp, -4 
	sw $t0, 0($sp)
	jal drawG

	addi $sp, $sp, -4
	li $t2, 0x100083C4	
	sw $t2, 0($sp)
	addi $sp, $sp, -4 
	sw $t0, 0($sp)
	jal drawE

	addi $sp, $sp, -4
	li $t2, 0x100083D4
	sw $t2, 0($sp)	
	addi $sp, $sp, -4 
	sw $t0, 0($sp)
	jal drawR

	addi $sp, $sp, -4
	li $t2, 0x100083E4
	sw $t2, 0($sp)
	addi $sp, $sp, -4 
	sw $t0, 0($sp)
	jal drawFive
	
	lw $t0, 0($sp) # pop return address of showPoggers
	addi $sp, $sp, 4 # decrease stack size
	
	jr $t0 # jump back to showNotifications
	
showWow:
	addi $sp, $sp, -4 # increase stack size
	sw $ra, 0($sp) # push return address of showWow into stack
	
	lw $t0, backgroundColour # $t0 stores the background colour
	lw $t1, notificationColour # $t1 stores the notification colour
	
	addi $sp, $sp, -4 # increase stack size 
	li $t2, 0x10008384 # push top left pixel of letter into stack
	sw $t2, 0($sp) 
	addi $sp, $sp, -4 # increase stack size
	sw $t1, 0($sp) # push notification colour into stack
	jal drawW

	addi $sp, $sp, -4
	li $t2, 0x10008394 
	sw $t2, 0($sp)	
	addi $sp, $sp, -4 
	sw $t1, 0($sp)
	jal drawZero

	addi $sp, $sp, -4
	li $t2, 0x100083A4	
	sw $t2, 0($sp)
	addi $sp, $sp, -4 
	sw $t1, 0($sp)
	jal drawW
	
	# fully coloured message stays on for 200ms
	li $v0, 32 
	li $a0, 200
	syscall

	addi $sp, $sp, -4 # increase stack size 
	li $t2, 0x10008384 # push top left pixel of letter into stack
	sw $t2, 0($sp) 
	addi $sp, $sp, -4 # increase stack size
	sw $t0, 0($sp) # push notification colour into stack
	jal drawW
	
	addi $sp, $sp, -4
	li $t2, 0x10008394 
	sw $t2, 0($sp)
	addi $sp, $sp, -4 
	sw $t0, 0($sp)
	jal drawZero
	
	addi $sp, $sp, -4
	li $t2, 0x100083A4
	sw $t2, 0($sp)
	addi $sp, $sp, -4 
	sw $t0, 0($sp)
	jal drawW	
	
	lw $t0, 0($sp) # pop return address of showWow
	addi $sp, $sp, 4 # decrease stack size
	
	jr $t0 # jump back to showNotifications
	
show5Head:
	addi $sp, $sp, -4 # increase stack size
	sw $ra, 0($sp) # push return address of show5Head into stack
	
	lw $t0, backgroundColour # $t0 stores the background colour
	lw $t1, notificationColour # $t1 stores the notification colour

	addi $sp, $sp, -4 # increase stack size 
	li $t2, 0x10008384 # push top left pixel of letter into stack
	sw $t2, 0($sp) 	
	addi $sp, $sp, -4 # increase stack size
	sw $t1, 0($sp) # push notification colour into stack
	jal drawFive 

	addi $sp, $sp, -4
	li $t2, 0x10008394 
	sw $t2, 0($sp)	
	addi $sp, $sp, -4 
	sw $t1, 0($sp)
	jal drawH

	addi $sp, $sp, -4
	li $t2, 0x100083A4
	sw $t2, 0($sp)	
	addi $sp, $sp, -4 
	sw $t1, 0($sp)
	jal drawE

	addi $sp, $sp, -4
	li $t2, 0x100083B4
	sw $t2, 0($sp)
	addi $sp, $sp, -4 
	sw $t1, 0($sp)
	jal drawA

	addi $sp, $sp, -4
	li $t2, 0x100083C4
	sw $t2, 0($sp)
	addi $sp, $sp, -4 
	sw $t1, 0($sp)
	jal drawD
	
	# fully coloured message stays on for 200ms
	li $v0, 32 
	li $a0, 200
	syscall
	
	addi $sp, $sp, -4 # increase stack size 
	li $t2, 0x10008384 # push top left pixel of letter into stack
	sw $t2, 0($sp) 
	addi $sp, $sp, -4 # increase stack size
	sw $t0, 0($sp) # push notification colour into stack
	jal drawFive 

	addi $sp, $sp, -4
	li $t2, 0x10008394 
	sw $t2, 0($sp)
	addi $sp, $sp, -4 
	sw $t0, 0($sp)
	jal drawH
	
	addi $sp, $sp, -4
	li $t2, 0x100083A4
	sw $t2, 0($sp)
	addi $sp, $sp, -4 
	sw $t0, 0($sp)
	jal drawE

	addi $sp, $sp, -4
	li $t2, 0x100083B4
	sw $t2, 0($sp)
	addi $sp, $sp, -4 
	sw $t0, 0($sp)
	jal drawA
	
	addi $sp, $sp, -4
	li $t2, 0x100083C4
	sw $t2, 0($sp)
	addi $sp, $sp, -4 
	sw $t0, 0($sp)
	jal drawD	
	
	lw $t0, 0($sp) # pop return address of show5Head
	addi $sp, $sp, 4 # decrease stack size
	
	jr $t0 # jump back to showNotifications
	

showNotification:
	addi $sp, $sp, -4 # increase stack size
	sw $ra, 0($sp) # push return address of showNotification into stack
	
	noNotifZeroIf:
		lw $t0, score # $t0 stores the current game score
		beq $t0, $zero, noNotifZeroElse # if score is 0, don't show notification
	noNotifZeroThen:
		j noNotifZeroDone
	noNotifZeroElse:
		j showNotificationDone
	noNotifZeroDone:
			
	
	showNotificationIf:
		lw $t0, score # $t0 stores the current game score
		li $t1, 10 # $t1 stores the number 10
		div $t0, $t1 # score / 10
		mfhi $t0 # $t0 stores score % 10
		beq  $t0, $zero, showNotificationElse # if score is muiltiple of 10, print message
	showNotificationThen:
		j showNotificationDone
	showNotificationElse:	
		# random number to decide what message to show
		li $v0, 42
		li $a0, 0
		li $a1, 3
		syscall
		
		showPoggersIf:
			li $t2, 0 # $t2 stores the ID for POGGERS
			beq $a0, $t2, showPoggersElse # if id == 0 show POGGERS
		showPoggersThen:
			j showPoggersDone
		showPoggersElse:
			jal showPoggers
			j show5HeadDone
		showPoggersDone:
	
		showWowIf:
			li $t2, 1 # $t2 stores the ID for WOW
			beq $a0, $t2, showWowElse # if id == 1 show WOW
		showWowThen:
			j showWowDone
		showWowElse:
			jal showWow
			j show5HeadDone
		showWowDone:
	
		show5HeadIf:
			li $t2, 2 # $t3 stores the ID for 5HEAD
			beq $a0, $t2, show5HeadElse # if id == 2 show 5HEAD
		show5HeadThen:
			j show5HeadDone
		show5HeadElse:
			jal show5Head
		show5HeadDone:
	showNotificationDone:
	
	lw $t0, 0($sp) # pop return address of showNotification
	addi $sp, $sp, 4 # decrease stack size
	
	jr $t0 # jump back to main

# change difficulty as score increases
changeDifficulty:
	addi $sp, $sp, -4 # increase stack size
	sw $ra, 0($sp) # push return address of changeDifficulty into stack
	
	lw $t0, score # $t0 stores the current game score
	
	# change background colour (darker i.e. darker sky as altitude increases) every level
	# decrease platform length by 2 every 2 levels (up to min. 2 block platform length)
		li $t1, 80 # $t1 stores the score needed to increase the game level
	level8If:
		bge $t0, $t1, level8Else # level 7 70 <= x <= 80
	level8Then:
		j level8Done
	level8Else:
		lw $t1, greyLevel8
		sw $t1, backgroundColour
		j level1Done
	level8Done:
	
	li $t1, 70 # $t1 stores the score needed to increase the game level
	level7If:
		bge $t0, $t1, level7Else # level 7 70 <= x <= 80
	level7Then:
		j level7Done
	level7Else:
		lw $t1, greyLevel7
		sw $t1, backgroundColour
		j level1Done
	level7Done:
	
	li $t1, 60 # $t1 stores the score needed to increase the game level
	level6If:
		bge $t0, $t1, level6Else # level 6 60 <= x <= 70
	level6Then:
		j level6Done
	level6Else:
		lw $t1, greyLevel6
		sw $t1, backgroundColour
		li $t1, 8
		sw $t1, newPlatformLength
		j level1Done
	level6Done:
	
	li $t1, 50 # $t1 stores the score needed to increase the game level
	level5If:
		bge $t0, $t1, level5Else # level 5 50 <= x <= 60
	level5Then:
		j level5Done
	level5Else:
		lw $t1, greyLevel5
		sw $t1, backgroundColour
		j level1Done
	level5Done:
	
	li $t1, 40 # $t1 stores the score needed to increase the game level
	level4If:
		bge $t0, $t1, level4Else # level 4 40 <= x <= 50
	level4Then:
		j level4Done
	level4Else:
		lw $t1, greyLevel4
		sw $t1, backgroundColour
		li $t1, 16
		sw $t1, newPlatformLength
		j level1Done
	level4Done:
	
	li $t1, 30 # $t1 stores the score needed to increase the game level
	level3If:
		bge $t0, $t1, level3Else # level 3 30 <= x < 40
	level3Then:
		j level3Done
	level3Else:
		lw $t1, greyLevel3
		sw $t1, backgroundColour
		j level1Done
	level3Done:
	
	li $t1, 20 # $t1 stores the score needed to increase the game level
	level2If:
		bge $t0, $t1, level2Else # level 2 20 <= x < 30
	leve21Then:
		j level2Done
	level2Else:
		lw $t1, greyLevel2
		sw $t1, backgroundColour
		li $t1, 20
		sw $t1, newPlatformLength
		j level1Done
	level2Done:
	
	li $t1, 10 # $t1 stores the score needed to increase the game level
	level1If:
		bge $t0, $t1, level1Else # level 1 10 <= x < 20
	level1Then:
		j level1Done
	level1Else:
		lw $t1, greyLevel1
		sw $t1, backgroundColour
	level1Done:
		
	
	lw $t0, 0($sp) # pop return address of changeDifficulty
	addi $sp, $sp, 4 # decrease stack size
	
	jr $t0 # jump back to main
# erase previous scoreboard display
drawBlank:
	lw $t5, 0($sp) # pop colour and store in $t5
	addi $sp, $sp, 4 # decrease stack size
	lw $t6, 0($sp) # pop location of left pixel and store in $t6
	addi $sp, $sp, 4 # decrease stack size 	
	
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, -128
	sw $t5, 0($t6)
	addi $t6, $t6, 4
	sw $t5, 0($t6)
	addi $t6, $t6, 4
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, -4
	sw $t5, 0($t6)
	addi $t6, $t6, -4
	sw $t5, 0($t6)
	addi $t6, $t6, -128
	sw $t5, 0($t6)
	addi $t6, $t6, -128
	sw $t5, 0($t6)
	addi $t6, $t6, 4
	sw $t5, 0($t6)
	addi $t6, $t6, -128
	sw $t5, 0($t6)
	addi $t6, $t6, 256
	sw $t5, 0($t6)
	
	jr $ra # jump backto undrawScoreboard

undrawScoreboard:
	addi $sp, $sp, -4 # increase stack size
	sw $ra, 0($sp) # push return address of drawScoreboard into stack

	li $t0, 0x100080C0 # $t0 stores the top left pixel of 1000's digit
	lw $t1, backgroundColour # $t1 stores the background colour
	
	addi $sp, $sp, -4 # increase stack size
	sw $t0, 0($sp) # push location of top left pixel
	addi $sp, $sp, -4 # increase stack size
	sw $t1, 0($sp) # push background colour into stack
	
	jal drawBlank # colour digit background colour (erase)
	
	li $t0, 0x100080D0 # $t0 stores the top left pixel of 100's digit
	lw $t1, backgroundColour # $t1 stores the background colour
	
	addi $sp, $sp, -4 # increase stack size
	sw $t0, 0($sp) # push location of top left pixel
	addi $sp, $sp, -4 # increase stack size
	sw $t1, 0($sp) # push background colour into stack
	
	jal drawBlank
	
	li $t0, 0x100080E0 # $t0 stores the top left pixel of 10's digit
	lw $t1, backgroundColour # $t1 stores the background colour
	
	addi $sp, $sp, -4 # increase stack size
	sw $t0, 0($sp) # push location of top left pixel
	addi $sp, $sp, -4 # increase stack size
	sw $t1, 0($sp) # push background colour into stack
	
	jal drawBlank
	
	li $t0, 0x100080F0 # $t0 stores the top left pixel of 1's digit
	lw $t1, backgroundColour # $t1 stores the background colour
	
	addi $sp, $sp, -4 # increase stack size
	sw $t0, 0($sp) # push location of top left pixel
	addi $sp, $sp, -4 # increase stack size
	sw $t1, 0($sp) # push background colour into stack
	
	jal drawBlank
	
	lw $t0, 0($sp) # pop return address of undrawScoreboard
	addi $sp, $sp, 4 # decrease stack size
	
	jr $t0 # jump back to main
	
# draw a digit
drawZero:
	lw $t5, 0($sp) # pop colour and store in $t5
	addi $sp, $sp, 4 # decrease stack size
	lw $t6, 0($sp) # pop location of left pixel and store in $t6
	addi $sp, $sp, 4 # decrease stack size 	
	
	# draw digit
	sw $t5, 0($t6) 
	sw $t5, 4($t6)
	sw $t5, 8($t6)
	addi $t6, $t6, 8
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, -4
	sw $t5, 0($t6)
	addi $t6, $t6, -4
	sw $t5, 0($t6)
	addi $t6, $t6, -128
	sw $t5, 0($t6)
	addi $t6, $t6, -128
	sw $t5, 0($t6)
	addi $t6, $t6, -128
	sw $t5, 0($t6)
	
	jr $ra # jump back to drawDigit
	
drawOne:
	lw $t5, 0($sp) # pop colour and store in $t5
	addi $sp, $sp, 4 # decrease stack size
	lw $t6, 0($sp) # pop location of left pixel and store in $t6
	addi $sp, $sp, 4 # decrease stack size 	
	
	addi $t6, $t6, 4
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	
	jr $ra # jump backto drawDigit

drawTwo:
	lw $t5, 0($sp) # pop colour and store in $t5
	addi $sp, $sp, 4 # decrease stack size
	lw $t6, 0($sp) # pop location of left pixel and store in $t6
	addi $sp, $sp, 4 # decrease stack size 	
	
	sw $t5, 0($t6)
	addi $t6, $t6, 4
	sw $t5, 0($t6)
	addi $t6, $t6, 4
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, -4 
	sw $t5, 0($t6)
	addi $t6, $t6, -4
	sw $t5, 0($t6)
	addi $t6, $t6, 128 
	sw $t5, 0($t6)
	addi $t6, $t6, 128 
	sw $t5, 0($t6)
	addi $t6, $t6, 4
	sw $t5, 0($t6)
	addi $t6, $t6, 4 
	sw $t5, 0($t6)
	
	jr $ra # jump backto drawDigit

drawThree:
	lw $t5, 0($sp) # pop colour and store in $t5
	addi $sp, $sp, 4 # decrease stack size
	lw $t6, 0($sp) # pop location of left pixel and store in $t6
	addi $sp, $sp, 4 # decrease stack size 	
	
	sw $t5, 0($t6)
	addi $t6, $t6, 4
	sw $t5, 0($t6)
	addi $t6, $t6, 4
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, 128 
	sw $t5, 0($t6)
	addi $t6, $t6, 128 
	sw $t5, 0($t6)
	addi $t6, $t6, -4 
	sw $t5, 0($t6)
	addi $t6, $t6, -4
	sw $t5, 0($t6)
	addi $t6, $t6, -256 
	sw $t5, 0($t6)
	addi $t6, $t6, 4 
	sw $t5, 0($t6)
	
	jr $ra # jump backto drawDigit

drawFour:
	lw $t5, 0($sp) # pop colour and store in $t5
	addi $sp, $sp, 4 # decrease stack size
	lw $t6, 0($sp) # pop location of left pixel and store in $t6
	addi $sp, $sp, 4 # decrease stack size 	
	
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, 4
	sw $t5, 0($t6)
	addi $t6, $t6, 4
	addi $t6, $t6, -128
	addi $t6, $t6, -128
	sw $t5, 0($t6)
	addi $t6, $t6, 128 
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, 128 
	sw $t5, 0($t6)
	addi $t6, $t6, 128 
	sw $t5, 0($t6)
	
	jr $ra # jump backto drawDigit

drawFive:
	lw $t5, 0($sp) # pop colour and store in $t5
	addi $sp, $sp, 4 # decrease stack size
	lw $t6, 0($sp) # pop location of left pixel and store in $t6
	addi $sp, $sp, 4 # decrease stack size 	
	
	addi $t6, $t6, 8
	sw $t5, 0($t6)
	addi $t6, $t6, -4 
	sw $t5, 0($t6)
	addi $t6, $t6, -4
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, 4
	sw $t5, 0($t6)
	addi $t6, $t6, 4
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, -4
	sw $t5, 0($t6)
	addi $t6, $t6, -4
	sw $t5, 0($t6)
	
	jr $ra # jump backto drawDigit

drawSix:
	lw $t5, 0($sp) # pop colour and store in $t5
	addi $sp, $sp, 4 # decrease stack size
	lw $t6, 0($sp) # pop location of left pixel and store in $t6
	addi $sp, $sp, 4 # decrease stack size 	
	
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, 4
	sw $t5, 0($t6)
	addi $t6, $t6, 4
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, -4
	sw $t5, 0($t6)
	addi $t6, $t6, -4
	sw $t5, 0($t6)
	addi $t6, $t6, -128
	sw $t5, 0($t6)
	
	jr $ra # jump backto drawDigit

drawSeven:
	lw $t5, 0($sp) # pop colour and store in $t5
	addi $sp, $sp, 4 # decrease stack size
	lw $t6, 0($sp) # pop location of left pixel and store in $t6
	addi $sp, $sp, 4 # decrease stack size 	
	
	sw $t5, 0($t6)
	addi $t6, $t6, 4
	sw $t5, 0($t6)
	addi $t6, $t6, 4
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	
	jr $ra # jump backto drawDigit

drawEight:
	lw $t5, 0($sp) # pop colour and store in $t5
	addi $sp, $sp, 4 # decrease stack size
	lw $t6, 0($sp) # pop location of left pixel and store in $t6
	addi $sp, $sp, 4 # decrease stack size 	
	
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, -128
	sw $t5, 0($t6)
	addi $t6, $t6, 4
	sw $t5, 0($t6)
	addi $t6, $t6, 4
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, -4
	sw $t5, 0($t6)
	addi $t6, $t6, -4
	sw $t5, 0($t6)
	addi $t6, $t6, -128
	sw $t5, 0($t6)
	addi $t6, $t6, -128
	sw $t5, 0($t6)
	addi $t6, $t6, 4
	sw $t5, 0($t6)
	
	jr $ra # jump backto drawDigit

drawNine:
	lw $t5, 0($sp) # pop colour and store in $t5
	addi $sp, $sp, 4 # decrease stack size
	lw $t6, 0($sp) # pop location of left pixel and store in $t6
	addi $sp, $sp, 4 # decrease stack size 	
	
	addi $t6, $t6, 256
	addi $t6, $t6, 4
	sw $t5, 0($t6)
	addi $t6, $t6, -4
	sw $t5, 0($t6)
	addi $t6, $t6, -128
	sw $t5, 0($t6)
	addi $t6, $t6, -128
	sw $t5, 0($t6)
	addi $t6, $t6, 4
	sw $t5, 0($t6)
	addi $t6, $t6, 4
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	addi $t6, $t6, 128
	sw $t5, 0($t6)
	
	jr $ra # jump backto drawDigit

drawDigit:
	lw $t5, 0($sp) # pop location of top left pixel and store in $t5
	addi $sp, $sp, 4 # decrease stack size
	lw $t6, 0($sp) # pop digit colour and store in $t6
	addi $sp, $sp, 4 # decrease stack size 
	lw $t7, 0($sp) # pop digit value and store in $t7 
	addi $sp, $sp, 4 # decrease stack size
	addi $sp, $sp, -4 # increase stack size 
	sw $ra, 0($sp) # push return address of drawDigit
	
	# draw desired digit
	drawZeroIf:
		beq $t7, $zero, drawZeroElse # if digit is 0, draw it
	drawZeroThen:
		j drawZeroDone
	drawZeroElse:
		addi $sp, $sp, -4 # increase stack size 
		sw $t5, 0($sp) # push location of top left pixel
		addi $sp, $sp, -4 # increase stack size 
		sw $t6, 0($sp) # push colour
		
		jal drawZero # draw digit 0
		j drawNineDone
	drawZeroDone:
	
	drawOneIf:
		li $t8, 1 
		beq $t7, $t8, drawOneElse	
	drawOneThen:
		j drawOneDone
	drawOneElse:
		addi $sp, $sp, -4 # increase stack size 
		sw $t5, 0($sp) # push location of top left pixel
		addi $sp, $sp, -4 # increase stack size 
		sw $t6, 0($sp) # push colour
		
		jal drawOne
		j drawNineDone
	drawOneDone:
	
	drawTwoIf:
		li $t8, 2
		beq $t7, $t8, drawTwoElse
	drawTwoThen:
		j drawTwoDone
	drawTwoElse:
		addi $sp, $sp, -4 # increase stack size 
		sw $t5, 0($sp) # push location of top left pixel
		addi $sp, $sp, -4 # increase stack size 
		sw $t6, 0($sp) # push colour
		
		jal drawTwo
		j drawNineDone
	drawTwoDone:
	
	drawThreeIf:
		li $t8, 3
		beq $t7, $t8, drawThreeElse
	drawThreeThen:
		j drawThreeDone
	drawThreeElse:
		addi $sp, $sp, -4 # increase stack size 
		sw $t5, 0($sp) # push location of top left pixel
		addi $sp, $sp, -4 # increase stack size 
		sw $t6, 0($sp) # push colour
		
		jal drawThree
		j drawNineDone
	drawThreeDone:
		
	drawFourIf:
		li $t8, 4
		beq $t7, $t8, drawFourElse
	drawFourThen:
		j drawFourDone
	drawFourElse:
		addi $sp, $sp, -4 # increase stack size 
		sw $t5, 0($sp) # push location of top left pixel
		addi $sp, $sp, -4 # increase stack size 
		sw $t6, 0($sp) # push colour
		
		jal drawFour
		j drawNineDone
	drawFourDone:
	
	drawFiveIf:
		li $t8, 5
		beq $t7, $t8, drawFiveElse
	drawFiveThen:
		j drawFiveDone
	drawFiveElse:
		addi $sp, $sp, -4 # increase stack size 
		sw $t5, 0($sp) # push location of top left pixel
		addi $sp, $sp, -4 # increase stack size 
		sw $t6, 0($sp) # push colour
		
		jal drawFive
		j drawNineDone
	drawFiveDone:
		
	drawSixIf:
		li $t8, 6
		beq $t7, $t8, drawSixElse
	drawSixThen:
		j drawSixDone
	drawSixElse:
		addi $sp, $sp, -4 # increase stack size 
		sw $t5, 0($sp) # push location of top left pixel
		addi $sp, $sp, -4 # increase stack size 
		sw $t6, 0($sp) # push colour
		
		jal drawSix
		j drawNineDone
	drawSixDone:	
	
	
	drawSevenIf:
		li $t8, 7
		beq $t7, $t8, drawSevenElse
	drawSevenThen:
		j drawSevenDone
	drawSevenElse:
		addi $sp, $sp, -4 # increase stack size 
		sw $t5, 0($sp) # push location of top left pixel
		addi $sp, $sp, -4 # increase stack size 
		sw $t6, 0($sp) # push colour
		
		jal drawSeven 
		j drawNineDone
	drawSevenDone:
	
	drawEightIf:
		li $t8, 8
		beq $t7, $t8, drawEightElse
	drawEightThen:
		j drawEightDone
	drawEightElse:
		addi $sp, $sp, -4 # increase stack size 
		sw $t5, 0($sp) # push location of top left pixel
		addi $sp, $sp, -4 # increase stack size 
		sw $t6, 0($sp) # push colour
		
		jal drawEight 
		j drawNineDone
	drawEightDone:
	
	drawNineIf:
		li $t8, 9
		beq $t7, $t8, drawNineElse
	drawNineThen:
		j drawNineDone
	drawNineElse:
		addi $sp, $sp, -4 # increase stack size 
		sw $t5, 0($sp) # push location of top left pixel
		addi $sp, $sp, -4 # increase stack size 
		sw $t6, 0($sp) # push colour
		
		jal drawNine
		j drawNineDone
	drawNineDone:
	
	lw $t5, 0($sp) # pop return address of drawDigit
	jr $t5 # jump back to drawDigits
	
# draw scoreboard digits
drawDigits:
	lw $t1, 0($sp) # pop 1000's digit
	addi $sp, $sp, 4 # decrease stack size
	lw $t2, 0($sp) # pop 100's digit
	addi $sp, $sp, 4 # decrease stack size
	lw $t3, 0($sp) # pop 10's digit 
	addi $sp, $sp, 4 # decrease stack size
	lw $t4, 0($sp) # pop 1's digit 
	addi $sp, $sp, 4 # decrease stack size
	addi $sp, $sp, -4 # increase stack size
	sw $ra, 0($sp) # push return address of drawDigits into stack
	
	
	addi $sp, $sp, -4 # increase stack size 
	sw $t1, 0($sp) # push 1000's digit into stack 
	lw $t5, blue # $t5 stores the colour blue
	addi $sp, $sp, -4 # increase stack size 
	sw $t5, 0($sp) # push colour blue into stack
	li $t6, 0x100080C0 # $t6 stores top left pixel of 1000's digit 
	addi $sp, $sp, -4 # increase stack size 
	sw $t6, 0($sp) # push location of top left pixel
	jal drawDigit 
	
	addi $sp, $sp, -4 # increase stack size
	sw $t2, 0($sp) # push 100's digit into stack
	lw $t5, blue # $t5 stores the colour blue
	addi $sp, $sp, -4 # increase stack size 
	sw $t5, 0($sp) # push colour blue into stack
	li $t6, 0x100080D0 # $t6 stores top left pixel of 100's digit
	addi $sp, $sp, -4 # increase stack size
	sw $t6, 0($sp) # push location of top lect pixel
	jal drawDigit
	
	addi $sp, $sp, -4 # increase stack size
	sw $t3, 0($sp) # push 10's digit into stack
	lw $t5, blue # $t5 stores the colour blue
	addi $sp, $sp, -4 # increase stack size
	sw $t5, 0($sp) # push colour blue into stack
	li $t6, 0x100080E0 # $t6 stores top left pixel of 10's digit
	addi $sp, $sp, -4 # increase stack size
	sw $t6, 0($sp) # push location of top lect pixel
	jal drawDigit
	
	addi $sp, $sp, -4 # increase stack size
	sw $t4, 0($sp) # push 1's digit into stack
	lw $t5, blue # $t5 stores the colour blue
	addi $sp, $sp, -4 # increase stack size
	sw $t5, 0($sp) # push colour blue into stack
	li $t6, 0x100080F0 # $t6 stores top left pixel of 1's digit
	addi $sp, $sp, -4 # increase stack size
	sw $t6, 0($sp) # push location of top lect pixel
	jal drawDigit
	
	lw $t0, 0($sp) # pop return address of drawDigits 
	addi $sp, $sp, 4 # increase stack size	
	
	jr $t0 # jump back to drawScoreboard

# display and update scoreboard
drawScoreboard:
	addi $sp, $sp, -4 # increase stack size
	sw $ra, 0($sp) # push return address of drawScoreboard into stack
	
	lw $t0, score # $t0 stores player 1 score 
	
	# end game if score somehow exceeds 9999
	scoreTooHighIf:
		li $t1, 10000 # $t1 stores maximum score
		bge $t0, $t1, scoreTooHighElse
	scoreTooHighThen:
		j scoreTooHighDone	
	scoreTooHighElse:
		lw $t0, 0($sp) # pop return address of drawScoreboard and store it in $t6
		addi $sp, $sp, 4 # decrease stack size
		
		j mainLoopDone # end game
	scoreTooHighDone:
	
	li $t1, 1000 # $t1 stores 1000
	div $t0, $t1 
	mflo $t3 # $t3 stores 1000's digit
	mfhi $t2 # $t2 stores score mod 1000
	
	li $t1, 100 # $t1 stores 100
	div $t2, $t1 
	mflo $t4 # $t4 stores 100's digit
	mfhi $t2 # $t2 stores (score mod 1000) mod 100
		
	li $t1, 10 # $t1 stores 10
	div $t2, $t1 
	mflo $t5 # $t5 stores 10's digit
	mfhi $t6 # t6 stores 1's digit
	
	addi $sp, $sp, -4 # increase stack size
	sw $t6, 0($sp) # push 1's digit into stack
	addi $sp, $sp, -4 # increase stack size
	sw $t5, 0($sp) # push 10's digit into stack
	addi $sp, $sp, -4 # increase stack size
	sw $t4, 0($sp) # push 100's digit into stack
	addi $sp, $sp, -4 # increase stack size
	sw $t3, 0($sp) # push 1000's digit into stack
	
	jal drawDigits
	
	
	lw $t0, 0($sp) # pop return address of drawScoreboard and store it in $t6
	addi $sp, $sp, 4 # decrease stack size
	
	jr $t0 # jump back to main
				
# change platforms if player too high in-game
changePlatforms:
	addi $sp, $sp, -4 # increase stack size
	sw $ra, 0($sp) # push return address of changePlatforms into stack
	
	move $t0, $s0 # $t0 stores the player's (body) current location, drawPlayer overwrites $t0
	lw $t1, newPlatformsRow # $t1 stores the last element s.t. touching any unit above triggers new platform change
	
	changePlatformsIf:
		ble $t0, $t1, changePlatformsElse # if player (body) is high enough, change platforms
	changePlatformsThen:
		jal drawPlatform1NoRandom # redraw platform 1 (in case of doodler collision)
		jal drawPlatform2NoRandom # redraw platform 1 (in case of doodler collision)
		jal drawPlatform3NoRandom # redraw platform 1 (in case of doodler collision)
		j changePlatformsDone 
	changePlatformsElse:

		
		addi $sp, $sp, -4 # increase stack size
		sw $s1, 0($sp) # push into stack location of platform 1 (first element) 
		
		jal undrawPlatform # erase current platform 1
		
		platform1NewIf:
			lw $t2, platform1Row # $t2 stores the row of platform 1
			li $t5, 0x10008F80 # $t5 stores the first unit box of the last row
			bge $s1, $t5, platform1NewElse # if platform 1 currently on last row make new one, else shift it down by one row
		platform1NewThen:
			addi $t2, $t2, 128 # shift platform 1 row down by one row, $t2 stores first element of row
			sw $t2, platform1Row # update platform1Row
			addi $s1, $s1, 128 # shift platform 1 row down by one row, $s1 stores first element of platform
			
			jal drawPlatform1NoRandom
			
			j platform1NewDone
		platform1NewElse:
			lw $t6, displayAddress # $t6 stores the display base address
			move $t2, $t6 
			sw $t2, platform1Row # generate new platform 1 at top of screen
			
			jal drawPlatform1
	
			lw $s1, 0($sp) # pop location of platform 1 (leftmost platform block) in $s1
			addi $sp, $sp, 4 # decrease stack size
		platform1NewDone:
		
		addi $sp, $sp, -4 # increase stack size
		sw $s2, 0($sp) # push into stack location of platform 2 (first element) 
		
		jal undrawPlatform # erase current platform 2
		
		platform2NewIf:
			lw $t3, platform2Row # $t3 stores the row of platform 2
			li $t5, 0x10008F80 # $t5 stores the first unit box of the last row
			bge $s2, $t5, platform2NewElse # if platform 2 currently on last row make new one, else shift it down by one row
		platform2NewThen:
			addi $t3, $t3, 128 # shift platform 2 row down by one row
			sw $t3, platform2Row # update platform2Row
			addi $s2, $s2, 128 # shift platform 2 row down by one row
			
			jal drawPlatform2NoRandom	
					
			j platform2NewDone
		platform2NewElse:
			lw $t6, displayAddress # $t6 stores the display base address
			move $t3, $t6 
			sw $t3, platform2Row # generate new platform 2 at top of screen
			
			jal drawPlatform2
	
			lw $s2, 0($sp) # pop location of platform 2 (leftmost platform block) in $s2
			addi $sp, $sp, 4 # decrease stack size
		platform2NewDone:
		
		addi $sp, $sp, -4 # increase stack size
		sw $s3, 0($sp) # push into stack location of platform 3 (first element) 
		
		jal undrawPlatform # erase current platform 3
		
		platform3NewIf:
			lw $t4, platform3Row # $t4 stores the row of platform 3
			li $t5, 0x10008F80 # $t5 stores the first unit box of the last row
			bge $s3, $t5, platform3NewElse # if platform 3 currently on last row make new one, else shift it down by one row
		platform3NewThen:
			addi $t4, $t4, 128 # shift platform 3 row down by one row
			sw $t4, platform3Row # update platform1Row
			addi $s3, $s3, 128 # shift platform 3 row down by one row
			
			jal drawPlatform3NoRandom
			
			j platform3NewDone
		platform3NewElse:
			lw $t6, displayAddress # $t6 stores the display base address
			move $t4, $t6 
			sw $t4, platform3Row # generate new platform 3 at top of screen
			
			jal drawPlatform3
	
			lw $s3, 0($sp) # pop location of platform 3 (leftmost platform block) in $s3
			addi $sp, $sp, 4 # decrease stack size
		platform3NewDone:	
	changePlatformsDone:
	
	lw $t6, 0($sp) # pop return address of changePlatforms and store it in $t6
	addi $sp, $sp, 4 # decrease stack size
	
	jr $t6 # jump back to main

drawPlatform1NoRandom:
	addi $sp, $sp, -4 # increase stack size
	sw $ra, 0($sp) # push return address of drawPlatform1NoRandom into stack
	
	lw $t0, platformLength # $t0 stores the length of the platform
	lw $t1, green # $t1 stores the green colour
	lw $t2, platform1Row # $t2 stores the address of the first display unit on platform 1's row
	
	drawPlatform1LoopNoRandomInit:
		sub $t3, $s1, $t2  # $t3 stores the offset
		
		# li $t3, 100
		add $t0, $t0, $t3 # calculate rightmost platform unit block
		add $t4, $t2, $t3 # $t4 stores the index
		
		lw $t5, 0($sp) # pop return address of drawPlatform1NoRandom and store in $t5
		addi $sp, $sp, 4 # decrease stack size
	drawPlatform1NoRandomLoop:
		sw $t1, 0($t4) # colour the unit green
		addi $t3, $t3, 4 # increase the offset by 4 (each colour is 4 bytes)
		add $t4, $t2, $t3 # $t4 stores the next index
		bne $t0, $t3, drawPlatform1NoRandomLoop # if offset < platformLength, loop again to continue drawing platform
	drawPlatform1NoRandomDone:
	
	jr $t5 # jump back to changePlatforms

drawPlatform2NoRandom:
	addi $sp, $sp, -4 # increase stack size
	sw $ra, 0($sp) # push return address of drawPlatform2NoRandom into stack
	
	lw $t0, platformLength # $t0 stores the length of the platform
	lw $t1, green # $t1 stores the green colour
	lw $t2, platform2Row # $t2 stores the address of the first display unit on platform 2's row
	
	drawPlatform2NoRandomLoopInit:
		sub $t3, $s2, $t2  # $t3 stores the offset
		
		# li $t3, 100
		add $t0, $t0, $t3 # calculate rightmost platform unit block
		add $t4, $t2, $t3 # $t4 stores the index
		
		lw $t5, 0($sp) # pop return address of drawPlatform2NoRandom and store in $t5
		addi $sp, $sp, 4 # decrease stack size
	drawPlatform2NoRandomLoop:
		sw $t1, 0($t4) # colour the unit green
		addi $t3, $t3, 4 # increase the offset by 4 (each colour is 4 bytes)
		add $t4, $t2, $t3 # $t4 stores the next index
		bne $t0, $t3, drawPlatform2NoRandomLoop # if offset < platformLength, loop again to continue drawing platform
	drawPlatform2NoRandomDone:
	
	jr $t5 # return to changePlatforms
	
drawPlatform3NoRandom:
	addi $sp, $sp, -4 # increase stack size
	sw $ra, 0($sp) # push return address of drawPlatform3NoRandom into stack
	
	lw $t0, platformLength # $t0 stores the length of the platform
	lw $t1, green # $t1 stores the green colour
	lw $t2, platform3Row # $t2 stores the address of the first display unit on platform 1's row
	
	drawPlatform3NoRandom1LoopInit:
		sub $t3, $s3, $t2  # $t3 stores the offset
		
		# li $t3, 100
		add $t0, $t0, $t3 # calculate rightmost platform unit block
		add $t4, $t2, $t3 # $t4 stores the index
		
		lw $t5, 0($sp) # pop return address of drawPlatform3NoRandom3 and store in $t5
		addi $sp, $sp, 4 # decrease stack size
	drawPlatform3NoRandomLoop:
		sw $t1, 0($t4) # colour the unit green
		addi $t3, $t3, 4 # increase the offset by 4 (each colour is 4 bytes)
		add $t4, $t2, $t3 # $t4 stores the next index
		bne $t0, $t3, drawPlatform3NoRandomLoop # if offset < platformLength, loop again to continue drawing platform
	drawPlatform3NoRandomDone:
	
	jr $t5 # return to changePlatforms

# erase a platform
undrawPlatform:
	lw $t6, 0($sp) # pop location of platform (first element) from stack and store it in $t6
	addi $sp, $sp, 4 # decrease stack size
	addi $sp, $sp, -4 # increase stack size
	sw $ra, 0($sp) # push return address of undrawPlatform into stack
	
	undrawPlatformLoopInit:
		lw $t7, platformLength # $t7 stores the last block of the platform
		add $t7, $t7, $t6  
		lw $t8, backgroundColour # $t8 stores the background colour
	undrawPlatformLoop:
		sw $t8, 0($t6) # colour the unit background colour
		addi $t6, $t6, 4 # go to unit on the right, each colour is 4 bytes
		bne $t6, $t7, undrawPlatformLoop # loop until platform entirely erased
	undrawPlatformLoopDone:
	
	lw $t6, 0($sp) # pop return address of undrawPlatform from stack and store it in $t9
	addi $sp, $sp, 4 # decrease stack size
	
	jr $t6 # jump back to changePlatforms

# jump up if enough "energy", otherwise fall down; always fall down if too high
jumpUp:
	addi $sp, $sp, -4 # increase stack size
	sw $ra, 0($sp) # push return address of jumpUp into the stack
	
	# force doodler to fall down if it will jump higher than (out of) the screen
	forceFallDownIf:
		ble $s0, 0x10008100, forceFallDownElse 
	forceFallDownThen:
		j forceFallDownDone
	forceFallDownElse:
		li $s4, 50
	forceFallDownDone:
	
	jumpUpIf:
		lw $t1, maxJumpHeight # t1 stores the maximum jump height
		addi $s4, $s4, 1 # continue increasing jump counter
		ble $s4, $t1, jumpUpElse # if current jump height <= max jump height, jump up, else fall down
	jumpUpThen:
		jal fallDown
		j jumpUpDone
	jumpUpElse:
		jal undrawPlayer
		addi $s0, $s0, -128 # move player up 1 block i.e. jump up
		jal drawPlayer # draw player at new location
	jumpUpDone:
	
	lw $t1, 0($sp) # pop return address of jumpUp and store it in $t1
	addi $sp, $sp, 4 # decrease stack size
	
	jr $t1 # return to checkCollisions
	
# fall down
fallDown:
	addi $sp, $sp, -4 # increase stack size
	sw $ra, 0($sp) # push return address of fallDownm into the stack
	
	jal undrawPlayer
	addi $s0, $s0, 128 # move player down 1 block, i.e. fall down
	jal drawPlayer # draw player at new location
	
	lw $t1, 0($sp) # pop return address of fallDown and store it in $t1
	addi $sp, $sp, 4 # decrease stack size
	
	jr $t1 # return to checkCollisions
	
	
# check for and react to various collisions
checkCollisions:
	addi $sp, $sp, -4 # increase stack size
	sw $ra, 0($sp) # push return address of checkCollisions into the stack
	
	move $t0, $s0 # $t0 stores the player's (body) current location 
	
	gameOverIf:
		li $t1, 0x10008F80 # $t1 stores the first display unit (from left to right) of the last row
		bge $t0, $t1, gameOverElse # if player position >= first display unit of last row, game over
	gameOverThen:
		j gameOverDone # continue checking for other events
	gameOverElse:
		j mainLoopDone # jump to program termination
	gameOverDone:
	
	addi $t1, $s0, 128 # t1 stores the location of the block right under the player
	lw $t1, 0($t1) # t1 now stores the colour of that block 
	
	startJumpingUpIf:
		lw $t2, green # t2 stores the colour green
		beq $t2, $t1, startJumpingUpElse
	startJumpingUpThen:
		jal jumpUp # jump up or fall down depending on energy
		j startJumpingUpDone
	startJumpingUpElse:
	
		# don't reset player energy if player just came from below block
		startJumpingUp2If:
			lw $t3, maxJumpHeight
			bge $s4, $t3, startJumpingUp2Else
		startJumpingUp2Then:
			jal jumpUp # player jumps up	
			j startJumpingUp2Done 
		startJumpingUp2Else:
			gainPointIf:
				addi $t1, $s0, 128 # t1 stores the location of the block right under the player
				lw $t4, minimumHeightForPoint # $t4 holds min height for platform landing to count as a point
				ble $t1, $t4, gainPointElse # if platform block below doodler <= min. height for point score +1
			gainPointThen:
				j gainPointDone
			gainPointElse:
				lw $t5, score # add 1 to the score
				addi $t5, $t5, 1 
				sw $t5, score
				jal showNotification
			gainPointDone:
			li $s4, 0 # reset jump counter i.e. player energy
			jal jumpUp # player jumps up
		startJumpingUp2Done:
	startJumpingUpDone:
		
	lw $t0, 0($sp) # pop return address of checkCollisions from stack and store it in $t0
	addi $sp, $sp, 4 # decrease stack size
	
	jr $t0 # jump back to main
	
# erase character to prepare for redrawing
undrawPlayer:
	addi $sp, $sp, -4 # increase stack size
	sw $ra, 0($sp) # push return addr5ess of undrawPlayer into stack
	
	move $t8, $s0
	lw $t9, backgroundColour # $t9 stores the backgroundColour
	sw $t9, 0($t8) # colour the player body white
	addi $t8, $t8, -128 # colour the player head white
	sw $t9, 0($t8)
	
	lw $t8, 0($sp) # pop the return address of undrawPlayer and store it in $t8
	addi $sp, $sp, 4 # decrease stack size
	
	jr $t8 # jump back	

# detect and respond to keyboard input
keyboardInput:
	addi $sp, $sp, -4 # increase stack size
	sw $ra, 0($sp) # push return address of drawPlayer into stack
	
	lw $t0, 0xffff0000  # load keystroke event value

	
	keyboardInputIf:
		beq $t0, 1, keyboardInputElse # process input
	keyboardInputThen:
		j keyboardInputDone # return to main
	keyboardInputElse:
		lw $t1, 0xffff0004 # store ASCII value of key pressed
		
		characterIsPIf:
			 beq $t1, 0x070, characterIsPElse # check if p is present
		characterIsPThen:
			j characterIsPDone
		characterIsPElse:
			# pause game until p is pressed again
			sw $zero, 0xffff0004
			pauseLoopInit:
			pauseLoop:				
				addi $sp, $sp, -4 # increase stack size
				li $t1, 0x100087B8 # $t1 stores the top left pixel of the letter
				sw $t1, 0($sp) # push top left pixel
				addi $sp, $sp, -4 # increase stack size
				lw $t0, black # $t0 stores black
				sw $t0, 0($sp) # push colour into stack
				jal drawP						
					
				lw $t1, 0xffff0004
				bne $t1, 0x070, pauseLoop # press p to unpause
			pauseLoopDone:
				addi $sp, $sp, -4 # increase stack size
				li $t1, 0x100087B8 # $t1 stores the top left pixel of the letter
				sw $t1, 0($sp) # push top left pixel
				addi $sp, $sp, -4 # increase stack size
				lw $t0, white # $t0 stores white
				sw $t0, 0($sp) # push colour into stack
				jal drawP
					
			sw $zero, 0xffff0004
			j keyboardInputDone
		characterIsPDone:
		
		characterIsJIf: 
			beq $t1, 0x06A, characterIsJElse # check if j is pressed
		characterIsJThen:
			j characterIsJDone
		characterIsJElse:
			jal undrawPlayer
			addi $s0, $s0, -8
			j keyboardInputDone
		characterIsJDone:
		
		characterIsKIf:
			beq $t1, 0x06B, characterIsKElse # check if k is pressed
		characterIsKThen:
			j characterIsKDone
		characterIsKElse:
			jal undrawPlayer
			addi $s0, $s0, 8
			j keyboardInputDone
		characterIsKDone:
		
	keyboardInputDone:
		lw $t0, 0($sp) # pop returh address of drawPlayer and store in $t0
		addi $sp, $sp, 4 # decrease stack size
		
		jr $t0 # jump back to main

# draw player character
drawPlayer:
	addi $sp, $sp, -4 # increase stack size
	sw $ra, 0($sp) # push return address of drawPlayer into stack
	
	lw $t0, blue # $t1 stores the black colour
	sw $t0, 0($s0) # color the player character blue (body)
	move $t1, $s0 # color the player character blue (head) 
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
	
	lw $s2, 0($sp) # pop location of platform 2 (leftmost platform block) and store it in $s2
	addi $sp, $sp, 4 # decrease stack size
	
	jal drawPlatform3
	
	lw $s3, 0($sp) # pop location of platform 3 (leftmost platform block) and store it in $s3
	addi $sp, $sp, 4 # decrease stack size	
	lw $t0, 0($sp) # pop return address of drawPlatforms from stack and store in $t0
	addi $sp, $sp, 4 # decrease stack size	
	
	jr $t0 # return to main

drawPlatform1:
	addi $sp, $sp, -4 # increase stack size
	sw $ra, 0($sp) # push return address of drawPlatform1 into stack
	
	lw $t0, newPlatformLength # $t0 stores the length of the platform
	sw $t0, platformLength # update platform length to new value
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
		sw $t4, 0($sp) # push the memory address of the leftmost platform1 unit into stack to save location of platform1
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
	
	lw $t0, newPlatformLength # $t0 stores the length of the platform
	sw $t0, platformLength # update platform length to new value
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
		sw $t4, 0($sp) # push the memory address of the leftmost platform2 unit into stack to save location of platform2
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
	
	lw $t0, newPlatformLength # $t0 stores the length of the platform
	sw $t0, platformLength # update platform length to new value
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

# colour the background white (in loop)
drawBackground:
	addi $sp, $sp, -4 # increase stack size
	sw $ra, 0($sp) # push return address of drawBackground into stack 
	
	backgroundLoopInit:
		add $t0, $zero, $zero # $t0 stores the offset (starting at 0)
		lw $t1, arraySize # $t1 stores the array size
		lw $t2, displayAddress # $t2 stores the base address for the display
		lw $t3, backgroundColour # $t3 stores the background colour
		add $t4, $t2, $t0 # $t4 stores the index 
	backgroundLoop:
		skipPlatformIf:
			lw $t6, 0($t4) # $t6 stores the colour of the block
			beq $t6, $t3, skipPlatformElse # if block not green (platform) paint background colour
		skipPlatformThen:
			addi $t0, $t0, 4 # increase the offset by 4 (each color is 4 bytes)
			add $t4, $t2, $t0 # $t4 stores the next index
			backgroundLoopEndIf:
				bne $t0, $t1, backgroundLoopEndElse # if index < 4096, loop again
			backgroundLoopEndThen:
				j backgroundLoopDone
			backgroundLoopEndElse:
				j backgroundLoop
			backgroundLoopEndDone:
		skipPlatformElse:
			sw $t3, 0($t4) # color the unit white
			addi $t0, $t0, 4 # increase the offset by 4 (each color is 4 bytes)
			add $t4, $t2, $t0 # $t4 stores the next index
			backgroundLoopEnd2If:
				bne $t0, $t1, backgroundLoopEnd2Else # if index < 4096, loop again
			backgroundLoopEnd2Then:
				j backgroundLoopDone
			backgroundLoopEnd2Else:
				j backgroundLoop
			backgroundLoopEnd2Done:
		skipPlatformDone:	
	backgroundLoopDone:
	
	lw $t5, 0($sp) # # pop return address of drawPlatform1 and store in $t5
	addi $sp, $sp, 4 # decrease stack size
	
	jr $t5 # return to main

# colour the background white initially
drawBackgroundInitial:
	addi $sp, $sp, -4 # increase stack size
	sw $ra, 0($sp) # push return address of drawBackground into stack 
	
	backgroundInitialLoopInit:
		add $t0, $zero, $zero # $t0 stores the offset (starting at 0)
		lw $t1, arraySize # $t1 stores the array size
		lw $t2, displayAddress # $t2 stores the base address for the display
		lw $t3, backgroundColour # $t3 stores the colour code for white
		add $t4, $t2, $t0 # $t4 stores the index 
	backgroundInitialLoop:
		skipPlatformInitialIf:
			lw $t6, 0($t4) # $t6 stores the colour of the block
			lw $t7, green # $t7 stores the colour green
			bne $t6, $t7, skipPlatformInitialElse # if block not green (platform) paint background colour
		skipPlatformInitialThen:
			addi $t0, $t0, 4 # increase the offset by 4 (each color is 4 bytes)
			add $t4, $t2, $t0 # $t4 stores the next index
			backgroundLoopInitialEndIf:
				bne $t0, $t1, backgroundLoopInitialEndElse # if index < 4096, loop again
			backgroundLoopInitialEndThen:
				j backgroundLoopInitialDone
			backgroundLoopInitialEndElse:
				j backgroundInitialLoop
			backgroundLoopInitialEndDone:
		skipPlatformInitialElse:
			sw $t3, 0($t4) # color the unit white
			addi $t0, $t0, 4 # increase the offset by 4 (each color is 4 bytes)
			add $t4, $t2, $t0 # $t4 stores the next index
			backgroundLoopInitialEnd2If:
				bne $t0, $t1, backgroundLoopInitialEnd2Else # if index < 4096, loop again
			backgroundLoopInitialEnd2Then:
				j backgroundLoopInitialDone
			backgroundLoopInitialEnd2Else:
				j backgroundInitialLoop
			backgroundLoopInitialEnd2Done:
		skipPlatformInitialDone:	
	backgroundLoopInitialDone:
	
	lw $t5, 0($sp) # # pop return address of drawPlatform1 and store in $t5
	addi $sp, $sp, 4 # decrease stack size
	
	jr $t5 # return to main
	
