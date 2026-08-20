import {
  BookOpen,
  CheckCircle2,
  MessageCircle,
  Route,
  Smartphone,
  Users,
} from "lucide-react"

import { LandingNavbar } from "@/components/landing/landing-nav"
import { HeroSection } from "@/components/landing/hero-section"
import { MasarPath } from "@/components/landing/masar-path"
import { ScrollReveal } from "@/components/landing/scroll-reveavl"

export function LandingPage() {
  return (
    <main
      dir="rtl"
      className="min-h-screen bg-background text-foreground select-none"
    >
      <div className="relative flex flex-col overflow-hidden">
        <LandingNavbar />
        <MasarPath />

        <div className="relative z-10 flex flex-col">
          <HeroSection />

          <section
            id="how-it-works"
            className="relative border-b border-border/40"
          >
            <div className="mx-auto max-w-7xl px-4 py-24 md:px-6 md:py-32">
              <ScrollReveal>
                <SectionHeading
                  eyebrow="كيف يعمل مسار؟"
                  title="تعلم بخطوات واضحة."
                  description="بدلاً من التنقل بين مصادر متفرقة، يجمع مسار تجربة التعلم في رحلة واحدة."
                />
              </ScrollReveal>

              <div className="relative mt-16 grid gap-5 md:grid-cols-4">
                {[
                  {
                    icon: Route,
                    title: "اختر مسارك",
                    desc: "ابدأ من المجال الذي تريد تطوير نفسك فيه.",
                  },
                  {
                    icon: BookOpen,
                    title: "تعلّم",
                    desc: "تابع الدورات والمحتوى بالترتيب المناسب لك.",
                  },
                  {
                    icon: MessageCircle,
                    title: "تفاعل",
                    desc: "اسأل، ناقش، وشارك المعرفة مع مجتمعك.",
                  },
                  {
                    icon: CheckCircle2,
                    title: "تقدّم",
                    desc: "تابع ما أنجزته واستمر نحو الخطوة التالية.",
                  },
                ].map((step, index) => (
                  <ScrollReveal key={index} delay={index * 150}>
                    <StepCard
                      number={`0${index + 1}`}
                      icon={step.icon}
                      title={step.title}
                      description={step.desc}
                    />
                  </ScrollReveal>
                ))}
              </div>
            </div>
          </section>

          <section
            id="experience"
            className="border-b border-border/40 bg-muted/[0.18]"
          >
            <div className="mx-auto max-w-7xl px-4 py-24 md:px-6 md:py-32">
              <ScrollReveal>
                <SectionHeading
                  eyebrow="تجربة التعلم"
                  title="أكثر من مجرد دورات."
                  description="الدورة هي جزء من الرحلة. مسار يجمع التعلم المنظم، المحتوى، المجتمع، والتقدم في تجربة واحدة."
                />
              </ScrollReveal>

              <div className="mt-14 grid gap-5 md:grid-cols-3">
                <ScrollReveal delay={0}>
                  <FeatureCard
                    icon={BookOpen}
                    title="دورات منظمة"
                    description="محتوى تعليمي واضح يساعدك على بناء المعرفة خطوة بخطوة."
                  />
                </ScrollReveal>
                <ScrollReveal delay={150}>
                  <FeatureCard
                    icon={Route}
                    title="مسارات تعليمية"
                    description="اعرف أين أنت الآن وما الذي يجب أن تتعلمه بعد ذلك."
                  />
                </ScrollReveal>
                <ScrollReveal delay={300}>
                  <FeatureCard
                    icon={MessageCircle}
                    title="مجتمع متفاعل"
                    description="تواصل مع المدرسين والطلاب وشارك الأسئلة والأفكار."
                  />
                </ScrollReveal>
              </div>
            </div>
          </section>

          <section
            id="community"
            className="overflow-hidden border-b border-border/40"
          >
            <div className="mx-auto grid max-w-7xl items-center gap-12 px-4 py-24 md:px-6 md:py-32 lg:grid-cols-2">
              <ScrollReveal direction="right">
                <p className="text-sm font-bold text-primary">مجتمع التعلم</p>
                <h2 className="mt-3 text-3xl font-black tracking-tight md:text-5xl">
                  التعلم لا يحدث بمفردك.
                </h2>
                <p className="mt-5 max-w-xl text-base leading-8 text-muted-foreground md:text-lg">
                  من سؤال بسيط إلى نقاش كامل، يتيح لك مسار التواصل مع مجتمعك
                  ومشاركة المعرفة أثناء التعلم.
                </p>
                <div className="mt-8 space-y-4">
                  <MiniPoint>اسأل المدرسين والطلاب</MiniPoint>
                  <MiniPoint>شارك أفكارك وتجاربك</MiniPoint>
                  <MiniPoint>تابع النقاشات والمحتوى</MiniPoint>
                </div>
              </ScrollReveal>

              <ScrollReveal direction="left" delay={200}>
                <CommunityPreview />
              </ScrollReveal>
            </div>
          </section>

          <section
            id="organizations"
            className="border-b border-border/40 bg-muted/[0.18]"
          >
            <div className="mx-auto max-w-7xl px-4 py-24 md:px-6 md:py-32">
              <ScrollReveal>
                <SectionHeading
                  eyebrow="للمدرسين والمؤسسات"
                  title="ابنِ تجربة تعليمية متكاملة."
                  description="مسار لا يخدم الطالب فقط. تمنح لوحة الإدارة المدرسين والمؤسسات الأدوات اللازمة لبناء وإدارة تجربتهم التعليمية."
                />
              </ScrollReveal>

              <div className="mt-14 grid gap-5 md:grid-cols-2">
                {[
                  {
                    icon: BookOpen,
                    title: "أنشئ الدورات",
                    desc: "حوّل خبرتك إلى محتوى تعليمي منظم يمكن للطلاب الوصول إليه بسهولة.",
                  },
                  {
                    icon: Route,
                    title: "ابنِ المسارات",
                    desc: "اربط الدورات ضمن رحلات تعليمية واضحة تساعد الطلاب على التقدم.",
                  },
                  {
                    icon: Users,
                    title: "أدر مجتمعك",
                    desc: "تابع الطلاب والمدرسين والمحتوى من لوحة واحدة.",
                  },
                  {
                    icon: MessageCircle,
                    title: "تواصل مع طلابك",
                    desc: "أنشئ مساحة تعليمية لا تنتهي بمجرد انتهاء الدرس.",
                  },
                ].map((org, idx) => (
                  <ScrollReveal key={idx} delay={idx * 150}>
                    <OrganizationFeature
                      icon={org.icon}
                      title={org.title}
                      description={org.desc}
                    />
                  </ScrollReveal>
                ))}
              </div>

              <ScrollReveal delay={300}>
                <DashboardPreview />
              </ScrollReveal>
            </div>
          </section>

          <section className="overflow-hidden border-b border-border/40">
            <div className="mx-auto grid max-w-7xl items-center gap-12 px-4 py-24 md:px-6 md:py-32 lg:grid-cols-2">
              <ScrollReveal direction="right" className="order-2 lg:order-1">
                <div className="mx-auto max-w-lg">
                  <ProductDevicePreview />
                </div>
              </ScrollReveal>

              <ScrollReveal
                direction="left"
                delay={200}
                className="order-1 lg:order-2"
              >
                <p className="text-sm font-bold text-primary">أينما كنت</p>
                <h2 className="mt-3 text-3xl font-black tracking-tight md:text-5xl">
                  تجربة واحدة للطلاب والمدرسين.
                </h2>
                <p className="mt-5 max-w-xl text-base leading-8 text-muted-foreground md:text-lg">
                  يتعلم الطالب من التطبيق، ويبني المدرس تجربته التعليمية من لوحة
                  التحكم، بينما تبقى التجربة مترابطة بين الطرفين.
                </p>
              </ScrollReveal>
            </div>
          </section>

          <section className="relative overflow-hidden">
            <div className="absolute inset-0 bg-primary/[0.04]" />
            <ScrollReveal className="relative mx-auto max-w-4xl px-4 py-24 text-center md:px-6 md:py-32">
              <p className="text-sm font-bold text-primary">ابدأ الآن</p>
              <h2 className="mt-3 text-4xl font-black tracking-tight md:text-6xl">
                جاهز تبدأ مسارك؟
              </h2>
              <p className="mx-auto mt-5 max-w-xl text-base leading-8 text-muted-foreground md:text-lg">
                ابدأ التعلم، اكتشف المسارات، وابنِ معرفتك خطوة بخطوة.
              </p>
              <a
                href="/login"
                className="mt-8 inline-flex h-14 items-center justify-center rounded-xl bg-primary px-8 text-sm font-bold text-primary-foreground shadow-lg shadow-primary/25 transition-all hover:-translate-y-1 hover:bg-primary/90 hover:shadow-xl"
              >
                ابدأ التعلم الآن
              </a>
            </ScrollReveal>
          </section>
        </div>
      </div>
    </main>
  )
}
function SectionHeading({
  eyebrow,
  title,
  description,
}: {
  eyebrow: string
  title: string
  description: string
}) {
  return (
    <div className="mx-auto max-w-2xl text-center">
      <p className="text-sm font-bold text-primary">{eyebrow}</p>

      <h2 className="mt-3 text-3xl font-black tracking-tight md:text-5xl">
        {title}
      </h2>

      <p className="mt-5 text-base leading-8 text-muted-foreground md:text-lg">
        {description}
      </p>
    </div>
  )
}

