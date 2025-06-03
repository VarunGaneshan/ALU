# ALU

## 🔹 Key Features

- **Configurable operand width** via `defines.v`
- Supports **2-operand** and **1-operand** (OPA/OPB) operations
- **Mode-based execution:**
  - `mode = 1`: Arithmetic
  - `mode = 0`: Logical
- **Multiplication-aware result sizing** using `MUL_OP` macro
- **Command and input validation** with structured error flagging
- **Output flags:** `cout`, `oflow`, `g`, `l`, `e`, `err`

---

## 🔹 File Structure

- **defines.v**
  - Defines operand and command widths (`OP_WIDTH`, `CMD_WIDTH`)
  - Instruction macros: `ADD`, `SUB`, `INC_A`, `ROL`, etc.

- **alu_top.v**
  - Top-level controller for the ALU
  - Validates instruction and operand availability
  - Categorizes commands using `is_opA_only()`, `is_opB_only()`, `is_two_op()`
  - Submodules are controlled by enable signals
  - Stores intermediate multiplication outputs for pipelining
  - Handles output muxing and error logic
  - Output widths are dynamically sized using `ifdef MUL_OP`

- **alu_two_op.v**
  - Handles all **2-operand operations**:
    - **Arithmetic:** `ADD`, `SUB`, `CMP`, `INC_MUL`, `SHL_MUL`
    - **Signed arithmetic:** `ADD_SIGN`, `SUB_SIGN`
    - **Logical:** `AND`, `OR`, `XOR`, `NAND`, `ROL`, `ROR`
  - Uses `$clog2(OP_WIDTH)` to determine rotation bit width
  - Checks MSBs of `opb` for illegal values in rotate ops (raises `err`)
  - Handles carry out, overflow, and comparison flags
  - Separate logic for arithmetic (`mode = 1`) and logical (`mode = 0`)

- **alu_opA.v** and **alu_opB.v**
  - Handle **single-operand operations**:
    - `alu_opA`: `INC_A`, `DEC_A`, `NOT_A`, `SHR1_A`, `SHL1_A`
    - `alu_opB`: `INC_B`, `DEC_B`, `NOT_B`, `SHR1_B`, `SHL1_B`
  - Separate logic for arithmetic (`mode = 1`) and logical (`mode = 0`)

---

## 🔹 Error Handling

- **`err = 1` is raised for:**
  - Invalid command codes
  - Mismatched `inp_valid` vs. expected operand type
  - Invalid rotation amounts in `ROL`/`ROR` (e.g., high bits set in `opb`)

---

## 🔹 Timing & Pipeline Behavior

- **Inputs** are latched on a valid `CE` cycle with valid `CMD` and `INP_VALID`
- **Results** from submodules are muxed out accordingly
- **Multiplication results** are latched for one additional cycle to account for extra delay

---

## 🔹 Usage Guidelines

- **Set `MUL_OP`** if wider multiplication result is required
- Use symbolic `defines.v` constants in your testbenches and control logic
- Provide the correct `inp_valid` for each instruction:
  - `2'b11` for two-operand instructions
  - `2'b01` or `2'b11` for OPA-only
  - `2'b10` or `2'b11` for OPB-only

---

## 🔹 Example Operation Flow

- **INC_A:**
  - `mode = 1`, `cmd = INC_A`
  - `inp_valid = 2'b01` or `2'b11`
  - `alu_opA` computes `opa + 1`
  - `cout` set if overflow from `OP_WIDTH`
- **ROL:**
  - `mode = 0`, `cmd = ROL`
  - `inp_valid = 2'b11`
  - `alu_two_op` computes rotate-left
  - If upper bits in `opb` beyond `$clog2(OP_WIDTH)` are non-zero, `err` is raised

---

## 🔹 Conclusion

This ALU is fully modular and parameterized. It supports wide data operations, structured error signaling, and clear mode separation. Its flexibility makes it ideal for integration into datapaths, processors, or hardware accelerators.

## Running tests in Questa sim
```
vlog -sv +acc +cover -l alu_coverage.log test_bench.v #Compile
vsim -novopt -suppress 12110 -coverage alu_top_tb -c -do "add wave * coverage save -onexit -directive -codeAll alu.ucdb; run -all; exit" #Simulation with coverage
vcover report -html alu.ucdb -htmldir covReport -details #Coverage Report
```
