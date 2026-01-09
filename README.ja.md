[ ![🇬🇧 English](https://img.shields.io/badge/%F0%9F%87%AC%F0%9F%87%A7-English-blue) ](README.md) [ ![🇫🇷 Français](https://img.shields.io/badge/%F0%9F%87%AB%F0%9F%87%B7-Fran%C3%A7ais-blue) ](README.fr.md) [ ![🇪🇸 Español](https://img.shields.io/badge/%F0%9F%87%AA%F0%9F%87%B8-Espa%C3%B1ol-blue) ](README.es.md) [ ![🇩🇪 Deutsch](https://img.shields.io/badge/%F0%9F%87%A9%F0%9F%87%AA-Deutsch-blue) ](README.de.md) [ ![🇮🇹 Italiano](https://img.shields.io/badge/%F0%9F%87%AE%F0%9F%87%B9-Italiano-blue) ](README.it.md) [ ![🇷🇺 Русский](https://img.shields.io/badge/%F0%9F%87%B7%F0%9F%87%BA-%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9-blue) ](README.ru.md) [ ![🇨🇳 中文](https://img.shields.io/badge/%F0%9F%87%A8%F0%9F%87%B3-%E4%B8%AD%E6%96%87-blue) ](README.zh.md) [ ![🇰🇷 한국어](https://img.shields.io/badge/%F0%9F%87%B0%F0%9F%87%B7-%ED%95%9C%EA%B5%AD%EC%96%B4-blue) ](README.ko.md)

# vesktopCustomCommands (VCC) の紹介
VCCは、Vesktopにミュートとスピーカーミュートのグローバルショートカットを追加できるシステムです。これは、Vesktopチームがより良いソリューションを見つけるまでの、Vesktopにおけるグローバルショートカットの欠如に対する一時的な解決策です。
基本的には、システムのカスタムグローバルショートカットから呼び出すことができる一連のスクリプト（`mute.sh`と`deafen.sh`）で、Vesktopで自分をミュート・スピーカーミュートにし、VencordプリロードファイルにカスタムJavascriptコードを注入することでVesktopでこれらのアクションをトリガーします。

# システムでのショートカット設定
`~/.vesktopCustomCommands/`フォルダーにある`mute.sh`と`deafen.sh`スクリプトを呼び出すために、システムでカスタムグローバルショートカットを設定する必要があります。
```plaintext
~/.vesktopCustomCommands/mute.sh
```
```plaintext
~/.vesktopCustomCommands/deafen.sh
```

---

# インストール

## 自動インストール
ターミナルでこのコマンドを実行し、指示に従ってください:
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/install.sh)"
```
注意: `~/.vesktopCustomCommands/.config`に設定ファイルが既に存在する場合、インストーラーはそれを保持し、必要に応じて`vencord_path`エントリのみを更新します。

### オプション: 自動再パッチ

インストール中に、VCCパッチがVencordプリロードファイルにまだ存在するかどうかを定期的にチェックし、削除された場合（例：Vencord/Vesktopの更新またはリセット後）に再適用する自動再パッチシステムを有効にできます。

- なぜ必要なのか？Vesktop/Vencordの更新や特定の起動シナリオにより、プリロードファイルが元の状態に復元され、VCCインジェクションが削除される可能性があります。自動再パッチにより、手動介入なしにショートカットが動作し続けることが保証されます。
- 設定は`~/.vesktopCustomCommands/.config`に保存されます:
  - `auto_repatch="true|false"` (デフォルト: `false`)
  - `auto_restart="true|false"` (デフォルト: `false`) – 有効にすると、再パッチ後にVesktopが自動的に再起動されます。以下のコマンドで後から切り替えることができます。
  - `autorepatch_interval="30s|1m|3m"` (デフォルト: `30s`) – チェック間隔。
  - `auto_repatch`が有効な場合、選択された間隔でユーザーの`systemd`タイマーが実行されます。
  - 自動再パッチを有効にする:
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/enable_autorepatch.sh)"
  ```
  - 自動再パッチを無効にする:
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/disable_autorepatch.sh)"
  ```

  - 自動再起動を有効にする（再パッチ後）:
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/enable_autorestart.sh)"
  ```
  - 自動再起動を無効にする:
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/disable_autorestart.sh)"
  ```


手動設定: `~/.vesktopCustomCommands/.config`を編集して`auto_repatch`と`auto_restart`を設定します。`autorepatch_interval`を`"30s"`、`"1m"`、または`"3m"`に設定することもできます。手動で無効にした場合、次のインストール実行時にタイマーが停止されるか、上記の無効化スクリプトを実行してください。

### オプション: 自動更新

GitHubで新しいバージョンが利用可能かどうかを定期的にチェックし、必要なファイル（Vencordのカスタムコードと`mute.sh`や`deafen.sh`などのローカルスクリプト）を更新する自動更新システムを有効にできます。

- `~/.vesktopCustomCommands/.config`での設定:
  - `auto_update="true|false"` (デフォルト: `false`)
  - `auto_update_interval` (デフォルト: `15m`) – 自動再パッチが有効な場合は`autorepatch_interval`で実行され、自動更新のみが有効な場合は`auto_update_interval`で実行されます。
- 自動更新を有効にする:
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/enable_autoupdate.sh)"
  ```
