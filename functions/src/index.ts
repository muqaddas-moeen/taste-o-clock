import { initializeApp } from "firebase-admin/app";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { logger } from "firebase-functions/v2";

initializeApp();

const STATUS_LABELS: Record<string, string> = {
  placed: "Order Placed",
  preparing: "Preparing",
  on_the_way: "On the Way",
  delivered: "Delivered",
};

interface OrderData {
  userId?: string;
  status?: string;
}

/**
 * Fires when an order document is updated (e.g. status changed in Firebase Console).
 * Creates an in-app notification and sends FCM to the customer's device.
 */
export const onOrderStatusChanged = onDocumentUpdated(
  "orders/{orderId}",
  async (event) => {
    const before = event.data?.before.data() as OrderData | undefined;
    const after = event.data?.after.data() as OrderData | undefined;

    if (!before || !after) {
      return;
    }

    const beforeStatus = before.status;
    const afterStatus = after.status;

    if (!afterStatus || beforeStatus === afterStatus) {
      return;
    }

    const userId = after.userId;
    const orderId = event.params.orderId;

    if (!userId) {
      logger.warn("Order status changed but userId is missing", { orderId });
      return;
    }

    const statusLabel = STATUS_LABELS[afterStatus] ?? afterStatus;
    const title = "Order Update";
    const body = `Your order is now: ${statusLabel}`;
    const shortOrderId =
      orderId.length > 8 ? orderId.substring(0, 8) : orderId;

    const db = getFirestore();
    const notificationRef = db.collection("notifications").doc();

    await notificationRef.set({
      userId,
      title,
      body: `${body} (#${shortOrderId})`,
      type: "order_status",
      orderId,
      isRead: false,
      createdAt: FieldValue.serverTimestamp(),
    });

    await event.data?.after.ref.update({
      updatedAt: FieldValue.serverTimestamp(),
    });

    const userDoc = await db.collection("users").doc(userId).get();
    const fcmToken = userDoc.data()?.fcmToken as string | undefined;

    if (!fcmToken) {
      logger.info("Notification saved; no FCM token for user", { userId, orderId });
      return;
    }

    try {
      await getMessaging().send({
        token: fcmToken,
        notification: {
          title,
          body: `${body} (#${shortOrderId})`,
        },
        data: {
          notificationId: notificationRef.id,
          orderId,
          type: "order_status",
          title,
          body: `${body} (#${shortOrderId})`,
        },
        android: {
          priority: "high",
          notification: {
            channelId: "taste_o_clock_updates",
          },
        },
      });

      logger.info("Order status notification sent", {
        orderId,
        userId,
        status: afterStatus,
      });
    } catch (error) {
      logger.error("Failed to send FCM message", {
        orderId,
        userId,
        error,
      });

      const invalidTokenCodes = new Set([
        "messaging/invalid-registration-token",
        "messaging/registration-token-not-registered",
      ]);

      const code =
        typeof error === "object" &&
        error !== null &&
        "code" in error &&
        typeof (error as { code?: string }).code === "string"
          ? (error as { code: string }).code
          : "";

      if (invalidTokenCodes.has(code)) {
        await db.collection("users").doc(userId).update({
          fcmToken: FieldValue.delete(),
          fcmTokenUpdatedAt: FieldValue.serverTimestamp(),
        });
      }
    }
  },
);
