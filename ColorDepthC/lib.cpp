/*
 * Topic: Color depth reduction
 * Description: Project used to change the color depth in the RGB palette of an image
 * Author: Kamil Kotorc
 * Date: 17.12.2025
 * Academic year: 3
 * Academic semester: 5
 *
*/

#include <windows.h>

// Definiujemy metodę eksportowaną dla bibliotek DLL w Windows
#define exported_method extern "C" __declspec(dllexport)

// Funkcja redukująca głębię kolorów w tablicy bajtów reprezentującej obraz
// Parametry wejściowe:
//	- byteArray:	tablica bajtów reprezentująca obraz w formacie RGB.
//	- byteStart:	początkowy indeks w tablicy, od którego zaczyna się przetwarzanie.
//	- byteCount:	liczba bajtów do przetworzenia.
//	- stride:		liczba bajtów w jednym wierszu obrazu.
//	- reduction:	liczba bitów do redukcji głębi kolorów.
exported_method
void ColorDepthCpp(char* byteArray, int byteStart, int byteCount, int stride, int reduction){

	// Obliczenie liczby wierszy w obrazie
	int rows = byteCount / stride;
	// Obliczenie reszty bajtów w każdym wierszu
	int rest = stride % 3;
	// Iteracja przez wiersze obrazu
	for(int i = 0; i < rows; i++)
	{
		// Iteracja przez każdy piksel w wierszu
		for(int j = 0; j < stride - rest; j += 3, byteStart += 3)
		{
			// Modyfikacja wartości składowych RGB w celu zmniejszenia głębi kolorów
			byteArray[byteStart] = (byteArray[byteStart] >> reduction) << reduction;
			byteArray[byteStart + 1] = (byteArray[byteStart + 1] >> reduction) << reduction;
			byteArray[byteStart + 2] = (byteArray[byteStart + 2] >> reduction) << reduction;
		}
		// Przejście do następnego wiersza, uwzględniając resztę bajtów
		byteStart += rest;
	}
}