# Đối chiếu yêu cầu với nguồn

Nguồn kỹ thuật gốc là [Excel kế hoạch OJT](../sources/FPTU_VLSI_OJT_Execution_Plan.xlsx), [báo cáo ALU 29 trang](../sources/ALU_4bit_full_report_29p.pdf) và [gate diagrams 5 trang](../sources/ALU_gate_level_diagrams_5p.pdf). Số trang dưới đây là số trang PDF, bắt đầu từ 1. Cả hai sheet Excel (`Execution Plan`, `VILT Session Plan`) đã được đọc; sheet VILT không bổ sung đặc tả phần cứng P1.

Các file hướng dẫn trong [context-pack](context-pack/) được giữ nguyên từ ZIP. `CODEX_TASK.md` tổng hợp việc triển khai từ nguồn; các gợi ý về công cụ hoặc tổ chức repository được phân biệt với yêu cầu phần cứng.

| Nội dung | Căn cứ | Hiện thực / tài liệu |
|---|---|---|
| P1 Digital Logic Foundation & Scripting; Week 1–2, D1–D10; gate-level 4-bit CPU Datapath, Python/TCL | Excel `Execution Plan!A28:E28` | ALU trong `rtl/`; script hỗ trợ trong `scripts/`; phạm vi mở trong `open_questions.md` |
| Giờ project P1: 19.1 và 18.8 | Excel `Execution Plan!F36:F37` | Thông tin bối cảnh, không tạo yêu cầu RTL |
| D10; design compile/simulate đúng; mentor review GitHub | Excel `Execution Plan!A53:E53` | Testbench, hướng dẫn chạy và `verification.md`; chưa xuất bản GitHub |
| Rubric 40% kỹ thuật, 25% kiểm chứng, 20% tài liệu, 15% thuyết trình | Excel `Execution Plan!A59` | Thông tin đánh giá chung của chương trình |
| Các cổng, 10 opcode, 6 opcode chưa dùng trả 0 | Báo cáo trang 11, 21–22, 26–27 | `alu_4bit.v`, `result_mux.v`, README |
| Full adder 2 XOR, 2 AND, 1 OR; ripple ×4, B XOR sub | Báo cáo trang 3–4, 23–24; gate PDF trang 1, 3–4 | `full_adder.v`, `adder_subtractor_4bit.v` |
| Decoder, logic song song, logical shift | Báo cáo trang 4, 16–18, 23–24; gate PDF trang 2–3 | `control_unit.v`, `logic_unit_4bit.v`, `shifter_4bit.v` |
| Shared adder cho MUL/DIV; không thêm multiplier/divider riêng | Báo cáo trang 5–8, 12–15, 21–22, 25–26; gate PDF trang 5 | Top-level adder mux và `muldiv_unit.v` |
| MUL shift-and-add, DIV restoring; bốn bước | Báo cáo trang 6–7, 25–26 | `muldiv_unit.v` |
| Busy, start một clock, done giữ mức; 1 nạp + 4 bước; result trung gian | Báo cáo trang 9–10, 19, 25–26 | `muldiv_unit.v`, `tb/alu_4bit_tb.v`, `architecture.md` |
| DIV/0 trả `{a,1111}`; top cờ chỉ hiện khi opcode DIV | Báo cáo trang 7, 22, 25–26 | Cờ chốt trong MUL/DIV và `is_div & md_dbz` trong top |
| Carry/no-borrow, overflow c3 XOR c4, zero 8-bit, negative | Báo cáo trang 5, 18, 27; gate PDF trang 4 | `flag_unit.v` |
| Đúng 9 design files + 1 simulation testbench | Báo cáo trang 13–15, Appendix trang 21–29 | `rtl/` và `tb/` |
| 3.584 single-cycle + 512 MUL/DIV; ví dụ và PASS/FAIL | Báo cáo trang 19, 27–29 | Testbench và kết quả thực chạy trong `verification.md` |
| Vivado tops, Behavioral Simulation, Run All, khoảng 35 µs | Báo cáo trang 19–20 | README; Tcl là công cụ hỗ trợ |

## Lựa chọn hỗ trợ triển khai

`check_sim.py` kiểm tra log đầy đủ và trả mã thoát; `vivado_run.tcl` tự tạo project Vivado trong `build/vivado/`; Makefile chạy Icarus Verilog. Excel chỉ ghi Python/TCL scripting, không quy định chức năng hay tên file cụ thể. Make/Icarus cũng là lựa chọn hỗ trợ chạy kiểm chứng; không thay đổi đặc tả ALU.

Các mô tả chức năng trong `CODEX_TASK.md` phù hợp với nguồn. Appendix làm rõ `div_by_zero` được gate theo opcode DIV, `done` giữ mức, và waveform cho thấy result thay đổi qua từng bước khi busy. “Giữ kết quả đến start tiếp theo” áp dụng cho thanh ghi kết quả sau khi hoàn tất, với opcode đang chọn nhánh MUL/DIV.

Hai PDF không bổ sung các khối CPU ngoài ALU. Việc mở rộng phạm vi, chọn board vật lý hoặc xác định thủ tục nộp bài được để trong [open_questions.md](open_questions.md).
