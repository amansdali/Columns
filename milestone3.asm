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
curr_gem_clrs: # the colours of the current gems, top to bottom
    .space 12
grid:   # the 6x13 grid representing the playing field, storing the colour in each position on the grid
    .space 312
curr_x: # the x position of the player in the 6x13 grid
    .byte 0x02
curr_y: # the y position of the player in the 6x13 grid
    .byte 0x00

##############################################################################
# Code
##############################################################################
	.text
	.globl main

    # Run the game.
main:
    # Initialize the game
    lw $t0, ADDR_DSPL       # $t0 = base address for display
    
    jal generate_gems
    jal draw_skydiver
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
convert_pixel:
     lw $t0, ADDR_DSPL       # $t0 = base address for display
    sll $a0, $a0, 3         # multiply the X coordinate by 8 to get the horizontal offset
    add $t1, $t0, $a0       # add this horizontal offset to $t0, store the result in $t1
    sll $a1, $a1, 9         # multiply the Y coordinate by 512 to get the vertical offset
    add $t1, $t1, $a1  
    add $v0, $t1, $zero
    jr $ra
    
draw_pixel:
    # save to stack
    addi $sp, $sp, -4               # move the stack pointer to an empty location
    sw $ra, 0($sp)                  # push $ra onto the stack
    addi $sp, $sp, -4               # move the stack pointer to an empty location
    sw $t1, 0($sp)                  # push $t1 onto the stack
    addi $sp, $sp, -4               # move the stack pointer to an empty location
    sw $t2, 0($sp)                  # push $t2 onto the stack
    addi $sp, $sp, -4               # move the stack pointer to an empty location
    sw $t3, 0($sp)                  # push $t3 onto the stack
    addi $sp, $sp, -4               # move the stack pointer to an empty location
    sw $t4, 0($sp)                  # push $t4 onto the stack
    
    jal convert_pixel
    add $t1, $zero, $v0
    
    sw $a2, 0( $t1 )        # paint the pixel the normal colour
    
    addi $t1, $t1, 4        # add 4 horizontal offset
    sw $a2, 0( $t1 )        # paint the pixel the normal colour
    
    addi $t1, $t1, 256      # add 256 vertical offset
    sw $a2, 0( $t1 )        # paint the pixel the normal colour
    
    addi $t1, $t1, -4       # add -4 horizontal offset
    sw $a2, 0( $t1 )        # paint the pixel the normal colour
    
    # recover from stack
    lw $t4, 0($sp)                  # pop $t4 from the stack
    addi $sp, $sp, 4                # move the stack pointer to the top stack element
    lw $t3, 0($sp)                  # pop $t3 from the stack
    addi $sp, $sp, 4                # move the stack pointer to the top stack element
    lw $t2, 0($sp)                  # pop $t2 from the stack
    addi $sp, $sp, 4                # move the stack pointer to the top stack element
    lw $t1, 0($sp)                  # pop $t1 from the stack
    addi $sp, $sp, 4                # move the stack pointer to the top stack element
    lw $ra, 0($sp)                  # pop $ra from the stack
    addi $sp, $sp, 4                # move the stack pointer to the top stack element
    
    jr $ra                  # return to the calling program.

##  The draw_gem function
##  - Draws a gem from a given X and Y coordinate 
#
# $a0 = the x coordinate
# $a1 = the y coordinate
# $a2 = the colour
# $t0 = the top left corner of the bitmap display
# $t1 = the location of the pixel
draw_gem:
    # save to stack
    addi $sp, $sp, -4               # move the stack pointer to an empty location
    sw $ra, 0($sp)                  # push $ra onto the stack
    addi $sp, $sp, -4               # move the stack pointer to an empty location
    sw $t1, 0($sp)                  # push $t1 onto the stack
    addi $sp, $sp, -4               # move the stack pointer to an empty location
    sw $t2, 0($sp)                  # push $t2 onto the stack
    addi $sp, $sp, -4               # move the stack pointer to an empty location
    sw $t3, 0($sp)                  # push $t3 onto the stack
    addi $sp, $sp, -4               # move the stack pointer to an empty location
    sw $t4, 0($sp)                  # push $t4 onto the stack
    
    lw $t0, ADDR_DSPL       # $t0 = base address for display
    sll $a0, $a0, 3         # multiply the X coordinate by 8 to get the horizontal offset
    add $t1, $t0, $a0       # add this horizontal offset to $t0, store the result in $t1
    sll $a1, $a1, 9         # multiply the Y coordinate by 512 to get the vertical offset
    add $t1, $t1, $a1       # add this vertical offset to $t1
    
    jal lighten_colour
    sw $v1, 0( $t1 )        # paint the pixel the colour
    
    addi $t1, $t1, 4        # add 4 horizontal offset
    sw $a2, 0( $t1 )        # paint the pixel the normal colour
    
    jal darken_colour
    addi $t1, $t1, 256      # add 256 vertical offset
    sw $v1, 0( $t1 )        # paint the pixel the darkened colour
    
    addi $t1, $t1, -4       # add -4 horizontal offset
    sw $a2, 0( $t1 )        # paint the pixel the normal colour
    
    # recover from stack
    lw $t4, 0($sp)                  # pop $t4 from the stack
    addi $sp, $sp, 4                # move the stack pointer to the top stack element
    lw $t3, 0($sp)                  # pop $t3 from the stack
    addi $sp, $sp, 4                # move the stack pointer to the top stack element
    lw $t2, 0($sp)                  # pop $t2 from the stack
    addi $sp, $sp, 4                # move the stack pointer to the top stack element
    lw $t1, 0($sp)                  # pop $t1 from the stack
    addi $sp, $sp, 4                # move the stack pointer to the top stack element
    lw $ra, 0($sp)                  # pop $ra from the stack
    addi $sp, $sp, 4                # move the stack pointer to the top stack element
    
    jr $ra                  # return to the calling program.

