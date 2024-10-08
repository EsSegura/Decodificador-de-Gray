module module_7_segments # (

    parameter DISPLAY_REFRESH = 27000
)(

    input clk_i,
    input rst_i,

    input [7 : 0] bcd_i,

    output reg [1 : 0] anodo_o,
    output reg [6 : 0] catodo_o
);

    localparam WIDTH_DISPLAY_COUNTER = $clog2(DISPLAY_REFRESH);
    reg [WIDTH_DISPLAY_COUNTER - 1 : 0] cuenta_salida;

    reg [3 : 0] digito_o;

    reg en_conmutador;
    reg [1 : 0]decena_unidad;

    // Contador de refresco
    always @ (posedge clk_i or negedge rst_i) begin
        if (!rst_i) begin
            cuenta_salida <= DISPLAY_REFRESH - 1;
            en_conmutador <= 0;
        end else begin
            cuenta_salida <= (cuenta_salida == 0) ? (DISPLAY_REFRESH - 1) : (cuenta_salida - 1'b1);
            en_conmutador <= (cuenta_salida == 0);
        end
    end

    // Contador de 1 bit 
    always @ (posedge clk_i) begin
        decena_unidad <= (rst_i) ? ((en_conmutador) ? (decena_unidad + 1'b1) : decena_unidad) : 2'b00;
    end

     //Multiplexed digits
    always @(decena_unidad) begin

        digito_o = 0;
        anodo_o = 2'b11;
        
        case(decena_unidad) 
            
            1'b0 : begin
                
                anodo_o  = 2'b10;
                digito_o = bcd_i [3 : 0];
            end

            1'b1 : begin
                
                anodo_o  = 2'b01;
                digito_o = bcd_i [7 : 4]; 
            end

            default: begin
                
                anodo_o  = 2'b11;
                digito_o = 0;
            end
        endcase
    end

    //BCD to 7 segments
    always @(*) begin
        catodo_o[0] = ~(digito_o == 4'd0 || digito_o == 4'd2 || digito_o == 4'd3 || digito_o == 4'd5 || digito_o == 4'd6 || digito_o == 4'd7 || digito_o == 4'd8 || digito_o == 4'd9);
        catodo_o[1] = ~(digito_o == 4'd0 || digito_o == 4'd1 || digito_o == 4'd2 || digito_o == 4'd3 || digito_o == 4'd4 || digito_o == 4'd7 || digito_o == 4'd8 || digito_o == 4'd9);
        catodo_o[2] = ~(digito_o == 4'd0 || digito_o == 4'd1 || digito_o == 4'd3 || digito_o == 4'd4 || digito_o == 4'd5 || digito_o == 4'd6 || digito_o == 4'd7 || digito_o == 4'd8 || digito_o == 4'd9);
        catodo_o[3] = ~(digito_o == 4'd0 || digito_o == 4'd2 || digito_o == 4'd3 || digito_o == 4'd5 || digito_o == 4'd6 || digito_o == 4'd8 || digito_o == 4'd9);
        catodo_o[4] = ~(digito_o == 4'd0 || digito_o == 4'd2 || digito_o == 4'd6 || digito_o == 4'd8);
        catodo_o[5] = ~(digito_o == 4'd0 || digito_o == 4'd4 || digito_o == 4'd5 || digito_o == 4'd6 || digito_o == 4'd8 || digito_o == 4'd9);
        catodo_o[6] = ~(digito_o == 4'd2 || digito_o == 4'd3 || digito_o == 4'd4 || digito_o == 4'd5 || digito_o == 4'd6 || digito_o == 4'd8 || digito_o == 4'd9);

    end
endmodule