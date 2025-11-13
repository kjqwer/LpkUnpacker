@echo off
setlocal EnableDelayedExpansion

REM =============================================================
REM  LpkUnpackerGUI – Build with a specific Conda environment
REM  Usage:  compile_env.bat [env_name]
REM  Default env_name = venv1
REM =============================================================

set ENV_NAME=%1
if "%ENV_NAME%"=="" set ENV_NAME=venv1

echo ===== LpkUnpackerGUI Compiler (Conda env: %ENV_NAME%) =====

REM 1) Ensure Conda exists
where conda >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: Conda not found in PATH.
    echo Please open this script from the "Miniconda/Anaconda Prompt" or add Conda to PATH.
    pause
    exit /b 1
)

REM 2) Activate target environment
call conda activate %ENV_NAME%
if %ERRORLEVEL% neq 0 (
    echo Error: Failed to activate Conda environment "%ENV_NAME%".
    echo Tip: Create it via: conda create -n %ENV_NAME% python=3.10 -y
    pause
    exit /b 1
)

REM 3) Show Python version for confirmation
python -c "import sys; print('Using Python', sys.version)" || (
    echo Error: Python not working in this environment.
    pause
    exit /b 1
)

REM 4) Install project dependencies
echo Installing dependencies from requirements.txt...
pip install -r requirements.txt
if %ERRORLEVEL% neq 0 (
    echo Error: pip install failed.
    pause
    exit /b 1
)

REM 5) Verify Nuitka is available
python -c "import nuitka" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: Nuitka not found in environment "%ENV_NAME%".
    echo Run: pip install nuitka
    pause
    exit /b 1
)

echo This may take several minutes. Please be patient...

REM Main compilation command
python -m nuitka --onefile ^
    --enable-plugin=pyqt5 ^
    --output-dir=build ^
    --windows-console-mode=disable ^
    --jobs=%NUMBER_OF_PROCESSORS% ^
    --lto=no ^
    --include-data-dir=./GUI/assets=GUI/assets ^
    --include-data-dir=./Img=Img ^
    --windows-icon-from-ico=Img/icon.ico ^
    --nofollow-import-to=matplotlib,scipy,pandas,tkinter,PyQtWebEngine,PyQt5.QtWebEngineWidgets,PyQt5.QtWebEngineCore ^
    --python-flag=no_site ^
    --python-flag=no_docstrings ^
    LpkUnpackerGUI.py

if %ERRORLEVEL% neq 0 (
    echo Compilation failed with error code %ERRORLEVEL%.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo Compilation completed successfully!
echo Executable can be found in the 'build' directory.
echo.