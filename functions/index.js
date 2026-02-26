const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendComplaintStatusNotification = functions.firestore
  .document('complaints/{complaintId}')
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const oldData = change.before.data();

    if (newData.status !== oldData.status) {
      const userId = newData.userId;
      
      try {
        const userDoc = await admin.firestore().collection('users').doc(userId).get();
        
        if (!userDoc.exists) {
          console.log('User document not found for userId:', userId);
          return null;
        }

        const fcmToken = userDoc.data().fcmToken;

        if (!fcmToken) {
          console.log('No FCM token found for user:', userId);
          return null;
        }

        const message = {
          notification: {
            title: 'Complaint Status Updated',
            body: `Your complaint status has been updated to: ${newData.status}`,
          },
          data: {
            complaintId: context.params.complaintId,
            status: newData.status,
          },
          token: fcmToken,
        };

        try {
          await admin.messaging().send(message);
          console.log('Notification sent successfully');
        } catch (error) {
          if (error.code === 'messaging/invalid-registration-token' ||
              error.code === 'messaging/registration-token-not-registered') {
            console.log('Invalid FCM token, removing from user document');
            await admin.firestore().collection('users').doc(userId).update({
              fcmToken: admin.firestore.FieldValue.delete()
            });
          } else {
            throw error;
          }
        }
      } catch (error) {
        console.error('Error sending notification:', error);
      }
    }

    return null;
  });
