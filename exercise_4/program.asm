# @Gianmarco Picarella
# Homework 4
# Create a program that executes various operation on a tree.
# This is my implementation in MIPS.
.data
	tree: .byte 0:2004
	input: .byte 0:2004
	jumpTable: .word  A, 0, C, 0, E, 0, 0, 0, I, 0, 0, L, M, 0, 0, 0, Q, 0, S, 0, 0, V
	params: .word 0:10
#	count_tree: .word 0:2000
.eqv len, $t7

.globl main


.macro get_params()
# scorri input da a0 + 2
la $a0, input
la $a3, params
add $a0, $a0, 1

li $s5, '\0'
li $s0, 0

lb $a2, ($a0)

while: beq $a2, '\0', end_while
	
	bne $a2, ' ', next_while
	
	sub $s1, $a0, $s0
	sw $s1, ($a3)
	sb $s5, ($a0)
	add $a3, $a3, 4
	li $s0, -1
	next_while:
	
	add $s0, $s0, 1
	
	add $a0, $a0, 1
	lb $a2, ($a0)

j while

end_while:

	sub $s6, $a0, $s0
	lb $s7, ($s6)
	beq $s7, '\0', end2_while

	sb $s5, -1($a0)
	sw $s6, ($a3)

end2_while:

.end_macro

.text

	
	
    main:
    	
    	# $a2 = indirizzo jumpTable
	
	read_command:
	# leggo stringa in input
	la $a2, jumpTable
    	la $a0, input 
    	li $a1, 2002
	li $v0, 8
	syscall
	
	# carico tipo istruzione
	lb $t6, ($a0)
	
	# eseguo jump tramite la jumpTable
	subi $t6, $t6, 65
	sll $t6, $t6, 2
	add $t6, $t6, $a2
	lw $t6, ($t6)
	
	# salta al comando specificato
	jr $t6
	
	
	L: # legge un albero e lo salva
		jal leggi_albero
		j read_command
	I:
		# estrae i parametri dalla stringa in input
		get_params()
		
		la $a3, params
		
		li $t0, 0 # indice a 0
		lw $t1, ($a3)
		
		lw $t2, 4($a3)
		
		lb $t4, ($t2) # k
		lb $t5, 1($t2) # v
		
		lw $t2, 8($a3)
		lb $t6, ($t2)
		sub $t6, $t6, 48
		
		la $t3, tree # indirizzo albero
		add $t3, $t3, 2 # indirizzo albero + 2
		
		jal inserisci_nodo
	
	j read_command
	
	E: # elimina sottoalbero
		
		# estrae i parametri dalla stringa in input
		get_params()
		
		li $t0, 0
		li $t2, 0
		la $t1, params
		lw $t1, ($t1) # indirizzo della path da seguire
		li $t5, '.'
		la $t3, tree # indirizzo albero
		add $t3, $t3, 2 # indirizzo albero + 2
		
		
		jal elimina_sottoalbero
		
		j read_command
	A:
		# estrae i parametri dalla stringa in input
		get_params()
		la $a3, params
	
		li $t0, 0 # indice a 0
		lw $t1, ($a3)
		li $t2, -1
		la $t3, tree # indirizzo albero
		add $t3, $t3, 2 # indirizzo albero + 2
		
		jal trova_indirizzo
		beq $t2, -1, read_command
		
		move $t0, $t2
		li $t1, 1
		li $t2, 0
			
		jal somma_alterna
			
		# stampa valore
		li $v0, 1
		move $a0, $t2
		syscall
			
		# stampa \n
		li $v0, 11
		li $a0, '\n'
		syscall
		j read_command
	S:
		# estrae i parametri dalla stringa in input
		get_params()
		la $a3, params
		
		li $t0, 0 # indice a 0
		lw $t1, ($a3) # primo parametro
		li $t2, -1
		la $t3, tree # indirizzo albero
		add $t3, $t3, 2 # indirizzo albero + 2
		
		jal trova_indirizzo
		beq $t2, -1, read_command
		
		move $s5, $t2 # salvo la x temporaneamente
		
		li $t0, 0 # indice a 0
		lw $t1, 4($a3) # primo parametro
		li $t2, -1
		la $t3, tree # indirizzo albero
		add $t3, $t3, 2 # indirizzo albero + 2
		
		jal trova_indirizzo
		beq $t2, -1, read_command
		
		# sposto il sottoalbero
		move $t0, $s5 # x
		move $t1, $t2 # y
		li $t2, '.'
		
		jal sposta_sottoalbero
		
		j read_command
	
	V:
		li $v0, 4 # syscall stampa stringa
		la $a0, tree # indirizzo albero
		add $a0, $a0, 2 # indirizzo albero + 2
		jal stampa_vettore
		j read_command
	
	C: # non implementata
	
	j read_command
	
	M:
		# estrae i parametri dalla stringa in input
		get_params()
		la $a3, params
		
		lw $a3, ($a3)
		lb $t1, ($a3)
		
		li $t0, 0 # indice
		li $t2, -1 # H maggiore
		la $t3, tree # indirizzo albero
		add $t3, $t3, 2 # indirizzo albero + 2
		li $t4, 0 # h nodo
		
		jal cerca_max_prof_nodo
		
		beq $t2, -1, read_command
		
		li $v0, 1
		move $a0, $t2
		syscall
		li $v0, 11
		li $a0, ' '
		syscall
		move $a0, $t5
		syscall
		li $a0, '\n'
		syscall
		
		j read_command
		
	Q: # fine programma
		li $v0, 10
		syscall
		
	#--------------------------

