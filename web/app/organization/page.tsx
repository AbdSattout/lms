import { api } from "@/lib/api"
import Link from "next/link"

export default async function OrganizationsPage() {
  const organizations = await api.organizations.list.get()

  return (
    <div dir="rtl" className="p-8">
      <h1 className="mb-6 text-2xl font-bold">منظماتي</h1>

      <div className="grid grid-cols-1 gap-6 md:grid-cols-3">
        <Link
          href="/organization/new"
          className="flex flex-col items-center justify-center rounded-xl border-2 border-dashed border-gray-300 p-8 text-center transition hover:bg-gray-50"
        >
          <div className="mb-4 rounded-full bg-blue-50 p-4 text-2xl text-blue-500">
            +
          </div>
          <h3 className="font-bold">إنشاء أو انضمام</h3>
          <p className="text-sm text-gray-500">
            قم بإضافة مؤسسة جديدة لإدارة محتواك التعليمي
          </p>
        </Link>

        {organizations.map((org) => (
          <div key={org.slug} className="rounded-xl border p-6 shadow-sm">
            <h3 className="mb-2 text-lg font-bold">{org.name}</h3>
            <p className="mb-4 text-sm text-gray-600">{org.description}</p>
            <Link
              href={`/dashboard/${org.slug}`}
              className="block w-full rounded-lg bg-blue-100 py-2 text-center text-blue-700 hover:bg-blue-200"
            >
              فتح
            </Link>
          </div>
        ))}
      </div>
    </div>
  )
}
