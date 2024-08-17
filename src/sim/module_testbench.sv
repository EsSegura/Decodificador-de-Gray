module module_testbench;
wire D;
reg A,B,D;

sample C1(D,A,B,C);
initial 
    begin
        A=1'b0; B=1'b0; C=1'b0;
        #20 A=1'b0; B=1'b0; C=1'b1;
        #20 A=1'b0; B=1'b1; C=1'b0;
        #20 A=1'b0; B=1'b1; C=1'b1;
        #20 A=1'b1; B=1'b0; C=1'b0;
        #20 A=1'b1; B=1'b1; C=1'b1;
        #20 A=1'b1; B=1'b1; C=1'b0;
        #20 A=1'b1; B=1'b0; C=1'b1;
    end
initial
$display("%b %b %b %b", D,A,B,C);
endmodule