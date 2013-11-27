	.file	1 "curveball.c"
	.section .mdebug.abi32
	.previous
	.gnu_attribute 4, 1
	.abicalls
	.option	pic0

	.comm	ball,4,4

	.comm	pball,4,4

	.comm	opponent,4,4

	.comm	paddle,4,4

	.comm	mouse,4,4

	.comm	pmouse,4,4

	.comm	stopped,2,2

	.comm	first,2,2

	.comm	oppScore,2,2

	.comm	playerScore,2,2

	.comm	difficulty,2,2

	.comm	grid,40000,4
	.rdata
	.align	2
$LC0:
	.ascii	"usage: insert difference in mouse position to define cur"
	.ascii	"ve used\012<x position difference> <y position differenc"
	.ascii	"e>\000"
	.align	2
$LC1:
	.ascii	"curve X = %d, Y = %d\012\000"
	.text
	.align	2
	.globl	main
	.set	nomips16
	.set	nomicromips
	.ent	main
	.type	main, @function
main:
	.frame	$fp,40,$31		# vars= 0, regs= 4/0, args= 16, gp= 8
	.mask	0xc0030000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-40
	sw	$31,36($sp)
	sw	$fp,32($sp)
	sw	$17,28($sp)
	sw	$16,24($sp)
	move	$fp,$sp
	sw	$4,40($fp)
	sw	$5,44($fp)
	lw	$3,40($fp)
	li	$2,3			# 0x3
	beq	$3,$2,$L2
	nop

	lui	$2,%hi($LC0)
	addiu	$4,$2,%lo($LC0)
	jal	puts
	nop

	move	$4,$0
	jal	exit
	nop

$L2:
	jal	setup
	nop

	lui	$2,%hi(pmouse)
	lw	$16,%lo(pmouse)($2)
	lui	$2,%hi(pmouse)
	lw	$2,%lo(pmouse)($2)
	lh	$2,0($2)
	andi	$17,$2,0xffff
	lw	$2,44($fp)
	addiu	$2,$2,4
	lw	$2,0($2)
	move	$4,$2
	jal	atoi
	nop

	andi	$2,$2,0xffff
	addu	$2,$17,$2
	andi	$2,$2,0xffff
	seh	$2,$2
	sh	$2,0($16)
	lui	$2,%hi(pmouse)
	lw	$16,%lo(pmouse)($2)
	lui	$2,%hi(pmouse)
	lw	$2,%lo(pmouse)($2)
	lh	$2,2($2)
	andi	$17,$2,0xffff
	lw	$2,44($fp)
	addiu	$2,$2,8
	lw	$2,0($2)
	move	$4,$2
	jal	atoi
	nop

	andi	$2,$2,0xffff
	addu	$2,$17,$2
	andi	$2,$2,0xffff
	seh	$2,$2
	sh	$2,2($16)
	lw	$2,44($fp)
	addiu	$2,$2,4
	lw	$2,0($2)
	move	$4,$2
	jal	atoi
	nop

	move	$16,$2
	lw	$2,44($fp)
	addiu	$2,$2,8
	lw	$2,0($2)
	move	$4,$2
	jal	atoi
	nop

	lui	$3,%hi($LC1)
	addiu	$4,$3,%lo($LC1)
	move	$5,$16
	move	$6,$2
	jal	printf
	nop

