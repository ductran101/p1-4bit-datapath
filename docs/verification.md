# Kết quả kiểm chứng

Đã biên dịch và mô phỏng ngày 26-09-2026 bằng **Icarus Verilog 13.0**. Kết quả thực tế: **4.096 trường hợp exhaustive, 0 lỗi**, thời gian mô phỏng **35,28 µs**. Log đầy đủ được giữ tại [verification_output.txt](verification_output.txt).

Tái kiểm tra ngày **27-09-2026** bằng `make -B sim` để biên dịch lại toàn bộ: vẫn PASS 4.096 trường hợp, 15 ví dụ và 9 nhóm giao thức/reset, 0 lỗi. Biên dịch riêng design top với `-g2005 -Wall` cũng thành công, không cảnh báo.

## Lệnh tái lập

Tại thư mục gốc project, khi `iverilog`, `vvp`, `make` và Python 3.9+ có trong `PATH`:

```sh
make sim
```

Trong môi trường triển khai hiện tại, Icarus được giải nén tạm tại `/tmp/p1_iverilog` từ RPM Fedora 44 `iverilog-13.0-4.fc44.x86_64.rpm`; không cài vào hệ thống. Lệnh đã chạy:

```sh
PATH=/tmp/p1_iverilog/bin:$PATH make sim
```

Đường dẫn `/tmp` là công cụ kiểm chứng của phiên này, không phải dependency cố định của project. `Makefile` cho phép đổi `IVERILOG`, `VVP` và `PYTHON`.

## Phạm vi và kết quả

| Kiểm tra | Kết quả thực tế |
|---|---|
| Biên dịch design top `alu_4bit` với `-g2005 -Wall` | Thành công, không cảnh báo |
| Biên dịch testbench với `-g2012 -Wall` | Thành công, không cảnh báo |
| Cấu trúc sau elaboration | 1 `adder_subtractor_4bit`, 4 `full_adder`, 1 `muldiv_unit` |
| 14 opcode single-cycle/unused × 256 cặp `a,b` | 3.584 trường hợp, 0 lỗi |
| MUL, tất cả 256 cặp `a,b` | 256 trường hợp, 0 lỗi |
| DIV, tất cả 256 cặp `a,b`, gồm 16 trường hợp `b=0` | 256 trường hợp, 0 lỗi |
| Ví dụ theo report trang 19 | 15 trường hợp, 0 lỗi; tính riêng |
| Giao thức/reset theo mã nguồn Appendix | 9 nhóm kiểm tra, 0 lỗi; tính riêng |
| Python kiểm tra log | Chấp nhận log thực tế; 11 tình huống CLI hợp lệ/lỗi đều cho exit code đúng |
| Tcl với API Vivado giả lập trong `tclsh` | 5 tình huống: sim/synth, lỗi synthesis, tham số sai/thiếu; xác nhận đường dẫn, tops, nguồn và Run All. Không thay thế chạy Vivado thật |
| Bản sao tài liệu ZIP | 11/11 file giống nguyên bản theo từng byte |

Testbench so sánh kết quả và các cờ `carry`, `zero`, `overflow`, `negative`, `div_by_zero` bằng phép so sánh phát hiện cả X/Z. Reference model dùng định nghĩa toán học trực tiếp, độc lập với chuỗi full adder của DUT. `*`, `/`, `%` chỉ dùng trong testbench, không dùng để thực hiện MUL/DIV trong RTL.

Mỗi MUL và DIV đều kiểm tra `busy`/`done` sau bước nạp và từng bước tính, kể cả chia cho 0. Latency đúng là **5 cạnh lên nếu tính cả cạnh nạp**, gồm 1 load + 4 work; khoảng thời gian từ cạnh nạp tới cạnh hoàn tất là 4 chu kỳ clock. Clock testbench có chu kỳ 10 ns.

Các nhóm giao thức kiểm tra reset bất đồng bộ khi idle và giữa MUL/DIV, chặn `start` với opcode khác, bỏ qua `start` khi busy, chốt toán hạng/mode khi nạp, giữ `done`/kết quả, giải mã `div_by_zero` theo opcode và chạy lại sau reset. Đây là kiểm chứng hành vi sẵn có trong Appendix, không bổ sung chức năng phần cứng. Kết quả khi busy là giá trị trung gian như waveform nguồn.

Không cộng ví dụ và nhóm giao thức vào tổng exhaustive của nguồn:

```text
Protocol checks: 9 scenarios, 0 errors (separate from exhaustive totals)
Representative checks: 15 cases, 0 errors (separate from exhaustive totals)
PASS: 3584 single-cycle checks + 512 MUL/DIV checks, 0 errors
```

