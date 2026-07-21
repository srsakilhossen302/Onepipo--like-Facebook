# macOS Disk Space Cleanup Guide for Flutter & iOS Developers
 
Ei guide-e details dewa holo kivabe macOS-e development caches clear kore space khali kora jay, jeno apnar disk space furiye gele apni nijei agulo clean korte paren.
 
---
 
## 1. iOS Simulator Data Clear (Most Effective)
Simulator-e test apps install kora, logs ebong cache files jome onek space noshto hoy.
 
**Command:**
```bash
xcrun simctl erase all
```
*   **Ki kaj kore:** Sob shutdown obosthay thaka simulator-er internal data, apps, ebong caches delete kore simulator gulo reset kore. Ete apnar kono project code ba configuration delete hobe na, shudhu simulator-er vitore thaka temp files clean hobe.
*   **Note:** Jodi space ekebarei shesh hoye jay (like < 100MB), tobe prothome system-er onno small files clean kore thora space banate hobe (e.g. `flutter clean`), tarpor ei command-ti successfully run hobe.
 
---
 
## 2. Xcode DerivedData Clean
Xcode jokhon app build kore, tokon onek temporary build artifacts joma kore rake.
 
**Command:**
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```
*   **Ki kaj kore:** Sob build artifacts delete kore dey. Porer bar run korar shomoy Xcode notun kore built assets generate kore nebe. Ete custom settings ba project-er kono loss hoy na.
 
---
 
## 3. Flutter Project Clean
Individual flutter project-er build caches delete korar jonno.
 
**Command:**
```bash
flutter clean
```
*   **Ki kaj kore:** Apnar project directories-er `build/` folder, `.dart_tool/`, and temporary build outputs delete kore. Substantially space bachay.
 
---
 
## 4. CocoaPods Cache Clean
iOS library dependency manager-er joma thaka cached packages remove korar jonno.
 
**Command:**
```bash
pod cache clean --all
```
*   **Ki kaj kore:** CocoaPods pod cache clear kore dey, jeno next `pod install` notun kore fetch kore download korte pare.
 
---
 
## 5. Quick Commands Checklist
Porobortite ekbare space khali korar jonno terminal-e ei commands sequence use korte paren:
 
```bash
# 1. Project level clean
flutter clean
 
# 2. Xcode Cache clean
rm -rf ~/Library/Developer/Xcode/DerivedData/*
 
# 3. CocoaPods Cache clean
pod cache clean --all
 
# 4. Erase Simulators data (to release GBs of space)
xcrun simctl erase all
```
 
---
 
## Disk Space Check korar Command:
Kono directory ba disk-er size dekhnar jonno terminal-e ei command gulo useful:
 
- **Free space check korar jonno:**
  ```bash
  df -h
  ```
- **Kono specific folder (e.g. home directory) er vitore kon folder koto space nicche ta dekhni:**
  ```bash
  du -sh ~/* 2>/dev/null
  ```
 