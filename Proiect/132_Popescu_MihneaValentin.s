.data
v: .space 1600
n: .space 4
m: .space 4
roles: .space 80
queue: .space 80
visited: .space 80
cerinta: .space 4
start: .space 4
stop: .space 4
cuv: .space 1000
nl: .asciiz "\n"
dp: .asciiz ": "
pv: .asciiz "; "
host: .asciiz "host "
switch: .asciiz "switch "
controller: .asciiz "controller "
switchmalitios: .asciiz "switch malitios "
index: .asciiz "index "
yes: .asciiz "Yes"
no: .asciiz "No"

.text

main:

li $v0,5
syscall
sw $v0,n
li $v0,5
syscall
sw $v0,m
li $t0,0  #t0=i
lw $t1,m #t1=m
lw $t2,n #t2=n
li $t5,1 #t5=Exista

readloop:
beq $t0,$t1,reinit1
li $v0,5
syscall
move $t3,$v0 #t3=x
li $v0,5
syscall
move $t4,$v0 #t4=y
#v[x][y]=1
mul $t6,$t3,$t2 #t5=lines*lineIndex
add $t6,$t6,$t4 #t5=lines*lineIndex+column Index
mul $t6,$t6,4
sw $t5,v($t6)
#v[y][x]=1
mul $t6,$t4,$t2 #t5=lines*lineIndex
add $t6,$t6,$t3 #t5=lines*lineIndex+column Index
mul $t6,$t6,4
sw $t5,v($t6)
addi $t0,1
j readloop

reinit1:
li $t0,0 #t0=i
li $t2,0 #t2=index
lw $t1,n #t1=n

cinroles:
beq $t0,$t1,cincerinta
li $v0,5
syscall
sw $v0,roles($t2)
addi $t0,1
addi $t2,4
j cinroles

cincerinta:
li $v0,5
syscall
sw $v0,cerinta
lw $t0,cerinta
beq $v0,1,cerinta1
beq $v0,2,cerinta2
li $v0,5
syscall
sw $v0,start
li $v0,5
syscall
sw $v0,stop
la $a0,cuv
li $a1,1000
li $v0,8
syscall
j cerinta3

cerinta1:
bne $t0,1,etexit
li $t0,0 #t0=i
lw $t1,n #t1=n
li $t2,0 #t2=index

loopc1:
beq $t0,$t1,etexit
	lw $t3,roles($t2) #t3=roles[i]
	bne $t3,3,contc1
	la $a0,switchmalitios
	li $v0,4
	syscall
	la $a0,index
	li $v0,4
	syscall
	move $a0,$t0
	li $v0,1
	syscall
	la $a0,dp
	li $v0,4
	syscall
	li $t4,0 #t4=j
	
	loop2c1:
	beq $t4,$t1,afisnl
		mul $t5,$t0,$t1
		add $t5,$t5,$t4
		mul $t5,$t5,4
		lw $t6,v($t5) #t6=v[i][j]
		beq $t6,0,contloop2c1
		mul $t6,$t4,4 #t6=index roles
		lw $t7,roles($t6) #t7=roles[j]
		
		ehost:
		bne $t7,1,eswitch
		la $a0,host
		li $v0,4
		syscall
		j afis
		
		eswitch:
		bne $t7,2,eswitchmalitios
		la $a0,switch
		li $v0,4
		syscall
		j afis
		
		eswitchmalitios:
		bne $t7,3,econtroller
		la $a0,switchmalitios
		li $v0,4
		syscall
		j afis
		
		econtroller:
		la $a0,controller
		li $v0,4
		syscall
		
		afis:
		la $a0,index
		li $v0,4
		syscall
		move $a0,$t4
		li $v0,1
		syscall
		la $a0,pv
		li $v0,4
		syscall
		
	    contloop2c1:
	    addi $t4,1
	    j loop2c1

