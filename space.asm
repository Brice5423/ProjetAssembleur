
.386

;----------------------------------------------------------------------------------------------;
;---------------------------------------- 1er Segment ----------------------------------------;

data segment use16 
		;-------------------- déclaration variable --------------------;
count 	db 0
	
; position du navire (pour initialiser)
our_boat_x 	dw 50 
our_boat_y 	dw 50
	
; tirs
hit			dw 100 DUP(0) ; dans la mémoire il n'y aura que des 0
count_hit 	dw 0
	

		;-------------------- définit le modèle navire --------------------;
; dimensions 8x8     01234567
models_boats	db 	'   xx   ';0  
				db	'   xx   ';1
				db	'  xxxx  ';2
				db	' xxxxxx ';3  Notre navire (modèle 0)
				db	'xxxxxxxx';4
				db	'xx xx xx';5
				db	'  xxxx  ';6
				db	' xxxxxx ';7

				;    01234567
				db 	' xxxxxx ';0
				db	'xxxxxxxx';1
				db	'x  xx  x';2
				db	'xxxxxxxx';3  navire ennemi (modèle 1)
				db	'x x x x ';4
				db	' x x x x';5
				db	'x x x x ';6
				db	'xxxxxxxx';7

	            ;    01234567
				db 	'        ';0
				db	'  xxxx  ';1
				db	' x    x ';2
				db	'x  xx  x';3  navire ennemi (modèle 2)
				db	'x  xx  x';4
				db	' x    x ';5
				db	'  xxxx  ';6
				db	'        ';7

	            ;    01234567
				db 	'xxxxxxxx';0
				db	'x x  x x';1
				db	' xxxxxx ';2 navire ennemi (modèle 3)
				db	'   xx   ';3
				db	' x xx x ';4
				db	'x  xx  x';5
				db	'  xxxx  ';6
				db	'  x  x  ';7	

models_boats_len equ $-models_boats
	

		;-------------------- définit position navire --------------------;
			; état_mort, no_medel, x, y 
boats   dw 0,1,50,20 ,0,1,90,20 ,0,1,130,20 ,0,1,170,20 ,0,1,210,20 ,0,1,250,20 
        dw 0,2,50,50 ,0,2,90,50 ,0,2,130,50 ,0,2,170,50 ,0,2,210,50 ,0,2,250,50
        dw 0,3,50,80 ,0,3,90,80 ,0,3,130,80 ,0,3,170,80 ,0,3,210,80 ,0,3,250,80

count_boats dw 18
	

		;-------------------- définit messages début --------------------;
Start_Mes1 db " SPACE INVADERS " ; message pour le nom du jeu
Start_Mes1_Len equ $-Start_Mes1
Start_Mes1_Center equ 20 - (Start_Mes1_Len/2)
	
Start_Mes2 db " Mode : HARDCORE " ; message de difficulté ;-)
Start_Mes2_Len equ $-Start_Mes2
Start_Mes2_Center equ 20 - (Start_Mes2_Len/2)
	
Start_Mes3 db " Press any key to start." ; message pour dire d'appuyer sur une touche pour lancer la partie (en anglais parce que c'est plus classe)
Start_Mes3_Len equ $-Start_Mes3
Start_Mes3_Center equ 20 - (Start_Mes3_Len/2)
	
Start_Mes4 db " GIANGRECO Vincent | ORLANGE Brice | Grp1 " ; message pour dire ceux qui l'ont fait 
Start_Mes4_Len equ $-Start_Mes4
Start_Mes4_Center equ 20 - (Start_Mes4_Len/2)


		;-------------------- définit messages fin --------------------;
End_Mes1 db " Vous avez perdu Monsieur ",01h ; message pour dire qu'il a gagné en fin de partie
End_Mes1_Len equ $-End_Mes1
End_Mes1_Center equ 20 - (End_Mes1_Len/2)
	
End_Mes2 db " Press any key to exit." ; message de fin de partie pour dire d'apuyer sur une touche pour fermer la page (en anglais parce que c'est plus classe)
End_Mes2_Len equ $-End_Mes2
End_Mes2_Center equ 20 - (End_Mes2_Len/2)

data ends



		;-------------------- Code couleur --------------------;
; 0 : Noir	|   F : Blanc  			||		7 : Gris Clair 	|	8 : Gris Foncé 
; 1 : Bleu  |	9 : Bleu Clair		||		4 : Rouge		|	C : Rouge Clair
; 2 : Vert  |	A : Vert Clair		||		5 : Magenta 	|	D : Magenta Clair
; 3 : Cyan  |	B : Cyan Clair		||		6 : Marron		|	E : Jaune



