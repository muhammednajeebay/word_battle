import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

export const createMatch = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "User must be logged in");
    }

    const matchRef = admin.firestore().collection("matches").doc();
    await matchRef.set({
        hostId: context.auth.uid,
        status: "waiting",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        currentWord: "FLUTTER", // In real app, generate random word
        timeLeft: 60,
    });

    return { matchId: matchRef.id };
});

export const submitGuess = functions.firestore
    .document("matches/{matchId}/guesses/{guessId}")
    .onCreate(async (snapshot, context) => {
        const matchId = context.params.matchId;
        const guessData = snapshot.data();
        const matchRef = admin.firestore().collection("matches").doc(matchId);

        const matchDoc = await matchRef.get();
        const currentWord = matchDoc.data()?.currentWord;

        if (guessData.guess.toUpperCase().trim() === currentWord) {
            // Correct guess
            await matchRef.update({
                status: "finished",
                winnerId: guessData.playerId,
            });
        }
    });
