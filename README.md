# 做一休七 · 插畫與 OC 網站

這是一個不需要寫程式的個人網站：作品集、角色頁（可對話）、委託、商品、私人留言箱。
可以免費放在 GitHub Pages，留言與內容用免費的 Supabase 儲存。

> 先說清楚：**不設定 Supabase 也能先上線**（示範模式），但這樣留言只存在訪客自己的瀏覽器、
> 你的編輯也只存在你自己的電腦，**別人看不到你的修改，也收不到留言**。
> 要讓大家看到你的修改、並收到留言，請完成第二部分。

---

## 第一部分：放上 GitHub（約 10 分鐘）

1. 註冊／登入 [github.com](https://github.com)。
2. 右上角 **＋ → New repository**。
   - Repository name 取一個英文名字，例如 `my-oc-site`
   - 選 **Public**
   - 按 **Create repository**
3. 在新頁面按 **uploading an existing file**，把這個資料夾裡的**所有檔案**拖進去
   （`index.html`、`config.js`、所有 `.jpg` 圖片、`supabase.sql`、`README.md`、`.nojekyll`），
   最下面按 **Commit changes**。
   - 圖片要和 `index.html` 放在同一層；解壓縮後可直接把全部內容一起選取拖曳。
4. 上方 **Settings → Pages**：
   - Source 選 **Deploy from a branch**
   - Branch 選 **main**、資料夾選 **/(root)**，按 **Save**
5. 等 1～3 分鐘，重新整理這個設定頁，上方會出現你的網址：
   `https://你的帳號.github.io/my-oc-site/`
   這就是可以分享給任何人的公開網址。

網址打開後可以先逛逛。一般公開網址不會顯示編輯入口。
在尚未完成 Supabase 設定前，請直接用瀏覽器開啟電腦裡的 `index.html` 編輯；
公開網站會鎖住編輯模式，避免訪客誤以為可以修改網站。

---

## 第二部分：讓留言與內容真的存到雲端（約 15 分鐘，免費）

1. 到 [supabase.com](https://supabase.com) 註冊，按 **New project**（地區選 Tokyo 或 Singapore 比較近）。
2. 專案建好後，左邊 **SQL Editor → New query**：
   - 打開 `supabase.sql`，把裡面兩處 `你的信箱@example.com` 換成你自己的信箱
   - 全部貼上，按 **Run**
3. 左邊 **Authentication → Users → Add user → Create new user**：
   - 填你的信箱（要跟上一步一樣）和一組密碼，勾選 Auto Confirm User
4. **Authentication → Sign In / Providers**（或 Settings）：
   把 **Allow new users to sign up（允許新使用者註冊）關掉**。
   這一步很重要，不然陌生人也能註冊帳號。
5. 左邊 **Project Settings → API**，複製：
   - **Project URL**
   - **anon public key**（新版可能叫 publishable key）
6. 回到 GitHub 的 repository，點 `config.js` → 右上角鉛筆（Edit），貼上：
   ```js
   window.SITE_CONFIG = {
     url: "https://xxxx.supabase.co",
     key: "你的 anon key"
   };
   ```
   按 **Commit changes**，等 1～2 分鐘。
   （anon key 本來就是設計成可以公開的；真正的保護是第 2 步的權限設定。）

### 之後怎麼用
- 完成 Supabase 設定後，在網址後面加 `#edit` → 按「✎ 編輯網站」→ 用第 3 步的信箱密碼登入。
- 改完按上方的 **☁ 發布**，所有訪客就會看到新內容。
- **留言**分頁：看到訪客留言、按「待回覆」的對話就能回覆。
- 訪客只看得到**自己**的留言與你的回覆，看不到別人的。

### 留言隱私怎麼做到的
每位訪客的瀏覽器會產生一組隨機代碼，只有他知道。
留言資料表不開放任何人直接讀取，訪客只能「用自己的代碼」讀自己的對話；
只有你（指定信箱登入後）能看到全部留言。每位訪客每小時最多送 10 則，避免洗版。

---

## 常見問題
- **改了 config.js 沒反應？** 等 1～2 分鐘，並用 Ctrl+F5 強制重新整理。
- **忘記密碼？** Supabase → Authentication → Users 可以重設。
- **想要新留言通知到信箱？** 之後可以加 Supabase 的 Database Webhook / Edge Function，需要的話再跟我說。
- **圖片很多會不會爆？** 上傳的圖會自動縮到 900px，個人網站通常綽綽有餘；免費額度為資料庫 500MB。
- **換電腦編輯？** 登入後會從雲端載入最新發布的版本。注意：未發布的草稿只存在原本那台電腦。
