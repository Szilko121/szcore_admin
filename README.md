<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&height=190&color=0:05080D,45:0066FF,100:00D4FF&text=SzCore+Admin&fontSize=42&fontColor=FFFFFF&animation=fadeIn&fontAlignY=38&desc=SzCore+Framework+%E2%80%A2+Administration&descAlignY=60&descSize=16" width="100%" alt="SzCore Admin" />

<img src="https://readme-typing-svg.demolab.com?font=Orbitron&weight=700&size=21&duration=2500&pause=850&color=00D4FF&center=true&vCenter=true&width=720&height=52&lines=Administration;Modular+%E2%80%A2+Server-Authoritative+%E2%80%A2+Developer+First" alt="SzCore Admin animated headline" />

<p><b>Modern administration and moderation module for SzCore with player management, economy/inventory tools, moderation actions and live framework metrics.</b></p>

<p>
  <img src="https://img.shields.io/badge/SzCore-v1.4.0--rc1-8B5CF6?style=for-the-badge" alt="SzCore version">
  <img src="https://img.shields.io/badge/Type-Administration-00D4FF?style=for-the-badge" alt="Administration">
  <img src="https://img.shields.io/badge/FiveM-Resource-F40552?style=for-the-badge&logo=fivem&logoColor=white" alt="FiveM">
  <img src="https://img.shields.io/badge/Lua-5.4-2C2D72?style=for-the-badge&logo=lua&logoColor=white" alt="Lua">
</p>

<p>
  <a href="https://github.com/Szilko121/szcore_admin/stargazers"><img src="https://img.shields.io/github/stars/Szilko121/szcore_admin?style=flat-square&logo=github&color=00D4FF" alt="Stars"></a>
  <a href="https://github.com/Szilko121/szcore_admin/issues"><img src="https://img.shields.io/github/issues/Szilko121/szcore_admin?style=flat-square&logo=github&color=EF4444" alt="Issues"></a>
  <img src="https://img.shields.io/github/last-commit/Szilko121/szcore_admin?style=flat-square&logo=github&color=22C55E" alt="Last commit">
</p>

<p>
  <a href="https://github.com/Szilko121/SzCore-Framework"><b>Framework</b></a> •
  <a href="https://github.com/Szilko121/SzCore-Framework/tree/main/docs"><b>Documentation</b></a> •
  <a href="https://github.com/Szilko121/SzCore-Recipe"><b>txAdmin Recipe</b></a> •
  <a href="https://github.com/Szilko121/szcore_admin/issues"><b>Report an Issue</b></a>
</p>

</div>

---

## 🚀 Overview

Modern administration and moderation module for SzCore with player management, economy/inventory tools, moderation actions and live framework metrics.

> Administrative actions are permission-gated and validated on the server.

## ✨ Highlights

| | Capability |
|---:|---|
| ⚡ | **F10 administration panel** |
| 🧩 | **Goto, bring, freeze and spectate** |
| 🛡️ | **Revive and heal actions** |
| 💾 | **Kick, ban and unban workflows** |
| 🎯 | **Job, gang, money and inventory administration** |
| 🔌 | **Framework/server metrics dashboard** |

## 📦 Installation

### Requirements

`oxmysql`, `szcore`, `szcore_ui`, `szcore_inventory`, `szcore_death`

### Clone

```bash
git clone https://github.com/Szilko121/szcore_admin.git "resources/[szcore]/szcore_admin"
```

### Start

```cfg
ensure szcore_admin
```

For a full framework deployment, use the dedicated **[SzCore-Recipe](https://github.com/Szilko121/SzCore-Recipe)** instead of installing every module manually.

## 🔌 API Highlights

`OpenAdmin`

Example:

```lua
-- Cross-resource integration should use documented exports.
local resourceState = GetResourceState('szcore_admin')
if resourceState == 'started' then
    -- Use the module's public API here.
end
```

For framework-wide player, callback, hook, permission and persistence conventions, see the **[SzCore developer documentation](https://github.com/Szilko121/SzCore-Framework/tree/main/docs)**.

## 🛡️ Design & Safety

- Sensitive persistent mutations belong on the server.
- Client input is treated as untrusted.
- Cross-resource APIs are explicit instead of relying on hidden globals.
- Tight permanent loops are avoided unless a FiveM native requires per-frame application.
- Performance claims should be verified with `resmon`, the FXServer profiler and repeatable benchmarks.

## 🧩 SzCore Ecosystem

This resource is part of the modular **SzCore Framework**. Modules are maintained in separate repositories so servers can install, update or replace features independently.

<div align="center">

[![Framework](https://img.shields.io/badge/SzCore-Framework-00D4FF?style=for-the-badge&logo=github)](https://github.com/Szilko121/SzCore-Framework)
[![Recipe](https://img.shields.io/badge/txAdmin-Recipe-2563EB?style=for-the-badge&logo=github)](https://github.com/Szilko121/SzCore-Recipe)

<br><br>
<sub>Built by <b>SzCode</b> for the FiveM community.</sub>

<img src="https://capsule-render.vercel.app/api?type=waving&height=90&section=footer&color=0:00D4FF,55:0066FF,100:05080D" width="100%" alt="SzCore footer" />

</div>
