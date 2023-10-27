pile segment para stack 'pile'
        dw 512 dup(00)
pile  ends


donnee segment
	_title_1		db	' _____________________________________',10,'$'
	_title_2		db	'|  Mini Projet     MICROPROCESSEURS   |',10,'$'
	_title_3		db	'|    ***  MINI CALCULATRICE  ***      |',10,'$'
	_title_4		db	'|  PAR :        Bouchkati Tarek       |',10,'$'
	_title_5		db	'|_____________________________________|',10,'$'
	_menu			db	' 1:(+) 2:(-) 3:(x) 4:(/) 5:(sin)',10,' taper le numero de votre operation: $'
	
	_qs				db	'   $'
	_r_add			db	' + $'
	_r_sub			db	' - $'
	_r_mul			db	' x $'
	_r_div			db	' / $'
	_qe				db	' = $'
	_q_dz			db	'Erreur : division par zero$'
	_r_sins			db	'   sin($' 
	_r_sine			db	') = $'
	
	_quit			db	'  > quitter (y/n)? $'
	ok		db 	13
	del		db	8
	delete	db	8,' ',8,'$'
donnee ends


code segment 
wrLn proc near
		push ax
		push dx
		mov dl,10
		mov ah,2
		int 21h
		pop dx
		pop ax
		ret
wrLn endp
scanInt	proc near
	;output di
	assume cs:code,ds:donnee
		push ax
		push bx
		push cx
		push dx
		
		mov di,0
		mov cx,4
		SIread_char:
			mov ah,8
			int 21h
			
			cmp al,del
			je SIaction_del
			cmp al,ok
			je SIaction_ok
			cmp cx,0
			je SIread_char
			cmp al,'0'
			jb SIread_char
			cmp al,'9'
			ja SIread_char
			mov dl,al
			mov ah,2
			int 21h
			sub al,'0'
			;di=number  al=digit
			mov bl,al	;bl=digit
			mov ax,10	
			mul di		;dx:ax=di x 10
			add al,bl	;ax = ax + digit
			mov di,ax
			;di=number
			dec cx
			
		jmp SIread_char
		
	SIaction_del:
		cmp cx,4
		jnb SIread_char
		lea dx, delete
		mov ah,9
		int 21h
		;di=number
		mov dx,0
		mov ax,di
		mov bx,10
		div bx		;dx:ax DIV bx => AX (MOD => DX)
		mov di,ax	;di <= di div 10
		;
		inc cx
		jmp SIread_char
	
	SIaction_ok:
		cmp cx,4
		jne SIfin
		mov dl,'0'
		mov ah,2
		int 21h		
		
	SIfin:
		pop dx
		pop cx
		pop bx
		pop ax
		ret
scanInt	endp

printInt16	proc near
	;input di
		push ax
		push bx
		push cx
		push dx
		
		mov cx,0
		mov ax,di
		mov bx,10
		
	PI16calc_digits:
		mov dx,0
		div bx
		push dx
		inc cx
		cmp ax,0
		jne PI16calc_digits
	
	PI16aff_digits:
		pop dx
		add dl,'0'
		mov ah,2
		int 21h
		loop PI16aff_digits
		
		pop dx
		pop cx
		pop bx
		pop ax
		ret
printInt16 endp

printInt32	proc near
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	;input si:di
		mov dx,si
		mov ax,di
		mov bx, 10000
		div bx ;=> 4 digits bas=dx ;; 4hauts=ax
		
		mov si,ax	;save the hi party
		mov ax,dx	;load the low in ax
		
		mov cx,0
		mov bx,10
	;sur bas
	PI32bas:
		mov dx,0
		div bx
		push dx
		inc cx
		;while  ax!0 ou (si!0 et cx<4)
		cmp ax,0
		jne PI32bas
		cmp cx,4
		jae _PI32haut
		cmp si,0
		jne PI32bas
	
	_PI32haut:
		mov ax,si
		PI32haut:
			cmp ax,0
			je PI32aff
			mov dx,0
			div bx
			push dx
			inc cx
			jmp PI32haut
		
	PI32aff:
		pop dx
		add dl,'0'
		mov ah,2
		int 21h
		loop PI32aff
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
printInt32 endp

