@echo off
chcp 65001 >nul
echo ===== 轻账项目 Git 推送命令 =====
echo.
echo 步骤：
echo 1. 访问 https://github.com/new 创建仓库
echo 2. 仓库名：light_account
echo 3. 设为 Public（公开）
echo 4. 点击 "Create repository"
echo 5. 执行以下命令：
echo.
echo cd /d "%~dp0"
echo git remote add origin https://github.com/你的用户名/light_account.git
echo git branch -M main
echo git push -u origin main
echo.
pause
