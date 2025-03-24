#include <xc.h>

// Configuración del PIC16F887
#pragma config FOSC = INTRC_NOCLKOUT, WDTE = OFF, PWRTE = OFF, BOREN = ON, LVP = OFF, CPD = OFF, WRT = OFF, CP = OFF, MCLRE = ON

#define _XTAL_FREQ 4000000  // Frecuencia del oscilador (4 MHz)

// Pines para los displays de 7 segmentos
#define DISPLAY_UNIDADES PORTC
#define DISPLAY_DECENAS PORTB
#define DISPLAY_CENTENAS PORTA

// Puerto de entrada (4 bits)
#define INPUT_PORT PORTD
#define INPUT_MASK 0x0F

// Tabla de conversión de dígitos a segmentos (cátodo común)
const unsigned char SEGMENTOS[] = {
    0b00111111, // 0
    0b00000110, // 1
    0b01011011, // 2
    0b01001111, // 3
    0b01100110, // 4
    0b01101101, // 5
    0b01111101, // 6
    0b00000111, // 7
    0b01111111, // 8
    0b01101111  // 9
};

void mostrar_numero(unsigned int num) {
    // Separar el número en centenas, decenas y unidades
    unsigned char centenas = num / 100;
    unsigned char decenas = (num % 100) / 10;
    unsigned char unidades = num % 10;

    // Mostrar los dígitos en los displays de 7 segmentos
    DISPLAY_CENTENAS = SEGMENTOS[centenas];
    DISPLAY_DECENAS = SEGMENTOS[decenas];
    DISPLAY_UNIDADES = SEGMENTOS[unidades];
}

void main(void) {
    unsigned int fib[14] = {0, 1}; // Primeros dos números de Fibonacci
    unsigned int i;

    OSCCON = 0b01100000;  // Configurar el oscilador interno a 4 MHz
    TRISA = 0x00;          // Puerto A como salida (Display Centena)
    TRISB = 0x00;          // Puerto B como salida (Display Decenas)
    TRISC = 0x00;          // Puerto C como salida (Display Unidades)
    TRISD = 0x0F;          // RD0, RD1, RD2, RD3 como entradas
    ANSELH = 0x00;         // Deshabilitar funciones analógicas en el puerto B

    // Mostrar y almacenar los primeros dos números de Fibonacci
    for (i = 0; i < 2; i++) {
        mostrar_numero(fib[i]);
        __delay_ms(1000); // Mostrar el número durante 1 segundo
    }

    // Calcular y mostrar el resto de los números de Fibonacci
    for (i = 2; i < 14; i++) {
        fib[i] = fib[i-1] + fib[i-2];  // Calcular el siguiente número
        mostrar_numero(fib[i]);         // Mostrar el número
        __delay_ms(1000);               // Mostrar el número durante 1 segundo
    }

    while (1) {
        unsigned char input_value = INPUT_PORT & INPUT_MASK;

        if (input_value >= 1 && input_value <= 14) {
            mostrar_numero(fib[input_value - 1]);
        } else {
            DISPLAY_CENTENAS = 0x00;
            DISPLAY_DECENAS = 0x00;
            DISPLAY_UNIDADES = 0x00;
        }

        __delay_ms(500);
    }
}
