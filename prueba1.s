PROCESSOR 16F887    

;*** CONFIG1 - Primera palabra de configuraci�n ***  
    CONFIG  FOSC = INTRC_NOCLKOUT      ; Oscilador Interno.  
    CONFIG  WDTE = OFF                 ; Watchdog Timer deshabilitado.  
    CONFIG  PWRTE = ON                 ; Power-up Timer habilitado.  
    CONFIG  MCLRE = ON                 ; Pin de MCLR activo.  
    CONFIG  CP = OFF                   ; Protecci�n de la memoria de programaci�n OFF.  
    CONFIG  CPD = OFF                  ; Protecci�n de la memoria de datos OFF.  
    CONFIG  BOREN = ON                 ; Brown Out Reset habilitado.  
    CONFIG  IESO = OFF                 ; Bit de Switchover deshabilitado.  
    CONFIG  FCMEN = OFF                ; Monitoreo del reloj deshabilitado.  
    CONFIG  LVP = OFF                  ; Programaci�n en Bajo Voltaje deshabilitado  

;*** CONFIG2 - Segunda palabra de configuraci�n ***  
    CONFIG  BOR4V = BOR40V             ; Brown-out Reset activo en 4 volts.  
    CONFIG  WRT = OFF                  ; Protecci�n de escritura de memoria Flash.  

#include <xc.inc>

    ; Definici�n de las variables
    fib     equ  0x20    ; Direcci�n de memoria para almacenar los valores de Fibonacci
    tmp1    equ  0x21    ; Variable temporal para F(n-2)
    tmp2    equ  0x22    ; Variable temporal para F(n-1)
    count   equ  0x23    ; Contador para la cantidad de t�rminos restantes

    ; Vectores de reset y de inicio de programa
    org 0
    goto Start          ; Salta a la etiqueta Start donde comienza el programa
    
Start: 
    ; Configuraci�n de registros
    bsf STATUS, 5       ; Cambia al banco 1
    movlw 0x00          ; Configura PORTA, PORTB y PORTC como salidas
    movwf TRISA         ; Configura PORTA como salida
    movwf TRISB         ; Configura PORTB como salida
    movwf TRISC         ; Configura PORTC como salida
    movlw 0x0F          ; Configura los primeros 4 bits de PORTD como entradas
    movwf TRISD         ; Configura PORTD como entrada

    ; Deshabilitar funciones anal�gicas (todos los pines como digitales)
    movlw 0x00          ; W = 0x00 (todos los pines como digitales)
    movwf ANSEL         ; Configura ANSEL (puerto A como digital)
    movwf ANSELH        ; Configura ANSELH (puerto B y otros como digitales)
    bcf STATUS, 5       ; Regreso al banco 0

    ; Configuraci�n del oscilador interno a 4 MHz
    movlw 0x68          ; Configura el oscilador interno a 4 MHz (IRCF = 110)
    movwf OSCCON

    ; Limpiar los puertos antes de usarlos
    clrf PORTA          ; Limpia PORTA
    clrf PORTB          ; Limpia PORTB
    clrf PORTC          ; Limpia PORTC

    ; Encender LED de prueba en RA0
    bsf PORTA, 0        ; Enciende el LED en RA0

    ; Inicializaci�n de la secuencia de Fibonacci
    movlw 0x00          ; F_0 = 0
    movwf tmp1          ; Almacena F_0 en tmp1 (F(n-2))
    movlw 0x01          ; F_1 = 1
    movwf tmp2          ; Almacena F_1 en tmp2 (F(n-1))

    ; Inicializa el contador
    movlw 12            ; 12 t�rminos restantes por generar
    movwf count         ; Guarda el valor del contador

    ; Ciclo principal para calcular la secuencia de Fibonacci
FibLoop:
    movf tmp1, W        ; W = F(n-2)
    addwf tmp2, W       ; W = F(n-1) + F(n-2)
    movwf fib           ; Almacena el resultado en la direcci�n de memoria "fib"

    ; Actualiza F(n-2) y F(n-1) para el siguiente c�lculo
    movf tmp2, W        ; W = F(n-1)
    movwf tmp1          ; tmp1 = F(n-1)
    movf fib, W         ; W = F(n)
    movwf tmp2          ; tmp2 = F(n)

    ; Mostrar el n�mero en los displays de 7 segmentos
    call mostrar_numero

    ; Retardo para visualizar el n�mero
    call delay_1s

    decfsz count, f     ; Decrementa el contador y verifica si es 0
    goto FibLoop        ; Si no es 0, contin�a el ciclo

    ; Ciclo infinito para leer el valor de entrada y mostrar el n�mero correspondiente
MainLoop:
    goto MainLoop       ; Repite el ciclo

mostrar_numero:
    ; Muestra el valor de Fibonacci en los puertos
    movf fib, W         ; W = fib
    movwf PORTB         ; Muestra el valor en PORTB (puedes cambiarlo a PORTC si es necesario)
    return              ; Retorna

delay_1s:
    ; Retardo de aproximadamente 1 segundo (ajustar seg�n la frecuencia del oscilador)
    movlw 0xFF
    movwf 0x30
delay_outer:
    movlw 0xFF
    movwf 0x31
delay_inner:
    decfsz 0x31, F
    goto delay_inner
    decfsz 0x30, F
    goto delay_outer
    return

    ; Fin del programa
    end