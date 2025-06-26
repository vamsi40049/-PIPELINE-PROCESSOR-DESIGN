module pipelined_processor_tb;

    logic clk, rst;

    pipelined_processor dut(clk, rst);

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        #10;
        rst = 0;
    end

    initial begin
        $monitor("Time: %0t | PC: %0d | IF_ID.op: %0b | ID_EX.op: %0b | EX_WB.rd: %0d | EX_WB.result: %0h",
                  $time, dut.pc, dut.IF_ID.opcode, dut.ID_EX.opcode, dut.EX_WB_rd, dut.EX_WB_result);
        #100;
        $display("\nFinal Register Values:");
        for (int i = 0; i < 16; i++) begin
            $display("R[%0d] = %0h", i, dut.reg_file[i]);
        end
        $finish;
    end
endmodule