prog_addition proc near
		push ax
		push dx
		push si
		push di
	;'   '
		lea dx,_qs
		mov ah,9
		int 21h
	;nbr 1 dans si
		call scanInt
		mov si,di
	;' + '
		lea dx,_r_add
		mov ah,9 
		int 21h
	;nbr 2 dans di
		call scanInt
	;' = '
		lea dx,_qe
		mov ah,9
		int 21h		
	;result	  
		add di,si
		call printInt16
		call wrLn
		
		pop di
		pop si
		pop dx
		pop ax
		ret
prog_addition endp

prog_soustraction proc near
		push ax
		push dx
		push si
		push di
	;'   '
		lea dx,_qs
		mov ah,9
		int 21h
	;nbr 1 dans si
		call scanInt
		mov si,di
	;' - '
		lea dx,_r_sub
		mov ah,9 
		int 21h
	;nbr 2 dans di
		call scanInt
	;' = '
		lea dx,_qe
		mov ah,9
		int 21h						
	;resultat
		sub si,di
		jns _ps_jumpOver
		;resultat negatif
			mov dl,'-' 
			mov ah,2   
			int 21h
			neg si
		_ps_jumpOver: 
			mov di,si
			call printInt16
			call wrLn
		
		pop di
		pop si
		pop dx
		pop ax
		ret
prog_soustraction endp

prog_multiplication proc near
		;mul source ->>  dx:ax = ax * source
		push ax
		push dx
		push si
		push di
	;'   '
		lea dx,_qs
		mov ah,9
		int 21h
	;nbr 1 dans si
		call scanInt
		mov si,di
	;' x '
		lea dx,_r_mul
		mov ah,9 
		int 21h
	;nbr 2 dans di
		call scanInt
	;' = '
		lea dx,_qe
		mov ah,9
		int 21h						
	;resultat
		mov ax,si
		mul di ;=> dx:ax = ax * di
		mov si,dx
		mov di,ax
		call printInt32
		call wrLn
		
		pop di
		pop si
		pop dx
		pop ax
		ret
prog_multiplication endp

prog_division proc near
	push ax
	push cx
	push dx
	push di
	push si
		
	;'   '
		lea dx,_qs
		mov ah,9
		int 21h
	;nbr 1 dans si
		call scanInt
		mov si,di
	;' / '
		lea dx,_r_div
		mov ah,9 
		int 21h
	;nbr 2 dans di
		call scanInt
	;' = '
		lea dx,_qe
		mov ah,9
		int 21h	
		
	;div by zero
		cmp di,0
		jne PDiv_overDivZero
		lea dx,_q_dz
		mov ah,9
		int 21h
		jmp PDiv_fin
	PDiv_overDivZero: ;calcul des résultats
		mov dx,0
		mov ax,si
		div di ;DIV di ->> DX:AX / di >> q = AX , r = DX
		mov si,di
		mov di,ax
		call printInt16
		;partie apré le virgule
		cmp dx,0
		je PDiv_fin
		
		push dx
		mov dl,'.'
		mov ah,2
		int 21h
		pop dx
		
		mov cx,2
		PDIV_vir:
			mov ax,10
			mul dx
			div si
			mov di,ax
			call printInt16
			loop PDIV_vir
	
	PDiv_fin:
		call wrLn
		pop si
		pop di
		pop dx
		pop cx
		pop ax
		ret
prog_division endp