$L7:
	lui	$2,%hi(ball)
	lw	$2,%lo(ball)($2)
	lh	$3,0($2)
	li	$2,1717960704			# 0x66660000
	ori	$2,$2,0x6667
	mult	$3,$2
	mfhi	$2
	sra	$4,$2,1
	sra	$2,$3,31
	subu	$4,$4,$2
	move	$2,$4
	sll	$2,$2,2
	addu	$2,$2,$4
	subu	$2,$3,$2
	seh	$2,$2
	slt	$2,$2,3
	beq	$2,$0,$L3
	nop

	lui	$2,%hi(ball)
	lw	$2,%lo(ball)($2)
	lh	$3,4($2)
	li	$2,1717960704			# 0x66660000
	ori	$2,$2,0x6667
	mult	$3,$2
	mfhi	$2
	sra	$4,$2,2
	sra	$2,$3,31
	subu	$2,$4,$2
	sll	$2,$2,1
	sll	$4,$2,2
	addu	$2,$2,$4
	subu	$2,$3,$2
	seh	$2,$2
	slt	$2,$2,5
	beq	$2,$0,$L4
	nop

	lui	$2,%hi(ball)
	lw	$2,%lo(ball)($2)
	lh	$2,0($2)
	li	$3,1717960704			# 0x66660000
	ori	$3,$3,0x6667
	mult	$2,$3
	mfhi	$3
	sra	$3,$3,1
	sra	$2,$2,31
	subu	$2,$3,$2
	seh	$2,$2
	move	$6,$2
	lui	$2,%hi(ball)
	lw	$2,%lo(ball)($2)
	lh	$2,4($2)
	li	$3,1717960704			# 0x66660000
	ori	$3,$3,0x6667
	mult	$2,$3
	mfhi	$3
	sra	$3,$3,2
	sra	$2,$2,31
	subu	$2,$3,$2
	seh	$2,$2
	move	$4,$2
	lui	$2,%hi(ball)
	lw	$2,%lo(ball)($2)
	lh	$2,2($2)
	move	$3,$2
	lui	$5,%hi(grid)
	move	$2,$6
	sll	$2,$2,2
	sll	$6,$2,2
	addu	$2,$2,$6
	sll	$6,$2,2
	addu	$2,$2,$6
	addu	$2,$2,$4
	sll	$4,$2,2
	addiu	$2,$5,%lo(grid)
	addu	$2,$4,$2
	sw	$3,0($2)
	b	$L5
	nop

$L4:
	lui	$2,%hi(ball)
	lw	$2,%lo(ball)($2)
	lh	$2,0($2)
	li	$3,1717960704			# 0x66660000
	ori	$3,$3,0x6667
	mult	$2,$3
	mfhi	$3
	sra	$3,$3,1
	sra	$2,$2,31
	subu	$2,$3,$2
	seh	$2,$2
	move	$6,$2
	lui	$2,%hi(ball)
	lw	$2,%lo(ball)($2)
	lh	$2,4($2)
	li	$3,1717960704			# 0x66660000
	ori	$3,$3,0x6667
	mult	$2,$3
	mfhi	$3
	sra	$3,$3,2
	sra	$2,$2,31
	subu	$2,$3,$2
	seh	$2,$2
	addiu	$4,$2,1
	lui	$2,%hi(ball)
	lw	$2,%lo(ball)($2)
	lh	$2,2($2)
	move	$3,$2
	lui	$5,%hi(grid)
	move	$2,$6
	sll	$2,$2,2
	sll	$6,$2,2
	addu	$2,$2,$6
	sll	$6,$2,2
	addu	$2,$2,$6
	addu	$2,$2,$4
	sll	$4,$2,2
	addiu	$2,$5,%lo(grid)
	addu	$2,$4,$2
	sw	$3,0($2)
	b	$L5
	nop

