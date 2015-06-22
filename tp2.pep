; Travail pratique 2 : Code correcteur
; programme de codage et de décodage de chaîne de caractères
; Mathieu Pronovost
; PROM18118300
; 28 septembre 2012
         LDA     -1,i        
         STA     nbRow,d     ; nbRow = -1
         LDA     0,i         
         CHARI   lettre,d    ; lettre = readChar()
         LDBYTEA lettre,d    ; if (entree == 'd') {
         CPA     'd',i       ;   decodage()
         BREQ    decodage    ; } else if (entree == 'c') {
         CPA     'c',i       ;   codage()
         BREQ    codage      ; } else {
         STRO    errMsg,d    ;   print(errMsg)
         STOP                ;   stop
                             ; }

; transforme entree en code binaire et le met dans le tableau code
codage:  CHARI   lettre,d    ; enlève le '\n' avant le mot
         CHARI   lettre,d    
         LDBYTEA lettre,d    
         STA     entree,d    ; entree = (int)readChar()
         LDA     3,i         
         STA     pos,d       ; pos = 3
loopDo1: BR      pairTest    ; do {
backCod1:LDA     erreur,d    ;   do {
         CPA     0,i         ;     pairTest(entree)
         BRNE    errPas0     ;     if (erreur == 0) { // si la valeur est pair
         LDX     incr,d      
         LDA     0,i         
         STA     tableau,x   ;       tableau[incr] = 0
         BR      etait0      
errPas0: LDX     incr,d      ;     } else {
         LDA     1,i         
         STA     tableau,x   ;       tableau[incr] = 1
etait0:  LDA     entree,d    ;     }
         ASRA                
         STA     entree,d    ;     entree = entree / 2
         LDA     0,i         
         STA     erreur,d    ;     erreur = 0
         LDA     incr,d      
         ADDA    2,i         
         STA     incr,d      ;     incr += 2
         LDA     colonne,d   
         ADDA    1,i         
         STA     colonne,d   ;     colonne++
         LDA     colonne,d   
         CPA     8,i         
         BRLT    loopDo1     ;   } while (colonne < 8)
         LDA     nbRow,d     
         ADDA    1,i         
         STA     nbRow,d     
         LDA     0,i         
         STA     colonne,d   ;   colonne = 0
         CHARI   lettre,d    
         LDBYTEA lettre,d    
         STA     entree,d    ;   entree = (int)readChar()
         LDA     entree,d    
         CPA     '\n',i      
         BRNE    loopDo1     ; } while (entree != '\n')

; affiche le code et la parité de chaque ligne
         LDA     14,i        
         STA     incr,d      ; incr = 14
         LDA     4,i         
         STA     pos,d       ; pos = 4
affiche1:LDX     incr,d      ; do {
         DECO    tableau,x   ;   do {
         LDA     addition,d  ;     print(tableau[incr])
         ADDA    tableau,x   
         STA     addition,d  ;     addition = addition + tableau[incr]
         LDA     incr,d      
         SUBA    2,i         
         STA     incr,d      ;     incr -= 2
         LDA     colonne,d   
         ADDA    1,i         
         STA     colonne,d   ;     colonne++
         LDA     colonne,d   
         CPA     8,i         
         BRLT    affiche1    ;   } while (colonne < 8)
         BR      pairTest    ;   pairTest(addition)
backCod2:DECO    erreur,d    ;   print(erreur)
         LDA     0,i         
         STA     addition,d  ;   addition = 0
         STA     colonne,d   ;   colonne = 0
         STA     erreur,d    ;   erreur = 0
         LDA     incr,d      
         ADDA    32,i        
         STA     incr,d      ;   incr += 32
         LDA     ligne,d     
         ADDA    1,i         
         STA     ligne,d     ;   ligne++
         CHARO   '\n',i      ;   print('\n')
         LDA     ligne,d     
         CPA     nbRow,d     
         BRLE    affiche1    ; } while (ligne <= nbRow)

