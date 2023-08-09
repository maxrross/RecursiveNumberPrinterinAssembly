.section .data

input_number:	.asciz	"Please enter a number: "
input_spec:	.asciz	"%d"
print_num:	.asciz	" %d \n"
error:		.asciz	"Please input a positive number \n"

.section .text

.global main

main:

# create stack frame for one reg, store orig return value
sub sp, sp, 8
str x30, [sp, 0]
# set x0 to input number specifier
ldr x0, =input_number
# prints to console
bl printf
# load x30, orig return address before print
ldr x30, [sp, 0]
# close out stack frame
add sp, sp, 8

# set input specifier for x0, create stack frame for 2 registers
ldr x0, =input_spec
sub sp, sp, 16
# move stack pointer to x1, storing x1 at sp+0
mov x1, sp
# store x30 at sp+8, loading return address to stack
str x30, [sp, 8]
# branch and link to x1, whatever is input is put in x1
bl scanf
# load signed word from x0 into x0+0 so now x0 holds number
ldrsw x0, [sp, 0]
# load original return address from stack pointer +8
ldur x30, [sp, 8]
# closing out stack frame
add sp, sp, 16

# if n = 0, branch to 0
b.eq zero

# compare x0 to 0, branch if greater than 0 to recursive function
cmp x0, 0
b.gt recursive_start

# if negative load error message into x0, branch and link to printf, then exit
ldr x0, =error
bl printf
b exit

recursive:
    # conditional branch if x0 is equal to 0, puts you at base case
	cbz x0, base

	# creating stack frame and storing current x0 and x30 return value to it
	sub sp, sp, 16
	str x0, [sp, 0]
	str x30, [sp, 8]

	# print current n value
	bl print
	
	# making sure x0 is holding current number
	ldr x0, [sp, 0]
    # subtract 1 from x0
	sub x0, x0, 1
    # call recursive again to set up stack frame with new number
	bl recursive

    # closes out stack frame
	add sp, sp, 16
    # prints out current number
	bl print 

    # loads x0 back to 0 and original return address and branches to x30
    # gets next number to print out
	ldur x0, [sp, 0]
	ldur x30, [sp, 8]

    # branches to x30, returning
	br x30

print: 
	mov x1, x0
	ldr x0, =print_num
    # set up stack frame
	sub sp, sp, 16
	str x1, [sp, 0]
	str x30, [sp, 8]
    # branch and link print out
	bl printf
    # load number back to x0
	ldur x0, [sp, 0]
	ldur x30, [sp, 8]
    # close out stack frame
	add sp, sp, 16
    # return with br x30 which takes back to line after where it was called
	br x30

# branch and link to recursive function, prints down and up, then print prints orig number
recursive_start:
	bl recursive
	bl print
	b exit

# if 0 is input, set x1 as number 0 which is in x0, load print statement to x0, then branch and link printf, then branch exit
zero:
	mov x1, x0
	ldr x0, =print_num
	bl printf
	b exit

# just prints out 0 if 0
base:
	bl print
	ldur x0, [sp, 0]
	ldur x30, [sp, 8]
	br x30
	
# branch to this label on program completion
exit:
	mov x0, 0
	mov x8, 93
	svc 0
	ret