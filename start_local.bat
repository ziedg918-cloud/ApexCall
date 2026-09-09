@echo off
cd /d "%~dp0"
python -m http.server 8080
echo.
echo Open http://localhost:8080/wall.html
pause