; affiche la parité de chaque colonne
         LDA     14,i        
         STA     incr,d      ; incr = 14
         STA     colonne,d   ; colonne = 14
         LDA     5,i         
         STA     pos,d       ; pos = 5
         LDA     0,i         
         STA     ligne,d     ; ligne = 0
         STA     addition,d  ; addition = 0
         STA     erreur,d    ; erreur = 0
affDo1:  LDX     incr,d      ; do {
         LDA     addition,d  ;   do {
         ADDA    tableau,x   
         STA     addition,d  ;     addition = addition + tableau[incr]
         LDA     incr,d      
         ADDA    16,i        
         STA     incr,d      ;     incr += 16
         LDA     ligne,d     
         ADDA    1,i         
         STA     ligne,d     ;     ligne++
         LDA     ligne,d     
         CPA     nbRow,d     
         BRLE    affDo1      ;   } while (ligne <= nbRow)
         BR      pairTest    ;   pairTest(addition)
backCod3:DECO    erreur,d    ;   print(erreur)
         LDA     dernier,d   
         ADDA    erreur,d    
         STA     dernier,d   ;   dernier = dernier + erreur
         LDA     colonne,d   
         SUBA    2,i         
         STA     colonne,d   ;   colonne -= 2
         STA     incr,d      ;   incr = colonne
         LDA     0,i         
         STA     addition,d  ;   addition = 0
         STA     ligne,d     ;   ligne = 0
         STA     erreur,d    ;   erreur = 0
         LDA     colonne,d   
         CPA     0,i         
         BRGE    affDo1      ; } while (colonne >= 0)
         LDA     6,i         
         STA     pos,d       ; pos = 6
         BR      pairTest    ; pairTest(dernier)
backCod4:DECO    erreur,d    ; print(erreur)
         STOP       

         
;décodage
decodage:CHARI   lettre,d    ; enlève le '\n' avant le code

; lecture de l'entrée à décoder
debutLir:CHARI   entree,d    ; do {
         LDBYTEA entree,d    ;   entree = readChar()
         CPA     '\n',i      
         BRNE    est01       ;   if (entree == '\n') {
         LDA     nbRow,d     
         ADDA    1,i         
         STA     nbRow,d     ;     nbRow++
         LDA     nb0x0A,d    
         ADDA    1,i         
         STA     nb0x0A,d    ;     nb0x0A++
         BR      finLire     
est01:   LDBYTEA entree,d    ;   } else {
         CPA     '1',i       
         BRNE    est0        ;     if (entree == '1') {
         LDX     incr,d      
         LDA     1,i         
         STA     tableau,x   ;       tableau[incr] = 1
         BR      incremen    
est0:    LDX     incr,d      ;     } else {
         LDA     0,i         
         STA     tableau,x   ;       tableau[incr] = 0
incremen:LDA     incr,d      ;     }
         ADDA    2,i         
         STA     incr,d      ;     incr += 2
         LDA     0,i         
         STA     nb0x0A,d    ;     nb0x0A = 0
finLire: LDA     nb0x0A,d    ;   }
         CPA     2,i         
         BRLT    debutLir    ; } while (nb0x0A < 2)

; met dans somLigne la somme des 1 de chaque lignes
         LDA     0,i         
         STA     incr,d      ; incr = 0
debutSom:LDX     chiffre,d   ; do {
         LDA     addition,d  
         ADDA    tableau,x   
         STA     addition,d  ;   addition = addition + tableau[chiffre]
         LDA     incr,d      
         CPA     16,i        
         BRLT    pas16       ;   if (incr == 16) {
         LDX     position,d  
         LDA     addition,d  
         STA     somLigne,x  ;     somLigne[position] = addition
         LDA     0,i         
         STA     addition,d  ;     addition = 0
         LDA     ligne,d     
         ADDA    1,i         
         STA     ligne,d     ;     ligne++
         LDA     -2,i        
         STA     incr,d      ;     incr = -2
         LDA     position,d  
         ADDA    2,i         
         STA     position,d  ;     position +=2
pas16:   LDA     incr,d      ;   }
         ADDA    2,i         
         STA     incr,d      ;   incr += 2
         LDA     chiffre,d   
         ADDA    2,i         
         STA     chiffre,d   ;   chiffre += 2
         LDA     ligne,d     
         CPA     nbRow,d     
         BRLT    debutSom    ; } while (ligne < nbRow)

