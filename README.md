# Decodificador de Gray

## 1. Abreviaturas y definiciones
- **FPGA**: Field Programmable Gate Arrays

## 2. Referencias
[0] David Harris y Sarah Harris. *Digital Design and Computer Architecture. RISC-V Edition.* Morgan Kaufmann, 2022. ISBN: 978-0-12-820064-3

## 3. Desarrollo

### 3.0 Descripción general del sistema
El sistema implementado consiste en tres módulos en Verilog que interactúan para la conversión y visualización de datos en un display de 7 segmentos. El módulo module_input_deco_gray realiza la conversión de un código Gray de 4 bits a su equivalente binario, sincronizando la entrada mediante un contador de refresco. El módulo module_bin_to_bcd toma este valor binario de 4 bits y lo convierte a un formato BCD de 8 bits, segregando los dígitos en decenas y unidades. Finalmente, el módulo module_7_segments utiliza este valor BCD para controlar un display de 7 segmentos multiplexado, manejando la conmutación entre dígitos y activando los segmentos correspondientes a cada dígito en función del valor BCD recibido, con un control preciso del tiempo de refresco del display. Este flujo garantiza una conversión precisa desde el código Gray hasta la visualización en un display de 7 segmentos de forma decimal.
### 3.1 Módulo 1
#### 1. Encabezado del módulo
```SystemVerilog
module mi_modulo(
    input logic     entrada_i,      
    output logic    salida_i 
    );
```
#### 2. Parámetros
- Lista de parámetros

#### 3. Entradas y salidas:
- `entrada_i`: descripción de la entrada
- `salida_o`: descripción de la salida

#### 4. Criterios de diseño
Diagramas, texto explicativo...

#### 5. Testbench
Descripción y resultados de las pruebas hechas

### Otros modulos
- agregar informacion siguiendo el ejemplo anterior.


## 4. Consumo de recursos

## 5. Problemas encontrados durante el proyecto

## Apendices:
### Apendice 1:
texto, imágen, etc

