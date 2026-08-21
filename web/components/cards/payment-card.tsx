"use client"

import { useState } from "react"
import type { LucideIcon } from "lucide-react"
import {
  Crown,
  Check,
  Zap,
  BookOpen,
  Route,
  Shuffle,
  Building2,
  GraduationCap,
  HardDrive,
  Star,
  Loader2,
  AlertCircle,
} from "lucide-react"
import {
  createCheckoutSession,
  createPortalSession,
  revokeSubscription,
  getUserSubscriptionStatus,
} from "@/lib/actions/billing"
import type { User } from "@/lib/api/types"

export default function PaymentCards({
  initialUser,
}: {
  initialUser: User | null
}) {
  const [user, setUser] = useState<User | null>(initialUser)

  const [loading, setLoading] = useState(false)
  const [showRevokeConfirm, setShowRevokeConfirm] = useState(false)
  const [revokeLoading, setRevokeLoading] = useState(false)
  const [revokeError, setRevokeError] = useState<string | null>(null)

  const isPremium = user?.plan?.premium ?? false

  const handleUpgrade = async () => {
    try {
      setLoading(true)
      const { checkoutUrl, error } = await createCheckoutSession()
      if (error) return console.error(error)
      if (checkoutUrl) window.location.href = checkoutUrl
    } catch (error) {
      console.error("Checkout error:", error)
    } finally {
      setLoading(false)
    }
  }

  const handleManageSubscription = async () => {
    try {
      setLoading(true)
      const { customerPortalUrl, error } = await createPortalSession()
      if (error) return console.error(error)
      if (customerPortalUrl) window.location.href = customerPortalUrl
    } catch (error) {
      console.error("Portal error:", error)
    } finally {
      setLoading(false)
    }
  }

  const handleRevokeSubscription = async () => {
    try {
      setRevokeLoading(true)
      setRevokeError(null)
      const { success, error } = await revokeSubscription()
      if (error) return setRevokeError(error)

      if (success) {
        const { user } = await getUserSubscriptionStatus()
        setUser(user)
        setShowRevokeConfirm(false)
      }
    } catch {
      setRevokeError("حدث خطأ غير متوقع")
    } finally {
      setRevokeLoading(false)
    }
  }

  const formatBytes = (bytes: number) => {
    if (bytes === 0) return "0 MB"
    const mb = bytes / (1024 * 1024)
    return mb >= 1000 ? `${(mb / 1000).toFixed(1)} GB` : `${mb} MB`
  }

  return (
    <div className="mx-auto w-full max-w-[900px] px-4">
      <div className="grid grid-cols-1 items-stretch gap-6 md:grid-cols-2 lg:gap-8">
        {/* Compressed Structure: Free Plan */}
        <div
          className={`flex flex-col rounded-[1.25rem] border border-gray-200 bg-white p-5 shadow-sm transition-all sm:p-6 dark:border-gray-800 dark:bg-gray-900/40 ${
            isPremium
              ? "opacity-60 saturate-50 hover:opacity-100 hover:saturate-100"
              : ""
          }`}
        >
          <div>
            <h2 className="font-heading text-xl font-bold text-gray-900 md:text-2xl dark:text-white">
              الخطة المجانية
            </h2>
            <p className="mt-1 text-[11px] leading-tight text-gray-500 sm:text-[13px] dark:text-gray-400">
              مثالية لتجربة المنصة واستكشاف ميزاتها الأساسية مع بعض القيود.
            </p>
          </div>

          <div className="my-5">
            <span className="text-3xl font-extrabold text-gray-900 md:text-4xl dark:text-white">
              مجاناً
            </span>
          </div>

          <button
            disabled
            className="w-full rounded-xl bg-gray-100 py-2 text-sm font-semibold text-gray-500 shadow-inner transition-colors dark:bg-gray-800/80 dark:text-gray-400"
          >
            {isPremium ? "غير نشطة حالياً" : "خطتك الحالية"}
          </button>

          <hr className="my-5 border-gray-100 dark:border-gray-800/80" />

          <div className="flex-1 space-y-[10px]">
            <FeatureItem
              icon={Zap}
              text="10 استخدامات للذكاء الاصطناعي يومياً"
            />
            <FeatureItem
              icon={BookOpen}
              text="2 اختبار ذكاء اصطناعي أسبوعياً"
            />
            <FeatureItem
              icon={GraduationCap}
              text="2 تسجيل في الدورات أسبوعياً"
            />
            <FeatureItem icon={Route} text="متابعة خريطة تعليمية واحدة" />
            <FeatureItem
              icon={Shuffle}
              text="اختبار عشوائي واحد لكل دورة كل 7 أيام"
            />
            <FeatureItem icon={Building2} text="منظمة واحدة" />
            <FeatureItem icon={BookOpen} text="3 دورات في المنظمة" />
            <FeatureItem
              icon={HardDrive}
              text={`${formatBytes(104857600)} مساحة تخزين`}
            />
            <FeatureItem icon={Star} text="1.00x مضاعف نقاط الخبرة" />
          </div>
        </div>

        <div
          className={`relative flex flex-col rounded-[1.25rem] border-[1.5px] p-5 shadow-lg transition-all sm:p-6 ${
            isPremium
              ? "border-green-500 bg-gradient-to-b from-green-50/50 to-emerald-50/50 dark:border-green-600/70 dark:from-green-950/10 dark:to-emerald-950/10"
              : "border-amber-500 bg-gradient-to-b from-amber-50/50 to-yellow-50/50 dark:from-amber-950/10 dark:to-yellow-950/10"
          }`}
        >
          {isPremium ? (
            <div className="absolute inset-x-0 -top-[14px] mx-auto flex w-max items-center justify-center rounded-full bg-gradient-to-r from-green-500 to-emerald-500 px-4 py-[3px] text-[11px] font-bold tracking-wide text-white shadow-md sm:text-xs">
              مفعلة ✓
            </div>
          ) : (
            <div className="absolute inset-x-0 -top-[14px] mx-auto flex w-max items-center justify-center rounded-full bg-gradient-to-r from-amber-500 to-yellow-500 px-4 py-[3px] text-[11px] font-bold tracking-wide text-white shadow-md sm:text-xs">
              موصى بها
            </div>
          )}

          <div>
            <h2 className="flex items-center gap-1.5 font-heading text-xl font-bold text-gray-900 md:text-2xl dark:text-white">
              <Crown
                className={`h-5 w-5 ${isPremium ? "text-green-500" : "text-amber-500"}`}
              />
              الخطة المميزة
            </h2>
            <p className="mt-1 text-[11px] leading-tight text-gray-500 sm:text-[13px] dark:text-gray-400">
              الخيار الأمثل للمتعلمين النشطين، صُناع المحتوى وأصحاب المنظمات.
            </p>
          </div>

          <div className="my-5 flex items-baseline">
            <span className="text-3xl font-extrabold text-gray-900 md:text-4xl dark:text-white">
              $5.00
            </span>
            <span className="ms-1.5 text-sm font-medium text-gray-500 dark:text-gray-400">
              /شهرياً
            </span>
          </div>

          <div className="space-y-2.5">
            {isPremium ? (
              <>
                <button
                  onClick={handleManageSubscription}
                  disabled={loading}
                  className="w-full rounded-xl bg-gradient-to-r from-green-500 to-emerald-500 py-[9px] text-[13px] font-bold tracking-wide text-white shadow transition-all hover:scale-[1.01] hover:shadow-lg active:scale-[0.98] disabled:pointer-events-none disabled:opacity-50"
                >
                  {loading ? (
                    <span className="flex items-center justify-center gap-1.5">
                      <Loader2 className="h-4 w-4 animate-spin" /> جاري
                      التحميل...
                    </span>
                  ) : (
                    "إدارة الاشتراك"
                  )}
                </button>
                <button
                  onClick={() => setShowRevokeConfirm(true)}
                  disabled={loading}
                  className="w-full rounded-xl border border-red-200/60 bg-transparent py-2 text-xs font-semibold text-red-600 transition-all hover:bg-red-50 disabled:pointer-events-none disabled:opacity-50 dark:border-red-900/30 dark:hover:bg-red-950/20"
                >
                  إلغاء الاشتراك
                </button>
              </>
            ) : (
              <button
                onClick={handleUpgrade}
                disabled={loading}
                className="w-full rounded-xl bg-gradient-to-r from-amber-500 to-yellow-500 py-[9px] text-[13px] font-bold tracking-wide text-white shadow transition-all hover:scale-[1.01] hover:shadow-lg active:scale-[0.98] disabled:pointer-events-none disabled:opacity-50"
              >
                {loading ? (
                  <span className="flex items-center justify-center gap-1.5">
                    <Loader2 className="h-4 w-4 animate-spin" /> جاري التحميل...
                  </span>
                ) : (
                  "اشترك في المميزة"
                )}
              </button>
            )}
          </div>

          <hr
            className={`my-5 ${
              isPremium
                ? "border-green-200/60 dark:border-green-800/40"
                : "border-amber-200/60 dark:border-amber-800/40"
            }`}
          />

          <div className="flex-1 space-y-[10px]">
            <FeatureItem
              icon={Zap}
              text="استخدام غير محدود للذكاء الاصطناعي"
              premium
              isActive={isPremium}
            />
            <FeatureItem
              icon={BookOpen}
              text="إنشاء غير محدود لاختبارات الذكاء الاصطناعي"
              premium
              isActive={isPremium}
            />
            <FeatureItem
              icon={GraduationCap}
              text="تسجيل غير محدود في الدورات"
              premium
              isActive={isPremium}
            />
            <FeatureItem
              icon={Route}
              text="متابعة غير محدودة للخرائط التعليمية"
              premium
              isActive={isPremium}
            />
            <FeatureItem
              icon={Shuffle}
              text="اختبارات عشوائية غير محدودة لكل دورة"
              premium
              isActive={isPremium}
            />
            <FeatureItem
              icon={Building2}
              text="منظمات غير محدودة"
              premium
              isActive={isPremium}
            />
            <FeatureItem
              icon={BookOpen}
              text="دورات غير محدودة في المنظمة"
              premium
              isActive={isPremium}
            />
            <FeatureItem
              icon={HardDrive}
              text="مساحة تخزين غير محدودة"
              premium
              isActive={isPremium}
            />
            <FeatureItem
              icon={Star}
              text="1.20x مضاعف نقاط الخبرة"
              premium
              isActive={isPremium}
            />
          </div>
        </div>
      </div>

      {showRevokeConfirm && (
        <div className="fixed inset-0 z-50 flex animate-in items-center justify-center bg-black/60 p-4 backdrop-blur-sm duration-200 fade-in">
          <div className="w-full max-w-[28rem] overflow-hidden rounded-3xl bg-white shadow-2xl transition-all dark:bg-gray-900">
            <div className="flex flex-col items-center gap-4 border-b border-gray-100 p-6 pt-7 text-center dark:border-gray-800">
              <div className="rounded-full bg-red-100 p-3 shadow-inner dark:bg-red-500/10">
                <AlertCircle className="h-7 w-7 text-red-600 dark:text-red-400" />
              </div>
              <h3 className="font-heading text-lg font-bold text-gray-900 dark:text-white">
                تأكيد إلغاء الاشتراك
              </h3>
            </div>

            <div className="p-5">
              <div className="space-y-4 text-center text-sm text-gray-600 sm:text-start dark:text-gray-400">
                <p>هل أنت متأكد من رغبتك في الإلغاء؟</p>
                <div className="rounded-xl border border-red-100 bg-red-50 p-4 text-[13px] leading-relaxed text-red-600 dark:border-red-900/30 dark:bg-red-500/10 dark:text-red-400">
                  <p className="mb-1 flex items-center gap-1.5 font-semibold">
                    ⚠️ تنبيه هام:
                  </p>
                  <p>
                    لن يتم استرداد المبلغ المدفوع. سيتم إلغاء خطتك المميزة فوراً
                    وستفقد جميع المزايا و العضويات المتصلة بها في نفس الوقت.
                  </p>
                </div>
              </div>

              {revokeError && (
                <div className="mt-4 rounded-xl border border-red-200 bg-red-50 p-2.5 text-center text-xs font-medium text-red-600 dark:border-red-900/50 dark:bg-red-900/20 dark:text-red-400">
                  {revokeError}
                </div>
              )}

              <div className="mt-7 flex flex-col gap-2.5 sm:flex-row">
                <button
                  onClick={() => {
                    setShowRevokeConfirm(false)
                    setRevokeError(null)
                  }}
                  disabled={revokeLoading}
                  className="flex-1 rounded-xl bg-gray-100 px-4 py-2.5 text-sm font-semibold text-gray-700 transition-all hover:bg-gray-200 disabled:pointer-events-none disabled:opacity-50 dark:bg-gray-800 dark:text-gray-300 dark:hover:bg-gray-700"
                >
                  تراجع عن الإلغاء
                </button>
                <button
                  onClick={handleRevokeSubscription}
                  disabled={revokeLoading}
                  className="flex-1 rounded-xl bg-red-600 px-4 py-2.5 text-sm font-semibold text-white shadow-md shadow-red-600/20 transition-all hover:bg-red-700 hover:shadow-red-700/30 active:scale-[0.98] disabled:pointer-events-none disabled:opacity-50"
                >
                  {revokeLoading ? (
                    <span className="flex items-center justify-center gap-1.5">
                      <Loader2 className="h-4 w-4 animate-spin" /> تنفيذ
                      الإلغاء...
                    </span>
                  ) : (
                    "الموافقة و الحذف"
                  )}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

function FeatureItem({
  icon: Icon,
  text,
  premium = false,
  isActive = false,
}: {
  icon: LucideIcon
  text: string
  premium?: boolean
  isActive?: boolean
}) {
  const checkBg = premium
    ? isActive
      ? "bg-green-100/80 text-green-600 dark:bg-green-900/40 dark:text-green-400"
      : "bg-amber-100/80 text-amber-600 dark:bg-amber-900/40 dark:text-amber-400"
    : "bg-gray-100/80 text-gray-500 dark:bg-gray-800/50 dark:text-gray-400"

  const iconColor = premium
    ? isActive
      ? "text-green-500 dark:text-green-400"
      : "text-amber-500 dark:text-amber-400"
    : "text-gray-400 dark:text-gray-500"

  return (
    <div className="flex items-center gap-[9px]">
      <div
        className={`flex shrink-0 items-center justify-center rounded-full p-[3px] shadow-sm ${checkBg}`}
      >
        <Check className="h-3 w-3 stroke-[3.5]" />
      </div>
      <div className="flex min-w-0 flex-1 items-center gap-[6px]">
        <Icon className={`h-3.5 w-3.5 shrink-0 ${iconColor}`} />
        <span className="text-xs leading-none font-semibold tracking-wide text-gray-600 dark:text-gray-300">
          {text}
        </span>
      </div>
    </div>
  )
}
