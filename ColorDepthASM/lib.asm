; Topic: Color depth reduction
; Description: Project used to change the color depth in the RGB palette of an image
; Author: Kamil Kotorc
; Date: 17.12.2025
; Academic year: 3
; Academic semester: 5

; Procesor funkcji w MASM do redukcji g��bi kolor�w obrazu
; Ta procedura pobiera ka�dy bajt reprezentuj�cy R, G, B i zmniejsza ich g��bi� kolor�w.
; Parametry:
; - rcx:    adres danych obrazu (tablica bajt�w)
; - rdx:    pocz�tkowy indeks bajtu (pozycja pocz�tkowa)
; - r8:     liczba bajt�w do przetworzenia
; - r9:     rz�d stride (liczba bajt�w w jednym rz�dzie, ��cznie z wype�nieniem)
; - r10:    warto�� redukcji (wielko�� przesuni�cia w celu zmniejszenia g��bi kolor�w)

.code
ColorDepthAsm proc
    
    mov r10d, dword ptr [rsp+40h]   ; Pobranie pi�tego parametru 'reduction' do r10
    mov r11, rdx                ; Zapisanie pocz�tkowego indeksu bajt�w do r11
    xor rdx, rdx                ; Wyzerowanie rejestru rdx (do dzielenia)
    mov rax, r8                 ; Za�aduj liczb� bajt�w do przetworzenia do RAX
    div r9                      ; Dzielenie przez row stride (RAX = liczba wierszy, RDX = reszta)
    mov r12, rax                ; Zapisanie liczby wierszy do r12

ROW:
    dec r12                     ; Dekrementacja licznika wierszy
    cmp r12, 0                  ; Sprawdzenie czy pozosta�y wiersze
    jl ENDING                   ; Je�eli brak wierszy, zako�cz zewn�trzn� p�tl�
    mov r13, r9                 ; Za�aduj row stride do r13 (ilo�� bajt�w w wierszu)
    cmp r10, 0                  ; Sprawdzenie czy redukcja bit�w jest r�wna 0
    jz ENDING                   ; Je�eli tak to nie modyfikujemy bajt�w

BYTES:
    sub r13, 16                 ; Przetwarzanie 16 bajt�w na raz
    cmp r13, 0                  ; Sprawdzenie czy zosta�y bajty w wierszu
    jl SKIP                     ; Je�eli nie, ko�czymy przetwarzanie bie��cego wiersza
    movdqu xmm1, [rcx + r11]    ; Pobranie 16 bajt�w z bie��cego offsetu
    pxor    xmm2, xmm2          ; Zerowanie xmm2 do odpakowania
    movdqa  xmm0, xmm1          ; Kopiujemy oryginalne dane
    punpcklbw xmm0, xmm2        ; Rozpakowanie dolnych 8 bajt�w
    psrldq  xmm1, 8             ; Przesuni�cie o 8 bajt�w (g�rna po�owa)
    punpcklbw xmm1, xmm2        ; Rozpakowanie g�rnych 8 bajt�w
    mov r14, r10                ; Za�aduj redukcje do licznika redukcji r14

RSHIFT:
    psrlw xmm0, 1               ; Przesu� 16-bitowe s�owa w xmm0 o 1 bit w prawo
    psrlw xmm1, 1               ; Przesu� 16-bitowe s�owa w xmm1 o 1 bit w prawo
    dec r10                     ; Dekrementacja licznika redukcji
    cmp r10, 0                  ; Sprawdzenie czy licznik doszed� do zera
    jnz RSHIFT                  ; Je�eli nie, wykonaj kolejn� iteracje p�tli
    mov r14, r10                ; Za�aduj redukcje do licznika redukcji r14

LSHIFT:
    psllw xmm0, 1               ; Przesu� 16-bitowe s�owa w xmm0 o 1 bit w lewo
    psllw xmm1, 1               ; Przesu� 16-bitowe s�owa w xmm1 o 1 bit w lewo
    dec r10                     ; Dekrementacja licznika redukcji
    cmp r10, 0                  ; Sprawdzenie czy licznik doszed� do zera
    jnz RSHIFT                  ; Je�eli nie, wykonaj kolejn� iteracje p�tli
    packuswb xmm0, xmm1         ; Po��czenie obu po��wek
    movdqu [rcx + r11], xmm0    ; Zapis 16 bajt�w z powrotem do obrazu
    add r11, 16                 ; Przej�cie do kolejnego bloku bajt�w
    jmp BYTES                   ; Powr�t do p�tli przetwarzania bie��cego wiersza

SKIP:
    add r11, rdx                ; Dodanie reszty z dzielenia
    jmp ROW                     ; Powr�t do p�tli wierszy

ENDING:
    ret                         ; Zako�czenie procedury

ColorDepthAsm endp
end