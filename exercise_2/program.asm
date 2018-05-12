# @Gianmarco Picarella
# Homework 2  
# Create a program that simulate Othello - Reversi game.
# This is my implementation in MIPS.



.data
	mat: .byte '|',' ',' ',' ',' ',' ',' ',' ',' ', '|', '\n', '|', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '|', '\n', '|', ' ',' ',' ',' ',' ',' ',' ',' ', '|', '\n', '|' ,' ',' ',' ','B','N',' ',' ',' ', '|', '\n', '|', ' ',' ',' ','N','B',' ',' ',' ', '|', '\n', '|',' ',' ',' ',' ',' ',' ',' ',' ','|','\n','|',' ',' ',' ',' ',' ',' ',' ',' ', '|', '\n', '|',' ',' ',' ',' ',' ',' ',' ',' ','|','\n','\n','\0'
	input: .space 5
	input_error: .asciiz "MOSSA ERRATA\n"
	vince_nero: .asciiz "STA VINCENDO IL NERO\n"
	vince_bianco: .asciiz "STA VINCENDO IL BIANCO\n"
	patta: .asciiz "PATTA\n"
.eqv $x, $t0
.eqv $y, $t1
.eqv $addr, $t2
.eqv $input_addr, $t7
.eqv $current_player, $s1
.eqv $opposite_player, $s4
.eqv $score_bianco, $s2
.eqv $score_nero, $s3

.macro sub_up_v(%et)
	ble $s0, $addr, %et
	addi $s0, $s0, -11
.end_macro
.macro add_down_v(%et)
	bgt $s0, $t6, %et
	addi $s0, $s0, 11
.end_macro
.macro add_right_v(%et)
	lb $a3, ($s0)
	beq $a3, '|', %et
	addi $s0, $s0, 1
.end_macro
.macro sub_left_v(%et)
	lb $a3, ($s0)
	beq $a3, '|', %et
	addi $s0, $s0, -1
.end_macro

.macro add_right_d1(%et)
	bgt $s0, $t6, %et
	lb $a3, ($s0)
	beq $a3, '|', %et
	addi $s0, $s0, 12
.end_macro

.macro sub_left_d1(%et)
	ble $s0, $addr, %et
	lb $a3, ($s0)
	beq $a3, '|', %et
	addi $s0, $s0, -12
.end_macro
.macro add_right_d2(%et)
	ble $s0, $addr, %et
	lb $a3, ($s0)
	beq $a3, '|', %et
	addi $s0, $s0, -10
.end_macro
.macro sub_left_d2(%et)
	bgt $s0, $t6, %et
	lb $a3, ($s0)
	beq $a3, '|', %et
	addi $s0, $s0, 10
.end_macro

#macro per girare le pedine -----

.macro sub_up_v_r()
	addi $s0, $s0, 11
.end_macro
.macro add_down_v_r()
	addi $s0, $s0, -11
.end_macro
.macro add_right_v_r()
	addi $s0, $s0, -1
.end_macro
.macro sub_left_v_r()
	addi $s0, $s0, 1
.end_macro
.macro add_right_d1_r()
	addi $s0, $s0, -12
.end_macro
.macro sub_left_d1_r()
	addi $s0, $s0, 12
.end_macro
.macro add_right_d2_r()
	addi $s0, $s0, 10
.end_macro
.macro sub_left_d2_r()
	addi $s0, $s0, -10
.end_macro

#fine -----


.macro find_range(%change_coord_proc, %etc, %et)
	#flag
	li $s7, 0

	range_loop: 
		#carico valore
		lb $t5, ($s0)
		
		bne $t5, $opposite_player, continue # se non è enemy continua
		li $s7, 1 # flag = true
		%change_coord_proc(%et) # cambia le variabili in base all'operazione
		j range_loop
		
		continue:
		bne $t5, $current_player, %et 	
		bne $s7, 1, %et
		j %etc

	j range_loop
.end_macro

.macro inverti_pedine(%change_coord_proc, %etc)
	add $t3, $t3, 2

	%change_coord_proc()
	lb $a2, ($s0)
	beq $a2, ' ', %etc

	sb $current_player, ($s0)

	%change_coord_proc()
	lb $a2, ($s0)
	beq $a2, ' ', %etc

	add $t3, $t3, 1
	sb $current_player, ($s0)

	%change_coord_proc()
	lb $a2, ($s0)
	beq $a2, ' ', %etc

	add $t3, $t3, 1
	sb $current_player, ($s0)

	%change_coord_proc()
	lb $a2, ($s0)
	beq $a2, ' ', %etc

	add $t3, $t3, 1
	sb $current_player, ($s0)

	%change_coord_proc()
	lb $a2, ($s0)
	beq $a2, ' ', %etc

	add $t3, $t3, 1
	sb $current_player, ($s0)

	%change_coord_proc()
	lb $a2, ($s0)
	beq $a2, ' ', %etc

	add $t3, $t3, 1
	sb $current_player, ($s0)

	%change_coord_proc()
	lb $a2, ($s0)
	beq $a2, ' ', %etc

	add $t3, $t3, 1
	sb $current_player, ($s0)

	%change_coord_proc()
	lb $a2, ($s0)
	beq $a2, ' ', %etc

	add $t3, $t3, 1
	sb $current_player, ($s0)

