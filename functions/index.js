const functions = require("firebase-functions");
const admin = require("firebase-admin");
const ExcelJS = require("exceljs");
const { v4: uuidv4 } = require("uuid");

admin.initializeApp();

function storageBucket() {
  const b = admin.app().options.storageBucket;
  if (b) return b;
  // fallback: <project-id>.appspot.com
  const projectId = admin.app().options.projectId || process.env.GCLOUD_PROJECT;
  return `${projectId}.appspot.com`;
}

async function requireAdmin(context) {
  if (!context.auth) throw new functions.https.HttpsError("unauthenticated", "Not signed in");
  const uid = context.auth.uid;
  const userSnap = await admin.firestore().collection("users").doc(uid).get();
  const role = userSnap.exists ? userSnap.data().role : null;
  if (role !== "admin") {
    throw new functions.https.HttpsError("permission-denied", "Admin only");
  }
  return uid;
}

exports.exportSurveyXlsx = functions.https.onCall(async (data, context) => {
  await requireAdmin(context);
  const surveyId = data.surveyId;
  if (!surveyId) throw new functions.https.HttpsError("invalid-argument", "surveyId is required");

  const db = admin.firestore();

  const surveySnap = await db.collection("surveys").doc(surveyId).get();
  if (!surveySnap.exists) throw new functions.https.HttpsError("not-found", "survey not found");
  const survey = surveySnap.data();

  const qSnap = await db.collection("surveys").doc(surveyId).collection("questions").orderBy("order").get();
  const questions = qSnap.docs
    .map(d => ({ id: d.id, ...d.data() }))
    .filter(q => !q.isDeleted);

  // Fetch responses
  // NOTE: avoid `where + orderBy` composite index requirements by sorting locally.
  const rSnap = await db.collection("responses").where("surveyId", "==", surveyId).get();
  const responses = rSnap.docs.map(d => ({ id: d.id, ...d.data() }));
  responses.sort((a, b) => {
    const bt = b.enteredAt && b.enteredAt.toDate ? b.enteredAt.toDate().getTime() : 0;
    const at = a.enteredAt && a.enteredAt.toDate ? a.enteredAt.toDate().getTime() : 0;
    return bt - at;
  });

  const workbook = new ExcelJS.Workbook();
  const sheet = workbook.addWorksheet("Responses");

  // Columns: meta + each question by label
  const columns = [
    { header: "responseId", key: "responseId", width: 36 },
    { header: "enteredByName", key: "enteredByName", width: 20 },
    { header: "enteredByUid", key: "enteredByUid", width: 28 },
    { header: "enteredAt", key: "enteredAt", width: 22 },
    { header: "lat", key: "lat", width: 14 },
    { header: "lng", key: "lng", width: 14 },
    { header: "accuracy", key: "accuracy", width: 10 },
  ];

  for (const q of questions) {
    const label = (q.label || q.id).toString();
    columns.push({ header: label, key: `q_${q.id}`, width: 28 });
  }

  sheet.columns = columns;

  for (const r of responses) {
    const loc = r.location || {};
    const row = {
      responseId: r.id,
      enteredByName: r.enteredByName || "",
      enteredByUid: r.enteredByUid || "",
      enteredAt: r.enteredAt && r.enteredAt.toDate ? r.enteredAt.toDate().toISOString() : "",
      lat: loc.lat ?? "",
      lng: loc.lng ?? "",
      accuracy: loc.accuracy ?? "",
    };
    const ans = r.answers || {};
    for (const q of questions) {
      const v = ans[q.id];
      row[`q_${q.id}`] = Array.isArray(v) ? v.join(", ") : (v ?? "");
    }
    sheet.addRow(row);
  }

  const buffer = await workbook.xlsx.writeBuffer();

  // Upload to Firebase Storage and return a public download URL (token-based).
  const token = uuidv4();
  const filePath = `exports/${surveyId}/${Date.now()}_${token}.xlsx`;
  const bucketName = storageBucket();
  const bucket = admin.storage().bucket(bucketName);

  try {
    const file = bucket.file(filePath);
    await file.save(Buffer.from(buffer), {
      contentType: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      metadata: {
        metadata: {
          firebaseStorageDownloadTokens: token,
          surveyTitle: survey.title || "",
        }
      }
    });

    const encodedPath = encodeURIComponent(filePath);
    const url = `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/${encodedPath}?alt=media&token=${token}`;
    return { url };
  } catch (err) {
    // Common misconfig: Firebase Storage is not enabled for the project.
    const msg = (err && err.message) ? err.message : String(err);
    throw new functions.https.HttpsError(
      "failed-precondition",
      "تعذر حفظ ملف التصدير على Firebase Storage. تأكد من تفعيل Storage داخل Firebase Console ثم أعد المحاولة.\n\nتفاصيل: " + msg
    );
  }
});
