; Ce programme lit une se ́quence de nombres au clavier et
; affiche 
        .MODEL  SMALL
        .STACK  100H
        .DATA
titre_1         db	' ___________________________________________',10,'$'
titre_2         db      '|                                           |',10,'$'
titre_3 	db	'|      PROJET ASSEMBLEUR DUT 1ERE ANNEE     |',10,'$'
titre_4 	db	'|        ***     CALCULATRICE    ***        |',10,'$'
titre_5 	db	'|        Nathan ALLEGRA / Allan TIJOU       |',10,'$'
titre_6	        db	'|___________________________________________|',10,'$'
msg_operation   db      10,'Operation : +, -, *, /',10,'$'
msg_demande_entier      db	10,' Entrez un nombre entier',10,'$'
msg_on_recommence       db      10,'Voulez-vous faire une autre operation (o/n) ?',10,'$'
msg_resultat            db      10,'Resultat :',10,'$'

erreur_div_par_0      db      10, 'Erreur : division par 0 !',10,'$'
touche_ent	db 	13
touche_suppr	db	8
delete	        db	8,' ',8,'$'
operande1       dw      0
operande2       dw      0
operateur       dw      0
touche_plus     db      43      ;'+'
touche_moins    db      45      ;'-'
touche_mult     db      42      ;'*'
touche_div      db      47      ;'/'
operateur_lu    db      0

        .CODE
        mov     ax, @data
        mov     ds, ax
        ;
        ; programme principal

        ; affichage de l'entete
        mov     ah,9
        lea     dx, titre_1
        int     21h
        lea     dx, titre_2
        int     21h
        lea     dx, titre_3
        int     21h
        lea     dx, titre_4
        int     21h
        lea     dx, titre_5
        int     21h
        lea     dx, titre_6
        int     21h

debut:
        ; Afficher le message demandant la saisie d'un entier
        mov     ah, 9
        lea     dx, msg_demande_entier
        int     21h

        call    lire_entier     ; lire un entier au clavier
        mov     si, di
        mov     operande1, si   ; stocker la valeur lue si dans operande1

        ;       Afficher le message demandant l'operation a executer
        mov     ah, 9
        lea     dx, msg_operation
        int     21h

        call    lire_operateur  ; lire un operateur et le recuperer dans op_lu

        ; Afficher le message demandant la saisie d'un entier
        mov     ah, 9
        lea     dx, msg_demande_entier
        int     21h
      
        call    lire_entier     ; lire un entier au clavier
        mov     si, di
        mov     operande2, si

        ; en fonction de l'operation choisie, executer le calcul 
        mov     al, operateur_lu
        cmp     al, touche_plus
        je      choix_addition
        mov     al, operateur_lu
        cmp     al, touche_mult
        je      choix_multiplication
        mov     al, operateur_lu
        cmp     al, touche_moins
        je      choix_soustraction
        mov     al, operateur_lu
        cmp     al, touche_div
        je      choix_division

choix_addition:
        call    addition 
        jmp     fin
choix_multiplication:
        call    multiplication
        jmp     fin
choix_soustraction:
        call    soustraction
        jmp     fin
choix_division:
        call    division
        jmp     fin

fin:
        ; affiche le message demandant si on souhaite refaire une operation
        mov     ah, 9
        lea     dx, msg_on_recommence
        int     21h
on_recommence:
        ; saisir la reponse (o)ui ou (n)on
        mov     ah, 1
        int     21h
        cmp     al, 'o'
        je      debut
        cmp     al, 'n'
        je      fin_prog
        jmp     on_recommence
fin_prog:
        mov     ah, 4ch
        int     21h
        ret

;       ----------------------------
;       sous-programme de l'addition
;       ----------------------------
addition        proc
        ; Sauvegarde des registres ax, bx, cx et dx dans la pile
        push    ax
        push    bx
        push    cx
        push    dx

        ; affiche du mot Reresulat
        mov     ah, 9
        lea     dx, msg_resultat
        int     21h

        mov     ax, operande1   ; Transfert de l'operande1 dans le registre ax
        mov     bx, operande2   ; Transfert de l'operande2 dans le registre bx

        add     ax, bx          ; Addition des 2 registres ax et bx, avec resultat dans le registre ax
        mov     di, ax          ; Transfert du regsitre ax vers le registre di
 
        call    printInt16      ; Affichage du resultat
        
        ; recuperation des registres ax, bx, cx et dx depuis la pile
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret
addition        endp

;       ---------------------------------
;       sous-programme de la soustraction
;       ---------------------------------
soustraction    proc
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di

        mov     ah, 9
        lea     dx, _resultat
        int     21h

        mov     si, operande1
        mov     di, operande2

        sub     si, di

        mov     di, si
        jns     r_positif
        mov     dl, '-'
        mov     ah, 2
        int     21h

        neg     si