.end_macro

.globl main

.text
	main: #entry point del programma
	
	#carica l'indirizzo della matrice
	la $addr, mat
	
	#carica l'indirizzo dell'input
	la $input_addr, input
	
	#stampa la scacchiera
	jal print_mat
	
	# setto il giocatore iniziale
	li $current_player, 'N'
	li $opposite_player, 'B'
	
	# setto lo score iniziale
	li $score_bianco, 2
	li $score_nero, 2
	
	li $a1, 5

	#fine matrice in $t6
	add $t6, $addr, 87

		gameloop:
			# prendi input da tastiera e verifica che la mossa sia possibile
			jal input_cmd
			
			#stampa scacchiera
			jal print_mat
			
			# scegli chi gioca
			add $score_nero, $score_nero, $t3
			li $current_player, 'B'
			li $opposite_player, 'N'

			# prendi input da tastiera e verifica che la mossa sia possibile
			jal input_cmd
			
			# stampa la scacchiera
			jal print_mat
			
			# scegli chi gioca
			add $score_bianco, $score_bianco, $t3
			li $current_player, 'N'
			li $opposite_player, 'B'
		
		j gameloop
	
	end: #fine del programma
		
		beq $score_bianco, $score_nero, print_patta
		blt $score_bianco, $score_nero, print_nero
		
		la $a0, vince_bianco
		li $v0, 4
		syscall
		
		j final_syscall
		
		print_patta:
		la $a0, patta
		li $v0, 4
		syscall
		
		j final_syscall
		print_nero:
		la $a0, vince_nero
		li $v0, 4
		syscall
		
		final_syscall:
		li $v0, 10
		syscall
		
	input_cmd: #input cmd
	li $v0, 8
	add $a0, $zero, $input_addr
	syscall
	
	#calcolo variabile x
	lb $x, 0($input_addr)
	
	# se la lettera è una S allora esci dal programma (end)
	beq $x, 'S', end
	#altrimenti calcolo il valore della x sottraendo 96
	addi $x, $x, -96
	
	#calcolo y
	lb $y, 1($input_addr)
	addi $y, $y, -49 # -1 perchè le y partono da 1
	
	#controlla se nella posizione x, y c'è spazio
	mul $t4, $y, 11
	add $t4, $t4, $x
	add $t4, $t4, $addr
	lb $t5, ($t4)
	
	bne $t5, ' ', input_errato
	
	#chiama la funzione di check
	j movement_check
	
	last_control:
	#controlla se sono state invertite delle pedine
	beq $t3, $zero, input_errato
	
	#inserisco la pedina
	sb $current_player, ($t4)

	# ritorna dalla funzione
	jr $ra
	
	input_errato: #coordinate fuori range
		la $a0, input_error
		li $v0, 4
		syscall
		#ripete la funzione di input
		j input_cmd
	
	# ---------------------------------------------
	movement_check: # controllo se la mossa è valida
		li $t3, 0 # setto il contatore di pedine a 0 ogni volta

		add $s0, $t4, -11
		find_range(sub_up_v, case_c1, next1)
		
		case_c1:
		inverti_pedine(sub_up_v_r, next1)
		
		next1:
		
		add $s0, $t4, 11
		find_range(add_down_v, case_c2, next2)
		
		case_c2:
		inverti_pedine(add_down_v_r, next2)
		
		next2:
		
		add $s0, $t4, 1
		find_range(add_right_v, case_c3, next3)
		
		case_c3:
		inverti_pedine(add_right_v_r, next3)
		
		next3:
		
		add $s0, $t4, -1
		find_range(sub_left_v, case_c4, next4)
		
		case_c4:
		inverti_pedine(sub_left_v_r, next4)
		
		next4:
		
		add $s0, $t4, -12
		find_range(sub_left_d1, case_c5, next5)
		
		case_c5:
		inverti_pedine(sub_left_d1_r, next5)
		
		next5:
		
		add $s0, $t4, 12
		find_range(add_right_d1, case_c6, next6)
		
		case_c6:
		inverti_pedine(add_right_d1_r, next6)
		
		next6:

		add $s0, $t4, 10
		find_range(sub_left_d2, case_c7, next7)
		
		case_c7:
		inverti_pedine(sub_left_d2_r, next7)

		next7:
		
		add $s0, $t4, -10
		find_range(add_right_d2, case_c8, last_control)
		
		case_c8:
		inverti_pedine(add_right_d2_r, last_control)
		
	#----------------------------------------------	
	print_mat: #stampa della matrice
	li $v0, 4
	add $a0, $zero, $addr	
	syscall
	jr $ra