$L3:
	lui	$2,%hi(ball)
	lw	$2,%lo(ball)($2)
	lh	$3,4($2)
	li	$2,1717960704			# 0x66660000
	ori	$2,$2,0x6667
	mult	$3,$2
	mfhi	$2
	sra	$4,$2,2
	sra	$2,$3,31
	subu	$2,$4,$2
	sll	$2,$2,1
	sll	$4,$2,2
	addu	$2,$2,$4
	subu	$2,$3,$2
	seh	$2,$2
	slt	$2,$2,5
	beq	$2,$0,$L6
	nop

	lui	$2,%hi(ball)
	lw	$2,%lo(ball)($2)
	lh	$2,0($2)
	li	$3,1717960704			# 0x66660000
	ori	$3,$3,0x6667
	mult	$2,$3
	mfhi	$3
	sra	$3,$3,1
	sra	$2,$2,31
	subu	$2,$3,$2
	seh	$2,$2
	addiu	$6,$2,1
	lui	$2,%hi(ball)
	lw	$2,%lo(ball)($2)
	lh	$2,4($2)
	li	$3,1717960704			# 0x66660000
	ori	$3,$3,0x6667
	mult	$2,$3
	mfhi	$3
	sra	$3,$3,2
	sra	$2,$2,31
	subu	$2,$3,$2
	seh	$2,$2
	move	$4,$2
	lui	$2,%hi(ball)
	lw	$2,%lo(ball)($2)
	lh	$2,2($2)
	move	$3,$2
	lui	$5,%hi(grid)
	move	$2,$6
	sll	$2,$2,2
	sll	$6,$2,2
	addu	$2,$2,$6
	sll	$6,$2,2
	addu	$2,$2,$6
	addu	$2,$2,$4
	sll	$4,$2,2
	addiu	$2,$5,%lo(grid)
	addu	$2,$4,$2
	sw	$3,0($2)
	b	$L5
	nop

$L6:
	lui	$2,%hi(ball)
	lw	$2,%lo(ball)($2)
	lh	$2,0($2)
	li	$3,1717960704			# 0x66660000
	ori	$3,$3,0x6667
	mult	$2,$3
	mfhi	$3
	sra	$3,$3,1
	sra	$2,$2,31
	subu	$2,$3,$2
	seh	$2,$2
	addiu	$6,$2,1
	lui	$2,%hi(ball)
	lw	$2,%lo(ball)($2)
	lh	$2,4($2)
	li	$3,1717960704			# 0x66660000
	ori	$3,$3,0x6667
	mult	$2,$3
	mfhi	$3
	sra	$3,$3,2
	sra	$2,$2,31
	subu	$2,$3,$2
	seh	$2,$2
	addiu	$4,$2,1
	lui	$2,%hi(ball)
	lw	$2,%lo(ball)($2)
	lh	$2,2($2)
	move	$3,$2
	lui	$5,%hi(grid)
	move	$2,$6
	sll	$2,$2,2
	sll	$6,$2,2
	addu	$2,$2,$6
	sll	$6,$2,2
	addu	$2,$2,$6
	addu	$2,$2,$4
	sll	$4,$2,2
	addiu	$2,$5,%lo(grid)
	addu	$2,$4,$2
	sw	$3,0($2)
$L5:
	jal	update_game
	nop

	b	$L7
	nop

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.align	2
	.globl	setup
	.set	nomips16
	.set	nomicromips
	.ent	setup
	.type	setup, @function
