module sample (D,A,B,C);
    output D;
    input A,B,C;
    wire w1,w2,w3,w4;

    not G1(w1, B);
    not G1(w2, C);
    and G3(w3, A, w1);
    and G4(w4, A, w2);
    or G5(D, w3, w4);
 
endmodule 
