# P1 — 4-bit CPU Datapath / 4-bit ALU — Codex Context Pack

Gói này tổng hợp tạm thời các yêu cầu đã xác định từ 3 tài liệu nguồn để đưa cho Codex tiếp tục triển khai project P1.

## Kết luận ngắn
- Kế hoạch OJT gọi P1 là **Digital Logic Foundation & Scripting**.
- Mục tiêu P1 trong Excel: **Build a 4-bit CPU Datapath from gate-level. Python & TCL scripting.**
- Milestone P1 ở D10: **Gate-level design compiles and simulates correctly**.
- Cách đánh giá: **GitHub repo reviewed by mentor**.
- Hai PDF mô tả rất chi tiết một **4-bit ALU** là phần datapath tính toán: 10 phép toán, 9 file Verilog design + 1 testbench, mô phỏng trên Vivado.

## Cảnh báo phạm vi
Excel dùng thuật ngữ **4-bit CPU Datapath**, nhưng PDF hiện có chỉ đặc tả chi tiết **4-bit ALU**. Không có yêu cầu rõ ràng trong tài liệu hiện tại về Program Counter, register file, instruction memory, data memory, instruction register, accumulator hay một CPU hoàn chỉnh.

Vì vậy Codex **không được tự ý thêm các khối CPU ngoài ALU** nếu không tìm thấy yêu cầu đó trong các file nguồn hoặc người dùng/mentor cung cấp thêm specification.

## File quan trọng
- `CODEX_TASK.md` — prompt chính để Codex thực hiện.
- `REQUIREMENTS.md` — yêu cầu đã xác định từ tài liệu.
- `ARCHITECTURE.md` — module, opcode, ports, flags, MUL/DIV.
- `IMPLEMENTATION_PLAN.md` — thứ tự triển khai và kiểm thử.
- `ACCEPTANCE_CHECKLIST.md` — checklist nghiệm thu.
- `OPEN_QUESTIONS.md` — những phần tài liệu chưa đặc tả rõ.
- `sources/` — 3 tài liệu gốc.
