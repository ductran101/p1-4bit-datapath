# P1 — Datapath ALU 4-bit

Project triển khai ALU 4-bit trong tài liệu P1: mười phép toán, bộ cộng/trừ cấu trúc dùng chung cho ADD/SUB và MUL/DIV, cùng testbench tự kiểm tra toàn bộ 4.096 trường hợp. Phạm vi được đối chiếu trong [source_traceability.md](docs/source_traceability.md).

Đã chạy Icarus Verilog 13.0: **4.096 trường hợp PASS, 0 lỗi, 35,28 µs**; 15 ví dụ và 9 nhóm kiểm tra giao thức/reset cũng đạt. [Kết quả kiểm chứng](docs/verification.md) kèm log thực tế.

Excel mô tả P1 là “4-bit CPU Datapath” và yêu cầu Python/TCL. Hai PDF cung cấp đặc tả chi tiết cho ALU; các khối CPU khác chưa có đặc tả. Các script Python, Tcl và Makefile ở đây là **lựa chọn công cụ hỗ trợ triển khai**, không phải deliverable cụ thể được PDF bắt buộc.

## Cấu trúc

```text
rtl/                      9 module Verilog tổng hợp được
tb/alu_4bit_tb.v           Testbench tự kiểm tra, chỉ dùng mô phỏng
scripts/check_sim.py      Kiểm tra log và trả mã thoát PASS/FAIL
scripts/vivado_run.tcl    Tạo project Vivado, mô phỏng hoặc tổng hợp
docs/                     Kiến trúc, nguồn, kiểm chứng, câu hỏi còn mở
docs/context-pack/        Tài liệu hướng dẫn gốc từ ZIP
sources/                  Hai PDF và Excel gốc
build/                    Sản phẩm sinh ra, được .gitignore bỏ qua
```

`alu_4bit` là design top; `alu_4bit_tb` là simulation top. RTL dùng Verilog-2005; testbench dùng thêm `$fatal` của SystemVerilog để báo lỗi bằng mã thoát. Xem sơ đồ và chi tiết từng module trong [architecture.md](docs/architecture.md).

## Cổng và opcode

| Cổng | Hướng | Độ rộng | Ý nghĩa |
|---|---|---:|---|
| `clk` | vào | 1 | Clock cho MUL/DIV |
| `rst` | vào | 1 | Reset bất đồng bộ, active high |
| `start` | vào | 1 | Xung một clock để bắt đầu MUL/DIV |
| `a`, `b` | vào | 4 mỗi cổng | Toán hạng |
| `opcode` | vào | 4 | Chọn phép toán |
| `result` | ra | 8 | Kết quả |
| `carry`, `zero`, `overflow`, `negative` | ra | 1 mỗi cổng | Cờ trạng thái |
| `div_by_zero` | ra | 1 | Phép DIV đã nạp có `b=0`, chỉ xuất khi opcode là DIV |
| `busy`, `done` | ra | 1 mỗi cổng | MUL/DIV đang chạy / đã hoàn thành |

| Opcode | Phép toán | `result[7:0]` |
|---|---|---|
| `0000` | ADD | `{0000, (a+b)[3:0]}` |
| `0001` | SUB | `{0000, (a-b)[3:0]}` |
| `0010` | AND | `{0000, a & b}` |
| `0011` | OR | `{0000, a \| b}` |
| `0100` | XOR | `{0000, a ^ b}` |
| `0101` | NOT A | `{0000, ~a}` |
| `0110` | SHL | `{0000, a[2:0], 0}` |
| `0111` | SHR | `{0000, 0, a[3:1]}` |
| `1000` | MUL unsigned | Tích 8-bit |
| `1001` | DIV unsigned | `{remainder[3:0], quotient[3:0]}` |
| `1010`–`1111` | Chưa dùng | `00000000` |

Các biểu thức trong bảng là ký hiệu mô tả. ADD/SUB giữ 4 bit thấp; carry được xuất riêng. Tám phép đầu là logic tổ hợp: kết quả cập nhật theo đầu vào, không cần `start`.

`carry` là carry-out của ADD, bằng 1 khi SUB không mượn, hoặc bit bị đẩy ra khi shift; các phép khác bằng 0. `overflow = c3 XOR c4` chỉ với ADD/SUB. `zero` kiểm tra cả 8 bit của kết quả. `negative = result[3]` cho phép 4-bit và bằng 0 với MUL/DIV.

Với MUL/DIV, đặt toán hạng/opcode rồi đưa `start=1` qua một cạnh lên khi đang rảnh. Cạnh đó nạp thanh ghi; bốn cạnh lên tiếp theo thực hiện bốn bước. Sau cạnh thứ năm tính cả cạnh nạp, `busy=0`, `done=1`; giữ opcode MUL/DIV để đọc kết quả. `done` và kết quả thanh ghi giữ đến lần start được chấp nhận tiếp theo hoặc reset. Khi `busy=1`, đầu ra MUL/DIV phản ánh trạng thái trung gian và bộ cộng đang phục vụ MUL/DIV. DIV cho `b=0` vẫn chạy đủ bốn bước, trả thương `1111`, số dư bằng `a`, cờ `div_by_zero=1`.

## Mô phỏng bằng Icarus Verilog

Cần các lệnh `iverilog`, `vvp`, `python3` (Python 3.9+), `make` có sẵn. Từ thư mục project:

```sh
make sim
```

Makefile biên dịch đủ 9 file RTL và testbench với `-g2012 -Wall`, chạy mô phỏng, lưu `build/sim.log`, rồi kiểm tra log bằng Python. Cũng có thể chạy `make -C /path/to/p1-4bit-datapath sim` từ thư mục khác.