function StepCard({
  number,
  icon: Icon,
  title,
  description,
}: {
  number: string
  icon: typeof Route
  title: string
  description: string
}) {
  return (
    <div className="relative rounded-2xl border border-border/60 bg-card p-6 shadow-sm transition-all hover:-translate-y-1 hover:shadow-md">
      <div className="flex items-center justify-between">
        <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-primary/10 text-primary">
          <Icon className="h-5 w-5" />
        </div>

        <span className="text-sm font-black text-primary/40">{number}</span>
      </div>

      <h3 className="mt-6 text-lg font-black">{title}</h3>

      <p className="mt-2 text-sm leading-7 text-muted-foreground">
        {description}
      </p>
    </div>
  )
}

function FeatureCard({
  icon: Icon,
  title,
  description,
}: {
  icon: typeof BookOpen
  title: string
  description: string
}) {
  return (
    <div className="rounded-2xl border border-border/60 bg-card p-6 shadow-sm">
      <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-primary/10 text-primary">
        <Icon className="h-5 w-5" />
      </div>

      <h3 className="mt-5 text-lg font-black">{title}</h3>

      <p className="mt-2 text-sm leading-7 text-muted-foreground">
        {description}
      </p>
    </div>
  )
}

function MiniPoint({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex items-center gap-3">
      <CheckCircle2 className="h-5 w-5 shrink-0 text-primary" />

      <span className="text-sm font-semibold">{children}</span>
    </div>
  )
}

