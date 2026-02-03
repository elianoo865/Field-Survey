# Field Survey (Flutter Web + Android)

مشروع جاهز للاستبيانات الميدانية:

- تسجيل/دخول + أدوار (`admin` / `surveyor`)
- **Admin**: إنشاء/نشر/إلغاء نشر الاستبيانات + إضافة/تعديل/حذف الأسئلة في أي وقت (Soft Delete)
- **Admin**: تحديد Required لكل سؤال
- **Surveyor**: تعبئة استبيان لأشخاص متعددين
- **GPS إلزامي**: لا يمكن إرسال الاستبيان بدون موقع (lat/lng) محفوظ مع الاستجابة
- تتبع المُدخل: كل استجابة تتضمن `submittedByUid` + اسم المستخدم
- **Export XLSX** عبر Cloud Function (اختياري) + واجهة زر Export

## 0) أهم سبب لظهور صفحة بيضاء على GitHub Pages
90% من الحالات في Flutter Web على Pages تكون واحدة من هذه:

1) **Base href غلط** (لازم يكون نفس اسم الريبو)
2) **Service Worker Cache** (بيظل يعرض نسخة قديمة)
3) Firebase web config مو مركب (Firebase.initializeApp بيفشل)

هذا الإصدار:
- مضبوط على `--base-href "/Field-Survey/"` داخل GitHub Action
- فيه Splash HTML + Flutter Splash
- Firebase web config مدموج ضمن `lib/firebase_options.dart`

## 1) تشغيل محلي (Web)
```bash
flutter pub get
flutter run -d chrome
```

## 2) نشر على GitHub Pages (تلقائياً)
- ادخل إلى GitHub repo > **Settings** > **Pages**
- Source: اختار **GitHub Actions**
- اعمل push لأي تعديل، رح يشتغل workflow `deploy_pages.yml` وينشر على:
`https://<username>.github.io/Field-Survey/`

### إذا بقيت صفحة بيضاء (حل سريع)
- افتح DevTools > Application > Service Workers > **Unregister**
- بعده Hard Refresh (Ctrl+F5)

## 3) Firebase إعدادات
هذا المشروع مفعل لـ **Web + Android**.

### Web
الإعدادات موجودة في:
- `lib/firebase_options.dart`

### Android
لازم تحمل ملف `google-services.json` من Firebase Console وتحطه هنا:
- `android/app/google-services.json`

> ملاحظة: بدون هذا الملف، بناء Android ممكن يفشل.

## 4) إنشاء أول Admin
بعد تسجيل مستخدم عادي:
- Firestore Console > `users/{uid}`
- غيّر الحقل `role` إلى `admin`

## 5) Cloud Functions (اختياري للتصدير XLSX)
المجلد: `functions/`

خطوات عامة:
```bash
npm i -g firebase-tools
firebase login
firebase use harmony-project-42f2a
cd functions
npm install
firebase deploy --only functions
```

## 6) بنية البيانات (Firestore)
- `users/{uid}`: `{ name, email, role }`
- `surveys/{surveyId}`: `{ title, description, published, createdAt, updatedAt }`
- `surveys/{surveyId}/questions/{questionId}`: `{ type, title, required, options[], isDeleted }`
- `responses/{responseId}`: `{ surveyId, answers, location{lat,lng,acc?}, submittedByUid, submittedByName, createdAt }`

---

إذا بدك أضيف **Export XLSX بدون Cloud Functions** (توليد Excel من داخل التطبيق نفسه) قلّي.
