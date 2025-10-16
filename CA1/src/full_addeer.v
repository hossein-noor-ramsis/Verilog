module full_adder (
    input  a,
    input  b,
    input  cin,
    output sum,
    output cout
);
  wire axb, aandb, axb_cin;

  xor (axb, a, b);
  xor (sum, axb, cin);

  and (aandb, a, b);
  and (axb_cin, axb, cin);
  
  or (cout, aandb, axb_cin);
endmodule
