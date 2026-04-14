import { Button } from "@/components/ui/button"

export default function Page() {
  return (
    <div className="flex min-h-svh p-6">
      <div className="flex max-w-md min-w-0 flex-col gap-4 text-sm leading-loose">
        <div>
          <h1 className="font-heading text-xl">المشروع جاهز!</h1>
          <p>يمكنك الآن إضافة المكونات والبدء في البناء.</p>
          <p>لقد قمنا بالفعل بإضافة مكوّن الزر لك.</p>
          <Button className="mt-2">اضغط هنا</Button>
        </div>
        <div className="font-mono text-xs text-muted-foreground">
          (اضغط على <kbd>d</kbd> لتبديل الوضع الداكن)
        </div>
      </div>
    </div>
  )
}
