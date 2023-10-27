; Ce programme lit une sequence de nombres au clavier et
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
msg_operation   db      10,'Operation (+, -, *, /) :  ','$'
msg_demande_entier      db	10,'Entrez un nombre entier : ','$'
msg_on_recommence       db      10,10,'Voulez-vous faire une autre operation (o/
msg_souligne            db      10,'                          __________',10,'$'
msg_resultat            db      10,'Resultat :                ','$'

erreur_div_par_0      db      10, 'Erreur : division par 0 !',10,'$'
touche_entree	db 	13
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

        ; affichage du mot Resultat
        mov     ah, 9
        lea     dx, msg_souligne
        int     21h
        mov     ah, 9
        lea     dx, msg_resultat
        int     21h

        ; en fonction de l'opération choisie, executer le calcul 
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
        mov     ah, 8
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

        mov     ax, operande1   ; Transfert de l'operande1 dans le registre ax
        mov     bx, operande2   ; Transfert de l'operande2 dans le registre bx

        mov     si, 0
        add     ax, bx          ; Addition des 2 registres ax et bx, avec result
        mov     di, ax          ; Transfert du regsitre ax vers le registre di
        
        call    afficher_entier32      ; Affichage du resultat
        
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
        ; Sauvegarde des registres ax, bx, cx, dx, si et di dans la pile
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di

        mov     ax, operande1
        mov     bx, operande2

        mov     si, 0
        sub     ax, bx

        ; tester si le resultat a donné un signe
        ; si pas de signe, donc résultat positif, on saute à r_positif
        ; sinon on affiche le signe -, 
        jns     r_positif       
        
        ; si le résultat est négatif, on affiche un signe moins et on prend le c
        ; Affichage du signe
        push    ax
        mov     dl, '-'
        mov     ah, 2
        int     21h
        pop     ax
        ; passage au complment à la base car le résultat est négatif
        neg     ax

r_positif:
        mov     di, ax

        ; Affichage du résultat
        call    afficher_entier32

        ; recuperation des registres ax, bx, cx, dx, si et di
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
        ; Sauvegarde des registres ax, bx, cx, dx, si et di dans la pile
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di

        mov     bx, operande2
division_par_0:
        cmp     bx, 0
        jne     division_correcte
        lea     dx, erreur_div_par_0
        mov     ah, 9
        int     21h
        jmp     fin_division
division_correcte:
        mov     dx, 0
        mov     si, 0
        mov     ax, operande1
        mov     bx, operande2
        div     bx

        ; affichage du quotient
        mov     di, ax
        call    afficher_entier32
 
        ; partie décimale
        cmp     dx, 0
        je      fin_division
        
        push    dx              ; sauvegarde du reste dx de la division dans la 
        
        ; affichage d'une virgule
        mov     dl, ','
        mov     ah, 2
        int     21h

        pop     dx              ; récupération du sommet de la pile dans dx
        
        mov     cx, 3           ; nombre de chiffres pour la partie décimale

partie_decimale:
        mov     ax, 10
        mul     dx
        div     bx

        mov     di, ax                  ; meettre le parametre input di avec le 
        call    Afficher_entier32         ; affiche du chiffre obtenu
        loop    partie_decimale

fin_division:
        ; Récupération des registres ax, bx, cx et dx depuis la pile
        pop     di
        pop     si
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

        mov     ax, operande1
        mov     bx, operande2

        mul     bx
        mov     di, ax
        mov     si, dx
        call    afficher_entier32


        pop     bx
        pop     ax
        ret
multiplication  endp


; -----------------------------------------------------
;       Affichage d'un entier stocké sur 32 bits
; -----------------------------------------------------
afficher_entier32	proc
	; l'entrée se trouve dans le registre di et si pour la partie haute des bits
        ; on divise d'abord par 10000 pour décaler les chiffres dans ax
         
        ; on procède par divisions successives par 10: 
        ; le quotient obtenu est à chaque fois divisé par 10 
        ; le reste obtenu à chaque division est un chiffre à afficher
        ; dans l'ordre inverse. 
        ; on refait le même calcul pour la partie basse
        ; On empile au fur et à mesure et ensuite 
        ; on dépile et on affiche au fur et à mesure
	push    ax
	push    bx
	push    cx
	push    dx
	push    si
	push    di
	;le nombre en entrée est stocké en si et di
	mov     dx,si
	mov     ax,di
	mov     bx, 10000
	div     bx              ; permet de décaler les 4 chiffres du bas dans dx et le
                                ; dans ax
		
	mov     si,ax	        ; sauvegarde de ax dans si, car ax va être utilisé pour l
	mov     ax,dx
		
	mov     cx,0
	mov     bx,10

Calcul_chiffres_bas:           ; on divise ax successivement par 10 
	mov     dx,0
	div     bx
	push    dx
	inc     cx
		
	cmp     ax,0
	jne     Calcul_chiffres_bas
	cmp     cx,4
	jae     fin_calcul_chiffres_bas
	cmp     si,0
	jne     Calcul_chiffres_bas
	
fin_calcul_chiffres_bas:
	mov     ax,si
Calcul_chiffres_haut:
	cmp     ax,0
	je      affiche_tous_chiffres
	mov     dx,0
	div     bx
	push    dx
	inc     cx
	jmp     Calcul_chiffres_haut
		
Affiche_tous_chiffres:                  ; Affichage des chiffres stockés dans la
	pop     dx
	add     dl,'0'
	mov     ah,2
	int     21h
	loop    affiche_tous_chiffres
	
        pop     di
	pop     si
	pop     dx
	pop     cx
	pop     bx
	pop     ax
	ret
afficher_entier32 endp

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

;---------------------------
;       Lire un operateur
;---------------------------
lire_operateur	proc
	;output di

	push    ax
	push    bx
	push    cx
	push    dx
		
	mov     di,0
	mov     cx,1
lire_car2:
        ; on lit un caraactère saisi au clavier
        ; on ne l'affiche que s'il est correct (signe opérateur)
	mov     ah,8
	int     21h
			
	cmp     al, touche_suppr
	je      traiter_suppr2
	cmp     al, touche_entree
	je      traiter_entree2
	cmp     cx, 0
	je      lire_car2

	cmp     al, touche_plus
	je      suite
	cmp     al, touche_moins      
	je      suite
	cmp     al, touche_mult
	je      suite
	cmp     al, touche_div
	je      suite
        jmp     lire_car2

suite:
        ; on affiche le signe opérateur saisi
        mov     operateur_lu, al
	mov     dl, operateur_lu  
	mov     ah, 2
	int     21h

	dec     cx
			
        jmp     lire_car2
		
traiter_suppr2:
	cmp     cx,1
	jnb     lire_car2
	lea     dx, delete
	mov     ah,9
	int     21h

	inc     cx
	jmp     lire_car2
	
traiter_entree2:
	cmp     cx,1
	jne     fin_lire_operateur
        jmp     lire_car2
	mov     dl, '0'
	mov     ah,2
	int     21h		
		
fin_lire_operateur:
	pop     dx
	pop     cx
	pop     bx
	pop     ax
	ret
lire_operateur	endp

        end