Kết quả kỳ vọng theo báo cáo gốc:

```text
PASS: 3584 single-cycle checks + 512 MUL/DIV checks, 0 errors
```

3.584 trường hợp bao phủ 14 opcode ngoài MUL/DIV × 256 cặp đầu vào; 512 trường hợp bao phủ MUL và DIV × 256 cặp. Testbench kiểm tra kết quả, cờ, chia cho 0 và độ trễ MUL/DIV. Các ví dụ minh họa được in riêng. [verification.md](docs/verification.md) ghi kết quả thực chạy và giới hạn xác minh.

Kiểm tra log đã có hoặc qua stdin:

```sh
python3 scripts/check_sim.py build/sim.log
python3 scripts/check_sim.py < build/sim.log
```

Parser chỉ trả mã 0 khi có đúng một dòng PASS với đủ 3.584 + 512 trường hợp và 0 lỗi. Log thiếu, sai số đếm, có FAIL/FATAL/ERROR hoặc số lỗi khác 0 đều trả mã 1, kể cả khi có dòng PASS.

## Vivado

Theo báo cáo, thêm 9 file `rtl/*.v` vào Design Sources và `tb/alu_4bit_tb.v` vào Simulation Sources. Với testbench của triển khai này, đặt **File Type = SystemVerilog** trong thuộc tính của file `alu_4bit_tb.v` để hỗ trợ `$fatal` (script Tcl tự đặt thuộc tính này). Chọn design top `alu_4bit`, simulation top `alu_4bit_tb`; chạy Behavioral Simulation rồi **Run All**. Báo cáo gốc chạy khoảng 35 µs, dài hơn mốc mặc định 1.000 ns.

Script hỗ trợ nhận chế độ và part có trong bản Vivado đang cài, không cố định board. Đặt `PART` thành mã part đã chọn, rồi chạy từ thư mục project:

```sh
mkdir -p build
vivado -mode batch -log build/vivado_sim.log -journal build/vivado_sim.jou -source scripts/vivado_run.tcl -tclargs sim "$PART"
python3 scripts/check_sim.py build/vivado/p1_4bit.sim/sim_1/behav/xsim/simulate.log
```

Script xác định đường dẫn nguồn theo vị trí của nó, nên cũng có thể gọi bằng đường dẫn tuyệt đối từ thư mục khác. Project sinh ra luôn nằm trong `build/vivado/`; chạy lại tái tạo project tại đây. XSim ghi log trong `build/vivado/p1_4bit.sim/sim_1/behav/xsim/`.

Để tổng hợp và xuất `build/vivado/utilization.rpt`:

```sh
vivado -mode batch -log build/vivado_synth.log -journal build/vivado_synth.jou -source scripts/vivado_run.tcl -tclargs synth "$PART"
```

Vivado/XSim 2026.1 đã được chạy và xác nhận thành công với target kiểm chứng `xc7a35tcpg236-1`; xem bằng chứng chi tiết trong [verification.md](docs/verification.md). Kết quả synthesis phụ thuộc part; nguồn vẫn không quy định chân I/O, board hay ràng buộc timing cho phần cứng.

Các điểm cần đặc tả thêm được giữ trong [open_questions.md](docs/open_questions.md). Tài liệu và nguồn được tổ chức để mentor có thể review trên GitHub; việc xuất bản repository chưa được thực hiện.

---

## Vivado 2026.1 Results

The current RTL implementation has been verified using AMD Vivado 2026.1.

### Functional Verification

- Design top: `alu_4bit`
- Simulation top: `alu_4bit_tb`
- Simulator: Vivado XSim 2026.1
- Exhaustive checks: 4096
- Errors: 0
- Simulation time: 35.28 us

Result:

`PASS: 3584 single-cycle checks + 512 MUL/DIV checks, 0 errors`

The Python log checker also passed:

`PASS: 4096 exhaustive cases passed with zero errors`

### RTL Architecture Verification

Vivado Elaborated Design confirmed:

- one shared `adder_subtractor_4bit`
- four structural `full_adder` instances
  - `fa0`
  - `fa1`
  - `fa2`
  - `fa3`
- MUL/DIV reuse the shared adder/subtractor

### Synthesis

Verification target:

`xc7a35tcpg236-1`

| Resource | Used | Available | Utilization |
|---|---:|---:|---:|
| Slice LUTs | 60 | 20800 | 0.29% |
| Slice Registers | 18 | 41600 | 0.04% |
| Block RAM Tile | 0 | 50 | 0.00% |
| DSPs | 0 | 90 | 0.00% |

Vivado synthesis completed successfully.

No ERROR or CRITICAL WARNING was found in the batch synthesis log.

### Tcl / Python Automation

The provided automation was also executed successfully with Vivado 2026.1:

- `scripts/vivado_run.tcl` behavioral simulation: PASS
- `scripts/vivado_run.tcl` synthesis: PASS
- `scripts/check_sim.py`: PASS
- Python checker exit code: `0`

### Evidence

Vivado evidence is stored in:

`docs/vivado_evidence/`

It contains:

- XSim output
- Vivado simulation log
- Vivado synthesis log
- utilization reports
- screenshots of simulation, RTL elaboration, utilization and Messages

Detailed verification information is available in:

`docs/verification.md`

### Hardware Scope

The supplied project sources do not specify a physical FPGA development board,
XDC pin mapping, or board-level timing constraints.

Therefore the current verified scope is:

- RTL implementation
- behavioral simulation
- exhaustive functional verification
- RTL elaboration
- synthesis
- Python checking
- Tcl automation

FPGA implementation, bitstream generation and physical-board validation are
not claimed at this stage.