afisnl:
la $a0,nl
li $v0,4
syscall
	
contc1:
addi $t0,1
addi $t2,4
j loopc1

cerinta2:
li $t0,0 #queueIdx
li $t1,0 #queueLen
lw $t3,n #t3=n
li $t6,1 #t6=True
sw $0,queue($t0)
sw $t6,visited($t0)
addi $t1,1

loopc2:
beq $t0,$t1,vfconex
	mul $t8,$t0,4
	lw $t4,queue($t8) #t4=CurrentNode (i)
	addi $t0,1
	mul $t8,$t4,4 
	lw $t5,roles($t8) #t5=roles[currentNode]
	bne $t5,1,contc2
	la $a0,host
	li $v0,4
	syscall
	la $a0,index
	li $v0,4
	syscall
	move $a0,$t4
	li $v0,1
	syscall
	la $a0,pv
	li $v0,4
	syscall
	
	contc2:
	li $t7,0 #t7=column index (j)
	
	loop2c2:
	beq $t7,$t3,loopc2
	mul $t8,$t4,$t3 #t8=currentNode*n
	add $t8,$t8,$t7 #t8=currentNode*n+column index
	mul $t8,$t8,4
	lw $t9,v($t8) #t9=graph[i][j]
	bne $t9,1,contloop2c2
	mul $t8,$t7,4
	lw $t9,visited($t8) #t9=visited[columnIndex]
	beq $t9,1,contloop2c2
	sw $t6,visited($t8)
	mul $t8,$t1,4
	sw $t7,queue($t8)
	addi $t1,1
	
	contloop2c2:
	addi $t7,1
	j loop2c2
	
	vfconex:
	la $a0,nl
	li $v0,4
	syscall
	beq $t1,$t3,conex
	la $a0,no
	li $v0,4
	syscall
	j etexit
	
	conex:
	la $a0,yes
	li $v0,4
	syscall
	j etexit

cerinta3:
li $t0,0 #queueIdx
li $t1,0 #queueLen
lw $t3,start #t3=start
sw $t3,queue($t0)
mul $t3,$t3,4
li $t6,1 #t6=True
sw $t6,visited($t3)
lw $t3,n #t3=n
addi $t1,1

loopc3:
beq $t0,$t1,caesar
	mul $t8,$t0,4
	lw $t4,queue($t8) #t4=CurrentNode (i)
	addi $t0,1 
	lw $t5,stop #t5=stop
	bne $t5,$t4,contc3
	j printcuv
	
	contc3:
	li $t7,0 #t7=column index (j)
	
	loop2c3:
	beq $t7,$t3,loopc3
	mul $t8,$t4,$t3 #t8=currentNode*n
	add $t8,$t8,$t7 #t8=currentNode*n+column index
	mul $t8,$t8,4
	lw $t9,v($t8) #t9=graph[i][j]
	bne $t9,1,contloop2c3
	mul $t8,$t7,4
	lw $t9,visited($t8) #t9=visited[columnIndex]
	beq $t9,1,contloop2c3
	lw $t9,roles($t8) #t9=roles[columnindex]
	beq $t9,3,contloop2c3
	sw $t6,visited($t8)
	mul $t8,$t1,4
	sw $t7,queue($t8)
	addi $t1,1
	
	contloop2c3:
	addi $t7,1
	j loop2c3
		
	caesar:
	li $t0,0 #t0=i

	loopcaesar:
	lb $t1,cuv($t0)
	beq $t1,0,printcuv
	#shift=-10~26-10=16
	addi $t1,-81 #t1=t1-a+16
	rem $t1,$t1,26 #t1=(t1-a+16)%26
	addi $t1,97    #t1=((t1-a+16)%26)+a
	sb $t1,cuv($t0)
	addi $t0,1
	j loopcaesar
	
	printcuv:
	la $a0,cuv
	li $v0,4
	syscall
	
etexit:
li $v0,10
syscall