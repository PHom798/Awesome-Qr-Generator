# 🧭 Contributing Guidelines for Flutter QR Code Generator

Thank you for considering contributing to the **Flutter QR Code Generator App**! 🎉  
This document outlines the standards and process for contributing to maintain a clean, consistent, and professional codebase.

---

## 📘 Overview

This project is a Flutter-based application that allows users to generate and customize QR codes with various colors, styles, and formats using the [`pretty_qr_code`](https://pub.dev/packages/pretty_qr_code) package.

Our goal is to keep the codebase readable, efficient, and accessible for developers of all levels while maintaining production-ready quality.

---

## ⚙️ Development Setup

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (latest stable version)
- Dart 3.x or higher
- Android Studio / VS Code with Flutter plugin
- A GitHub account

### Setting up the project
```bash
git clone https://github.com/<your-username>/<repo-name>.git
cd <repo-name>
flutter pub get
```
Run the app:
```bash
flutter run
```

---

## 🧩 How to Contribute

### 1. Fork and Clone
Fork the repository to your account and clone it locally:
```bash
git clone https://github.com/<your-username>/<repo-name>.git
```

### 2. Create a New Branch
Use a meaningful branch name related to your change:
```bash
git checkout -b feature/add-color-picker
```
Branch naming convention:
- `feat/` – new features
- `fix/` – bug fixes
- `docs/` – documentation updates
- `refactor/` – code restructuring

### 3. Make Your Changes
Follow Flutter and Dart best practices. Run analysis and formatting before committing:
```bash
flutter analyze
flutter format .
```

### 4. Test Your Changes
Ensure your changes don’t break the existing functionality:
```bash
flutter test
```
If you’ve added new UI components, provide basic widget tests when applicable.

### 5. Commit Your Changes
Use clear and descriptive commit messages:
```bash
git add .
git commit -m "feat: add color customization for QR generation"
```

### 6. Push to Your Fork
```bash
git push origin feature/add-color-picker
```

### 7. Create a Pull Request
- Navigate to your fork on GitHub.
- Click **“Compare & pull request.”**
- Ensure the base branch is `main`.
- Provide a detailed description of what you changed and why.
- Add screenshots or recordings if relevant.

---

## 🧠 Code Style & Best Practices
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) style guidelines.
- Keep widgets modular and reusable.
- Avoid deeply nested widget trees; extract components into separate widgets.
- Use meaningful names for variables, functions, and classes.
- Prefer `const` constructors where possible.
- Do not include API keys, credentials, or secrets in commits.

---

## 🧪 Testing Guidelines
Before submitting a pull request:
```bash
flutter test
```
Include tests for new features or bug fixes where applicable.

---

## 🧹 Folder Structure
```
lib/
 ├─ main.dart
 ├─ screens/
 ├─ widgets/
 ├─ utils/
 └─ models/
```
Keep new files logically organized within these directories.

---

## 📋 Reporting Issues
If you find a bug or want to request a feature:
- Check existing [issues](../../issues) to avoid duplicates.
- Provide clear steps to reproduce or describe the enhancement.
- Include screenshots or logs if possible.

---

## 💬 Communication
- Use [GitHub Discussions](../../discussions) (if enabled) for general questions.
- Be respectful and constructive when giving feedback.

---

## ❤️ Acknowledgment
We appreciate your effort and time spent contributing to this project.  
Your contributions make open-source development better for everyone. 🌍

