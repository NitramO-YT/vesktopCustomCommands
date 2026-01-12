[ ![🇬🇧 English](https://img.shields.io/badge/%F0%9F%87%AC%F0%9F%87%A7-English-blue) ](README.md) [ ![🇫🇷 Français](https://img.shields.io/badge/%F0%9F%87%AB%F0%9F%87%B7-Fran%C3%A7ais-blue) ](README.fr.md) [ ![🇪🇸 Español](https://img.shields.io/badge/%F0%9F%87%AA%F0%9F%87%B8-Espa%C3%B1ol-blue) ](README.es.md) [ ![🇩🇪 Deutsch](https://img.shields.io/badge/%F0%9F%87%A9%F0%9F%87%AA-Deutsch-blue) ](README.de.md) [ ![🇮🇹 Italiano](https://img.shields.io/badge/%F0%9F%87%AE%F0%9F%87%B9-Italiano-blue) ](README.it.md) [ ![🇷🇺 Русский](https://img.shields.io/badge/%F0%9F%87%B7%F0%9F%87%BA-%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9-blue) ](README.ru.md) [ ![🇯🇵 日本語](https://img.shields.io/badge/%F0%9F%87%AF%F0%9F%87%B5-%E6%97%A5%E6%9C%AC%E8%AA%9E-blue) ](README.ja.md) [ ![🇰🇷 한국어](https://img.shields.io/badge/%F0%9F%87%B0%F0%9F%87%B7-%ED%95%9C%EA%B5%AD%EC%96%B4-blue) ](README.ko.md)

# vesktopCustomCommands (VCC) 简介
VCC 是一个系统，允许您向 Vesktop 添加静音和拒听的全局快捷键。这是对 Vesktop 目前缺少全局快捷键的临时解决方案，直到 Vesktop 团队找到更好的解决方案。
基本上，它是一组脚本（`mute.sh` 和 `deafen.sh`），您可以从系统中的自定义全局快捷键调用这些脚本，在 Vesktop 中将自己静音和拒听，并通过在 Vencord 主文件中注入自定义 Javascript 代码来触发 Vesktop 中的这些操作。

# 系统中的快捷键配置
您需要在系统中配置自定义全局快捷键以调用 `~/.vesktopCustomCommands/` 文件夹中的 `mute.sh` 和 `deafen.sh` 脚本。
```plaintext
~/.vesktopCustomCommands/mute.sh
```
```plaintext
~/.vesktopCustomCommands/deafen.sh
```

---

# 安装

## 自动安装
在终端中运行此命令并按照说明操作：
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/install.sh)"
```
注意：如果 `~/.vesktopCustomCommands/.config` 中已存在配置文件，安装程序将保留它，并仅在必要时更新 `vencord_path` 条目。

### 可选：自动重新修补

在安装过程中，您可以启用自动重新修补系统，该系统会定期检查 VCC 补丁是否仍存在于 Vencord 主文件中，并在删除后重新应用（例如，在 Vencord/Vesktop 更新或重置后）。

- 为什么需要？Vesktop/Vencord 更新或某些启动场景可能会将主文件恢复到其原始状态，从而删除 VCC 注入。自动重新修补可确保您的快捷键无需手动干预即可继续工作。
- 设置存储在 `~/.vesktopCustomCommands/.config` 中：
  - `auto_repatch="true|false"`（默认：`false`）
  - `auto_restart="true|false"`（默认：`false`）– 如果启用，Vesktop 将在重新修补后自动重启。您可以稍后使用以下命令切换此选项。
  - `autorepatch_interval="30s|1m|3m"`（默认：`30s`）– 检查间隔。
  - 当 `auto_repatch` 启用时，用户 `systemd` 计时器将以所选间隔运行。
  - 启用自动重新修补：
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/enable_autorepatch.sh)"
  ```
  - 禁用自动重新修补：
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/disable_autorepatch.sh)"
  ```

  - 启用自动重启（重新修补后）：
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/enable_autorestart.sh)"
  ```
  - 禁用自动重启：
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/disable_autorestart.sh)"
  ```


手动配置：编辑 `~/.vesktopCustomCommands/.config` 并设置 `auto_repatch` 和 `auto_restart`。您还可以将 `autorepatch_interval` 设置为 `"30s"`、`"1m"` 或 `"3m"`。如果您手动禁用它，计时器将在下次安装运行时停止，或者运行上面的禁用脚本。

### 可选：自动更新

您可以启用自动更新系统，该系统会定期检查 GitHub 上是否有更新版本，并更新必要的文件（Vencord 的自定义代码和本地脚本，如 `mute.sh` 和 `deafen.sh`）。

- `~/.vesktopCustomCommands/.config` 中的设置：
  - `auto_update="true|false"`（默认：`false`）
  - `auto_update_interval`（默认：`15m`）– 如果启用自动重新修补，计时器将以 `autorepatch_interval` 运行，否则如果仅启用自动更新，则以 `auto_update_interval` 运行。
- 启用自动更新：
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/enable_autoupdate.sh)"
  ```
