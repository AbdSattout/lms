import Link from "next/link"
import { ArrowRight } from "lucide-react"
import { getUserSubscriptionStatus } from "@/lib/actions/billing"
import PaymentCards from "@/components/cards/payment-card"

export default async function PaymentPage() {
  const { user } = await getUserSubscriptionStatus()
  const isPremium = user?.plan?.premium ?? false

  return (
    <div className="flex min-h-[calc(100vh-64px)] flex-col bg-gray-50 md:justify-center md:py-8 dark:bg-[#0a0a0a]">
      <div className="w-full">
        <div className="mx-auto w-full max-w-[900px] px-4 pt-4 pb-3 lg:pb-4">
          <Link
            href="/"
            className="inline-flex w-fit items-center gap-2 rounded-[0.75rem] border border-gray-200/60 bg-gray-200/50 px-4 py-2 text-[13px] font-semibold text-gray-700 shadow-sm backdrop-blur-md transition-colors hover:bg-gray-200/80 dark:border-gray-800/40 dark:bg-gray-900/60 dark:text-gray-300 dark:hover:bg-gray-800"
          >
            <ArrowRight className="h-[14px] w-[14px] stroke-[3]" />
            العودة للرئيسية
          </Link>
        </div>
        <div className="mx-auto w-full max-w-2xl px-4 pb-5 text-center lg:pb-6">
          <h1 className="mb-2 font-heading text-3xl font-bold tracking-tight text-gray-900 md:text-4xl dark:text-white">
            اختر خطتك
          </h1>
          <p className="text-sm text-gray-600 dark:text-gray-400">
            {isPremium
              ? "أنت مشترك في الخطة المميزة - استمتع بكل المزايا غير المحدودة!"
              : "أطلق العنان لإمكانياتك الكاملة في التعلم واكتشف مستويات جديدة من الإبداع"}
          </p>
        </div>

        <PaymentCards initialUser={user} />
      </div>
    </div>
  )
}
