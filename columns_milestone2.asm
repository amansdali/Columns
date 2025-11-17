################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Columns.
#
# Student 1: Emilia Ma, 1011228930
# Student 2: Amanda Li, 1011028558
#
# We assert that the code submitted here is entirely our own 
# creation, and will indicate otherwise when it is not.
#
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       256
# - Unit height in pixels:      256
# - Display width in pixels:    4
# - Display height in pixels:   4
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000
# Colours
RED:
    .word 0x00ff0000
ORANGE:
    .word 0x00ffa500
YELLOW:
    .word 0x00ffff00
GREEN:
    .word 0x0000ff00
BLUE:
    .word 0x000000ff
PURPLE:
    .word 0x00800080
GRAY:
    .word 0x00808080
BLACK:
    .word 0x00000000

##############################################################################
# Mutable Data
##############################################################################
curr_x: # the x position of the player in the 6x13 grid
    .byte 0x02
curr_y: # the y position of the player in the 6x13 grid
    .byte 0x00
curr_gem_clrs: # the colours of the current gems, top to bottom
    .space 24
grid:   # the 6x13 grid representing the playing field, storing the colour in each position on the grid
    .space 312

##############################################################################
# Code
##############################################################################
	.text
	.globl main

    # Run the game.
main:
    # Initialize the game
    lw $t0, ADDR_DSPL       # $t0 = base address for display
    
    jal draw_gems
    jal draw_background
    jal game_loop
    
    j exit
    
##  The draw_pixel function
##  - Draws a pixel from a given X and Y coordinate 
#
# $a0 = the x coordinate
# $a1 = the y coordinate
# $a2 = the colour
# $t0 = the top left corner of the bitmap display
# $t1 = the location of the pixel
draw_pixel:
sll $a0, $a0, 3         # multiply the X coordinate by 8 to get the horizontal offset
add $t1, $t0, $a0       # add this horizontal offset to $t0, store the result in $t1
sll $a1, $a1, 9         # multiply the Y coordinate by 512 to get the vertical offset
add $t1, $t1, $a1       # add this vertical offset to $t1

sw $a2, 0( $t1 )        # paint the pixel the colour

addi $t1, $t1, 4     # add 4 horizontal offset
sw $a2, 0( $t1 )        # paint the pixel the colour

addi $t1, $t1, 256     # add 256 vertical offset
sw $a2, 0( $t1 )        # paint the pixel the colour

addi $t1, $t1, -4     # add -4 horizontal offset
sw $a2, 0( $t1 )        # paint the pixel the colour

jr $ra                  # return to the calling program.

##  The draw_background function
##  - Draws the background hardcoded
#
draw_background:
# initialize register $a2 (set colour)
    lw $t1, GRAY           # load gray hex code to $t1
    add $a2, $zero, $t1     # set colour to gray
    
    # loop variables
    li $t2, 12  # starting x coordinate
    li $t3, 8   # starting y coordinate
    li $t4, 20  # ending x coordinate (exclusive)
    li $t5, 22  # ending y coordinate (inclusive)
    add $t6, $t2, $zero  # coordinate variable to change (x)
    
    # draw the top and bottom horizontal lines of the rectangle
    background_hline_loop_start:
        beq $t6, $t4, background_hline_loop_end # check if $t6 has reached the ending x coordinate
        # set registers $a0 and $a1 to the x and y coordinates
        add $a0, $zero, $t6     # set X coordinate to value of $t6
        add $a1, $zero, $t3     # set Y coordinate to value of $t3
        
        # save to stack
        addi $sp, $sp, -4               # move the stack pointer to an empty location
        sw $ra, 0($sp)                  # push $ra onto the stack
        addi $sp, $sp, -4               # move the stack pointer to an empty location
        sw $a0, 0($sp)                  # push $a0 onto the stack
        addi $sp, $sp, -4               # move the stack pointer to an empty location
        sw $a1, 0($sp)                  # push $a1 onto the stack
        addi $sp, $sp, -4               # move the stack pointer to an empty location
        sw $a2, 0($sp)                  # push $a2 onto the stack
        
        jal draw_pixel          # call the draw pixel_function.
        add $a0, $zero, $t6     # set X coordinate to value of $t6
        add $a1, $zero, $t5     # set Y coordinate to value of $t5
        jal draw_pixel          # call the draw pixel_function.
        
        # recover from stack
        lw $a2, 0($sp)                  # pop $a2 from the stack
        addi $sp, $sp, 4                # move the stack pointer to the top stack element
        lw $a1, 0($sp)                  # pop $a1 from the stack
        addi $sp, $sp, 4                # move the stack pointer to the top stack element
        lw $a0, 0($sp)                  # pop $a0 from the stack
        addi $sp, $sp, 4                # move the stack pointer to the top stack element
        lw $ra, 0($sp)                  # pop $ra from the stack
        addi $sp, $sp, 4                # move the stack pointer to the top stack element
        
        addi $t6, $t6, 1        # increment $t6 (horizontally).
        j background_hline_loop_start            # jump to the start of the loop
    background_hline_loop_end:
    
    addi $t6, $t3, 1  # coordinate variable to change (y)
    # draw the left and right vertical lines of the rectangle
    background_vline_loop_start:
        beq $t6, $t5, background_vline_loop_end # check if $t6 has reached the ending y coordinate
        # set registers $a0 and $a1 to the x and y coordinates
        add $a0, $zero, $t2     # set X coordinate to value of $t2
        add $a1, $zero, $t6     # set Y coordinate to value of $t6
        
        # save to stack
        addi $sp, $sp, -4               # move the stack pointer to an empty location
        sw $ra, 0($sp)                  # push $ra onto the stack
        addi $sp, $sp, -4               # move the stack pointer to an empty location
        sw $a0, 0($sp)                  # push $a0 onto the stack
        addi $sp, $sp, -4               # move the stack pointer to an empty location
        sw $a1, 0($sp)                  # push $a1 onto the stack
        addi $sp, $sp, -4               # move the stack pointer to an empty location
        sw $a2, 0($sp)                  # push $a2 onto the stack
        
        jal draw_pixel          # call the draw pixel_function.
        add $a1, $zero, $t6     # set Y coordinate to value of $t6
        addi $a0, $t4, -1       # set X coordinate to value of $t4 - 1
        jal draw_pixel          # call the draw pixel_function.
        
        # recover from stack
        lw $a2, 0($sp)                  # pop $a2 from the stack
        addi $sp, $sp, 4                # move the stack pointer to the top stack element
        lw $a1, 0($sp)                  # pop $a1 from the stack
        addi $sp, $sp, 4                # move the stack pointer to the top stack element
        lw $a0, 0($sp)                  # pop $a0 from the stack
        addi $sp, $sp, 4                # move the stack pointer to the top stack element
        lw $ra, 0($sp)                  # pop $ra from the stack
        addi $sp, $sp, 4                # move the stack pointer to the top stack element
        
        addi $t6, $t6, 1        # increment $t6 (vertically).
        j background_vline_loop_start            # jump to the start of the loop
    background_vline_loop_end:
    jr $ra

