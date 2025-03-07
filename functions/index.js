const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Existing private message notification
exports.sendMessageNotification = functions.firestore
  .document('messagesprivate/{messageId}')
  .onCreate(async (snap, context) => {
    try {
      const message = snap.data();
      if (!message) {
        console.error('No message data');
        return null;
      }

      // Validate required fields
      if (!message.receiverId || !message.senderId) {
        console.error('Missing receiverId/senderId');
        return null;
      }

      // Get receiver's FCM token
      const receiverDoc = await admin.firestore().collection('users').doc(message.receiverId).get();
      if (!receiverDoc.exists) {
        console.error('Receiver document not found');
        return null;
      }

      const token = receiverDoc.data()?.fcmToken;
      if (!token) {
        console.error('No FCM token for receiver');
        return null;
      }

      // Get sender's name safely
      const senderDoc = await admin.firestore().collection('users').doc(message.senderId).get();
      const senderName = senderDoc.exists ?
        (senderDoc.data()?.name || 'Anonymous') :
        'Anonymous';

      const payload = {
        notification: {
          title: `New message from ${senderName}`,
          body: message.messagepriv || '(No content)',
        },
        data: {
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
          senderId: message.senderId,
          type: 'message'
        },
        token: token
      };

      // Use send() instead of sendToDevice
      const response = await admin.messaging().send(payload);
      console.log('Successfully sent message:', response);
      return null;
    } catch (error) {
      console.error('Full error:', error);
      return null;
    }
  });

  exports.sendMentionNotification = functions.firestore
    .document('messages/{messageId}')
    .onCreate(async (snap, context) => {
      try {
        const message = snap.data();
        if (!message) return null;

        const mentionedIds = message.mentionedUserIds || [];
        if (mentionedIds.length === 0) return null;

        const senderName = message.senderName;
        const messageText = message.text;
        const messageId = snap.id;
        const senderId = message.senderId;
        const filteredIds = mentionedIds.filter(uid => uid !== senderId);

        await Promise.all(filteredIds.map(async (userId) => {
          // Create notification document first
          await admin.firestore().collection('notifications').add({
            'type': 'mention',
            'userId': userId,
            'senderId': senderId,
            'senderName': senderName,
            'messageText': messageText,
            'timestamp': admin.firestore.FieldValue.serverTimestamp(),
            'read': false,
            'messageId': messageId
          });

          // Then handle FCM notification
          const userDoc = await admin.firestore().collection('users').doc(userId).get();
          const token = userDoc.data()?.fcmToken;
          if (!token) return;

          const payload = {
            notification: {
              title: `@${senderName} mentioned you`,
              body: messageText.length > 100
                ? `${messageText.substring(0, 97)}...`
                : messageText,
            },
            data: {
              click_action: 'FLUTTER_NOTIFICATION_CLICK',
              type: 'public_mention',
              messageId: messageId,
              senderId: senderId
            },
            token: token
          };

          return admin.messaging().send(payload);
        }));

        return null;
      } catch (error) {
        console.error('Mention notification error:', error);
        return null;
      }
    });