;----------------------------------------------------------------------------------------------;
;---------------------------------------- 2er Segment ----------------------------------------;

		;-------------------- Registre --------------------;
code segment use16
	assume cs:code, ds:data
	

start:
		;-------------------- Initialisation --------------------;
	mov ax, data
	mov ds, ax
	mov es, ax

		;-------------------- charte graphique --------------------;
	; 320x200 | 16 couleurs | A0000
	mov ax, 0013h
	int 10h
	
		;-------------------- message de bienvenue --------------------;
	; message 1
	mov ax, 1300h
	mov bx, 03h ; cyan
	mov dh, 10 ; ligne
	mov dl, Start_Mes1_Center ; colonne
	mov cx, Start_Mes1_Len
	lea bp, Start_Mes1
	int 10h

	; message 2
	mov ax, 1300h
	mov bx, 04h ; rouge
	mov dh, 11 
	mov dl, Start_Mes2_Center 
	mov cx, Start_Mes2_Len
	lea bp, Start_Mes2
	int 10h

	; message 3
	mov ax, 1300h
	mov bx, 0Fh ; blanc
	mov dh, 13 
	mov dl, Start_Mes3_Center
	mov cx, Start_Mes3_Len
	lea bp, Start_Mes3
	int 10h
	
	; message 4
	mov ax, 1300h
	mov bx, 05h ; magenta
	mov dh, 18
	mov dl, Start_Mes4_Center 
	mov cx, Start_Mes4_Len
	lea bp, Start_Mes4
	int 10h


		;-------------------- appuyer sur une touche --------------------;
	mov ah, 07h
	int 21h


		;-------------------- boucle verif --------------------;
	xor cx, cx
	lea di, models_boats


	process_models:
		cmp BYTE PTR [di], " " ; compare
		je pm_blank ; jump (si égal à " ")
		
		; les 1ers 64 Octets sont réservés à notre navire
		cmp cx, 64 ; compare
		jb pm_our_boat ; jump (si inferieur à 64)
		
		mov BYTE PTR [di], 0Dh ; rouge clair (ennemie)
		jmp pm_inc ; jump (jump)


	pm_our_boat:
		mov BYTE PTR [di], 09h ; bleu clair (notre navire)
		jmp pm_inc ; jump (jump)


	pm_blank:
		mov BYTE PTR [di], 0


	pm_inc:
		inc di
		inc cx
		cmp cx, models_boats_len ; compare
		jb process_models
	

	mov ax, 0A000h
	mov es, ax
	
	; position de notre navire au debut 
	mov our_boat_x, 150
	mov our_boat_y, 150

											;----- MAMAN ------;
	;---------------------------------------- la rande boucle ----------------------------------------;
	main_loop:		
		mov dx, 3DAh

		wait1: 
			in al,dx
			test al,8
			jz wait1 ; jump (si égale à 0)
		wait2:
			in al,dx
			test al,8
			jnz wait2 ; jump (si diférebce à 0)


		; éfacé l'ecran pour la mettre à jour
		clear_scr: ; clear = effacé 
			mov ecx, 32000
			xor eax, eax
			xor di, di
			rep stosd


		draw:	; pour savoir si c'est la fin 
			cmp count_boats, 0 ; compare
			jne draw_non_final ; compare (diférence à 0)
		

		;-------------------- message de fin --------------------;
		draw_final:
			mov ax, data
			mov es, ax
			
			; message 1
			mov ax, 1300h
			mov bx, 0Eh ; jaune 
			mov dh, 11 ; ligne
			mov dl, End_Mes1_Center ; colone
			mov cx, End_Mes1_Len
			lea bp, End_Mes1
			int 10h

			; message 2
			mov ax, 1300h
			mov bx, 0Fh ; blanc
			mov dh, 13 
			mov dl, End_Mes2_Center
			mov cx, End_Mes2_Len
			lea bp, End_Mes2
			int 10h

			; appuie sur une touche 
			mov ah, 07h
			int 21h
			
			jmp exit ; Pour mettre fin à la partie
			

		draw_non_final: ; charger le navire
			lea si, models_boats 
			xor cx, cx
			

		draw_our_boat:
			mov ax, [our_boat_y]	; position de notre navire
			mov di, ax				; duplication de notre position
			shl ax, 8				; multiplie par 256
			shl di, 6				; miltiplie par 64
			add di, ax				; (64 + 256 = 320)y 
			add di, [our_boat_x]	; addition x position
			mov cx, 8				; réintialise cx à 8
			dh_next:	
				movsd				; affiche 4 pixels
				movsd				; affiche les 4 autres pixels de la ligne
				add di,320-8		; pointe sur la ligne suivente
				loop dh_next		; boucle 


		;-------------------- affiche le tir --------------------;
		draw_hit:
			cmp count_hit, 0 ; compare
			je draw_boats ; si pas de tir affiche navire
			
			xor cx, cx
			lea si, hit


			ds_loop:
				push cx
				push si
				
				mov ax, 0C04h
				mov bx, 0h
				mov cx, [si]
				mov dx, [si+2]
				int 10h
				
				; vertical
				mov ax, 0C04h
				inc dx
				int 10h				
				
				; horisontal
				mov ax, 0C04h
				inc cx
				int 10h
				
				mov ax, 0C04h
				dec dx
				int 10h
				
				pop si
				pop cx
				
				inc cx
				add si, 4 
				cmp cx, count_hit
				jb ds_loop
		

		draw_boats:
			xor cx, cx
			lea bx, boats


		draw_boats_loop:
			cmp WORD PTR [bx], 1 ; pour dire si les navires sont mort 
			je ds_loop_inc
			
			push cx
			
			;---------- affiche navire ennemi ----------;
			lea si, models_boats
			
			mov ax, [bx+2]
			shl ax, 6 				; convertisseur (2^6 = 64)
			add si, ax
			mov ax, [bx+6]			; pos en y 
			mov di, ax				; duplique 
			shl ax, 8				; * par 256
			shl di, 6				; * par 64
			add di, ax				; (64 + 256 = 320)y
			add di, [bx+4]			; add x position
			mov cx, 8				; nb de lignes
			dsh_next:				
				movsd				; affiche 4 pixels 
				movsd				;    "    "    "
				add di,320-8		; pointe la ligne suivante
				loop dsh_next		; boucle
			
			; fin de l'affichage
			pop cx

	
		ds_loop_inc:
			add bx, 8
			inc cx
			cmp cx, count_boats ; vérifie qu'il y a tout les navires affichés
			jb draw_boats_loop
			

		;---------- Mise à jour ----------;
		;-----
		cmp count_hit, 0
		je update_boats
			
		lea si, hit
		xor cx, cx


		us_loop:
			dec WORD PTR [si+2]; actualisation de la position du tir
				
			cmp WORD PTR [si+2], 0 ; il est en dehors de la map
			jg us_loop_inc ; si elle est en dehors de la map, on passe au suivant
				
			; on efface le tir
			dec count_hit
			cmp count_hit, 0
			je update_boats ; on efface le dernier tir
			
			lea di, hit
			mov ax, count_hit
			shl ax, 2
			
			add di, ax

			mov ax, [di]
			mov [si], ax
			mov ax, [di+2]
			mov [si+2], ax
				
			; efface l'ancienne valeur 
			mov WORD PTR [di], 0
			mov WORD PTR [di+2], 0
					
			sub si, 4 ; si = si-4
			dec cx ; cx = cx-1
				

		us_loop_inc:
			add si, 4
			inc cx
			cmp cx, count_hit ; si il reste encore des tirs à affichier 
			jb us_loop
		;-----


		update_boats:
			xor cx, cx
			xor ax, ax ; on compte les navires restant
			lea si, boats

		update_boats_loop:
			cmp WORD PTR [si], 1 ; si il est mort 
			je ush_loop_inc		; alors on passe 
			
			inc ax
			
			; on verifie si il n'y a pas de tirs 
			cmp count_hit, 0
			je ush_loop_inc
			
			; verifie que les modèles sont lancés 
			push cx
			push ax
			
			lea di, models_boats
			; trouve le modèle du navire 
			mov ax, [si+2]
			shl ax, 6 ; conversion (2^6 = 64)
			add di, ax
			
			xor cx, cx


			ush_model:
				cmp BYTE PTR [di], 0 ; vérification de collisions 
				je ush_model_inc ; pas de colisions
				
				; calculer le pixel
				mov ax, cx
				mov dx, cx
				shr ax, 3 
				and dx, 7
				
				; on calcul les cordonnées réelles
				add dx, WORD PTR [si+4]
				add ax, WORD PTR [si+6]

				push di
				push si
				push cx
				
				xor cx, cx

				lea di, hit


			;---------- modèle de tir ----------;
				ush_model_hit0:
					mov bx, WORD PTR [di]
					mov si, WORD PTR [di+2]
					
					cmp ax, si
					jne ush_model_hit1
					
					cmp dx, bx
					je ush_model_hit_disable
				

				ush_model_hit1:
					inc bx
					
					cmp ax, si
					jne ush_model_hit2
					
					cmp dx, bx
					je ush_model_hit_disable
				

				ush_model_hit2:
					inc si
					
					cmp ax, si
					jne ush_model_hit3
					
					cmp dx, bx
					je ush_model_hit_disable
					

				ush_model_hit3:
					dec bx
					
					cmp ax, si
					jne ush_model_hit_inc
					
					cmp dx, bx
					je ush_model_hit_disable
					
					jmp ush_model_hit_inc


				ush_model_hit_disable:
					; supprime le tir après contact 
					dec count_hit
					lea si, hit
					mov ax, count_hit
					shl ax, 2 
					
					add si, ax

					mov ax, [si]
					mov [di], ax
					mov ax, [si+2]
					mov [di+2], ax
					
					; changement de valeur
					mov WORD PTR [si], 0
					mov WORD PTR [si+2], 0
					
					; on a fini de vérifier, on peut partir 
					pop cx
					pop si
					pop di
					
					pop cx ; ush_model
					
					mov WORD PTR [si], 1 ; ennemi est tué
					jmp ush_loop_inc
					

				ush_model_hit_inc:
					add di, 4 
					inc cx
					cmp cx, count_hit
					jb ush_model_hit0 ; jb (inférieur)
				
				pop cx
				pop si
				pop di
				

			ush_model_inc:
				inc di
				inc cx
				cmp cx, 64
				jb ush_model
				
			
			; fini de générer les modèles
			pop ax
			pop cx


		ush_loop_inc:
			add si, 8
			inc cx
			cmp cx, count_boats
			jb update_boats_loop
		
			cmp ax, 0 ; on verifie si on a encore des navires vivants 
			jne key_handling

			; nb de navires à 0 (réinisialisation )
			mov count_boats, 0
			

		;----------- key handling code -----------;		
		key_handling:
			; regarde si on appuie sur une touche (pour ne pas être bloqué)
			mov ax, 0100h 
			int 16h
			jz main_loop ; si il n'y a pas de touche 
								
			mov ah, 07h ; regadre si on appuie sur une touche
			int 21h
			
			cmp al, 0
			jne key_left
			
			mov ah, 07h ; regadre si on appuie sur une touche	
			int 21h
			

			; handle keys
			key_left:
				cmp al, 4Bh ; regarde si on appuie sur la touche pour aller à gauche (<=)
				jne key_right
				
				cmp our_boat_x, 0 ; regarde si il est tout à gauche (pour evité les sortie de map)
				je main_loop
				
				dec our_boat_x ; décremente x de 1 pour le faire décaler à gauche
				jmp main_loop ; jump (jump)
				

			key_right:
				cmp al, 4DH ; regarde si on appuie sur la touche pour aller à droite (=>)
				jne key_space
								
				cmp our_boat_x, 312 ; (312+8 = 320) regarde si il est tout à droite (pour eviter les sorties de map)
				je main_loop
				
				inc our_boat_x ; incrémente x de 1 pour le faire décaler à droite
				jmp main_loop ; jump (jump)
			

			; tir
			key_space:
				cmp al, 20H ; regarde si on appuie sur "espace"
				jne key_x
				
				cmp count_hit, 7 ; 7+1 tirs max
				ja key_x
				
				;----- gestion du tir -----;
				lea si, hit ; hit + count_hit*4
				mov ax, count_hit
				mov bx, 4
				mul bx
				add si, ax
				
				mov ax, our_boat_x
				add ax, 3 ; pour centrer tout les tirs (on décale à droite)
				mov [si], ax
				mov ax, our_boat_y
				dec ax ; fait monter le pixel de 1
				mov [si+2], ax
				
				inc count_hit

				jmp main_loop ; jump (jump)
				

			key_x:
				cmp al, 78h ; on regare si on appuie sur x (x fait quitter la partie)
				jne main_loop
			
			jmp exit ; jump (jump)
	

	exit: ; fin de la partie
		mov ax, 0003h
		int 10h
		
		mov ax, 4c00h
		int 21h
code ends

end start