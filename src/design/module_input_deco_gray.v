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