setup:
	.frame	$fp,32,$31		# vars= 0, regs= 2/0, args= 16, gp= 8
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-32
	sw	$31,28($sp)
	sw	$fp,24($sp)
	move	$fp,$sp
	lui	$2,%hi(first)
	li	$3,1			# 0x1
	sh	$3,%lo(first)($2)
	lui	$2,%hi(pball)
	sw	$0,%lo(pball)($2)
	li	$4,16			# 0x10
	jal	malloc
	nop

	move	$3,$2
	lui	$2,%hi(ball)
	sw	$3,%lo(ball)($2)
	lui	$2,%hi(ball)
	lw	$2,%lo(ball)($2)
	li	$3,256			# 0x100
	sh	$3,0($2)
	lui	$2,%hi(ball)
	lw	$2,%lo(ball)($2)
	li	$3,192			# 0xc0
	sh	$3,2($2)
	lui	$2,%hi(ball)
	lw	$2,%lo(ball)($2)
	sh	$0,4($2)
	lui	$2,%hi(ball)
	lw	$2,%lo(ball)($2)
	sh	$0,6($2)
	lui	$2,%hi(ball)
	lw	$2,%lo(ball)($2)
	sh	$0,8($2)
	lui	$2,%hi(ball)
	lw	$2,%lo(ball)($2)
	li	$3,1			# 0x1
	sh	$3,12($2)
	lui	$2,%hi(ball)
	lw	$2,%lo(ball)($2)
	li	$3,1			# 0x1
	sh	$3,14($2)
	lui	$2,%hi(ball)
	lw	$2,%lo(ball)($2)
	li	$3,1			# 0x1
	sh	$3,10($2)
	li	$4,4			# 0x4
	jal	malloc
	nop

	move	$3,$2
	lui	$2,%hi(opponent)
	sw	$3,%lo(opponent)($2)
	lui	$2,%hi(opponent)
	lw	$2,%lo(opponent)($2)
	li	$3,256			# 0x100
	sh	$3,0($2)
	lui	$2,%hi(opponent)
	lw	$2,%lo(opponent)($2)
	li	$3,192			# 0xc0
	sh	$3,2($2)
	li	$4,4			# 0x4
	jal	malloc
	nop

	move	$3,$2
	lui	$2,%hi(paddle)
	sw	$3,%lo(paddle)($2)
	lui	$2,%hi(paddle)
	lw	$2,%lo(paddle)($2)
	li	$3,256			# 0x100
	sh	$3,0($2)
	lui	$2,%hi(paddle)
	lw	$2,%lo(paddle)($2)
	li	$3,256			# 0x100
	sh	$3,2($2)
	li	$4,4			# 0x4
	jal	malloc
	nop

	move	$3,$2
	lui	$2,%hi(mouse)
	sw	$3,%lo(mouse)($2)
	lui	$2,%hi(mouse)
	lw	$2,%lo(mouse)($2)
	li	$3,256			# 0x100
	sh	$3,0($2)
	lui	$2,%hi(mouse)
	lw	$2,%lo(mouse)($2)
	li	$3,192			# 0xc0
	sh	$3,2($2)
	li	$4,4			# 0x4
	jal	malloc
	nop

	move	$3,$2
	lui	$2,%hi(pmouse)
	sw	$3,%lo(pmouse)($2)
	lui	$2,%hi(pmouse)
	lw	$2,%lo(pmouse)($2)
	li	$3,256			# 0x100
	sh	$3,0($2)
	lui	$2,%hi(pmouse)
	lw	$2,%lo(pmouse)($2)
	li	$3,192			# 0xc0
	sh	$3,2($2)
	lui	$2,%hi(oppScore)
	sh	$0,%lo(oppScore)($2)
	lui	$2,%hi(playerScore)
	sh	$0,%lo(playerScore)($2)
	lui	$2,%hi(difficulty)
	li	$3,1			# 0x1
	sh	$3,%lo(difficulty)($2)
	move	$sp,$fp
	lw	$31,28($sp)
	lw	$fp,24($sp)
	addiu	$sp,$sp,32
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	setup
	.size	setup, .-setup
	.align	2
	.globl	update_game
	.set	nomips16
	.set	nomicromips
	.ent	update_game
	.type	update_game, @function
update_game:
	.frame	$fp,32,$31		# vars= 0, regs= 2/0, args= 16, gp= 8
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-32
	sw	$31,28($sp)
	sw	$fp,24($sp)
	move	$fp,$sp
	jal	opp_update
	nop

	jal	ball_update
	nop

	jal	paddle_update
	nop

	move	$sp,$fp
	lw	$31,28($sp)
	lw	$fp,24($sp)
	addiu	$sp,$sp,32
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	update_game
	.size	update_game, .-update_game
	.rdata
	.align	2
$LC2:
	.ascii	"test.txt\000"
	.align	2
$LC3:
	.ascii	"w\000"
	.align	2
$LC4:
	.ascii	"0\011\000"
	.align	2
$LC5:
	.ascii	"%d\011\000"
	.text
	.align	2
	.globl	restart
	.set	nomips16
	.set	nomicromips
	.ent	restart
	.type	restart, @function
