import Link from "next/link"
import { CheckCircle2, Sparkles, ArrowRight, Crown } from "lucide-react"

export default function PaymentSuccessPage() {
  return (
    <div className="flex min-h-[calc(100vh-64px)] items-center justify-center bg-gray-50 p-4 dark:bg-[#0a0a0a]">
      <div className="w-full max-w-[26rem] animate-in overflow-hidden rounded-3xl border border-gray-200 bg-white p-8 text-center shadow-2xl backdrop-blur-md duration-500 zoom-in-95 fade-in dark:border-gray-800 dark:bg-gray-900/60">
        <div className="relative mx-auto mb-6 flex h-24 w-24 items-center justify-center rounded-full bg-green-50 shadow-inner dark:bg-green-500/10 dark:shadow-green-900/20">
          <div className="absolute inset-0 animate-ping rounded-full bg-green-400/20 dark:bg-green-500/10"></div>
          <CheckCircle2 className="relative z-10 h-12 w-12 text-green-500 dark:text-green-400" />
          <Sparkles className="absolute -top-1 -right-2 h-6 w-6 animate-pulse text-amber-500" />
        </div>

        <h1 className="mb-2 font-heading text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
          تمت عملية الدفع بنجاح!
        </h1>

        <p className="mb-6 text-[15px] leading-relaxed text-gray-600 dark:text-gray-400">
          شكراً لاشتراكك. لقد تم ترقية حسابك وتفعيل كافة المزايا اللامحدودة.
          استمتع بتجربتك الجديدة!
        </p>

        <div className="mb-8 rounded-2xl border border-amber-200/50 bg-gradient-to-r from-amber-500/10 to-yellow-500/10 p-4 dark:border-amber-900/30">
          <div className="flex items-center justify-center gap-2">
            <Crown className="h-5 w-5 text-amber-600 dark:text-amber-500" />
            <span className="text-sm font-semibold text-amber-700 dark:text-amber-400">
              الخطة المميزة مفعلة الآن
            </span>
          </div>
        </div>

        <Link
          href="/"
          className="flex w-full items-center justify-center gap-2 rounded-xl bg-gray-900 px-5 py-3.5 text-[15px] font-bold text-white shadow-lg transition-all hover:bg-gray-800 hover:shadow-xl active:scale-[0.98] dark:bg-gray-100 dark:text-gray-900 dark:hover:bg-white"
        >
          <ArrowRight className="h-4 w-4 stroke-[3]" />
          العودة للرئيسية
        </Link>
      </div>
    </div>
  )
}
