# Team Git & GitHub Workflow (Beginner Step-by-Step)

  - Everything is done through GitHub Pull Requests.
  - Branches should represent **one small, complete task**
  -️ Do not push directly to `main`.

---

## 1 Clone the Team Repository (One Time)

```
cd ~/<DIRECTORY>
mkdir class_project
cd class_project
git clone <TEAM_REPO_URL>
cd <REPO_NAME>
```

---

## 2 Create Your Personal Work Branch

```
git checkout -b your-name/task-description
git push -u origin your-name/task-description
```

Example:
```
git checkout -b esther/add-eda-section
git push -u origin esther/add-eda-section
```

---

## 3 Start Working

Make changes to files normally.

---

## 4 Save Your Work to Git

```
git add <SPECIFIC FILES TO ADD>
git commit -m "Short description of changes"
git push
```

---

## 5 Open a Pull Request (PR)

1. Go to GitHub, then to your repo
2. Click **Pull Requests**
3. Click **New Pull Request**
4. Base branch: `main`
5. Compare branch: your personal branch
6. Click **Create Pull Request**
7. Title your PR clearly

---

## 6 Request Reviews

On the PR page:
  - Click **Reviewers**
  - Add:
    - At least 1 person NOT you
    - Anyone working on related code

---

## 7 Review Process

Reviewers will choose:
  - **Approve**
  - **Comment**
  - **Request Changes**

If changes are requested:

```
git add .
git commit -m "Updated after review"
git push
```

  - Keep Code reviews constructive.
  - All review comments must be addressed before merging. 
  - If commits are added after approval, a **re-review must be requested**.


---

## 8 Merge Only When Approved

After approval:

  - Click **Merge Pull Request**
  - Click **Confirm Merge**
  - Delete branch after merging (GitHub will suggest this)

---

## 9 Update Local Main After Merge

```
git checkout main
git pull
```

---

## 10 Start Next Task

Repeat from Step 2 for every new task.