function OrganizationFeature({
  icon: Icon,
  title,
  description,
}: {
  icon: typeof BookOpen
  title: string
  description: string
}) {
  return (
    <div className="rounded-2xl border border-border/60 bg-card p-6">
      <div className="flex items-center gap-4">
        <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-primary/10 text-primary">
          <Icon className="h-5 w-5" />
        </div>

        <div>
          <h3 className="font-black">{title}</h3>

          <p className="mt-1 text-sm leading-6 text-muted-foreground">
            {description}
          </p>
        </div>
      </div>
    </div>
  )
}

function CommunityPreview() {
  return (
    <div className="relative">
      <div className="absolute -inset-4 rounded-[2rem] bg-primary/[0.04] blur-2xl" />

      <div className="relative space-y-3 rounded-[1.5rem] border border-border/60 bg-card p-5 shadow-xl">
        <div className="rounded-xl border border-border/50 p-4">
          <div className="flex items-center gap-3">
            <div className="flex h-9 w-9 items-center justify-center rounded-full bg-primary/10 text-xs font-black text-primary">
              أ
            </div>

            <div>
              <p className="text-sm font-black">أحمد</p>

              <p className="text-xs text-muted-foreground">منذ 12 دقيقة</p>
            </div>
          </div>

          <p className="mt-4 text-sm leading-7">
            كيف أبدأ في تعلم الخوارزميات بالطريقة الصحيحة؟
          </p>

          <div className="mt-4 text-xs font-semibold text-muted-foreground">
            ❤️ 24 &nbsp;&nbsp; 💬 8
          </div>
        </div>

        <div className="mr-8 rounded-xl border border-border/50 bg-muted/20 p-4">
          <div className="flex items-center gap-3">
            <div className="flex h-9 w-9 items-center justify-center rounded-full bg-secondary text-xs font-black">
              م
            </div>

            <div>
              <p className="text-sm font-black">محمد</p>

              <p className="text-xs text-muted-foreground">منذ 8 دقائق</p>
            </div>
          </div>

          <p className="mt-4 text-sm leading-7">
            ابدأ بتعلم كيفية كتابة الكود أولاً، وبعدها انتقل للخوارزميات
            تدريجياً.
          </p>
        </div>
      </div>
    </div>
  )
}

