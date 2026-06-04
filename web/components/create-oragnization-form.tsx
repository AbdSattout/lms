"use client"

import { useActionState } from "react"
import { createOrganization } from "@/actions/organization"

export function CreateOrganizationForm() {
  const [state, formAction, isPending] = useActionState(createOrganization, {
    error: "",
  })
  return (
    <form
      action={formAction}
      dir="rtl"
      className="flex max-w-md flex-col gap-4"
    >
      {state.error && <p className="text-sm text-red-500">{state.error}</p>}
      <div className="flex flex-col gap-1">
        <label htmlFor="name">اسم المنظمة</label>
        <input
          id="name"
          name="name"
          type="text"
          required
          disabled={isPending}
          className="rounded border p-2"
        />
      </div>

      <div className="flex flex-col gap-1">
        <label htmlFor="description">الوصف</label>
        <textarea
          id="description"
          name="description"
          required
          disabled={isPending}
          className="rounded border p-2"
        />
      </div>

      <div className="flex flex-col gap-1">
        <label htmlFor="visibility">حالة الظهور</label>
        <select
          id="visibility"
          name="visibility"
          defaultValue="PUBLIC"
          disabled={isPending}
          className="rounded border p-2"
        >
          <option value="PUBLIC">عام</option>
          <option value="PRIVATE">خاص</option>
        </select>
      </div>

      <div className="flex flex-col gap-1">
        <label htmlFor="image">شعار المنظمة</label>
        <input
          id="image"
          name="image"
          type="file"
          accept="image/*"
          disabled={isPending}
        />
      </div>

      <button
        type="submit"
        disabled={isPending}
        className="mt-2 rounded bg-blue-600 p-2 text-white disabled:bg-gray-400"
      >
        {isPending ? "جاري الإنشاء..." : "إنشاء المنظمة"}
      </button>
    </form>
  )
}