prog_sin 	proc near
		push ax
		push bx
		push cx
		push dx
		push di
		push si
	
	;'   sin('
		lea dx,_r_sins
		mov ah,9
		int 21h
		
	;saisie dans di
		call scanInt
		
	;' deg) = '
		lea dx,_r_sine
		mov ah,9
		int 21h
	
	;limitation du domaine
		;si=di%360
			mov dx,0
			mov ax,di
			mov bx,360
			div bx
			mov si,dx
		;limitation dans le domaine I1=[0 180]
			cmp si,180
			jbe sin_I1
			sub si,180
			;afficher la signe moins
			mov dl,'-'
			mov ah,2
			int 21h
		sin_I1:
			;limitation dans le domaine I2=[0 90]
			cmp si,90
			jbe sin_I2
			mov ax, 180
			sub ax,si
			mov si,ax
		sin_I2:
			;cas de zero
			cmp si,0
			jne sin_pi2
			mov dl,'0'
			mov ah,2
			int 21h
			jmp sin_fin
		sin_pi2:
			cmp si,90
			jne sin_rad
			mov dl,'1'
			mov ah,2
			int 21h
			jmp sin_fin
		sin_rad:
			;conv deg-> rad
			mov ax,3142 ; 1000Pi
			mul si
			mov bx,180
			div bx
			mov si,ax ; l'angle en radian est dans si
			;di = sin x = x - x^3/6 + x^5/120 - x^7/5040
			;+x
			mov di,si
			;-x^3/6
			mov ax,si
			mov bx,si
			mul bx
			mov cx,1000
			div cx
			mul bx
			div cx
			mov cx,ax ; x^3
			mov dx,0
			mov bx,6
			div bx
			sub di,ax
			;+x^5/120
			mov ax,cx
			mov bx,si
			mul bx
			mov cx,1000
			div cx
			mul bx
			div cx
			mov cx, ax ; x^5
			mov dx,0
			mov bx,120
			div bx
			add di,ax
			
		;affichage
			mov cx,3
			mov ax,di
			mov bx,10
		sin_calc_digits:
				mov dx,0
				div bx
				push dx
				loop sin_calc_digits
			mov cx,3
			mov ah,2
			mov dl,'0'
			int 21h
			mov dl,'.'
			int 21h
		sin_aff_digits:
				pop dx
				add dl,'0'
				mov ah,2
				int 21h
				loop sin_aff_digits
		
	sin_fin:
		call wrLn
		pop si
		pop di
		pop dx
		pop cx
		pop bx
		pop ax
		ret
prog_sin endp

prog    proc near
        assume cs:code;ds:donnee;ss:pile;es:nothing
        mov ax,donnee
        mov ds,ax
		
		;affichage de l'entete
				mov ah,9
				lea dx,_title_1
				int 21h
				lea dx,_title_2
				int 21h
				lea dx,_title_3
				int 21h
				lea dx,_title_4
				int 21h
				lea dx,_title_5
				int 21h
			
		_p_menu:;afichage du menu			
				mov ah,9
				lea dx,_menu
				int 21h
			;choix
				mov ah,1
				int 21h
				call wrLn
			;test selection
		_p_addition:
				cmp al,'1'
				jne _p_soustraction
				call prog_addition
				jmp _p_repeat
		_p_soustraction:
				cmp al,'2'
				jne _p_multiplication
				call prog_soustraction
				jmp _p_repeat
		_p_multiplication:
				cmp al,'3'
				jne _p_division
				call prog_multiplication
				jmp _p_repeat
		_p_division:
				cmp al,'4'
				jne _p_sin
				call prog_division
				jmp _p_repeat
		_p_sin:
				cmp al,'5'
				jne _p_menu
				call prog_sin
				jmp _p_repeat
	
		_p_repeat:
			mov ah,9
			lea dx, _quit
			int 21h
			;saisi du reponse
			mov ah,1
			int 21h
			call wrLn
			;traitement
			cmp al,'n'
			je _p_menu
			cmp al,'y'
			jne _p_repeat
		
		_p_end:
			mov	ax,4c00h ;retour au dos
			int	21h
		
prog  endp
code ends
        end  prog