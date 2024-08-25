// Descripción: Decodificador de código Gray a binario usando lógica booleana

module gray_to_bin_decoder (
    input  logic [4 : 0] codigo_gray_pi,  // Entrada: Código Gray (4 bits)
    output logic [4 : 0] codigo_bin_led_po // Salida: Código Binario (N bits)
);

    // Declaración de señales internas
    logic bit_a, bit_b, bit_c, bit_d;

    initial begin
         binary_code = '0; // Inicializar la salida (opcional)
         bit_a = codigo_gray_pi[3];
         bit_b = codigo_gray_pi[2];
         bit_c = codigo_gray_pi[1];
         bit_d = codigo_gray_pi[0];
    end

    // Lógica combinacional para la decodificación
    always_comb begin
        // gray_code a binary_code usando compuertas lógicas

        codigo_bin_led_po[3] = bit_a;
        codigo_bin_led_po[2] = (bit_a&~bit_b) | (~bit_a&bit_b);
        codigo_bin_led_po[1] = binary_code[1] ^ bit_c;
        codigo_bin_led_po[0] = binary_code[2] ^ bit_d;

    end

endmodule
