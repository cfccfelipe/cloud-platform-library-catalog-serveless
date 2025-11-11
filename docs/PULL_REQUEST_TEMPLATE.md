# 📝 Pull Request Template Guide

This guide standardizes the structure and expectations for every Pull Request (PR) to ensure efficient reviews, high code quality, and clear traceability.

---

## 📌 Metadata & Purpose

| Aspect | Details |
| :--- | :--- |
| **Scope** | Code Reviews, CI/CD, Onboarding |
| **Audience** | Developers, Reviewers, Maintainers |
| **Purpose** | Ensure every PR is consistent, reducing friction and accelerating the merge process by outlining clear expectations. |
| **Mnemonic** | **T-D-C-S-I-R** (Title, Description, Checklist, Screenshots, Issues, Reviewer notes) |

---

## 🛠️ PR Template Structure

### 1. **Title**
* **Goal:** Clear, concise, and descriptive summary of the change.
* **Format:** `[Type] Short summary`
* **Example:** `[Feature] Add JWT authentication middleware`

### 2. **Description**
Provide comprehensive detail using structured headings.
* **Context:** Why is this change needed? (Link to the core problem.)
* **Implementation:** Briefly summarize what was changed (e.g., *Refactored login handler to use Strategy Pattern*).
* **Impact:** List affected systems or modules.
* **Testing:** How was this change verified? (e.g., *Local testing, new unit tests added*).

### 3. **Checklist**
All items must be checked before merging. This is the **validation layer** for quality control.

* [ ] Code follows [[Style Guide]] conventions
* [ ] Unit tests added/updated
* [ ] Documentation updated (README, ADR, etc.)
* [ ] Security considerations addressed
* [ ] CI/CD pipeline passes

### 4. **Screenshots / Logs (if applicable)**
* **Goal:** Provide visual or diagnostic proof for UI changes, complex logic, or debugging context.

### 5. **Linked Issues**
* **Goal:** Maintain traceability by referencing the source of the work.
* **Format:** Reference Issue IDs (e.g., `Closes #1234`, `Fixes JIRA-567`).

### 6. **Reviewer Notes**
* **Goal:** Highlight specific areas needing extra scrutiny.
* **Example:** *Please pay special attention to the concurrency lock used in the cache module and the Terraform policy changes.*

---

## ✅ Workflow Steps

1.  **Author:** Fills out the template completely before submitting the PR.
2.  **CI/CD:** Pipeline runs to validate automated checks (tests, linting).
3.  **Reviewer:** Checks against the checklist and the Reviewer Notes.
4.  **Merge:** Only occurs after all checklist boxes are ticked, the pipeline passes, and necessary approvals are granted.