# darken a hex colour
# $a2 = colour to darken
# $v1 = darkened colour
darken_colour:
    andi $t2, $a2, 0x00ff0000 # red
    andi $t3, $a2, 0x0000ff00 # green
    andi $t4, $a2, 0x000000ff # blue
    sra $t2, $t2, 1 # divide by 2
    andi $t2, $t2, 0x00ff0000 # get just red component
    sra $t3, $t3, 1 # divide by 2
    andi $t3, $t3, 0x0000ff00 # get just green component
    sra $t4, $t4, 1 # divide by 2
    andi $t4, $t4, 0x000000ff # get just blue component
    add $t2, $t2, $t3 # add red and green
    add $v1, $t2, $t4 # then add blue as well and save
    jr $ra

# lighten a hex colour
# $a2 = colour to lighten
# $v1 = lightened colour
lighten_colour:
  addi $sp, $sp, -24
    sw $t7, 20($sp)
    sw $t0, 16($sp)
    sw $t2, 12($sp)
    sw $t3, 8($sp)
    sw $t4, 4($sp)
    sw $t6, 0($sp)

    
    addi $t6, $a2, 0   
    srl  $t6, $t6, 16           #shifted bits untilonly each colouris isolated (red)
    andi $t6, $t6, 0xff
    addi $t2, $a2, 0   
    srl  $t2, $t2, 8            #green     
    andi $t2, $t2, 0xff
    andi $t3, $a2, 0xff
    
    li $t4, 0x0000ff            #maximum value
    li $t7, 0x1
    addi $t6, $t6 0x66
    add $t2, $t2, 0x66
    add $t3, $t3, 0x67
    
    slt $t0, $t6, $t4       # t0 = 1 if t6 < t4
    beq  $t0, $t7, nolimit  
    li $t6, 0xff            # limit to max
    nolimit:
    slt $t0, $t2, $t4       # t0 = 1 if t1 < t4
    beq  $t0, $t7, nolimit1  # limit to max 0xff
    li $t2, 0xff
    nolimit1:
    slt $t0, $t3, $t4       # t0 = 1 if t1 < t4
    beq  $t0, $t7, nolimit2  # limit to max 0xff
    li $t3, 0xff
    nolimit2:
    sll $t6, $t6, 16
    sll $t2, $t2, 8
    add $t0, $t6, $t2 #build result
    add $t0, $t0, $t3
    
    add $v1, $t0, $zero

    lw $t6, 0($sp)
    lw $t4, 4($sp)
    lw $t3, 8($sp)
    lw $t2, 12($sp)
    lw $t0, 16($sp)
    lw $t7, 20($sp) 
    addi $sp, $sp, 24
    jr $ra

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
    
    li $t4, 0   # i
    li $t5, 3   # i+3 (for the loop)
    
    lbu $t6, curr_x
    lbu $t7, curr_y
    la $t8, curr_gem_clrs
    
    # draw each gem
    draw_gems_loop_start:
    beq $t4, $t5, draw_gems_loop_end
        sll $t1, $t4, 2     # offset is index*4
        # draw gem
        addi $a0, $t6, 13       # set X coordinate
        addi $a1, $t7, 9        # set Y coordinate
        
        add $t2, $t8, $t1       # address of the colour to access (base address + offset)
        lw $t9, 0($t2)          # load the colour
        add $a2, $zero, $t9     # set colour
        jal draw_gem          # call the draw_gem function.

        addi $t4, $t4, 1
        addi $t7, $t7, 1
        j draw_gems_loop_start
    draw_gems_loop_end:
        # recover from stack
        lw $ra, 0($sp)                  # pop $ra from the stack
        addi $sp, $sp, 4                # move the stack pointer to the top stack element
        
        jr $ra
 
