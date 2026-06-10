@echo off
REM Initialize a new project from acc-governance (Agent Control Center Governance) template
REM Usage: init.bat my-project

setlocal enabledelayedexpansion

if "%1"=="" (
  echo Usage: %0 project-name
  echo Example: %0 my-project
  exit /b 1
)

set PROJECT_NAME=%1
set PROJECT_PATH=projects\%PROJECT_NAME%

if exist "%PROJECT_PATH%" (
  echo Error: %PROJECT_PATH% already exists
  exit /b 1
)

echo Initializing project: %PROJECT_NAME%

REM Copy acc-governance to projects\my-project
xcopy acc-governance "%PROJECT_PATH%" /E /I /Q
echo - Created %PROJECT_PATH%

REM Create .project-spec.json
(
  echo {
  echo   "name": "",
  echo   "description": "",
  echo   "domain": "",
  echo   "initialized_at": "",
  echo   "phases": ["01-define", "02-spec", "03-build", "04-reconciliation", "05-test-ship"],
  echo   "disabled_reviewers": []
  echo }
) > "%PROJECT_PATH%\.project-spec.json"
echo - Created .project-spec.json

REM Create PROGRESS.md (minimal)
(
  echo # PROGRESS — [Project Name]
  echo.
  echo Running log of work. Newest entries at the top.
) > "%PROJECT_PATH%\PROGRESS.md"
echo - Created PROGRESS.md

REM Create work-list.json (Phase 1-5 items)
(
  echo {
  echo   "items": [
  echo     {"id": "def-001", "title": "Product definition", "status": "pending", "phase": "01-define", "agent": "define-author"},
  echo     {"id": "def-002", "title": "User journey", "status": "pending", "phase": "01-define", "agent": "define-author"},
  echo     {"id": "def-003", "title": "UI/UX and roles", "status": "pending", "phase": "01-define", "agent": "define-author"},
  echo     {"id": "spec-001", "title": "Stack decisions", "status": "pending", "phase": "02-spec", "agent": "spec-author"},
  echo     {"id": "spec-002", "title": "Data model", "status": "pending", "phase": "02-spec", "agent": "spec-author"},
  echo     {"id": "spec-003", "title": "API specification", "status": "pending", "phase": "02-spec", "agent": "spec-author"},
  echo     {"id": "spec-004", "title": "Coding standards", "status": "pending", "phase": "02-spec", "agent": "spec-author"},
  echo     {"id": "build-001", "title": "Implementation", "status": "pending", "phase": "03-build", "agent": "build-author"},
  echo     {"id": "recon-001", "title": "Domain logic", "status": "pending", "phase": "04-reconciliation", "agent": "reconciliation-author"},
  echo     {"id": "ship-001", "title": "Testing and deployment", "status": "pending", "phase": "05-test-ship", "agent": "ship-author"}
  echo   ]
  echo }
) > "%PROJECT_PATH%\work-list.json"
echo - Created work-list.json

echo.
echo Project initialized: %PROJECT_NAME%
echo.
echo Next steps:
echo 1. Run project-init agent to gather project details
echo 2. Or manually edit GLOSSARY.md and start define-author
echo.
