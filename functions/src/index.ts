import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {WebhookClient} from "dialogflow-fulfillment";

admin.initializeApp();
const db = admin.firestore();

export const Webhook = functions.https.onRequest((request, response) => {
  const agent = new WebhookClient({request, response});

  /**
   * Handles the "Get Event Details" intent.
   * @param {WebhookClient} agent - The Dialogflow agent.
   */
  async function getEventDetails(agent: WebhookClient) {
    const eventName = agent.parameters.eventName;

    try {
      const Ref = db.collection("events").where("eventName", "==", eventName);
      const snapshot = await Ref.get();

      if (snapshot.empty) {
        agent.add(`Sorry, I couldn't find any event named ${eventName}.`);
        return;
      }

      const eventData = snapshot.docs[0].data();
      const eventDetails = `
        Event Name: ${eventData.eventName}
        Date: ${eventData.eventDate}
        Time: ${eventData.eventTime}
        Venue: ${eventData.eventLocation}
        Price: ${eventData.eventPrice}
      `;

      agent.add(eventDetails);
    } catch (error) {
      console.error("Error fetching event details:", error);
      agent.add("Sorry, there was an error fetching the event details.");
    }
  }

  const intentMap = new Map<string, (agent:WebhookClient) => void>();
  intentMap.set("Get Event Details", getEventDetails);
  agent.handleRequest(intentMap);
});

export const sendNotificationOnNewEvent = functions.firestore
  .document("events/{eventId}")
  .onCreate((snap) => {
    const newValue = snap.data();
    const message = {
      notification: {
        title: "New Event Added",
        body: newValue?.name || "No name",
      },
      topic: "all",
    };

    return admin.messaging().send(message)
      .then((response) => {
        console.log("Successfully sent message:", response);
      })
      .catch((error) => {
        console.error("Error sending message:", error);
      });
  });
