@echo off
REM 拉取main分支的最新更改
git pull origin main

REM 切换到main分支
git checkout main

REM 添加所有更改
git add .

REM 提交更改
git commit -m "笔记内容更新"

REM 推送到main分支
git push origin main

pause