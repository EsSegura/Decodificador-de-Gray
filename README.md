# Decodificador de Gray

## 1. Abreviaturas y definiciones
- **FPGA**: Field Programmable Gate Arrays

## 2. Referencias
[0] David Harris y Sarah Harris. *Digital Design and Computer Architecture. RISC-V Edition.* Morgan Kaufmann, 2022. ISBN: 978-0-12-820064-3

## 3. Desarrollo

### 3.0 Descripción general del sistema
El sistema implementado consiste en tres módulos en Verilog que interactúan para la conversión y visualización de datos en un display de 7 segmentos. El módulo module_input_deco_gray realiza la conversión de un código Gray de 4 bits a su equivalente binario, sincronizando la entrada mediante un contador de refresco. El módulo module_bin_to_bcd toma este valor binario de 4 bits y lo convierte a un formato BCD de 8 bits, segregando los dígitos en decenas y unidades. Finalmente, el módulo module_7_segments utiliza este valor BCD para controlar un display de 7 segmentos multiplexado, manejando la conmutación entre dígitos y activando los segmentos correspondientes a cada dígito en función del valor BCD recibido, con un control preciso del tiempo de refresco del display. Este flujo garantiza una conversión precisa desde el código Gray hasta la visualización en un display de 7 segmentos de forma decimal.

### 3.1 Módulo 1
#### 3.1.1. module_input_deco_gray
```SystemVerilog
module module_input_deco_gray # (
    parameter WIDTH = 4,                // Ancho del código Gray y del código binario
    parameter INPUT_REFRESH = 2700000   // Frecuencia de actualización para el contador
)(
    input                  clk_i,        // Señal de reloj
    input                  rst_i,        // Señal de reinicio asíncrono
    input [WIDTH - 1 : 0]  codigo_gray_i, // Entrada de código Gray

    output reg [WIDTH - 1 : 0] codigo_bin_o // Salida de código binario
);

    // Parámetros
    localparam WIDTH_INPUT_COUNTER = $clog2(INPUT_REFRESH); // Tamaño del contador de entrada

    // Señales internas
    reg [WIDTH - 1 : 0]               codigo_gray_sync_r; // Registro para almacenar el código Gray sincronizado
    reg [WIDTH_INPUT_COUNTER - 1 : 0] cuenta_entrada;    // Contador para la actualización de la entrada

    reg en_lectura; // Señal de habilitación de lectura

    // Contador de actualización
    always @(posedge clk_i) begin
        cuenta_entrada <= rst_i ? (cuenta_entrada == 0 ? (INPUT_REFRESH - 1) : (cuenta_entrada - 1)) : (INPUT_REFRESH - 1);
        en_lectura <= (cuenta_entrada == 0) && rst_i;
    end

    // Sincronización de entrada
    always @(posedge clk_i) begin
        codigo_gray_sync_r <= rst_i ? (en_lectura ? codigo_gray_i : codigo_gray_sync_r) : 0;
    end

    // Conversión de Gray a binario usando lógica booleana
    always_comb begin
        // Cálculo del código binario a partir del código Gray
        logic bit_a, bit_b, bit_c, bit_d;
        bit_a = codigo_gray_sync_r[3];
        bit_b = codigo_gray_sync_r[2];
        bit_c = codigo_gray_sync_r[1];
        bit_d = codigo_gray_sync_r[0];

        // Aplicar las fórmulas para convertir Gray a binario
        codigo_bin_o[3] = bit_a; // MSB del binario es igual al MSB del Gray
        codigo_bin_o[2] = (bit_a & ~bit_b) | (~bit_a & bit_b); // Segunda posición del binario
        codigo_bin_o[1] = codigo_bin_o[2] ^ bit_c; // Tercera posición del binario
        codigo_bin_o[0] = codigo_bin_o[1] ^ bit_d; // LSB del binario
    end

endmodule
```
#### 3.1.2. Parámetros

1. WIDTH Ancho del código Gray y del código binario
2. INPUT_REFRESH es la frecuencia de actualización para el contador
3. clk_i: Pulso de reloj que sincroniza las operaciones.
4. rst_i: Pulso de reinicio asincrono.
5. codigo_gray_i Entrada del código gray, definido para 4 bits, aqui se guarda lo que recibe la fpga.
6. codigo_bin_o Salida a LEDs en codificacion binaria, aqui se guarda la entrada decodificada a binario.

