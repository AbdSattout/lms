"use server"

import { api } from "@/lib/api"

export async function createCheckoutSession() {
  try {
    const response = await api.billing.checkout.post()
    return {
      checkoutUrl: response.checkoutUrl,
      error: null,
    }
  } catch (error) {
    console.error("Checkout error:", error)
    return {
      checkoutUrl: null,
      error: "فشل في إنشاء جلسة الدفع",
    }
  }
}

export async function createPortalSession() {
  try {
    const response = await api.billing.portal.post()
    return {
      customerPortalUrl: response.customerPortalUrl,
      error: null,
    }
  } catch (error) {
    console.error("Portal error:", error)
    return {
      customerPortalUrl: null,
      error: "فشل في فتح بوابة الاشتراك",
    }
  }
}

export async function revokeSubscription() {
  try {
    await api.billing.revoke.post()
    return {
      success: true,
      error: null,
    }
  } catch (error) {
    console.error("Revoke error:", error)
    return {
      success: false,
      error: "فشل في إلغاء الاشتراك",
    }
  }
}

export async function getUserSubscriptionStatus() {
  try {
    const user = await api.users.me.get()
    return {
      user,
      error: null,
    }
  } catch (error) {
    console.error("Failed to fetch user:", error)
    return {
      user: null,
      error: "فشل في جلب بيانات المستخدم",
    }
  }
}
