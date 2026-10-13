# Beijing Air Quality Project

## 📘 Team Collaboration Guide

This repository contains the R project files and datasets for our group assignment. Follow the steps below to set up your environment and collaborate effectively.

---

## 1. Install Required Tools

### Git
- Download Git: [https://git-scm.com/downloads](https://git-scm.com/downloads)
- After installation, check with:
  ```bash
  git --version
  ```

### GPG (GNU Privacy Guard)
- Windows users: install Gpg4win from [https://www.gpg4win.org/download.html](https://www.gpg4win.org/download.html)
- Check installation:
  ```bash
  gpg --version
  ```

### GitHub
- Register an account at [https://github.com](https://github.com)
- Share your GitHub username with the project owner to be added as a collaborator.

### RStudio
- Download RStudio: [https://posit.co/download/rstudio-desktop/](https://posit.co/download/rstudio-desktop/)
- This will allow you to open and work with `.Rproj` files.

---

## 2. Configure Git

Set your name and email (use the same email linked to your GitHub account):

```bash
git config --global user.name "Your Name"
git config --global user.email "your_email@example.com"
```

---

## 3. Generate and Configure GPG Key

1. Generate a new key:
   ```bash
   gpg --full-generate-key
   ```
   - Select RSA and RSA
   - Enter `4096` for key size
   - Use your GitHub email
   - Set a secure passphrase

2. List your keys:
   ```bash
   gpg --list-secret-keys --keyid-format LONG
   ```
   - Copy the long key ID (e.g., `1BE609DA53B931AF`).

3. Configure Git to use your key:
   ```bash
   git config --global user.signingkey 1BE609DA53B931AF
   git config --global gpg.program "C:/Program Files (x86)/GnuPG/bin/gpg.exe"
   ```

4. Export your public key and add it to GitHub:
   ```bash
   gpg --armor --export 1BE609DA53B931AF
   ```
   - Copy the output
   - Go to GitHub → Settings → SSH and GPG keys → New GPG key → Paste and save

---

## 4. Clone the Repository

```bash
git clone https://github.com/Caroline3599/Beijing_AirQuality.git
cd Beijing_AirQuality
```

Open the project in RStudio:
- `File` → `Open Project` → Select `Beijing_AirQuality.Rproj`

---

## 5. Collaboration Workflow

1. Create a branch for your work:
   ```bash
   git checkout -b your_branch_name
   ```
2. Make changes in RStudio.
3. Commit with GPG signature:
   ```bash
   git add .
   git commit -S -m "Describe your changes"
   ```
4. Push your branch:
   ```bash
   git push origin your_branch_name
   ```
5. Open a Pull Request on GitHub:
   - Go to the repository page
   - Click **Compare & pull request**
   - Ensure `base = main`, `compare = your_branch_name`
   - Add a description → Submit the pull request
   - The project owner will review and merge

---

## 6. Best Practices

- Do not commit directly to `main`. Always use branches.
- Keep your local repository updated:
  ```bash
  git checkout main
  git pull origin main
  ```
- Write clear commit messages describing your changes.
- Use GPG signing (`-S`) for all commits to ensure authenticity.

✅ With these steps, every team member can install Git, GPG, and RStudio, configure GitHub, and collaborate on the same R project using branches and pull requests.