#### 3.1.3. Entradas y salidas:

- `codigo_gray_i`: Se configura la entrada de la fpga, la cual va de codigo_gray_i[0] a codigo_gray_i[3], donde el [0] corresponde al bit menos significativo de codigo ingresado, y el [3] es el mas significativo.
- `codigo_bin_o`: Se establece cada uno como salida para los led que forman parte de la fpga, al igual que en el código gray el [0] es el menos significativo, y el [3] el más significatico.

#### 3.1.4. Criterios de diseño
![Diagrama de gray to bin decoder](https://github.com/user-attachments/assets/7e91c164-f2bf-44fe-9dbb-b73324f14cdf)


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
#### 3.2.2. Parámetros

1. `DISPLAY_REFRESH`: Define la cantidad de ciclos de reloj para refrescar el display.
2. `WIDTH_DISPLAY_COUNTER`: Calcula el número de bits necesarios para contar hasta DISPLAY_REFRESH.
3. `clk_i`: Señal de reloj que sincroniza las operaciones del módulo.
4. `rst_i`: Señal de reinicio para inicializar los registros.
5. `bcd_i [7:0]`: Entrada de 8 bits que contiene el valor en BCD a mostrar (dos dígitos).
6. `anodo_o [1:0]`: Controla qué dígito del display está activo.
7. `catodo_o [6:0]`: Controla los segmentos del display para representar el dígito en BCD.
8. `cuenta_salida`: Contador de refresco para el display.
9. `digito_o [3:0]`: Registro que almacena el dígito actual a mostrar en el display.
10. `en_conmutador`: Señal que indica cuándo cambiar entre dígitos.
11. `decena_unidad [1:0]`: Registro que indica si se está mostrando la unidad o la decena.

#### 3.2.3. Entradas y salidas:
##### Descripción de la entrada:
- `clk_i `
Señal de reloj. Esta señal sincroniza todas las operaciones internas del módulo. Es una señal de tipo input, normalmente conectada al reloj del sistema. Su frecuencia determina la velocidad de actualización del display de 7 segmentos.
- `rst_i`
Señal de reinicio. Se utiliza para restablecer el módulo a su estado inicial. Cuando rst_i es bajo (0), se reinician los registros internos, y el display muestra un estado predeterminado. Es una señal de tipo input y se activa de manera asíncrona, es decir, no depende del reloj.
- `bcd_i [7:0]`
Entrada de 8 bits que contiene el valor en BCD (Binary-Coded Decimal) para el display. Los 4 bits menos significativos (bcd_i[3:0]) representan el dígito de las unidades y los 4 bits más significativos (bcd_i[7:4]) representan el dígito de las decenas. Esta entrada determina qué números se mostrarán en los dos dígitos del display de 7 segmentos.

##### Descripción de la salida:
- `anodo_o [1:0]`
Controla los ánodos de los dos dígitos del display de 7 segmentos. Esta señal indica qué dígito está actualmente activado para la visualización. Solo uno de los dos valores posibles (2'b10 o 2'b01) estará activo en un momento dado, permitiendo la multiplexión entre los dígitos. La salida es de 2 bits, donde cada combinación de bits enciende un dígito específico del display
- `catodo_o [6:0]`
Controla los cátodos de los segmentos del display de 7 segmentos. Esta señal determina qué segmentos del display están encendidos para representar el dígito actual. La salida es de 7 bits, cada bit controla un segmento específico del display, donde un valor bajo (0) enciende el segmento y un valor alto (1) lo apaga. La configuración de los bits en catodo_o permite mostrar los dígitos del 0 al 9.

#### 3.2.4. Criterios de diseño
Diagramas, texto explicativo...

### 3.3 Módulo 3
#### 3.3.1. module_bin_to_bcd
```SystemVerilog
module module_bin_to_bcd #(
    parameter WIDTH = 4
)(
    input clk_i,
    input rst_i,
    input [WIDTH - 1 : 0] bin_i,
    output reg [7 : 0] bcd_o
);

    // Señales internas para las decenas y las unidades
    reg [3:0] unidades;
    reg [3:0] decenas;

    // Registros para sincronizar las señales internas
    reg [3:0] unidades_sync;
    reg [3:0] decenas_sync;

    // Lógica combinacional para calcular unidades y decenas
    always @(*) begin
        // Inicialización de las señales internas
        unidades = 4'b0000;
        decenas  = 4'b0000;

        // Determinar unidades y decenas basadas en el valor de bin_i
        case (bin_i)
            4'b0000: begin // 0
                unidades = 4'b0000;
                decenas  = 4'b0000;
            end
            4'b0001: begin // 1
                unidades = 4'b0001;
                decenas  = 4'b0000;
            end
            4'b0010: begin // 2
                unidades = 4'b0010;
                decenas  = 4'b0000;
            end
            4'b0011: begin // 3
                unidades = 4'b0011;
                decenas  = 4'b0000;
            end
            4'b0100: begin // 4
                unidades = 4'b0100;
                decenas  = 4'b0000;
            end
            4'b0101: begin // 5
                unidades = 4'b0101;
                decenas  = 4'b0000;
            end
            4'b0110: begin // 6
                unidades = 4'b0110;
                decenas  = 4'b0000;
            end
            4'b0111: begin // 7
                unidades = 4'b0111;
                decenas  = 4'b0000;
            end
            4'b1000: begin // 8
                unidades = 4'b1000;
                decenas  = 4'b0000;
            end
            4'b1001: begin // 9
                unidades = 4'b1001;
                decenas  = 4'b0000;
            end
            4'b1010: begin // 10
                unidades = 4'b0000;
                decenas  = 4'b0001;
            end
            4'b1011: begin // 11
                unidades = 4'b0001;
                decenas  = 4'b0001;
            end
            4'b1100: begin // 12
                unidades = 4'b0010;
                decenas  = 4'b0001;
            end
            4'b1101: begin // 13
                unidades = 4'b0011;
                decenas  = 4'b0001;
            end
            4'b1110: begin // 14
                unidades = 4'b0100;
                decenas  = 4'b0001;
            end
            4'b1111: begin // 15
                unidades = 4'b0101;
                decenas  = 4'b0001;
            end
            default: begin // Caso por defecto para valores no esperados
                unidades = 4'b0000;
                decenas  = 4'b0000;
            end
        endcase
    end

    // Sincronización de las señales internas con el reloj
    always @(posedge clk_i or negedge rst_i) begin
        if (~rst_i) begin
            unidades_sync <= 4'b0000;
            decenas_sync  <= 4'b0000;
        end else begin
            unidades_sync <= unidades;
            decenas_sync  <= decenas;
        end
    end

    // Lógica de salida con flip-flop para sincronización
    always @(posedge clk_i or negedge rst_i) 
    begin
        if (~rst_i) begin
            bcd_o <= 8'b0; // Resetear la salida a 0
        end else begin
            bcd_o[3:0] <= unidades_sync;  // Asignar el valor sincronizado de unidades a los 4 bits menos significativos
            bcd_o[7:4] <= decenas_sync;   // Asignar el valor sincronizado de decenas a los 4 bits más significativos
        end
    end
endmodule
```
#### 3.3.2. Parámetros
1. WIDTH: Especifica el ancho del dato binario de entrada, configurado como 4 bits.
2. clk_i: Señal de reloj.
3. rst_i: Señal de reset asíncrona, que reinicia el módulo.
4. bin_i: Entrada binaria de 4 bits que se va a convertir a BCD.
5. bcd_o: Salida en formato BCD, donde los 4 bits menos significativos ([3:0]) representan las unidades y los 4 bits más significativos ([7:4]) representan las decenas.
6. unidades y decenas: Registros para almacenar temporalmente las unidades y decenas del número BCD calculado.
7. unidades_sync y decenas_sync: Registros que sincronizan los valores de unidades y decenas con el reloj del sistema.


#### 3.3.3. Entradas y salidas:
##### Descripción de la entrada:
- `clk_i `
Señal de reloj que sincroniza el funcionamiento del módulo. Las operaciones internas, como la actualización de los registros, se realizan en el flanco ascendente del reloj.
- `rst_i`
Señal de reinicio. Señal de reset asíncrona. Cuando se activa (nivel bajo), el módulo se reinicia y la salida se establece en 0. El reset permite poner el sistema en un estado conocido antes de iniciar cualquier operación.
- `bin_i [WIDTH - 1 : 0]`
Entrada que recibe el número binario que se desea convertir a BCD. La longitud de esta entrada está parametrizada por WIDTH, lo que permite flexibilidad para admitir diferentes anchos de datos.

##### Descripción de la salida:
- `bcd_o [7:0]`
 Salida que proporciona la representación BCD del número binario de entrada. Está formada por dos grupos de 4 bits: Bits [3:0]: Representan las unidades del número en formato BCD. Bits [7:4]: Representan las decenas del número en formato BCD. Los valores se actualizan en los flancos ascendentes del reloj (clk_i) y están sincronizados con el reset (rst_i).

#### 3.3.4. Criterios de diseño
El módulo module_bin_to_bcd convierte una entrada binaria de 4 bits a BCD, que sincroniza las salidas con el reloj del sistema utilizando lógica combinacional para asignar los valores de las unidades y las decenas basados en la entrada binaria que registra estos valores para garantizar una salida estable y sincronizada. 
 Para ello, se utiliza una instrucción case con la cual se puede asignar valores de unidades y decenas en función de la entrada binaria bin_i a los valores BCD del display de 7 segmentos, estos valores de unidades y decenas se calculan para cada valor bin_i (0 a 15) posible. En el caso por defecto, ambos se establecen en 0. 
 En cuanto a la sincronización, cuando rst_i está activo, los registros unidades_sync y decenas_sync se reinician a 0, si rst_i no está activo, los registros sincronizan los valores de unidades y decenas con el reloj.
 Por último, para la lógica de salida, si rst_i está bajo entonces la salida bcd_o se restablece a 0, en caso contrario, bcd_o se actualiza con los valores sincronizados de unidades_sync y decenas_sync donde los bits [3:0] corresponden a las unidades y los bits [7:4] a las decenas.


### 4. Testbench
Con los modulos listos, se trabajo en un testbench para poder ejecutar todo de la misma forma y al mismo tiempo, y con ello, poder observar las simulaciones y obtener una mejor visualización de como funciona todo el código. 
```SystemVerilog
`timescale 1ns/1ns

module test;

    reg clk_i = 0;
    reg rst_i;
    reg [3 : 0] codigo_gray_i;

    wire [1 : 0] anodo_o;
    wire [6 : 0] catodo_o;
    wire [3 : 0] codigo_bin_led_o;

    module_top_deco_gray # (6, 5) DUT 
    (

        .clk_pi            (clk_i),
        .rst_pi            (rst_i),
        .codigo_gray_pi    (codigo_gray_i),
        .anodo_po          (anodo_o),
        .catodo_po         (catodo_o),              
        .codigo_bin_led_po (codigo_bin_led_o)
    );

    always begin
        
        clk_i = ~clk_i;
        #10;
    end
    
    initial begin
        
        rst_i = 0;
        #30;
        rst_i = 1;

        codigo_gray_i = 4'b0000; #100;
        codigo_gray_i = 4'b0001; #100;
        codigo_gray_i = 4'b0011; #100;
        codigo_gray_i = 4'b0010; #100;
        codigo_gray_i = 4'b0110; #100;
        codigo_gray_i = 4'b0111; #100;
        codigo_gray_i = 4'b0101; #100;
        codigo_gray_i = 4'b0100; #100;
        codigo_gray_i = 4'b1100; #100;
        codigo_gray_i = 4'b1101; #100;
        codigo_gray_i = 4'b1111; #100;
        codigo_gray_i = 4'b1110; #100;
        codigo_gray_i = 4'b1010; #100;
        codigo_gray_i = 4'b1011; #100;
        codigo_gray_i = 4'b1001; #100;
        codigo_gray_i = 4'b1000; #100;

        #1000;
        $finish;
    end


    initial begin
        $dumpfile("module_deco_gray.vcd");
        $dumpvars(0, test);
    end

endmodule
```


### Otros modulos
En este apartado, se colocará el ultimo modulo, el cual corresponde a la unión de los tres modulos para poder ejecutar un Makefile de manera correcta.
```SystemVerilog
`timescale 1ns / 1ps

module module_top_deco_gray # (
     parameter INPUT_REFRESH = 2700000,  // Frecuencia de actualización para el módulo de decodificación de Gray
     parameter DISPLAY_REFRESH = 27000   // Frecuencia de actualización para el módulo de 7 segmentos
)(
    input                  clk_pi,          // Señal de reloj de entrada
    input                  rst_pi,          // Señal de reinicio asíncrono de entrada
    input [3 : 0]          codigo_gray_pi,  // Código Gray de 4 bits de entrada

    output  [1 : 0]     anodo_po,           // Señal de salida para los ánodos del display de 7 segmentos
    output  [6 : 0]     catodo_po,          // Señal de salida para los cátodos del display de 7 segmentos
    output  [3 : 0]     codigo_bin_led_po   // Salida del código binario para los LEDs
);

    // Definición de señales internas
    wire [3 : 0] codigo_bin;  // Señal interna para el código binario de 4 bits
    wire [7 : 0] codigo_bcd;  // Señal interna para el código BCD de 8 bits (2 dígitos)

    // Bloques generados
    generate
        // Instancia del módulo de decodificación de Gray a binario
        module_input_deco_gray # (4, INPUT_REFRESH) SUBMODULE_INPUT (
            .clk_i         (clk_pi),          // Conexión del reloj de entrada
            .rst_i         (rst_pi),          // Conexión de la señal de reinicio de entrada
            .codigo_gray_i (codigo_gray_pi),  // Conexión del código Gray de entrada
            .codigo_bin_o  (codigo_bin)       // Conexión del código binario de salida
        );

        // Instancia del módulo de conversión de binario a BCD
        module_bin_to_bcd # (4) SUBMODULE_BIN_BCD (
            .clk_i (clk_pi),       // Conexión del reloj de entrada
            .rst_i (rst_pi),       // Conexión de la señal de reinicio de entrada
            .bin_i (codigo_bin),   // Conexión del código binario de entrada
            .bcd_o (codigo_bcd)    // Conexión del código BCD de salida
        );

        // Instancia del módulo de control del display de 7 segmentos
        module_7_segments # (DISPLAY_REFRESH) SUBMODULE_DISPLAY (
            .clk_i    (clk_pi),     // Conexión del reloj de entrada
            .rst_i    (rst_pi),     // Conexión de la señal de reinicio de entrada
            .bcd_i    (codigo_bcd), // Conexión del código BCD de entrada
            .anodo_o  (anodo_po),   // Conexión de la salida de los ánodos
            .catodo_o (catodo_po)   // Conexión de la salida de los cátodos
        );
    endgenerate

    // Asignación directa del código binario a los LEDs, invirtiendo el valor
    assign codigo_bin_led_po = ~codigo_bin; // La salida es el complemento del código binario

endmodule
```
#### Parámetros
- Lista de parámetros

#### Entradas y salidas:
- `entrada_i`: descripción de la entrada
- `salida_o`: descripción de la salida

#### Criterios de diseño
Diagramas, texto explicativo...

## 5. Consumo de recursos

![image](https://github.com/user-attachments/assets/05d0f397-2e95-41e6-b3d8-099ba000e531)

## 6. Problemas encontrados durante el proyecto

Durante el desarrollo del proyecto se encontraron varios problemas técnicos que fueron resueltos mediante ajustes en el diseño. Primero, se adquirieron displays de 7 segmentos de ánodo común, ya que la programación original estaba diseñada para este tipo de displays, corrigiendo así el problema de visualización que se presentó con los displays de cátodo común. . Además, se intentó implementar la conversión de binario a BCD utilizando compuertas lógicas, pero se emplearon terminologías incorrectas como "case", lo que resultó en una reducción de puntos por parte del profesor. Finalmente, se implementó un módulo de sincronización para asegurar que solo se mostrara el número correspondiente en el display en lugar de intentar encender ambos números simultáneamente. 

## Apendices:
### Apendice 1:
texto, imágen, etc

