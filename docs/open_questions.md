# Các điểm nguồn chưa quy định

Các điểm sau được giữ từ `OPEN_QUESTIONS.md` của ZIP, không chuyển thành yêu cầu triển khai mới.

1. **P1 có cần datapath CPU đầy đủ ngoài ALU?** Excel ghi “4-bit CPU Datapath”; hai PDF chỉ đặc tả ALU. PC, instruction memory, register file và fetch/decode/execute chưa được định nghĩa. Cần đặc tả bổ sung của mentor trước khi mở rộng.
2. **Python phải làm gì?** Excel yêu cầu Python scripting, PDF không chỉ định script. `scripts/check_sim.py` là lựa chọn hỗ trợ kiểm chứng log của triển khai này.
3. **TCL phải làm gì?** Excel yêu cầu TCL scripting, PDF không chỉ định script. `scripts/vivado_run.tcl` hỗ trợ project/simulation/synthesis như một lựa chọn triển khai.
4. **Có phải nạp FPGA vật lý?** Báo cáo nêu Vivado simulation/synthesis và cho phép chọn part/board; không quy định board, pin map, ràng buộc timing hay lập trình FPGA.
5. **Tên repository, URL nộp và thủ tục deadline?** Excel nêu mốc D10 và mentor review GitHub, nhưng không cho tên hoặc URL repository cụ thể. Project hiện đã được xuất bản trên GitHub; URL và thủ tục nộp chính thức vẫn cần theo hướng dẫn của mentor.

Giao thức `done` giữ mức, result trung gian khi busy và gating `div_by_zero` được Appendix và waveform làm rõ; các điểm này được triển khai theo nguồn và ghi trong [architecture.md](architecture.md).