# ---------------------------- funzioni --------------------------------

leggi_albero:
	
	la $a1, tree # indirizzo albero
	add $a0, $a0, 1 # indirizzo input + 2
	add $a1, $a1, 2 # indirizzo albero + 2
	
	li len, 0
	li $t2, '\0'
	
	loop_conta:
		
		lb $t0, 0($a0)
		lb $t1, 1($a0)
		
		sb $t0, 0($a1)
		sb $t1, 1($a1)
		
		
		beq $t0, '.', salta_check
		beq $t0, '\n', fine_conta
		beq $t0, '\0', fine_conta
		
		blt $t1, 48, fine_conta
		bgt $t1, 57, fine_conta
		
		salta_check:
		
		add $a0, $a0, 2
		add $a1, $a1, 2
		
		add len, len, 2
		j loop_conta
	
	fine_conta:
		sb $t2, 1($a0) # tolgo \n alla fine della stringa con \0
		# stampa numero nodi
		srl $a0, len, 1
		li $v0, 1
		syscall
		# stampa \n
		li $v0, 11
		li $a0, '\n'
		syscall
	
	jr $ra # return dalla lettura
	
	
# -----------------------------------------------------------------
stampa_vettore:
	syscall
	
	li $v0, 11
	li $a0, '\n'
	syscall
	
	jr $ra # return dal print
# ------------------------------------------------------------------
inserisci_nodo:
	sub $sp, $sp, 12
	sw $t0, 0($sp) # indice nodo
	sw $t1, 4($sp) # indice path
	sw $ra, 8($sp) # ra

	# t0 -> id nodo
	# t1 -> id path
	
	# carico p
	lb $s0, ($t1)
	
	#carico nodo.key
	add $s2, $t0, $t3
	lb $s1, ($s2)
	
	# se p != nodo.key allora return
	bne $s0, $s1, return
		# p = p + 1
		add $t1, $t1, 1
		# se p + 1 == '\0'
		lb $s0, ($t1)
		bne $s0, '\0', right_check
			# modifico nodo
			
			# se sx
			beq $t6, $zero, insert_right
				# nodo sx esiste?
				sll $s0, $t0, 1
				add $s0, $s0, 2
				
				# se indice < len(albero)
				bge $s0, len, return
				add $s0, $s0, $t3
				# salvo nodo
				sb $t4, ($s0)
				sb $t5, 1($s0)
			# return
			j return
			
			# se dx
			insert_right: 
				# nodo dx esiste?
				sll $s0, $t0, 1
				add $s0, $s0, 4
				
				# se indice < len(albero)
				bge $s0, len, return
				add $s0, $s0, $t3
				# salvo nodo
				sb $t4, ($s0)
				sb $t5, 1($s0)
			# return
			j return
		
		right_check:
			# calcolo nodo dx
			sll $s1, $t0, 1
			add $s1, $s1, 4
			add $s1, $s1, $t3
			lb $s1, ($s1)
			
		bne $s0, $s1, left_check
			sll $t0, $t0, 1
			add $t0, $t0, 4
			# ricorsione dx
			jal inserisci_nodo
			# return
			j return
		
		left_check: 
			# calcolo nodo sx
			sll $s1, $t0, 1
			add $s1, $s1, 2
			add $s1, $s1, $t3
			lb $s1, ($s1)
			
		bne $s0, $s1, return
			sll $t0, $t0, 1
			add $t0, $t0, 2
			#ricorsione sx
			jal inserisci_nodo
			# return
		return:
			# return
			lw $ra, 8($sp)
			add $sp, $sp, 12
			jr $ra
		