; boucles for qui met dans somCol la somme des 1 de chaque colonne
         LDA     0,i         
         STA     incr,d      ; incr = 0
         STA     addition,d  ; addition = 0
         STA     chiffre,d   ; chiffre = 0
debutCol:LDX     chiffre,d   ; do {
         LDA     addition,d  
         ADDA    tableau,x   
         STA     addition,d  ;   addition = addition + tableau[chiffre]
         LDA     incr,d      
         CPA     nbRow,d     
         BRNE    pasNbRow    ;   if (incr == nbRow) {
         LDX     colonne,d   
         LDA     addition,d  
         STA     somCol,x    ;     somCol[colonne] = addition
         LDA     colonne,d   
         ADDA    2,i         
         STA     colonne,d   ;     colonne += 2
         SUBA    18,i        
         STA     chiffre,d   ;     chiffre = colonne -18
         LDA     -1,i        
         STA     incr,d      ;     incr = -1
         LDA     0,i         
         STA     addition,d  ;     addition = 0
pasNbRow:LDA     incr,d      ;   }
         ADDA    1,i         
         STA     incr,d      ;   incr +=1
         LDA     chiffre,d   
         ADDA    18,i        
         STA     chiffre,d   ;   chiffre += 18
         LDA     colonne,d   
         CPA     16,i        
         BRLE    debutCol    ; } while (colonne <= 16)

; vérifie et corrige les erreurs ou
; affiche un message d'erreur si le code ne peut être corrigé
         LDA     0,i         
         STA     incr,d      ; incr = 0
         STA     chiffre,d   ; chiffre = 0
         STA     ligne,d     ; ligne = 0
         STA     colonne,d   ; colonne = 0
                             ; do {
         LDA     1,i         
         STA     pos,d       
boucRow: BR      pairTest    ;   erreur = pairTest(somLigne[incr])
backRow: LDA     erreur,d    
         CPA     1,i         
         BRNE    errPas1     ;   if (erreur == 1) {
         LDA     2,i         ;     pos = 1
         STA     pos,d       ;     do {
boucCol: BR      pairTest    ;       erreur = pairTest(somCol[colonne])
backCol: LDA     erreur,d    
         CPA     2,i         
         BRNE    errPas2     ;       if (erreur == 2) {
loopMult:LDA     errPos,d    
         ADDA    ligne,d     
         STA     errPos,d    
         LDA     multiple,d  
         ADDA    1,i         
         STA     multiple,d  
         CPA     18,i        
         BRLT    loopMult    
         LDA     errPos,d    
         ADDA    colonne,d   
         STA     errPos,d    ;         errPos = ligne * 18 + colonne
errPas2: LDA     erreur,d    ;       }
         CPA     3,i         
         BRLT    errPas3     ;       if (erreur >= 3) {
         STRO    ereurMsg,d  ;         print("Erreur, message corrompu.")
         STOP                ;         stop()
errPas3: LDA     colonne,d   ;       }
         ADDA    2,i         
         STA     colonne,d   ;       colonne += 2
         LDA     colonne,d   
         CPA     16,i        
         BRLE    boucCol     ;     } while (colonne <= 16)
errPas1: LDA     incr,d      ;   }
         ADDA    2,i         
         STA     incr,d      ;   incr +=2
         LDA     ligne,d     
         ADDA    1,i         
         STA     ligne,d     ;   ligne++
         LDA     ligne,d     
         CPA     nbRow,d     
         BRLT    boucRow     ; } while (ligne < nbRow)
         LDA     erreur,d    
         CPA     2,i         
         BRNE    continue    ; if (erreur = 2) {
         LDX     errPos,d    
         LDA     tableau,x   
         CPA     0,i         
         BRNE    pasUn0      ;   if (tableau[errPos] == 0) {
         LDA     1,i         ;     tableau[errPos] = 1
         STA     tableau,x   ;   } else {
         BR      continue    ;     tableau[errPos] = 0
pasUn0:  LDA     0,i         ;   }
         STA     tableau,x   ; }

