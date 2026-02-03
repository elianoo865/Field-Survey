# Deploy Flutter Web to GitHub Pages (with Firebase)

## 1) Create a Flutter project (one time)
From an empty folder (or your cloned repo):

```bash
flutter create --platforms=android,web .
```

Then copy this repo's files (`lib/`, `pubspec.yaml`, `firebase/`, `functions/`...) into the project root.

## 2) Firebase setup (required)
Generate real Firebase config:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This should generate/update `lib/firebase_options.dart` and wire web config.

## 3) Add authorized domain (VERY IMPORTANT)
In Firebase Console → Authentication → Settings → Authorized domains:
- Add: `<YOUR_GITHUB_USERNAME>.github.io`

If you use a custom domain, add it too.

## 4) Enable GitHub Pages
GitHub repo → Settings → Pages:
- Source: **Deploy from a branch**
- Branch: **gh-pages** / **root**

(After your first workflow run, `gh-pages` branch will appear automatically.)

## 5) Deploy
Push to `main` and GitHub Actions will:
- Build web with correct base path
- Publish to `gh-pages`

Your site URL will be:
`https://<YOUR_GITHUB_USERNAME>.github.io/<REPO_NAME>/`

## Notes
- GPS on web requires HTTPS (GitHub Pages is HTTPS).
- If you see auth errors, double-check the authorized domains.