- 自動更新を無効にする:
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/disable_autoupdate.sh)"
  ```

## 手動インストール
1. リポジトリから`dist`フォルダーまたはその内容をダウンロードします。
2. `dist`は2つの部分に分かれています:
    - `vencord`フォルダーには、Vencordプリロードファイルに注入するファイルが含まれています。
    - `vesktopCustomCommands`フォルダーには、ミュート/スピーカーミュート用のスクリプトと`.config`ファイルが含まれています。
3. Vencordプリロードファイル（通常は`~/.config/Vencord/dist/vencordDesktopPreload.js`にあります）のバックアップを作成できます（`cp ~/.config/Vencord/dist/vencordDesktopPreload.js ~/.config/Vencord/dist/vencordDesktopPreload.js.bak`）。後で復元したい場合は、ファイルを削除してVesktopを起動すると再作成されます。
4. `vencordDesktopPreload_sample.js`の内容をVencordプリロードファイル（通常は`~/.config/Vencord/dist/vencordDesktopPreload.js`にあります）に注入します:
    - **ユニバーサルメソッド（すべてのVencordバージョンで動作）:** ファイルの最後にある`//# sourceURL=file:///VencordPreload`行の直前に`vencordDesktopPreload_sample.js`の全内容を挿入します。
    - **代替:** ファイル全体を提供された`vencordDesktopPreload.js`に置き換えます（*推奨されません。Vesktopの更新があった場合、VCCがそれ以降更新されていない場合、信頼性が低く、このファイルは古くなっている可能性があります*）。
5. Vencordパス（通常は`~/.config/Vencord/dist/`にあります）に`vesktopCustomCommands`ディレクトリを作成し、その中に`customCode.js`ファイルを配置します。
6. `~/.vesktopCustomCommands`ディレクトリを作成し、その中に`mute.sh`と`deafen.sh`ファイルを配置します。
7. `mute.sh`と`deafen.sh`スクリプトに権限を追加します:
    ```bash
    chmod +x ~/.vesktopCustomCommands/mute.sh
    chmod +x ~/.vesktopCustomCommands/deafen.sh
    ```
8. `.config`ファイルを`~/.vesktopCustomCommands`に配置し、必要に応じて`vencord_path`変数をVencordパスで更新します。
9. Vesktopを再起動して変更を適用します。
10. `~/.vesktopCustomCommands/`フォルダーにある`mute.sh`と`deafen.sh`スクリプトを呼び出すために、システムでカスタムグローバルショートカットを設定します。
    - 自分をミュートするための`mute.sh`。`~/.vesktopCustomCommands/mute.sh`
    - 自分をスピーカーミュートするための`deafen.sh`。`~/.vesktopCustomCommands/deafen.sh`
