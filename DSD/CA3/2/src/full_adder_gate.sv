module full_adder_gate (
    input  logic a,
    input  logic b,
    input  logic cin,
    output logic sum,
    output logic cout
);
  logic axb, ab, bc, ac;

  xor (axb, a, b);
  xor (sum, axb, cin);

  and (ab, a, b);
  and (bc, b, cin);
  and (ac, a, cin);

  or (cout, ab, bc, ac);
endmodule
