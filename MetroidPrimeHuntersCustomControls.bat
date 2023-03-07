@echo off
start "F:\Program Files (x86)\AutoIt3\AutoIt3.exe" /w /b "MouseLookMapper.au3"
cd MetroidPrimeHuntersScripts
for /f %%a IN ('dir /b /s *.au3') do (
	echo %%a
	start "F:\Program Files (x86)\AutoIt3\AutoIt3.exe" %%a
)
::start "F:\Program Files (x86)\AutoIt3\AutoIt3.exe" "MouseLookMapper.au3"
::start "F:\Program Files (x86)\AutoIt3\AutoIt3.exe" "MouseToKeyboardMapper.au3"