save_stack:
    #save return address to return to game loop 
    addi $sp, $sp, -4               
    sw $ra, 0($sp)   

    la $t0, grid           # base address of grid[]
    la $t1, curr_gem_clrs  # base address of gem colours

    li $t4, 0

    lbu $t2, curr_x # current x
    lbu $t3, curr_y 
    
    SaveLoop: beq $t4, 3, endsaveloop
    
    add $t3, $t3, $t4 #current y
    
    #calculate location in memory 
    mult $t5, $t2, 4
    
    li  $t1, 0xFF0000    # $t1 = some colour (red)
    #syntax to store in memory: sw colour, offset x many bytes more, location of first byte in memory
    #Storing a word (sw) writes all 4 bytes of 32-bit val starting at the given address, automatically filling the next three addresses
    sw  $t1, 0($t0)      # memory[grid + 0] = $t1
   
   
    addi $t4, $t4, 1         # i++
    j SaveLoop
    
    
    endsaveloop:
    
    
    #here save it onto memory so it doesnt poof.
    jal generate_gems
    
    
    #reset cur x and y
    li $t0, 2
    li $t1, 0
    sb $t0, curr_x
    sb $t1, curr_y
    jal draw_skydiver
    
    
     # restore caller's $ra and return
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
# the clear grid function that clears the 6x13 playing field
clear_grid:
    # save to stack
    addi $sp, $sp, -4               # move the stack pointer to an empty location
    sw $ra, 0($sp)                  # push $ra onto the stack
    
    li $t1, 13  # start x coord (at top left corner)
    li $t3, 19  # end x coord exclusive
    li $t4, 22   # end y coord exclusive
    
    lw $t5, BLACK # load black colour
    add $a2, $zero, $t5     # set colour to black
    
    clear_grid_loop_x_start:
        beq $t1, $t3, clear_grid_loop_x_end
        li $t2, 9   # start y coord
        clear_grid_loop_y_start:
            beq $t2, $t4, clear_grid_loop_y_end
            add $a0, $t1, $zero     # set X coordinate
            add $a1, $t2, $zero     # set Y coordinate
            
            # stack stuff
            addi $sp, $sp, -4               # move the stack pointer to an empty location
            sw $t1, 0($sp)                  # push $t1 onto the stack
            addi $sp, $sp, -4               # move the stack pointer to an empty location
            sw $t2, 0($sp)                  # push $t2 onto the stack
            addi $sp, $sp, -4               # move the stack pointer to an empty location
            sw $t3, 0($sp)                  # push $t3 onto the stack
            addi $sp, $sp, -4               # move the stack pointer to an empty location
            sw $t4, 0($sp)                  # push $t4 onto the stack
            
            jal draw_pixel
            
            # unstack stuff
            lw $t4, 0($sp)                  # pop $t4 from the stack
            addi $sp, $sp, 4                # move the stack pointer to the top stack element
            lw $t3, 0($sp)                  # pop $t3 from the stack
            addi $sp, $sp, 4                # move the stack pointer to the top stack element
            lw $t2, 0($sp)                  # pop $t2 from the stack
            addi $sp, $sp, 4                # move the stack pointer to the top stack element
            lw $t1, 0($sp)                  # pop $t1 from the stack
            addi $sp, $sp, 4                # move the stack pointer to the top stack element
            
            addi $t2, $t2, 1
            j clear_grid_loop_y_start
        clear_grid_loop_y_end:
            addi $t1, $t1, 1
            j clear_grid_loop_x_start
    clear_grid_loop_x_end:
    
    # recover from stack
    lw $ra, 0($sp)                  # pop $ra from the stack
    addi $sp, $sp, 4                # move the stack pointer to the top stack element
    
    jr $ra