##  The generate_gems function
##  - Generate the three new gems with random colours to be placed
#
generate_gems:
    # save to stack
    addi $sp, $sp, -4               # move the stack pointer to an empty location
    sw $ra, 0($sp)                  # push $ra onto the stack
    
    li $t4, 0
    li $t5, 3
    
    generate_gems_loop_start:
    beq $t4, $t5, generate_gems_loop_end
    
        la $t9, curr_gem_clrs
     
        jal rand_num
        add $t1, $a0, $zero
        
        li $t2, 0
        beq $t1, $t2, generate_gems_if_0
        li $t2, 1
        beq $t1, $t2, generate_gems_if_1
        li $t2, 2
        beq $t1, $t2, generate_gems_if_2
        li $t2, 3
        beq $t1, $t2, generate_gems_if_3
        li $t2, 4
        beq $t1, $t2, generate_gems_if_4
        li $t2, 5
        beq $t1, $t2, generate_gems_if_5
        generate_gems_if_0:
            lw $t1, RED
            j generate_gems_condition_end
        generate_gems_if_1:
            lw $t1, ORANGE
            j generate_gems_condition_end
        generate_gems_if_2:
            lw $t1, YELLOW
            j generate_gems_condition_end
        generate_gems_if_3:
            lw $t1, GREEN
            j generate_gems_condition_end
        generate_gems_if_4:
            lw $t1, BLUE
            j generate_gems_condition_end
        generate_gems_if_5:
            lw $t1, PURPLE
            j generate_gems_condition_end
        generate_gems_condition_end:
            # set the gem to the generated colour
            sll $t3, $t4, 2     # offset is index*4
            add $t6, $t3, $t9   # address of the colour to update
            sw $t1, 0($t6)      # set the colour
        addi $t4, $t4, 1
        j generate_gems_loop_start
    generate_gems_loop_end:
        # recover from stack
        lw $ra, 0($sp)                  # pop $ra from the stack
        addi $sp, $sp, 4                # move the stack pointer to the top stack element
        
        jr $ra

##  The draw_skydiver function
##  - Draws the current gem stack thing at the current location, with the precondition that it is valid location
#
draw_skydiver:
    # save to stack
    addi $sp, $sp, -4               # move the stack pointer to an empty location
    sw $ra, 0($sp)                  # push $ra onto the stack
    
    li $t4, 0
    li $t5, 3
    
    lw $t6, 
    
    draw_gems_loop_start:
    beq $t4, $t5, draw_gems_loop_end
        # draw gem
        addi $a0, $zero, 15     # set X coordinate to 15
        addi $a1, $t4, 9        # set Y coordinate to 9 + $t4
        add $a2, $zero, $t1     # set colour
        jal draw_pixel          # call the draw pixel_function.

        addi $t4, $t4, 1
        j draw_gems_loop_start
    draw_gems_loop_end:
        # recover from stack
        lw $ra, 0($sp)                  # pop $ra from the stack
        addi $sp, $sp, 4                # move the stack pointer to the top stack element
        
        jr $ra

game_loop:
    # 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (capsules)
	# 3. Draw the screen
	# 4. Sleep

    # 5. Go back to Step 1
    j game_loop

    # Generate a random integer
rand_num:
    li $v0, 42              # command for random number generation with a maximum
    li $a0, 0               # random number generator ID
    li $a1, 6               # maximum value, exclusive
    syscall                 # value is in a0
    jr $ra

    # Sleep
sleep:
    li $v0, 32              # command for sleep
    li $a0, 1000            # number of milliseconds (1000 = 1 second)
    syscall
    jr $ra

    # Terminate program gracefully
exit:
    li $v0, 10              # terminate the program gracefully
    syscall