# ----------------------------------------------------------------
elimina_sottoalbero:
	sub $sp, $sp, 16
	sw $t0, ($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $ra, 12($sp)
	
	
	#controllo nodo != null
	bge $t0, len, return_elimina
	
	beq $t2, 1, next_actions
	
	# carico p
	lb $s0, ($t1)
	
	# carico nodo.k
	add $s2, $t0, $t3
	lb $s1, ($s2)
	
	bne $s0, $s1, return_elimina
	# p = p + 1
	add $t1, $t1, 1
	# carico p
	lb $s0, ($t1)
	bne $s0, '\0', next_actions
	
	# setto cancella = 1
	li $t2, 1
	sw $t2, 8($sp)
	
	next_actions:
		bne $t2, 1, rec_left
		# setta il nodo attuale a ..
		add $s2, $t0, $t3
		sb $t5, ($s2)
		sb $t5, 1($s2)
	rec_left:
	# ricorsione sx
	lw $t2, 8($sp)
	sll $t0, $t0, 1
	add $t0, $t0, 2
	jal elimina_sottoalbero
	
	
	rec_right:
	# ricorsione dx
	lw $t2, 8($sp)
	lw $t0, ($sp)
	sll $t0, $t0, 1
	add $t0, $t0, 4
	jal elimina_sottoalbero
	
	
	return_elimina:
		lw $ra, 12($sp)
		add $sp, $sp, 16
		jr $ra
		
# --------------------------------------------------------

sposta_sottoalbero:
	sub $sp, $sp, 20
	sw $t0, ($sp) # x
	sw $t1, 4($sp) # y
	sw $ra, 8($sp)
	
	# x < len(albero) -> imposta s2, s3 a k, v di x
	bge $t0, len, return_sposta
	
	# indirizzo nodo x attuale
	add $s1, $t0, $t3
	
	lb $s2, ($s1) # leggo chiave
	lb $s3, 1($s1) # leggo valore
	
	# salvo in stack k, v di x
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	
	# nodo attuale x a ..
	sb $t2, ($s1)
	sb $t2, 1($s1)

	# ricorsione sx
	sll $t0, $t0, 1
	add $t0, $t0, 2
	
	sll $t1, $t1, 1
	add $t1, $t1, 2
	
	jal sposta_sottoalbero
	
	# ricorsione dx
	lw $t0, ($sp)
	lw $t1, 4($sp)
	
	sll $t0, $t0, 1
	add $t0, $t0, 4
	
	sll $t1, $t1, 1
	add $t1, $t1, 4

	jal sposta_sottoalbero
	
	sposta_y: # sposta ad y il valore di x
	
	lw $t1, 4($sp)
	
	bge $t1, len, return_sposta
	
	# leggo k, v di x da stack
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	
	# calcolo indirizzo nodo y
	add $t1, $t1, $t3
	
	sb $s2, ($t1)
	sb $s3, 1($t1)
	
	return_sposta:
	lw $ra, 8($sp)
	add $sp, $sp, 20
	jr $ra
	
# trova indirizzo
trova_indirizzo:
	sub $sp, $sp, 12
	sw $t0, ($sp)
	sw $t1, 4($sp)
	sw $ra, 8($sp)
	
	# if addr != -1 -> return
	bne $t2, -1, return_trova_addr
	# if nodo == null -> return
	bge $t0, len, return_trova_addr
	
	lb $s0, ($t1)
	add $s1, $t0, $t3
	lb $s2, ($s1)
	
	bne $s0, $s2, return_trova_addr
	# p = p + 1
	add $t1, $t1, 1
	lb $s0, ($t1)
	bne $s0, '\0', ricorsione_trova
	
	add $t2, $t0, $zero
	j return_trova_addr
	
	
	ricorsione_trova:
	
	# ricorsione sx
	sll $t0, $t0, 1
	add $t0, $t0, 2
	jal trova_indirizzo
	
	# ricorsione dx
	lw $t0, ($sp)
	sll $t0, $t0, 1
	add $t0, $t0, 4
	jal trova_indirizzo
	
	return_trova_addr:
		lw $ra, 8($sp)
		add $sp, $sp, 12
		jr $ra

#-----------------------------------------------------
cerca_max_prof_nodo:
	sub $sp, $sp, 12
	sw $t0, ($sp)
	sw $ra, 4($sp)
	sw $t4, 8($sp)
	
	# if nodo != null
	bge $t0, len, return_max_prof
	# carica valore nodo
	add $s0, $t0, $t3
	lb $s1, 1($s0)
	bne $s1, $t1, recursion_max_prof
	# if nodo.h > H -> H = nodo.h
	ble $t4, $t2, recursion_max_prof
	add $t2, $t4, $zero
	lb $t5, ($s0)
	
	recursion_max_prof:
	add $t4, $t4, 1
	sw $t4, 8($sp)
	
	# ricorsione dx
	sll $t0, $t0, 1
	add $t0, $t0, 4
	jal cerca_max_prof_nodo
	
	# ricorsione sx
	lw $t4, 8($sp)
	
	lw $t0, ($sp)
	sll $t0, $t0, 1
	add $t0, $t0, 2
	jal cerca_max_prof_nodo
	
	return_max_prof:
		lw $ra, 4($sp)
		add $sp, $sp, 12
		jr $ra

#--------------------------------------------------

somma_alterna:
	sub $sp, $sp, 12
	sw $t0, ($sp)
	sw $t1, 4($sp)
	sw $ra, 8($sp)
	
	# if nodo != null
	bge $t0, len, return_somma_alt
	
	add $s0, $t0, $t3
	lb $s0, 1($s0)
	
	beq $s0, '.', return_somma_alt
	
	subi $s0, $s0, 48
	mul $s0, $s0, $t1
	add $t2, $t2, $s0
	
	# ricorsione sx
	sll $t0, $t0, 1
	add $t0, $t0, 2
	mul $t1, $t1, -1
	jal somma_alterna
	
	
	# ricorsione dx
	lw $t0, ($sp)
	lw $t1, 4($sp)
	
	sll $t0, $t0, 1
	add $t0, $t0, 4
	mul $t1, $t1, -1
	jal somma_alterna
	
	return_somma_alt:
		lw $ra, 8($sp)
		add $sp, $sp, 12
		jr $ra
	
	
# --------------------------------------
conta_figli:

li $s0, 0

sub $sp, $sp, 12
sw $t0, ($sp)
sw $s0, 4($sp)
sw $ra, 8($sp)

bge $t0, len, return_count_0

add $t4, $t0, $t3
lb $t4, ($t4)

beq $t4, '.', return_count_0

# add 1 to $s0 and save it
li $s0, 1
sw $s0, 4($sp)

# ricorsione sx
sll $t0, $t0, 1
add $t0, $t0, 2
jal conta_figli

lw $s4, 4($sp)
add $s0, $s4, $s0
sw $s0, 4($sp)

lw $t0, ($sp)
#ricorsione dx
sll $t0, $t0, 1
add $t0, $t0, 4
jal conta_figli

lw $s4, 4($sp)
add $s0, $s4, $s0

lw $ra, 8($sp)
add $sp, $sp, 12
jr $ra



return_count_0:
lw $s0, 4($sp)
lw $ra, 8($sp)
add $sp, $sp, 12
jr $ra

# ------------------
genera_conto_nodi:
sub $sp, $sp, 8
sw $s1, ($sp)
sw $ra, 4($sp)

# if p != null
bge $s1, len, return_genera_conto

add $s5, $s1, $t3
lb $s5, ($s5)

beq $s5, '.', return_genera_conto

# conta sottonodi 
move $t0, $s1 
li $s0, 0 
li $t0, 0 
jal conta_figli  
# salvo valore in array 
sll $s6, $s1, 2 
add $s6, $t5, $s6 
sw $s0, ($s6)


# ricorsione sx 
sll $s1, $s1, 1
add $s1, $s1, 2

jal genera_conto_nodi

lw $s1, ($sp)
# ricorsione dx
sll $s1, $s1, 1
add $s1, $s1, 4

jal genera_conto_nodi

return_genera_conto:
lw $ra, 4($sp)
add $sp, $sp, 8
jr $ra




	