- 禁用自动更新：
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/disable_autoupdate.sh)"
  ```

## 手动安装
1. 从存储库下载 `dist` 文件夹或其内容。
2. `dist` 分为两部分：
    - `vencord` 文件夹包含要注入 Vencord 主文件的文件。
    - `vesktopCustomCommands` 文件夹包含用于静音/拒听的脚本和 `.config` 文件。
3. 您可以备份 Vencord 主文件（通常位于 `~/.config/Vencord/dist/vencordDesktopMain.js`，使用 `cp ~/.config/Vencord/dist/vencordDesktopMain.js ~/.config/Vencord/dist/vencordDesktopMain.js.bak`），如果您想稍后恢复它，可以删除该文件并启动 Vesktop 以重新创建它。
4. 将 `vencordDesktopMain_sample.js` 的内容注入到您的 Vencord 主文件中（通常位于 `~/.config/Vencord/dist/vencordDesktopMain.js`）：
    - 在文件末尾的 `//# sourceURL=` 行之前插入 `vencordDesktopMain_sample.js` 的全部内容。
5. 在您的 Vencord 路径中创建一个 `vesktopCustomCommands` 目录（通常位于 `~/.config/Vencord/dist/`）并将 `customCode.js` 文件放入其中。
6. 创建一个 `~/.vesktopCustomCommands` 目录并将 `mute.sh` 和 `deafen.sh` 文件放入其中。
7. 为 `mute.sh` 和 `deafen.sh` 脚本添加权限：
    ```bash
    chmod +x ~/.vesktopCustomCommands/mute.sh
    chmod +x ~/.vesktopCustomCommands/deafen.sh
    ```
8. 将 `.config` 文件放入 `~/.vesktopCustomCommands` 并根据需要使用您的 Vencord 路径更新 `vencord_path` 变量。
9. 重启 Vesktop 以应用更改。
10. 在系统中配置自定义全局快捷键以调用 `~/.vesktopCustomCommands/` 文件夹中的 `mute.sh` 和 `deafen.sh` 脚本。
    - `mute.sh` 用于静音自己。`~/.vesktopCustomCommands/mute.sh`
    - `deafen.sh` 用于拒听自己。`~/.vesktopCustomCommands/deafen.sh`
11. 享受您的新全局快捷键以静音和拒听自己！

---

# 卸载

## 自动卸载

在终端中运行此命令并按照说明操作：
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/uninstall.sh)"
```
在卸载过程中，系统会询问您是否要删除所有内容，包括您的设置（`~/.vesktopCustomCommands/.config`）。
- 回答"y"：删除所有文件和设置。
- 回答"n"：仅删除程序文件；保留您的 `.config`。

如果删除了设置，自动重新修补服务/计时器和辅助脚本也将被删除。如果您拒绝自动卸载，请按照下面的手动卸载步骤操作（相同的说明也由脚本回显）。

## 手动卸载

1. 删除系统中调用 `~/.vesktopCustomCommands/` 文件夹中 `mute.sh` 和 `deafen.sh` 脚本的自定义全局快捷键。
2. 删除 `~/.vesktopCustomCommands` 中的 `.config` 文件。
3. 删除 `~/.vesktopCustomCommands` 文件夹。
4. 删除 Vencord 路径 `~/.config/Vencord/dist/vesktopCustomCommands/` 中的 `customCode.js` 文件。
5. 删除 Vencord 路径 `~/.config/Vencord/dist/` 中的 `vesktopCustomCommands` 文件夹。
6. 删除 Vencord 主文件（通常位于 `~/.config/Vencord/dist/vencordDesktopMain.js`）中注入的代码，或用您制作的备份替换它（如果您有）。（您也可以删除文件并启动 Vesktop 以重新创建它）。
7. 重启 Vesktop 以应用更改。

---

# 问题和改进

如果您有任何问题或改进建议，请打开 issue！

# 贡献

我知道这个系统并不完美，我没有遵守所有标准和语义，这就是为什么我指望那些想帮助我改进这个系统的人。issues 和 pull requests 已开放，我欢迎任何建设性的批评！

---

# 本项目主要目标的说明

我是一个习惯于在 X11 下使用 KDE Neon 的用户，总的来说我的 Discord 运行得很好。最近我切换到 Wayland 下的 KDE Neon，发现 Discord 在上面有很多问题，特别是屏幕共享对我来说是不可能的。在寻找解决 Discord 问题的方法时，我发现了 Vesktop，进而发现了 Vencord，我发现它解决了所有问题，甚至包括我在 X11 下已经存在的一些问题（例如在屏幕共享期间共享声音的可能性完全不存在）。我安装了它，一切都很完美，除了一个小细节：缺乏对全局键盘快捷键的支持。唯一的可能性是默认的 Discord 快捷键（`Ctrl + Shift + M` 和 `Ctrl + Shift + D`），它们只在窗口处于活动状态时才有效。因此，我开始在 Vesktop 中寻找快捷键，我可以看到并读到问题是已知的，但解决方案仍远未找到，特别是在 Wayland 上，它似乎使试图制作全局键盘快捷键的开发人员的生活变得复杂。所以我想放弃，但像所有优秀的开发人员一样，我无法放弃，所以我想到了一个解决方案，并找到了一个临时但稳健的解决方案。我不想要一个不稳定的系统，所以我试图使我的系统尽可能简单和功能。我本可以 fork Vesktop 并努力寻找解决方案或集成我的解决方案，但我不再有这种抱负和时间，而且我认为为想要在 Vesktop 中使用全局键盘快捷键的人创建替代存储库既不严肃也不健康。因此，我认为理想的做法是将其视为在官方版本之上添加的 mod 或插件，有点像最终的 Vencord 本身，感兴趣的人可以根据需要安装它。这就足够了，直到 Vesktop 找到全局键盘快捷键的解决方案！

---

谢谢 :)



<!-- Made with ❤️ by NitramO -->
