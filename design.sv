module pipelined_processor(input logic clk, input logic rst);

    typedef enum logic [1:0] {ADD = 2'b00, SUB = 2'b01, LOAD = 2'b10} opcode_t;

    typedef struct packed {
        opcode_t opcode;
        logic [3:0] rs1, rs2, rd;
        logic [7:0] imm;
    } instr_t;

    instr_t instr_mem [0:15];
    logic [7:0] reg_file [0:15];
    logic [7:0] data_mem [0:255];

    logic [3:0] pc;

    instr_t IF_ID;
    instr_t ID_EX;
    logic [7:0] EX_WB_result;
    logic [3:0] EX_WB_rd;
    logic EX_WB_we;

    initial begin
        instr_mem[0] = '{ADD, 4'd1, 4'd2, 4'd3, 8'd0};
        instr_mem[1] = '{SUB, 4'd3, 4'd1, 4'd4, 8'd0};
        instr_mem[2] = '{LOAD, 4'd0, 4'd0, 4'd5, 8'd10};
        reg_file[1] = 8'd20;
        reg_file[2] = 8'd5;
        data_mem[10] = 8'hAA;
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 0;
            IF_ID <= '0;
            ID_EX <= '0;
            EX_WB_result <= 0;
            EX_WB_rd <= 0;
            EX_WB_we <= 0;
        end else begin
            IF_ID <= instr_mem[pc];
            pc <= pc + 1;
            ID_EX <= IF_ID;

            logic [7:0] val1, val2, result;
            val1 = reg_file[ID_EX.rs1];
            val2 = reg_file[ID_EX.rs2];

            case (ID_EX.opcode)
                ADD:  result = val1 + val2;
                SUB:  result = val1 - val2;
                LOAD: result = data_mem[ID_EX.imm];
                default: result = 8'h00;
            endcase

            EX_WB_result <= result;
            EX_WB_rd <= ID_EX.rd;
            EX_WB_we <= 1;
        end
    end

    always_ff @(posedge clk) begin
        if (EX_WB_we)
            reg_file[EX_WB_rd] <= EX_WB_result;
    end
endmodule
