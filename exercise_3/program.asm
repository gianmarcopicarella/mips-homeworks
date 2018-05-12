.data 
	array: .word -666:1000
	tokens: .byte '*','+','-','^'

.globl main

.eqv $addr, $a2

.text
	
	main:
		# carico indirizzo albero
		la $addr, array
		
		#carico indirizzo - 1 dell'array con gli op aritmetici
		la $a3, tokens
		add $a3, $a3, -1
		
		# prende in input n
		li $v0, 5
		syscall
		
		# salva n nella prima posizione dell'array
		sw $v0, ($addr)
		move $s7, $v0
		
		sll $t7, $s7, 2
		add $t7, $t7, $addr
		add $s0, $addr, 4
		
		loading_loop: bgt $s0, $t7, loop
			li $v0, 5
			syscall
			sw $v0, ($s0)
		add $s0, $s0, 4
		j loading_loop
		
		loop: 
		lw $t6, 8($addr)
		beq $t6, -666, end_program
			# set index = 1
			li $s0, 1
			jal print_expression
			
			li $v0, 11
			li $a0, '\n'
			syscall
			
			li $s0, 1
			jal esegui_passo
		j loop
		
		end_program: # fine programma
		
		li $s0, 1
		jal print_expression
		
		li $v0, 11
		li $a0, '\n'
		syscall
		
		li $v0, 10
		syscall
	
	print_expression:
		
		# prima parentesi
		li $v0, 11
		li $a0, '('
		syscall
		
		#salvo $ra e l'indice del nodo
		addi $sp, $sp, -8
		
		sw $s0, 0($sp)
		sw $ra, 4($sp)
		
		# calcola indice sx
		
		sll $t0, $s0, 1
		
		# calcola indice dx
		
		add $t1, $t0, 1
		
		# se gli indici vanno fuori range allora vado a caso base
		
		bgt $t0, $s7, base
		bgt $t1, $s7, base	
			
		# altrimenti carico i valori
		sll $t2, $t0, 2
		add $t2, $t2, $addr
		lw $s1, ($t2)
		
		sll $t2, $t1, 2
		add $t2, $t2, $addr
		lw $s2, ($t2)
		
		# se i valori contenuti nell'array sono uguali a -666 allora vai a caso base
		
		beq $s1, -666, base
		beq $s2, -666, base
		
		# altrimenti fai la ricorsione sx
		# salva l'indice di destra nello stack
		addi $sp, $sp, -4
		sw $t1, 0($sp)
		
		move $s0, $t0
		jal print_expression
		
		# stampa operatore aritmetico
		
		lw $s0, 4($sp)
		sll $s0, $s0, 2
		add $s0, $s0, $addr
		lw $s0, ($s0)
		mul $s0, $s0, -1
		add $s3 $s0, $a3
		lb $a0, ($s3)
		li $v0, 11
		syscall
		
		# fine stampa operatore
		
		# fai la ricorsione dx

		lw $s0, 0($sp)
		addi $sp, $sp, 4
		
		jal print_expression
		
		# stampa altra parentesi
		
		li $v0, 11
		li $a0, ')'
		syscall
		
		# fine funzione, torno indietro
		
		lw $ra, 4($sp)
		addi $sp, $sp, 8
		
		jr $ra
		
		base: # caso base
			
			# ricarico l'indice attuale
			lw $s0, 0($sp)
			
			# calcolo l'indirizzo
			sll $s0, $s0, 2
			add $s0, $s0, $addr
			
			# carico il valore della foglia
			lw $a0, ($s0)
			li $v0, 1
			syscall
		
			# stampa altra parentesi
			li $v0, 11
			li $a0, ')'
			syscall
			
			# fine funzione, torno indietro
			lw $ra, 4($sp)
			addi $sp, $sp, 8
			
			jr $ra
			
	esegui_passo:
		# return $s4 = 0

		addi $sp, $sp, -20
		
		# calcola indice sx
		sll $t0, $s0, 1
		
		# calcola indice dx
		add $t1, $t0, 1
		
		# salva nello stack
		sw $zero, 16($sp)
		sw $t1, 12($sp)
		sw $t0, 8($sp)
		sw $ra, 4($sp)
		sw $s0, 0($sp)
		
		# se non ha figli
		bgt $t0, $s7, return1
		bgt $t1, $s7, return1
		
		# oppure ha i figli a -666
		sll $t0, $t0, 2
		add $t0, $t0, $addr
		
		lw $t0, ($t0)
		beq $t0, -666, return1
		
		sll $t1, $t1, 2
		add $t1, $t1, $addr
		
		lw $t1, ($t1)
		beq $t1, -666, return1
		
		j continue
		
		return1: # return 1
		li $s4, 1
		
		lw $ra, 4($sp)
		addi $sp, $sp, 20
		
		jr $ra
		
		continue:
		
		# ricorsione sx
		li $s4, 0
		lw $s0, 8($sp)
		jal esegui_passo
		
		# somma $s4 al contatore
		lw $s5, 16($sp)
		add $s5, $s5, $s4
		sw $s5, 16($sp)
		
		#ricorsione dx
		li $s4, 0
		lw $s0, 12($sp)
		jal esegui_passo
		
		# somma $s4 al contatore
		lw $s5, 16($sp)
		add $s5, $s5, $s4
		sw $s5, 16($sp)
		
		# controllo se è uguale a 2
		bne $s5, 2, next
		
		# carico i 2 valori
		lw $t0, 8($sp)
		sll $t0, $t0, 2
		add $t0, $t0, $addr
		lw $t2, ($t0) #primo valore
		
		lw $t1, 12($sp)
		sll $t1, $t1, 2
		add $t1, $t1, $addr
		lw $t3, ($t1) #secondo valore
		
		lw $s0, 0($sp)
		sll $s0, $s0, 2
		add $s0, $s0, $addr
		lw $t4, ($s0) #operazione da svolgere
		
		beq $t4, -1, m
		beq $t4, -2, a
		beq $t4, -3, s
		beq $t4, -4, p
		
		
		m:
			mul $t2, $t2, $t3
			sw $t2, ($s0)
			j after_operation
		a:
			add $t2, $t2, $t3
			sw $t2, ($s0)
			j after_operation
		s:
			sub $t2, $t2, $t3
			sw $t2, ($s0)
			j after_operation
		p:
			# t2 = base
			# t3 = esp
			bgt $t3, -1, pow_next
		
			# $t3 positivo
			sub $t3, $zero, $t3
		
			pow_next:
		
			#base
			add $t5, $zero, $t2
		
			#contatore a 0
			li $s6, 0
			#risultato ad 1
			li $t6, 1
			power_loop: beq $s6, $t3, end_power
			mul $t6, $t6, $t5
			add $s6, $s6, 1
			j power_loop
			end_power:
			sw $t6, ($s0)

		after_operation:
		li $t3, -666
		sw $t3, ($t0)
		sw $t3, ($t1)
		
		next:
			li $s4, 0
			lw $ra, 4($sp)
			addi $sp, $sp, 20
			jr $ra