11. ミュートとスピーカーミュートの新しいグローバルショートカットをお楽しみください！

---

# アンインストール

## 自動アンインストール

ターミナルでこのコマンドを実行し、指示に従ってください:
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/uninstall.sh)"
```
アンインストール中に、設定（`~/.vesktopCustomCommands/.config`）を含むすべてを削除するかどうかを尋ねられます。
- "y"と答える: すべてのファイルと設定が削除されます。
- "n"と答える: プログラムファイルのみが削除され、`.config`は保持されます。

設定が削除された場合、自動再パッチサービス/タイマーと補助スクリプトも削除されます。自動アンインストールを拒否した場合は、以下の手動アンインストール手順に従ってください（同じ手順はスクリプトによっても表示されます）。

## 手動アンインストール

1. `~/.vesktopCustomCommands/`フォルダーにある`mute.sh`と`deafen.sh`スクリプトを呼び出すシステムのカスタムグローバルショートカットを削除します。
2. `~/.vesktopCustomCommands`の`.config`ファイルを削除します。
3. `~/.vesktopCustomCommands`フォルダーを削除します。
4. Vencordパス`~/.config/Vencord/dist/vesktopCustomCommands/`にある`customCode.js`ファイルを削除します。
5. Vencordパス`~/.config/Vencord/dist/`にある`vesktopCustomCommands`フォルダーを削除します。
6. Vencordプリロードファイル（通常は`~/.config/Vencord/dist/vencordDesktopPreload.js`にあります）の注入されたコードを削除するか、作成したバックアップがある場合はそれで置き換えます。（ファイルを削除してVesktopを起動して再作成することもできます）。
7. Vesktopを再起動して変更を適用します。

---

# 問題と改善

問題や改善の提案がある場合は、issueを開いてください！

# 貢献

このシステムが完璧ではなく、すべての標準とセマンティクスを尊重していないことは承知しています。そのため、このシステムの改善を手伝ってくれる方々に期待しています。issuesとpull requestsは開かれており、建設的な批判を歓迎します！

---

# このプロジェクトの主な目的の説明

私はX11上でKDE Neonを使用していたユーザーで、Discordは全体的にうまく機能していました。最近、Wayland上のKDE Neonに切り替えたところ、Discordに多くの問題があり、特に画面共有が不可能でした。Discordの問題を解決しようと探していたところ、Vesktopとそれに伴うVencordを発見し、それが解決したすべての問題と、X11ですでに抱えていた問題（画面共有中に音声を共有する可能性がまったくないなど）さえも発見しました。インストールしたところ、すべてが完璧でしたが、1つだけ小さな詳細がありました：グローバルキーボードショートカットのサポートの欠如です。唯一の可能性は、ウィンドウがアクティブな場合にのみ機能するデフォルトのDiscordショートカット（`Ctrl + Shift + M`と`Ctrl + Shift + D`）でした。そこで、Vesktopでショートカットを探し始め、問題は知られているが解決策はまだ見つかっていないこと、特にグローバルキーボードショートカットを作成しようとする開発者の生活を複雑にしているWaylandで、ということを読むことができました。諦めようと思いましたが、すべての優れた開発者と同様に、諦めることができなかったので、解決策を考え、一時的ではあるが堅牢な解決策を見つけました。不安定なシステムは望んでいなかったので、システムをできるだけシンプルで機能的にしようとしました。Vesktopをフォークして解決策を見つけたり、自分の解決策を統合するために懸命に働くこともできましたが、もうそのような野心も時間もなく、さらに、Vesktopでグローバルキーボードショートカットを望む人々のための代替リポジトリを作成することは真剣でも健全でもないと思います。そこで、公式のものの上に追加されるmodまたはaddonとして考えるのが理想的だと思いました。最終的にはVencord自体のように、興味のある人々が必要に応じて自分の側でインストールできるようにすることです。Vesktopがグローバルキーボードショートカットの解決策を見つけるまで、これで十分でしょう！

---

ありがとうございます :)



<!-- Made with ❤️ by NitramO -->
