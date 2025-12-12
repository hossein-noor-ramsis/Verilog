module shift_reg_24bit (
    input  logic        clk,
    reset,
    shift_en,
    load_en,
    input  logic        serial_in,
    input  logic [23:0] parallel_in,
    output logic        serial_out,
    output logic [23:0] shift_out
);

  // ۱. ایجاد یک زنجیره برای اتصال سریال (7 سیم برای اتصال 6 بلوک)
  logic [6:0] wire_chain;

  // ۲. ورودی اصلی مدار را به اولین خانه زنجیره وصل می‌کنیم
  assign wire_chain[0] = serial_in;

  // ۳. خروجی آخرین خانه زنجیره را به خروجی اصلی مدار وصل می‌کنیم
  assign serial_out = wire_chain[6];

  // ۴. استفاده از حلقه generate برای کپی کردن ماژول‌ها
  genvar i;
  generate
    for (i = 0; i < 6; i = i + 1) begin : block_gen
      // هر ماژول 4 بیتی را اینجا فراخوانی می‌کنیم
      shift_reg_4bit u_step (
          .clk        (clk),
          .reset      (reset),
          .shift_en   (shift_en),
          .load_en    (load_en),
          // ورودی سریال از سیم i می‌آید
          .serial_in  (wire_chain[i]),
          // خروجی سریال به سیم i+1 می‌رود
          .serial_out (wire_chain[i+1]),
          // جدا کردن 4 بیت از 24 بیت ورودی موازی
          .parallel_in(parallel_in[(i*4)+3 : i*4]),
          // جدا کردن 4 بیت از 24 بیت خروجی موازی
          .shift_out  (shift_out[(i*4)+3 : i*4])
      );
    end
  endgenerate

endmodule
