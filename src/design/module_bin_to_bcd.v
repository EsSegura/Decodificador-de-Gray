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