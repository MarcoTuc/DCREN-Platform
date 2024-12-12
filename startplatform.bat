@echo off
python310\python.exe setup.py develop
python310\python.exe -m reflex run
pause