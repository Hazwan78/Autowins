# Autowins
# Windows Automated App Installer & Uninstaller

A set of PowerShell scripts to streamline batch software deployment and removal on Windows using interactive GUI selection (`Out-GridView`).

---

## 📁 Features

* **Auto Administrator Elevation**: Automatically prompts for UAC/Admin privileges.
* **Dual Format Support**: Handles both `.exe` and `.msi` installers seamlessly.
* **Interactive Selection**: Allows selecting single or multiple apps via a clean GUI menu.
* **Silent Execution**: Passes quiet/silent flags (`/S`, `/verysilent`, `/qn`) to avoid manual clicks.

---

## 🚀 How to Use

### 1. Interactive App Installer (`installmultipleapps.ps1`)
1. Place `install_apps.ps1` into a folder alongside your downloaded `.exe` and `.msi` installer files.
2. Right-click `install_apps.ps1` -> **Run with PowerShell**.
3. Select the applications you want to install from the pop-up menu (Hold `CTRL` to select multiple).
4. Click **OK** to begin batch installation.

### 2. Interactive App Uninstaller (`uninstall_apps.ps1`)
1. Run `uninstall_apps.ps1` from anywhere on your machine via **Run with PowerShell**.
2. A window displaying all installed applications (queried from Windows Registry) will appear.
3. Select the apps you wish to remove and click **OK**.

---

## 🔒 Execution Policy Note

If Windows blocks script execution, open PowerShell as Administrator once and run:

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```