restart:
	.frame	$fp,48,$31		# vars= 16, regs= 2/0, args= 16, gp= 8
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-48
	sw	$31,44($sp)
	sw	$fp,40($sp)
	move	$fp,$sp
	lui	$2,%hi($LC2)
	addiu	$4,$2,%lo($LC2)
	lui	$2,%hi($LC3)
	addiu	$5,$2,%lo($LC3)
	jal	fopen
	nop

	sw	$2,32($fp)
	lui	$2,%hi($LC4)
	addiu	$4,$2,%lo($LC4)
	li	$5,1			# 0x1
	li	$6,2			# 0x2
	lw	$7,32($fp)
	jal	fwrite
	nop

	sw	$0,24($fp)
	b	$L11
	nop

$L12:
	lw	$2,24($fp)
	sll	$2,$2,1
	sll	$3,$2,2
	addu	$2,$2,$3
	lw	$4,32($fp)
	lui	$3,%hi($LC5)
	addiu	$5,$3,%lo($LC5)
	move	$6,$2
	jal	fprintf
	nop

	lw	$2,24($fp)
	addiu	$2,$2,1
	sw	$2,24($fp)
$L11:
	lw	$2,24($fp)
	slt	$2,$2,100
	bne	$2,$0,$L12
	nop

	li	$4,10			# 0xa
	lw	$5,32($fp)
	jal	fputc
	nop

	sw	$0,24($fp)
	b	$L13
	nop

$L16:
	lw	$3,24($fp)
	move	$2,$3
	sll	$2,$2,2
	addu	$2,$2,$3
	lw	$4,32($fp)
	lui	$3,%hi($LC5)
	addiu	$5,$3,%lo($LC5)
	move	$6,$2
	jal	fprintf
	nop

	sw	$0,28($fp)
	b	$L14
	nop

$L15:
	lui	$4,%hi(grid)
	lw	$2,24($fp)
	sll	$2,$2,2
	sll	$3,$2,2
	addu	$2,$2,$3
	sll	$3,$2,2
	addu	$2,$2,$3
	lw	$3,28($fp)
	addu	$2,$2,$3
	sll	$3,$2,2
	addiu	$2,$4,%lo(grid)
	addu	$2,$3,$2
	lw	$2,0($2)
	lw	$4,32($fp)
	lui	$3,%hi($LC5)
	addiu	$5,$3,%lo($LC5)
	move	$6,$2
	jal	fprintf
	nop

	lw	$2,28($fp)
	addiu	$2,$2,1
	sw	$2,28($fp)
$L14:
	lw	$2,28($fp)
	slt	$2,$2,100
	bne	$2,$0,$L15
	nop

	li	$4,10			# 0xa
	lw	$5,32($fp)
	jal	fputc
	nop

	lw	$2,24($fp)
	addiu	$2,$2,1
	sw	$2,24($fp)
$L13:
	lw	$2,24($fp)
	slt	$2,$2,100
	bne	$2,$0,$L16
	nop

	lw	$4,32($fp)
	jal	fclose
	nop

	move	$4,$0
	jal	exit
	nop

	.set	macro
	.set	reorder
	.end	restart
	.size	restart, .-restart
	.align	2
	.globl	mousePressed
	.set	nomips16
	.set	nomicromips
	.ent	mousePressed
	.type	mousePressed, @function
mousePressed:
	.frame	$fp,8,$31		# vars= 0, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-8
	sw	$fp,4($sp)
	move	$fp,$sp
	lui	$2,%hi(stopped)
	lhu	$2,%lo(stopped)($2)
	beq	$2,$0,$L17
	nop

	lui	$2,%hi(stopped)
	sh	$0,%lo(stopped)($2)
$L17:
	move	$sp,$fp
	lw	$fp,4($sp)
	addiu	$sp,$sp,8
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	mousePressed
	.size	mousePressed, .-mousePressed
	.ident	"GCC: (Sourcery CodeBench Lite 2013.05-66) 4.7.3"