Testbench có giới hạn đợi MUL/DIV và watchdog 100 µs. Khi lỗi, `$fatal(1)` làm mô phỏng thất bại; Python từ chối log thiếu kết quả, tổng sai, kết quả trùng hoặc có thông báo lỗi dù có dòng PASS.

## Giới hạn của lần kiểm chứng này

Ở giai đoạn kiểm chứng Icarus ban đầu, Vivado/XSim chưa được chạy. Trạng thái hiện tại đã được cập nhật trong mục **Vivado 2026.1 Verification — 2026-09-28** bên dưới, bao gồm XSim, elaboration, synthesis và số liệu tài nguyên thực tế. Project vẫn chưa có bằng chứng implementation, timing closure hoặc chạy trên FPGA vật lý.

Project đã có mã nguồn, testbench, tài liệu, script và repository GitHub để mentor review. Nguồn gốc vẫn không quy định URL repository hoặc thủ tục nộp chính thức; những nội dung còn thiếu đặc tả được liệt kê ở [open_questions.md](open_questions.md).

## Vivado 2026.1 Verification — 2026-09-28

### Environment

- Tool: AMD Vivado 2026.1
- Verification target part: `xc7a35tcpg236-1`
- Design top: `alu_4bit`
- Simulation top: `alu_4bit_tb`
- Testbench file type: SystemVerilog

The selected Artix-7 part is used as a synthesis/verification target only.
The source package does not specify a physical FPGA board or pin mapping.

### Vivado XSim Behavioral Simulation

Behavioral simulation completed successfully.

Results:

- Single-cycle / unused-opcode checks: 3584
- MUL/DIV checks: 512
- Total exhaustive checks: 4096
- Errors: 0
- Simulation completion time: 35.28 us

Observed summary:

`PASS: 3584 single-cycle checks + 512 MUL/DIV checks, 0 errors`

The Python log checker also passed:

`PASS: 4096 exhaustive cases passed with zero errors`

Checker exit status:

`0`

### Elaborated RTL Architecture

Vivado Elaborated Design confirmed the intended RTL structure:

- one shared `adder_subtractor_4bit`
- four structural full-adder instances:
  - `fa0`
  - `fa1`
  - `fa2`
  - `fa3`
- MUL/DIV reuse the shared adder/subtractor datapath
- the top-level module is `alu_4bit`

### Vivado Synthesis

Vivado synthesis completed successfully.

Target:

`xc7a35tcpg236-1`

Resource utilization:

| Resource | Used | Available | Utilization |
|---|---:|---:|---:|
| Slice LUTs | 60 | 20800 | 0.29% |
| Slice Registers | 18 | 41600 | 0.04% |
| Block RAM Tile | 0 | 50 | 0.00% |
| DSPs | 0 | 90 | 0.00% |

The GUI Messages view showed no Warning, Critical Warning, or Error.
The batch synthesis log contained no ERROR or CRITICAL WARNING.

### Tcl Automation Verification

`scripts/vivado_run.tcl` was executed with Vivado 2026.1 in batch mode.

Simulation command:

`vivado -mode batch -source scripts/vivado_run.tcl -tclargs sim xc7a35tcpg236-1`

Result:

- XSim completed
- 4096 exhaustive checks passed
- 0 errors

Synthesis command:

`vivado -mode batch -source scripts/vivado_run.tcl -tclargs synth xc7a35tcpg236-1`

Result:

- synthesis completed
- `utilization.rpt` generated
- resource usage matched the GUI synthesis result

### Saved Vivado Evidence

Evidence is stored in:

`docs/vivado_evidence/`

Main files:

- `xsim_vivado_2026_1_output.txt`
- `xsim_batch_output.txt`
- `vivado_sim.log`
- `vivado_synth.log`
- `utilization_vivado_2026_1_xc7a35tcpg236-1.rpt`
- `utilization_batch.rpt`

Screenshots:

- `screenshots/01_xsim_4096_pass.png`
- `screenshots/02_rtl_4_full_adders.png`
- `screenshots/03_utilization_summary.png`
- `screenshots/04_messages_clean.png`

### Current Physical-Hardware Limitation

The provided source package does not define:

- a specific FPGA development board
- XDC pin assignments
- board I/O connections
- physical timing constraints

Therefore the verified scope currently covers:

- RTL implementation
- behavioral simulation
- exhaustive functional verification
- elaboration
- synthesis
- Python log checking
- Tcl Vivado automation

No FPGA implementation, generated bitstream, board programming, or physical-board validation is claimed.