function DashboardPreview() {
  return (
    <div className="mt-14 overflow-hidden rounded-[1.5rem] border border-border/60 bg-card shadow-2xl">
      <div className="border-b border-border/50 bg-muted/20 p-4">
        <div className="flex items-center gap-2">
          <div className="h-2.5 w-2.5 rounded-full bg-muted-foreground/20" />
          <div className="h-2.5 w-2.5 rounded-full bg-muted-foreground/20" />
          <div className="h-2.5 w-2.5 rounded-full bg-muted-foreground/20" />
        </div>
      </div>

      <div className="grid gap-4 p-5 md:grid-cols-4 md:p-7">
        <DashboardStat label="الطلاب" value="1,240" />

        <DashboardStat label="الدورات" value="42" />

        <DashboardStat label="المسارات" value="8" />

        <DashboardStat label="المنشورات" value="128" />
      </div>
    </div>
  )
}

function DashboardStat({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-xl border border-border/50 bg-background p-5">
      <p className="text-xs font-semibold text-muted-foreground">{label}</p>

      <p className="mt-2 text-2xl font-black">{value}</p>
    </div>
  )
}

function ProductDevicePreview() {
  return (
    <div className="relative mx-auto w-67.5 rounded-[2rem] border-8 border-foreground/10 bg-card p-3 shadow-2xl">
      <div className="rounded-[1.4rem] border border-border/50 bg-muted/20 p-4">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-[10px] font-semibold text-muted-foreground">
              مرحباً بك
            </p>

            <p className="mt-1 text-sm font-black">تابع مسارك</p>
          </div>

          <Smartphone className="h-4 w-4 text-primary" />
        </div>

        <div className="mt-5 rounded-xl border border-border/50 bg-card p-4">
          <p className="text-xs font-bold">كورس البرمجيات</p>

          <div className="mt-3 h-1.5 overflow-hidden rounded-full bg-muted">
            <div className="h-full w-[72%] rounded-full bg-primary" />
          </div>

          <p className="mt-2 text-[10px] font-semibold text-muted-foreground">
            72% مكتمل
          </p>
        </div>

        <div className="mt-3 space-y-2">
          <div className="rounded-lg bg-primary/10 p-3">
            <p className="text-xs font-bold">الخوارزميات</p>

            <p className="mt-1 text-[10px] text-muted-foreground">
              الخطوة الحالية
            </p>
          </div>

          <div className="rounded-lg border border-border/50 p-3">
            <p className="text-xs font-bold">قواعد البيانات</p>

            <p className="mt-1 text-[10px] text-muted-foreground">
              الخطوة التالية
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}
