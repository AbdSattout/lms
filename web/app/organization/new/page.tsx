import { CreateOrganizationForm } from "@/components/create-oragnization-form"
import Link from "next/link"

export default function NewOrganizationPage() {
  return (
    <div dir="rtl" className="mx-auto max-w-4xl p-8">
      <div className="mb-8">
        <div className="mb-2 flex items-center gap-4">
          <Link
            href="/organization"
            className="text-gray-500 hover:text-gray-900"
          >
            &rarr; عودة
          </Link>
          <h1 className="text-2xl font-bold">إعداد منظمة جديدة</h1>
        </div>
        <p className="text-gray-600">.يرجى إدخال تفاصيل المنظمة</p>
      </div>
      <div className="max-w-md rounded-xl border bg-white p-6 shadow-sm">
        <CreateOrganizationForm />
      </div>
    </div>
  )
}