; lit le code binaire et le transforme en caractères
continue:LDA     0,i         
         STA     ligne,d     ; ligne = 0
         STA     position,d  ; position = 0
         LDA     14,i        
         STA     incr,d      ; incr = 14
         LDA     nbRow,d     
         SUBA    1,i         
         STA     nbRow,d     ; nbRow -= 1
transDo1:LDA     0,i         ; do {
         STA     exposant,d  ;   exposant = 0
         STA     sommeExp,d  ;   sommeExp = 0
         LDA     7,i         
         STA     position,d  ;   position = 7
transDo2:LDA     position,d  ;   do {
         CPA     7,i         
         BRNE    pas7        ;     if (position == 7) {
         LDX     incr,d      
         LDA     tableau,x   
         CPA     1,i         
         BRNE    pas7        ;       if (tableau[incr] = 1) {
         LDA     1,i         
         STA     sommeExp,d  ;         sommeExp = 1
         BR      mettre1     
pas7:    LDA     position,d  ;       }
         CPA     7,i         ;     }
         BRGE    est7        ;     if (position < 7) {
         LDX     incr,d      
         LDA     tableau,x   
         CPA     1,i         
         BRNE    est7        ;       if (tableau[incr] = 1) {
         LDA     exposant,d  
         STA     exp,d       ;       exp = exposant -2
         LDA     exp,d       
         CPA     0,i         
         BRLE    est7        ;       if (exp > 0) {
         LDA     2,i         
         STA     sommeExp,d  ;         sommeExp = 2
transdo3:LDA     sommeExp,d  ;         do {
         ASLA                
         STA     sommeExp,d  ;           sommeExp = sommeExp * 2
         LDA     exp,d       
         SUBA    1,i         
         STA     exp,d       ;           exp--
         LDA     exp,d       
         CPA     0,i         
         BRGT    transdo3    ;         } while (exp >= 0)
est7:    LDA     sommeExp,d  ;       }
         ASRA                ;     }
         STA     sommeExp,d  ;     sommeExp = sommeExp / 2
mettre1: LDBYTEA valCode,d   
         ADDA    sommeExp,d  
         STBYTEA valCode,d   ;     valCode = valCode + sommeExp
         LDA     0,i         
         STA     sommeExp,d  ;     sommeExp = 0
         LDA     exposant,d  
         ADDA    1,i         
         STA     exposant,d  ;     exposant++
         LDA     position,d  
         SUBA    1,i         
         STA     position,d  ;     position -= 1
         LDA     incr,d      
         SUBA    2,i         
         STA     incr,d      ;     incr -= 2
         LDA     position,d  
         CPA     0,i         
         BRGE    transDo2    ;   } while (position >=0)
         CHARO   valCode,d   ;   printChar(valCode)
         LDA     0,i         
         STA     valCode,d   ;   valCode = 0
         LDA     incr,d      
         ADDA    34,i        
         STA     incr,d      ;   incr += 32
         LDA     ligne,d     
         ADDA    1,i         
         STA     ligne,d     ;   ligne++
         LDA     ligne,d     
         CPA     nbRow,d     
         BRLT    transDo1    ; } while (ligne < nbRow)
         STOP        
        
; pairTest
; vérifie si un nombre est pair ou impair
pairTest:LDA     pos,d       
         CPA     1,i         
         BRNE    else2       ; if (pos == 1) {
         LDX     incr,d      
         LDA     somLigne,x  
         STA     nb1,d       ;   nb1 = somLigne[incr]
         BR      testPair    
else2:   LDA     pos,d       ; } else if (pos == 2) {
         CPA     2,i         
         BRNE    else3       
         LDX     colonne,d   
         LDA     somCol,x    
         STA     nb1,d       ;   nb1 = somCol[colonne]
         BR      testPair    
else3:   LDA     pos,d       
         CPA     3,i         
         BRNE    else4       ; } else if (pos == 3) {
         LDA     entree,d    
         STA     nb1,d       ;   nb1 = entree
         BR      testPair    
else4:   LDA     pos,d       
         CPA     4,i         
         BRNE    else5       ; } else if (pos == 4) {
         LDA     addition,d  
         STA     nb1,d       ;   nb1 = addition
         BR      testPair    
else5:   LDA     pos,d       
         CPA     5,i         
         BRNE    else6       
         LDA     addition,d  
         STA     nb1,d       ;   nb1 = addition
         BR      testPair    ; } else {
else6:   LDA     dernier,d   ;   nb1 = dernier
         STA     nb1,d       ; }
testPair:LDA     0,i         ; }
         STA     nb2,d       ; nb2 = 0
