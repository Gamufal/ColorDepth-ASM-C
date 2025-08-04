; Topic: Color depth reduction
; Description: Project used to change the color depth in the RGB palette of an image
; Author: Kamil Kotorc
; Date: 17.12.2025
; Academic year: 3
; Academic semester: 5

; Procesor funkcji w MASM do redukcji g³êbi kolorów obrazu
; Ta procedura pobiera ka¿dy bajt reprezentuj¹cy R, G, B i zmniejsza ich g³êbiê kolorów.
; Parametry:
; - rcx:    adres danych obrazu (tablica bajtów)
; - rdx:    pocz¹tkowy indeks bajtu (pozycja pocz¹tkowa)
; - r8:     liczba bajtów do przetworzenia
; - r9:     rz¹d stride (liczba bajtów w jednym rzêdzie, ³¹cznie z wype³nieniem)
; - r10:    wartoœæ redukcji (wielkoœæ przesuniêcia w celu zmniejszenia g³êbi kolorów)

.code
ColorDepthAsm proc
    
    mov r10d, dword ptr [rsp+40h]   ; Pobranie pi¹tego parametru 'reduction' do r10
    mov r11, rdx                ; Zapisanie pocz¹tkowego indeksu bajtów do r11
    xor rdx, rdx                ; Wyzerowanie rejestru rdx (do dzielenia)
    mov rax, r8                 ; Za³aduj liczbê bajtów do przetworzenia do RAX
    div r9                      ; Dzielenie przez row stride (RAX = liczba wierszy, RDX = reszta)
    mov r12, rax                ; Zapisanie liczby wierszy do r12

ROW:
    dec r12                     ; Dekrementacja licznika wierszy
    cmp r12, 0                  ; Sprawdzenie czy pozosta³y wiersze
    jl ENDING                   ; Je¿eli brak wierszy, zakoñcz zewnêtrzn¹ pêtlê
    mov r13, r9                 ; Za³aduj row stride do r13 (iloœæ bajtów w wierszu)
    cmp r10, 0                  ; Sprawdzenie czy redukcja bitów jest równa 0
    jz ENDING                   ; Je¿eli tak to nie modyfikujemy bajtów

BYTES:
    sub r13, 16                 ; Przetwarzanie 16 bajtów na raz
    cmp r13, 0                  ; Sprawdzenie czy zosta³y bajty w wierszu
    jl SKIP                     ; Je¿eli nie, koñczymy przetwarzanie bie¿¹cego wiersza
    movdqu xmm1, [rcx + r11]    ; Pobranie 16 bajtów z bie¿¹cego offsetu
    pxor    xmm2, xmm2          ; Zerowanie xmm2 do odpakowania
    movdqa  xmm0, xmm1          ; Kopiujemy oryginalne dane
    punpcklbw xmm0, xmm2        ; Rozpakowanie dolnych 8 bajtów
    psrldq  xmm1, 8             ; Przesuniêcie o 8 bajtów (górna po³owa)
    punpcklbw xmm1, xmm2        ; Rozpakowanie górnych 8 bajtów
    mov r14, r10                ; Za³aduj redukcje do licznika redukcji r14

RSHIFT:
    psrlw xmm0, 1               ; Przesuñ 16-bitowe s³owa w xmm0 o 1 bit w prawo
    psrlw xmm1, 1               ; Przesuñ 16-bitowe s³owa w xmm1 o 1 bit w prawo
    dec r10                     ; Dekrementacja licznika redukcji
    cmp r10, 0                  ; Sprawdzenie czy licznik doszed³ do zera
    jnz RSHIFT                  ; Je¿eli nie, wykonaj kolejn¹ iteracje pêtli
    mov r14, r10                ; Za³aduj redukcje do licznika redukcji r14

LSHIFT:
    psllw xmm0, 1               ; Przesuñ 16-bitowe s³owa w xmm0 o 1 bit w lewo
    psllw xmm1, 1               ; Przesuñ 16-bitowe s³owa w xmm1 o 1 bit w lewo
    dec r10                     ; Dekrementacja licznika redukcji
    cmp r10, 0                  ; Sprawdzenie czy licznik doszed³ do zera
    jnz RSHIFT                  ; Je¿eli nie, wykonaj kolejn¹ iteracje pêtli
    packuswb xmm0, xmm1         ; Po³¹czenie obu po³ówek
    movdqu [rcx + r11], xmm0    ; Zapis 16 bajtów z powrotem do obrazu
    add r11, 16                 ; Przejœcie do kolejnego bloku bajtów
    jmp BYTES                   ; Powrót do pêtli przetwarzania bie¿¹cego wiersza

SKIP:
    add r11, rdx                ; Dodanie reszty z dzielenia
    jmp ROW                     ; Powrót do pêtli wierszy

ENDING:
    ret                         ; Zakoñczenie procedury

ColorDepthAsm endp
end