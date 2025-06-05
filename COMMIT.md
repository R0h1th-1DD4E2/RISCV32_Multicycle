---

## 📝 Git Commit Message Template Setup

This project uses a standardized commit message format for clarity and consistency. Follow the steps below to set it up in your local repository.

---

### 📦 One-time setup (after cloning)

Run this from the root of the repository:

```bash
git config commit.template .gitmessage.txt
```

This ensures that every time you run:

```bash
git commit
```

Git will open your editor with a commit message template pre-filled from `.gitmessage.txt`.

---

### ✍️ How to use it

1. Run `git commit` (without `-m`)

2. Your editor opens with a template like this:

   ```text
   # <type>: <short summary>
   #
   # Example: feat: add pipeline support to ALU module
   #
   # Write a short summary (max 50 characters)
   #
   # Detailed description:
   # - What changed?
   # - Why it changed?
   # - Side effects or TODOs?
   #
   ```

3. Edit the file:

   * Replace `<type>` with one of the commit types below
   * Write your summary and description
   * Save and close to finish the commit

---

### ✅ Example Commit

```text
fix: correct overflow flag in ALU subtraction

Previously, the ALU did not set the overflow flag correctly
when subtracting large positive and negative numbers.

Added a regression test in alu_tb.v.

Fixes: #17
```

---

### 💡 Pro Tip: Common Commit Types for `<type>`

| Type       | Purpose                                 |
| ---------- | --------------------------------------- |
| `feat`     | A new feature                           |
| `fix`      | A bug fix                               |
| `docs`     | Documentation-only changes              |
| `style`    | Formatting, missing semicolons, etc.    |
| `refactor` | Code change that isn't a bug or feature |
| `test`     | Adding or fixing tests                  |
| `chore`    | Build process, tooling, config, etc.    |

Stick to these types to keep the commit history clean and understandable! ✅

---

🔧 Change Your Default Git Editor

If you prefer to use a specific text editor for commit messages, you can change the default editor for Git using the following commands:

For Vim (default on many systems):
```
git config --global core.editor "vim"
```

For Nano:
```
git config --global core.editor "nano"
```

For Visual Studio Code:
```
git config --global core.editor "code --wait"

For Visual Studio Code:
```
git config --global core.editor "notepad"

```


---
