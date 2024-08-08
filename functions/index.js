const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendNotificationOnNewEvent = functions.firestore
  .document('events/{eventId}')
  .onCreate((snap, context) => {
    const newValue = snap.data();

    const message = {
      notification: {
        title: 'New Event Added',
        body: newValue.name,
      },
      topic: 'all',
    };

    return admin.messaging().send(message)
      .then((response) => {
        console.log('Successfully sent message:', response);
      })
      .catch((error) => {
        console.error('Error sending message:', error);
      });
  });