# game loop
game_loop:
    # 1a. Check if key has been pressed
    jal is_key_pressed
    beq $v1, 1, if_keyboard_input
    b end_key_input_handling

    # 1b. Check which key has been pressed  
    if_keyboard_input:
        jal keyboard_input
       # li $v0, 1 # ask system to print $a0
        #syscall
        beq $v1, 0x61, respond_to_a
        beq $v1, 0x64, respond_to_d
        beq $v1, 0x77, respond_to_w
        beq $v1, 0x73, respond_to_s
        beq $v1, 0x71, respond_to_q
        b end_key_input_handling
        respond_to_a:   # move left
            lbu $t5, curr_x     # get current x
            addi $t6, $t5, -1   # temporary check value
            add $t4, $t6, $zero # store displacement value
            add $a0, $zero, $t6 # add to current coordinate
            lbu $a1, curr_y     # retrieve current y
            addi $a0, $a0, 13  # convert to absolute coordinates
            addi, $a1, $a1, 9
            jal convert_pixel 
            add $t6, $zero, $v0 # return value of converted pixel
            lw $t5, 0($t6)      # get colour from memory
            lw $t6, BLACK   
            beq $t5, $t6, allow
            b end_key_input_handling
            
            allow:
            sb $t4, curr_x      # save new x to curr_x
            b end_key_input_handling
        respond_to_d:   # move right
            lbu $t5, curr_x     # get current x
            addi $t6, $t5, 1   # temporary check value
            add $t4, $t6, $zero 
            add $a0, $zero, $t6
            lbu $a1, curr_y
            addi $a0, $a0, 13
            addi, $a1, $a1, 9
            jal convert_pixel
            add $t6, $zero, $v0 # return value of converted pixel
            lw $t5, 0($t6)      # get colour from memory
            lw $t6, BLACK   
            beq $t5, $t6, allow2
            b end_key_input_handling
            
            allow2:
            sb $t4, curr_x      # save new x to curr_x
            b end_key_input_handling
        respond_to_w:   # shuffle/shift gems
            jal shift_gems
            b end_key_input_handling
        respond_to_s:   # move down
            lbu $t5, curr_y     # get current y
            
            addi $t6, $t5, 3   # temporary check value
            addi $t4, $t5, 1   # displacement value 
            add $a1, $zero, $t6
            lbu $a0, curr_x
            addi $a0, $a0, 13
            addi $a1, $a1, 9
            
            jal convert_pixel
            add $t6, $zero, $v0 # return value of converted pixel
            lw $t5, 0($t6)      # get colour from memory
            lw $t6, BLACK   
            beq $t5, $t6, allow3

            jal save_stack      # end this skydiver's journey </3 
            b end_key_input_handling
            
            allow3:
            sb $t4, curr_y
            b end_key_input_handling
        respond_to_q:   # quit
            j exit
    end_key_input_handling:
        lbu $a0, curr_x
        lbu $a1, curr_y
        addi $a1, $a1, 3 #look down by 1 pixel (+2 pixels of the stack itself)
        addi $a0, $a0, 13 #convert to absolute system
        addi, $a1, $a1, 9 #convert to absolute system
        jal convert_pixel
        add $t6, $zero, $v0 # return value of converted pixel
        lw $t5, 0($t6)      # get colour from memory
        lw $t6, BLACK   
        beq $t5, $t6, not_bottom
        jal save_stack 
    not_bottom:
	# 2b. Update locations (capsules)
	# 3. Draw the screen
	jal clear_grid
	jal draw_skydiver
	# 4. Sleep
	jal sleep

    # 5. Go back to Step 1
    j game_loop

# check for and handle keyboard input
# $v1 return value: 1 if key has been pressed, 0 otherwise
is_key_pressed:
    lw $t1, ADDR_KBRD   # get address of keyboard input
    lw $t2, 0($t1)      # load first word from keyboard
    add $v1, $t2, $zero # return this value
    jr $ra
    
# get the key that has been pressed
# $v1 return value: the value of the key that has been pressed as a hex representation of its ascii code
keyboard_input:
    lw $t1, ADDR_KBRD   # get address of keyboard input
    lw $t2, 4($t1)      # load second word from keyboard
    add $v1, $t2, $zero # return this value
    jr $ra
    
# shift/rotate gems
shift_gems:
    la $t9, curr_gem_clrs
    lw $t1, 0($t9)      # first gem colour
    lw $t2, 4($t9)      # second gem colour
    lw $t3, 8($t9)      # third gem colour
    sw $t3, 0($t9)      # set first gem's colour as the bottom colour
    sw $t1, 4($t9)      # set second gem's colour as the top colour
    sw $t2, 8($t9)      # set thrid gem's colour as the middle colour
    jr $ra

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
    li $a0, 10              # number of milliseconds (1000 = 1 second)
    syscall
    jr $ra

# Terminate program gracefully
exit:
    li $v0, 10              # terminate the program gracefully
    syscall
