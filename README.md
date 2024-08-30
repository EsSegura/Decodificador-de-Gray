# Decodificador de Gray

## 1. Abreviaturas y definiciones
- **FPGA**: Field Programmable Gate Arrays

## 2. Referencias
[0] David Harris y Sarah Harris. *Digital Design and Computer Architecture. RISC-V Edition.* Morgan Kaufmann, 2022. ISBN: 978-0-12-820064-3

## 3. Desarrollo

### 3.0 Descripción general del sistema
El sistema implementado consiste en tres módulos en Verilog que interactúan para la conversión y visualización de datos en un display de 7 segmentos. El módulo module_input_deco_gray realiza la conversión de un código Gray de 4 bits a su equivalente binario, sincronizando la entrada mediante un contador de refresco. El módulo module_bin_to_bcd toma este valor binario de 4 bits y lo convierte a un formato BCD de 8 bits, segregando los dígitos en decenas y unidades. Finalmente, el módulo module_7_segments utiliza este valor BCD para controlar un display de 7 segmentos multiplexado, manejando la conmutación entre dígitos y activando los segmentos correspondientes a cada dígito en función del valor BCD recibido, con un control preciso del tiempo de refresco del display. Este flujo garantiza una conversión precisa desde el código Gray hasta la visualización en un display de 7 segmentos de forma decimal.

### 3.1 Módulo 1
#### 3.1.1. Encabezado del módulo
```SystemVerilog
module mi_modulo(
    input logic     entrada_i,      
    output logic    salida_i 
    );
```
#### 3.1.2. Parámetros
- Lista de parámetros

#### 3.1.3. Entradas y salidas:
- `entrada_i`: descripción de la entrada
- `salida_o`: descripción de la salida

#### 3.1.4. Criterios de diseño
Diagramas, texto explicativo...

### 3.2 Módulo 2
#### 3.2.1 Module_7_segments
```SystemVerilog
module module_7_segments # 
(

    parameter DISPLAY_REFRESH = 27000  // Parámetro para definir la tasa de refresco del display
)(

    input clk_i,            // Entrada de reloj
    input rst_i,            // Entrada de reset asíncrono
    input [7 : 0] bcd_i,    // Entrada de 8 bits en formato BCD (4 bits para unidades y 4 bits para decenas)

    output reg [1 : 0] anodo_o,   // Salida para el control de los ánodos de los displays
    output reg [6 : 0] catodo_o   // Salida para el control de los cátodos de los displays
);

    // Calcula el ancho del contador basado en la tasa de refresco
    localparam WIDTH_DISPLAY_COUNTER = $clog2(DISPLAY_REFRESH);
    reg [WIDTH_DISPLAY_COUNTER - 1 : 0] cuenta_salida; // Registro para almacenar el valor del contador de refresco

    reg [3 : 0] digito_o;      // Registro para almacenar el dígito que se va a mostrar en el display

    reg en_conmutador;         // Señal de control para alternar entre decenas y unidades
    reg [1 : 0] decena_unidad; // Registro para seleccionar entre las decenas y las unidades

    // Contador de refresco
    always @ (posedge clk_i or negedge rst_i) begin
        if (!rst_i) begin
            cuenta_salida <= DISPLAY_REFRESH - 1; // Si se activa el reset, inicializa el contador
            en_conmutador <= 0;                   // Desactiva el conmutador
        end else begin
            // Si el contador llega a 0, se reinicia; de lo contrario, se decrementa en 1
            cuenta_salida <= (cuenta_salida == 0) ? (DISPLAY_REFRESH - 1) : (cuenta_salida - 1'b1);
            en_conmutador <= (cuenta_salida == 0); // Activa el conmutador si el contador llega a 0
        end
    end

    // Contador de 1 bit para alternar entre decenas y unidades
    always @ (posedge clk_i) begin
        // Alterna entre decenas y unidades si el conmutador está activo, de lo contrario mantiene su valor
        decena_unidad <= (rst_i) ? ((en_conmutador) ? (decena_unidad + 1'b1) : decena_unidad) : 2'b00;
    end

     // Selección del dígito a mostrar en el display
    always @(decena_unidad) begin

        digito_o = 0;          // Inicializa el valor del dígito
        anodo_o = 2'b11;       // Desactiva ambos displays

        // Selecciona el dígito correspondiente a las unidades o decenas según el valor de decena_unidad
        case(decena_unidad) 
            1'b0 : begin
                anodo_o  = 2'b10;             // Activa el display de las unidades
                digito_o = bcd_i [3 : 0];     // Muestra las unidades en el display
            end

            1'b1 : begin
                anodo_o  = 2'b01;             // Activa el display de las decenas
                digito_o = bcd_i [7 : 4];     // Muestra las decenas en el display
            end

            default: begin
                anodo_o  = 2'b11;             // Desactiva ambos displays en caso de error
                digito_o = 0;                 // Establece el dígito a 0
            end
        endcase
    end

    // Conversión de BCD a segmentos del display de 7 segmentos
    always @(*) begin
        // Asigna cada segmento del display según el valor del dígito actual
        // Cada línea representa un segmento del display (a, b, c, d, e, f, g) que se activa o desactiva según el valor del dígito
        catodo_o[0] = ~(digito_o == 4'd0 || digito_o == 4'd2 || digito_o == 4'd3 || digito_o == 4'd5 || digito_o == 4'd6 || digito_o == 4'd7 || digito_o == 4'd8 || digito_o == 4'd9);
        catodo_o[1] = ~(digito_o == 4'd0 || digito_o == 4'd1 || digito_o == 4'd2 || digito_o == 4'd3 || digito_o == 4'd4 || digito_o == 4'd7 || digito_o == 4'd8 || digito_o == 4'd9);
        catodo_o[2] = ~(digito_o == 4'd0 || digito_o == 4'd1 || digito_o == 4'd3 || digito_o == 4'd4 || digito_o == 4'd5 || digito_o == 4'd6 || digito_o == 4'd7 || digito_o == 4'd8 || digito_o == 4'd9);
        catodo_o[3] = ~(digito_o == 4'd0 || digito_o == 4'd2 || digito_o == 4'd3 || digito_o == 4'd5 || digito_o == 4'd6 || digito_o == 4'd8 || digito_o == 4'd9);
        catodo_o[4] = ~(digito_o == 4'd0 || digito_o == 4'd2 || digito_o == 4'd6 || digito_o == 4'd8);
        catodo_o[5] = ~(digito_o == 4'd0 || digito_o == 4'd4 || digito_o == 4'd5 || digito_o == 4'd6 || digito_o == 4'd8 || digito_o == 4'd9);
        catodo_o[6] = ~(digito_o == 4'd2 || digito_o == 4'd3 || digito_o == 4'd4 || digito_o == 4'd5 || digito_o == 4'd6 || digito_o == 4'd8 || digito_o == 4'd9);
    end
endmodule
```
#### 3.1.2. Parámetros

