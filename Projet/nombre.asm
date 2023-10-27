         .MODEL  SMALL
         .STACK  100H
         .DATA

TXT_1    DB    'Entrez un nombre de 4 chiffres maximum: ',10,'$'
TXT_2    DB    ' n''est pas un nombre premier !',10,'$'
TXT_3    DB    ' est un nombre premier !',10,'$'

touche_entree	db 	13
touche_suppr	db	8
delete	        db	8,' ',8,'$'

         .CODE
debut:
         mov     ax, @data
         mov     ds, ax
         
         mov   ah, 9
         lea   dx, txt_1
         int   21h

         CALL  lire_entier

         CALL  est_premier

         jmp   fin_prog
est_premier    proc
         push  ax
         push  bx
         push  cx
         push  dx
         
         cmp   di, 1
         je    pas_premier
         MOV   cx, di
         DEC   cx
Boucle:
         MOV   ax, di
         mov   dx, 0
         
         DIV   cx
         CMP   dx, 0
         JE    pas_premier
         DEC   cx
         CMP   cx, 1
         JE    aff_premier
         JMP   Boucle
pas_premier:
         MOV   ah, 9
         LEA   dx, txt_2
         INT   21h
         JMP   fin_premier
aff_premier:
         MOV   ah, 9
         LEA   dx, txt_3
         INT   21h
fin_premier:
         pop   dx
         pop   cx
         pop   bx
         pop   ax
         ret
est_premier    endp

; --------------------------------------
;       Lire un entier au clavier
; --------------------------------------
lire_entier	proc
	;output di

	push    ax
	push    bx
	push    cx
	push    dx
		
	mov     di,0
	mov     cx,4
lire_char:
        ; on lit un caractère saisi au clavier ans l'afficher
        ; on ne l'affichera que s'il est valide
	mov     ah,8
	int     21h
			
	cmp     al, touche_suppr
	je      traiter_suppr
	cmp     al, touche_entree
	je      traiter_entree
	cmp     cx, 0
	je      lire_char
	cmp     al, '0'
	jb      lire_char
	cmp     al, '9'
	ja      lire_char

        ; le caractère saisi est correct, on l'affiche
	mov     dl,al
	mov     ah,2
	int     21h

	sub     al,'0'
	
	mov     bl, al	
	mov     ax, 10	
	mul     di	
	add     al, bl	
	mov     di, ax
	
	dec     cx
			
        jmp     lire_char
		
traiter_suppr:
	cmp     cx,4
	jae     lire_char
	lea     dx, delete
	mov     ah,9
	int     21h
		
	mov     dx,0
	mov     ax,di
	mov     bx,10
	div     bx	
	mov     di,ax	
	;
	inc     cx
	jmp     lire_char
	
traiter_entree:
	cmp     cx,4
	jne     fin_lire_entier
	mov     dl,'0'
	mov     ah,2
	int     21h		
		
fin_lire_entier:
	pop     dx
	pop     cx
	pop     bx
	pop     ax
	ret
lire_entier	endp



fin_prog:
        mov     ah, 4ch
        int     21h
        ret


         END