import { BreadcrumbTrail } from "@/components/breadcrumb-trail"

export default function PostPage() {
  return (
    <div>
      <BreadcrumbTrail items={[{ label: "المنشورات" }]} />
      <h1 className="text-2xl font-bold">منشورات</h1>
    </div>
  )
}
