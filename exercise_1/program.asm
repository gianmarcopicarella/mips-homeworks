# @Gianmarco Picarella
# Homework 1
# create a program that computes the last k sum of integers taken in input with 0 < k < 20.
# The sequence can vary drastically so i can't define a static array to collect all the integers.
# This is my implementation in MIPS.

.data
.align 2
	
	input_array: .word 0:20

.globl main

.eqv $k, $t0
.eqv $array_addr, $a2
.eqv $count, $t1
.eqv $min_s, $t5
.eqv $max_s, $t6
.eqv $min_y, $s4
.eqv $max_y, $s5
.eqv $sum, $t4

.macro max(%a, %b)
	blt %a, %b, end_max
	add %b, $zero, %a
	end_max:
.end_macro

.macro min(%a, %b)
	bgt %a, %b, end_min
	add %b, $zero, %a
	end_min:
.end_macro

.macro print(%code, %val)
	li $v0, %code
	add $a0, $zero, %val
	syscall
.end_macro

.text
	main: #entry point del programma
		
		#calcola l'indirizzo dell'array temporaneo di lunghezza k 
		la $array_addr, input_array
		add $t2, $zero, $array_addr
		
		#prendi in input k
		li $v0, 5
		syscall
		add $k, $zero, $v0
		
		#prendi un numero in input
		li $v0, 5
		syscall
		#se il numero è uguale a 0
		beqz $v0, end
		#imposta max e min al valore inziale
		add $max_s, $zero, $v0
		add $min_s, $zero, $v0
		
		j false
		
		loop: #input loop
			
			#prendi un numero in input
			li $v0, 5
			syscall
			#se il numero è uguale a 0
			beqz $v0, end	
			
			#calcolo il maggiore e minore di S
			
			max($v0, $max_s)
			min($v0, $min_s)
			
			bne $count, $k, false
			
			true:
				#carico il valore attualmente salvato
				lw $s7, ($t2)
				#eseguo la sottrazione tra $sum ed il valore salvato
				sub $sum, $sum, $s7
				add $sum, $sum, $v0
				
				sw $v0, 0($t2)		
				
				#calcolo il nuovo $max_y e $min_y
				max($sum, $max_y)
				min($sum, $min_y)
				
				#print
				print(1, $sum)
				
				#stampa a capo
				print(11, '\n')
				
				add $t2, $t2, 4
				blt $t2, $k, continue
				add $t2, $zero, $array_addr
			#salta alla prossima iterazione
			j continue	
			
			#FALSE:
			false:
				#salvo il numero nell'arrray
				sw $v0, 0($t2)
				add $t2, $t2, 4
				
				add $sum, $sum, $v0
				#incremento il count
				add $count, $count, 1
				
				#controllo se ora count è uguale a $k 
				bne $count, $k, continue
				
				#setto max e min al valore di $sum
				add $max_y, $zero, $sum
				add $min_y, $zero, $sum
				
				#stampa la somma
				print(1, $sum)
				
				#stampa a capo
				print(11, '\n')
				
				add $t2, $zero, $array_addr
				sll $k, $k, 2
				add $k, $k, $array_addr
				add $count, $zero, $k
				
		continue:
		j loop
		
	end: #fine del programma
	
		#stampa min e max si S ed Y
		print(1, $min_s)
		#stampa a capo
		print(11, '\n')
		print(1, $max_s)
		#stampa a capo
		print(11, '\n')
		print(1, $min_y)
		#stampa a capo
		print(11, '\n')
		print(1, $max_y)
		#stampa a capo
		print(11, '\n')
	
		li $v0, 10
		syscall