loopTest:LDA     nb2,d       ; do {
         ADDA    1,i         
         STA     nb2,d       ;   nb2++
         LDA     nb1,d       
         CPA     nb2,d       
         BRNE    pasEq       ;   if (nb1 == nb2) {
         LDA     erreur,d    
         ADDA    1,i         
         STA     erreur,d    ;     erreur += 1
pasEq:   LDA     nb2,d       ;   }
         ADDA    1,i         
         STA     nb2,d       ;   nb2++
         LDA     nb1,d       
         CPA     nb2,d       
         BRGE    loopTest    ; } while (nb1 >= nb2)
         LDA     pos,d       
         CPA     1,i         ; if (pos = 1) {
         BREQ    backRow     ;   go(backRow)
         CPA     2,i         ; } else if (pos = 2) {
         BREQ    backCol     ;   go(backCol)
         CPA     3,i         ; } else if (pos = 3) {
         BREQ    backCod1    ;   go(backCod1)
         CPA     4,i         ; } else if (pos = 4) {
         BREQ    backCod2    ;   go(backCod2)
         CPA     5,i         ; } else if (pos = 5) {
         BREQ    backCod3    ;   go(backCod3)
         CPA     6,i         ; } else if (pos = 6) {
         BREQ    backCod4    ;   go(backCod4)
         STOP                ; }

lettre:  .BLOCK  2           ; lettre entrée ('c' ou 'd')
tableau: .BLOCK  500         ; tableau contenant le code du mot
entree:  .BLOCK  2           ; valeur entrée
nb0x0A:  .BLOCK  2           ; compte le nombre de '\n' de suite
incr:    .BLOCK  4           ; valeur incrémentée qui permet de naviguer dans tableau
nbRow:   .BLOCK  2           ; nombre de lignes à décoder
addition:.BLOCK  2           ; sert à compter la somme des 1 par ligne
chiffre: .BLOCK  4           ; position présente dans tableau
somLigne:.BLOCK  26          ; tableau contenant la somme des 1 de chaque ligne
position:.BLOCK  2           ; position à traiter
ligne:   .BLOCK  2           ; permet de savoir à quelle ligne on est rendu
somCol:  .BLOCK  26          ; tableau contenant la somme des 1 de chaque colonne
colonne: .BLOCK  2           ; position dans le tableau somCol
erreur:  .BLOCK  2           ; contient le nombre d'erreur de code
pos:     .BLOCK  2           ; permet de savoir où aller après l'exécution de pairTest
errPos:  .BLOCK  2           ; position de l'erreur à corriger
nb1:     .BLOCK  2           ; nombre à vérifier s'il est pair ou impair
nb2:     .BLOCK  2           ; nombre à comparer avec nb1
multiple:.BLOCK  2           ; sert à faire des multiplications
errMsg:  .ASCII  "Erreur, entrée invalide.\x00"
ereurMsg:.ASCII  "Erreur, message corrompu.\x00"
exposant:.BLOCK  2           ; valeur de l'exposant
sommeExp:.BLOCK  2           ; valeur accumulée de l'exposant
exp:     .BLOCK  2           ; valeur utulisée pour calculer sommeExp
valCode: .BLOCK  1           ; valeur du caractère décodé
dernier: .BLOCK  2           ; sert à calculer le dernier chiffre de code
         .END                  