r_positif:
        mov     di, si



        call    printint16
        
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret
soustraction    endp


;       -----------------------------
;       sous-programme de la division
;       -----------------------------
division        proc
        push    ax
        push    bx
        push    cx
        push    dx

        ;       Affichage de l'opérande 1
        mov     di, operande1
        mov     ah, 9
        lea     dx, _oper1
        int     21h
        call    printInt16
        ;       Affichage de l'opérande 2
        mov     ah, 9
        lea     dx, _oper2
        int     21h
        mov     di, operande2
        call    printInt16

        ; affichage du texte Resultat
        mov     ah, 9
        lea     dx, _resultat
        int     21h

        mov     bx, operande2
division_par_0:
        cmp     bx, 0
        jne     division_correcte
        lea     dx, _div_par_0
        mov     ah, 9
        int     21h
        jmp     fin_division
division_correcte:
        mov     dx, 0
        mov     ax, operande1
        mov     bx, operande2
        div     bx

        ; affichage du quotient
        mov     di, ax
        call    printint16
 
        ; partie décimale
        cmp     dx, 0
        je      fin_division
        
        push    dx               ; sauvegarde du reste dx de la division dans la pile
        ; affiche une virgule
        mov     dl, ','
        mov     ah, 2
        int     21h

        pop     dx              ; recuperation du sommet de la pile dans dx
        
        mov     cx, 3           ; nombre de chiffres pour la partie décimale

partie_decimale:
        mov     ax, 10
        mul     dx
        div     bx

        mov     di, ax          ; meettre le parametre input di avec le resultat a afficher
        call    printint16      ; affiche du chiffre obtenu
        loop    partie_decimale

fin_division:
        pop     dx
        pop     cx
        pop     bx
        pop     ax

        ret
division        endp

;       -----------------------------------
;       sous-programme de la multiplication
;       -----------------------------------
multiplication  proc
        push    ax
        push    bx

        mov     di, operande1
        mov     ah, 9
        lea     dx, _oper1
        int     21h
        call    printInt16

        mov     ah, 9
        lea     dx, _oper2
        int     21h
        mov     di, operande2
        call    printInt16


        mov     ah, 9
        lea     dx, _resultat
        int     21h

        mov     ax, operande1
        mov     bx, operande2

        mul     bx
        mov     di, ax
        mov     si, dx
        call    printInt32

        pop     bx
        pop     ax
        ret
multiplication  endp



printInt16	proc
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

lire_entier	proc
	;output di

	push    ax
	push    bx
	push    cx
	push    dx
		
	mov     di,0
	mov     cx,4
SIread_char:
	mov     ah,8
	int     21h
			
	cmp al, del
	je SIaction_del
	cmp al, ok
	je SIaction_ok
	cmp cx, 0
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
			
        jmp     SIread_char
		
SIaction_del:
	cmp     cx,4
	jae     SIread_char
	lea     dx, delete
	mov     ah,9
	int     21h
		;di=number
	mov     dx,0
	mov     ax,di
	mov     bx,10
	div     bx		;dx:ax DIV bx => AX (MOD => DX)
	mov     di,ax	;di <= di div 10
	;
	inc     cx
	jmp     SIread_char
	
SIaction_ok:
	cmp     cx,4
	jne     SIfin
	mov     dl,'0'
	mov     ah,2
	int     21h		
		
SIfin:
	pop     dx
	pop     cx
	pop     bx
	pop     ax
	ret
lire_entier	endp

;       Lire un operateur
;==========================
scanOper	proc
	;output di

	push    ax
	push    bx
	push    cx
	push    dx
		
	mov     di,0
	mov     cx,1
SIread_car:
	mov     ah,8
	int     21h
			
	cmp     al, del
	je      SIaction_bs
	cmp     al, ok
	je      SIaction_rc
	cmp     cx, 0
	je      SIread_car

	cmp     al, op_plus
	je      suite
	cmp     al, op_moins       
	je      suite
	cmp     al, op_mult
	je      suite
	cmp     al, op_div
	je      suite
        jmp     SIread_car

suite:
        mov     op_lu, al
	mov     dl, op_lu   ;al
	mov     ah, 2
	int     21h

	dec     cx
			
        jmp     SIread_car
		
SIaction_bs:
	cmp     cx,1
	jnb     SIread_car
	lea     dx, delete
	mov     ah,9
	int     21h
		;di=number
	;
	inc     cx
	jmp     SIread_car
	
SIaction_rc:
	cmp     cx,1
	jne     SIfin2
	mov     dl, '0'
	mov     ah,2
	int     21h		
		
SIfin2:
	pop     dx
	pop     cx
	pop     bx
	pop     ax
	ret
scanOper	endp

        end
