@echo off
chcp 65001 >nul
cd /d "%~dp0"
typst compile --root . book/exams.typ "最优化方法_往年试卷_数字版.pdf" || goto :err
typst compile --root . book/main.typ "最优化方法_往年试题_参考解析.pdf" || goto :err
echo 完成
pause
exit /b 0
:err
echo 编译失败
pause
exit /b 1