1.DISPLAY_REFRESH: Define la cantidad de ciclos de reloj para refrescar el display.
2.WIDTH_DISPLAY_COUNTER: Calcula el número de bits necesarios para contar hasta DISPLAY_REFRESH.
3.clk_i: Señal de reloj que sincroniza las operaciones del módulo.
4.rst_i: Señal de reinicio para inicializar los registros.
5.bcd_i [7:0]: Entrada de 8 bits que contiene el valor en BCD a mostrar (dos dígitos).
6.anodo_o [1:0]: Controla qué dígito del display está activo.
7.catodo_o [6:0]: Controla los segmentos del display para representar el dígito en BCD.
8.cuenta_salida: Contador de refresco para el display.
9.digito_o [3:0]: Registro que almacena el dígito actual a mostrar en el display.
10.en_conmutador: Señal que indica cuándo cambiar entre dígitos.
11.decena_unidad [1:0]: Registro que indica si se está mostrando la unidad o la decena.

#### 3.1.3. Entradas y salidas:
# Descripción de la entrada:
- `clk_i `
Descripción: Señal de reloj. Esta señal sincroniza todas las operaciones internas del módulo. Es una señal de tipo input, normalmente conectada al reloj del sistema. Su frecuencia determina la velocidad de actualización del display de 7 segmentos.
- `rst_i`
Descripción: Señal de reinicio. Se utiliza para restablecer el módulo a su estado inicial. Cuando rst_i es bajo (0), se reinician los registros internos, y el display muestra un estado predeterminado. Es una señal de tipo input y se activa de manera asíncrona, es decir, no depende del reloj.
- `bcd_i [7:0]`
Descripción: Entrada de 8 bits que contiene el valor en BCD (Binary-Coded Decimal) para el display. Los 4 bits menos significativos (bcd_i[3:0]) representan el dígito de las unidades y los 4 bits más significativos (bcd_i[7:4]) representan el dígito de las decenas. Esta entrada determina qué números se mostrarán en los dos dígitos del display de 7 segmentos.

#### 3.1.4. Criterios de diseño
Diagramas, texto explicativo...

### 3.3 Módulo 3
#### 3.3.1. Encabezado del módulo
```SystemVerilog
module mi_modulo(
    input logic     entrada_i,      
    output logic    salida_i 
    );
```
#### 3.3.2. Parámetros
- Lista de parámetros

#### 3.3.3. Entradas y salidas:
- `entrada_i`: descripción de la entrada
- `salida_o`: descripción de la salida

#### 3.3.4. Criterios de diseño
Diagramas, texto explicativo...

### 4. Testbench
Descripción y resultados de las pruebas hechas

### Otros modulos
- agregar informacion siguiendo el ejemplo anterior.


## 5. Consumo de recursos

## 6. Problemas encontrados durante el proyecto

## Apendices:
### Apendice 1:
texto, imágen, etc

