import { Suspense } from "react"
import { notFound } from "next/navigation" // استيراد صفحة غير موجود لحل الخطأ بأمان
import { BreadcrumbTrail } from "@/components/breadcrumb-trail"
import { api } from "@/lib/api"
import { PostsListSkeleton } from "@/components/skeletons/post-list-skeleton"
import { PostsContent } from "@/components/posts/post-content"

async function CoursePostsSection({
  slug,
  courseId,
}: {
  slug: string
  courseId: number
}) {
  const posts = await api.dashboard.posts
    .byCourse(courseId, { page: 0, size: 20, sort: ["createdAt,desc"] })
    .catch((error) => {
      console.error("Failed to fetch posts in Server Component:", error)
      return null
    })

  return (
    <PostsContent
      orgSlug={slug}
      initialPosts={posts?.content ?? []}
      initialHasMore={
        (posts?.content?.length ?? 0) < (posts?.totalElements ?? 0)
      }
      courseId={courseId}
    />
  )
}

export default async function CoursePostsPage({
  params,
}: {
  params: Promise<{ slug: string; courseSlug: string }>
}) {
  const { slug, courseSlug } = await params
  const courses = await api.dashboard.organizations.courses
    .get(slug)
    .catch(() => [])

  const matchedCourse = courses.find(
    (c: { slug: string; id?: number }) =>
      c.slug === courseSlug || c.id?.toString() === courseSlug
  )

  if (!matchedCourse || typeof matchedCourse.id === "undefined") {
    notFound()
  }

  const courseId = matchedCourse.id

  console.log("CoursePostsPage: courseId", courseId)

  return (
    <>
      <BreadcrumbTrail
        items={[
          { label: "الدورات", href: `/${slug}/courses` },
          { label: "منشورات الدورة" },
        ]}
      />
      <Suspense fallback={<PostsListSkeleton />}>
        <CoursePostsSection slug={slug} courseId={courseId} />
      </Suspense>
    </>
  )
}
