"use client"

import type { Route } from "next"
import Link from "next/link"
import {
  ArrowLeft,
  ArrowDown,
  BookOpen,
  Check,
  MessageCircle,
  Route as RouteIcon,
  Sparkles,
} from "lucide-react"
import { motion } from "framer-motion"

export function HeroSection() {
  return (
    <section
      dir="rtl"
      className="relative overflow-hidden border-b border-border/40"
    >
      <div className="pointer-events-none absolute inset-0">
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_50%_15%,hsl(var(--primary)/0.08),transparent_40%)]" />
        <div className="absolute top-24 left-1/2 h-[450px] w-[900px] -translate-x-1/2 rounded-full bg-primary/[0.04] blur-[120px]" />
      </div>

      <div className="relative z-10 mx-auto w-full max-w-7xl px-4 pt-16 pb-16 md:px-6 md:pt-24 md:pb-24">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, staggerChildren: 0.15 }}
          className="mx-auto max-w-4xl text-center"
        >
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.1 }}
            className="mb-6 inline-flex items-center gap-2 rounded-full border border-primary/20 bg-primary/[0.06] px-4 py-2 text-xs font-bold text-primary backdrop-blur-sm"
          >
            <Sparkles className="h-3.5 w-3.5" />
            تعلّم، تواصل، وتقدّم
          </motion.div>

          <motion.h1
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="text-4xl leading-[1.2] font-black tracking-tight text-balance sm:text-5xl md:text-6xl lg:text-[4.5rem]"
          >
            كل ما تحتاجه لتتعلم،
            <span className="mt-2 block text-primary">في مسار واحد.</span>
          </motion.h1>

          <motion.p
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.3 }}
            className="mx-auto mt-6 max-w-2xl text-base leading-8 text-pretty text-muted-foreground sm:text-lg md:text-xl"
          >
            دورات منظمة، مسارات تعليمية واضحة، مجتمع تتبادل معه المعرفة، وأدوات
            تساعدك على تحويل التعلم إلى تقدم حقيقي.
          </motion.p>

          <motion.div
            initial={{ opacity: 0, y: 15 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.4 }}
            className="mt-10 flex flex-col justify-center gap-4 sm:flex-row"
          >
            <Link
              href={"/login" as Route}
              className="group inline-flex h-14 items-center justify-center rounded-xl bg-primary px-8 text-sm font-bold text-primary-foreground shadow-lg shadow-primary/25 transition-all hover:scale-105 hover:bg-primary/90 hover:shadow-xl active:scale-95"
            >
              ابدأ التعلم
              <ArrowLeft className="mr-2 h-4 w-4 transition-transform group-hover:-translate-x-1" />
            </Link>

            <a
              href="#how-it-works"
              className="inline-flex h-14 items-center justify-center rounded-xl border border-border bg-background/50 px-8 text-sm font-bold backdrop-blur-md transition-all hover:scale-105 hover:bg-muted active:scale-95"
            >
              اكتشف مسار
              <ArrowDown className="mr-2 h-4 w-4" />
            </a>
          </motion.div>
        </motion.div>

        <div className="relative mx-auto mt-16 max-w-6xl md:mt-24">
          <div className="absolute -inset-10 rounded-[3rem] bg-primary/[0.05] blur-3xl" />

          <motion.div
            initial={{ opacity: 0, y: 100, rotateX: 15 }}
            animate={{ opacity: 1, y: 0, rotateX: 0 }}
            transition={{
              type: "spring",
              stiffness: 50,
              damping: 20,
              delay: 0.5,
            }}
            style={{ perspective: 1200 }}
            className="relative"
          >
            <motion.div
              animate={{ y: [0, -8, 0] }}
              transition={{ repeat: Infinity, duration: 6, ease: "easeInOut" }}
              className="overflow-hidden rounded-[1.5rem] border border-border/60 bg-card shadow-2xl shadow-black/20"
            >
              <div className="flex h-11 items-center border-b border-border/50 bg-muted/25 px-4">
                <div className="flex gap-1.5">
                  <span className="h-3 w-3 rounded-full bg-muted-foreground/20" />
                  <span className="h-3 w-3 rounded-full bg-muted-foreground/20" />
                  <span className="h-3 w-3 rounded-full bg-muted-foreground/20" />
                </div>
              </div>

              <div className="grid min-h-[410px] md:grid-cols-[210px_1fr]">
                <aside className="hidden border-l border-border/50 bg-muted/15 p-5 md:block">
                  <div className="flex items-center gap-2">
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary text-sm font-black text-primary-foreground">
                      م
                    </div>
                    <span className="text-sm font-black">مسار</span>
                  </div>
                  <div className="mt-8 space-y-1.5">
                    {["لوحة التعلم", "الدورات", "المسارات", "المجتمع"].map(
                      (item, index) => (
                        <div
                          key={item}
                          className={[
                            "cursor-pointer rounded-lg px-3 py-2.5 text-xs font-bold transition-colors hover:bg-primary/5 hover:text-primary",
                            index === 0
                              ? "bg-primary/10 text-primary"
                              : "text-muted-foreground",
                          ].join(" ")}
                        >
                          {item}
                        </div>
                      )
                    )}
                  </div>
                  <div className="mt-8 rounded-xl border border-border/50 bg-card p-3 shadow-sm">
                    <p className="text-[10px] font-bold text-muted-foreground">
                      تقدمك
                    </p>
                    <div className="mt-2 h-1.5 overflow-hidden rounded-full bg-muted">
                      <motion.div
                        initial={{ width: "0%" }}
                        animate={{ width: "72%" }}
                        transition={{
                          duration: 1.5,
                          delay: 1,
                          ease: "circOut",
                        }}
                        className="h-full rounded-full bg-primary"
                      />
                    </div>
                    <p className="mt-2 text-xs font-black text-primary">72%</p>
                  </div>
                </aside>

                <div className="p-5 md:p-8">
                  <div className="flex flex-wrap items-start justify-between gap-4">
                    <div>
                      <p className="text-xs font-bold text-muted-foreground">
                        مسارك الحالي
                      </p>
                      <h2 className="mt-1 text-2xl font-black">
                        كورس البرمجيات
                      </h2>
                    </div>
                    <div className="flex items-center gap-2 rounded-lg bg-primary/10 px-3 py-2 text-xs font-bold text-primary">
                      <RouteIcon className="h-3.5 w-3.5" />
                      72% مكتمل
                    </div>
                  </div>

                  <div className="mt-7 grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
                    <PreviewCard
                      icon={BookOpen}
                      title="أساسيات البرمجة"
                      description="مفاهيم البرمجة الأساسية"
                      completed
                      delay={1.2}
                    />
                    <PreviewCard
                      icon={BookOpen}
                      title="هياكل البيانات"
                      description="تنظيم البيانات بكفاءة"
                      completed
                      delay={1.3}
                    />
                    <PreviewCard
                      icon={BookOpen}
                      title="الخوارزميات"
                      description="حل المشكلات بطريقة منهجية"
                      active
                      delay={1.4}
                    />
                    <PreviewCard
                      icon={MessageCircle}
                      title="المجتمع"
                      description="شارك وتعلم مع الآخرين"
                      delay={1.5}
                    />
                    <PreviewCard
                      icon={RouteIcon}
                      title="الخطوة التالية"
                      description="قواعد البيانات"
                      delay={1.6}
                    />
                    <PreviewCard
                      icon={Check}
                      title="إنجازاتك"
                      description="استمر في بناء تقدمك"
                      delay={1.7}
                    />
                  </div>
                </div>
              </div>
            </motion.div>
          </motion.div>

          <motion.div
            initial={{ scale: 0, opacity: 0, rotate: -15 }}
            animate={{ scale: 1, opacity: 1, rotate: 0 }}
            transition={{
              type: "spring",
              damping: 10,
              stiffness: 100,
              delay: 2,
            }}
            className="absolute -bottom-6 -left-4 z-20 hidden rounded-2xl border border-border/40 bg-card/60 px-5 py-4 shadow-2xl backdrop-blur-xl sm:block md:-left-8"
          >
            <div className="flex items-center gap-4">
              <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-emerald-500/15">
                <Check className="h-5 w-5 text-emerald-500" />
              </div>
              <div>
                <p className="text-sm font-black text-foreground">
                  استمر في التقدم
                </p>
                <p className="mt-1 text-[11px] font-bold text-muted-foreground">
                  خطوة واحدة في كل مرة
                </p>
              </div>
            </div>
          </motion.div>
        </div>

        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 2.5 }}
          className="mt-16 flex justify-center"
        >
          <a
            href="#how-it-works"
            className="group flex flex-col items-center gap-3 text-muted-foreground transition-colors hover:text-primary"
          >
            <span className="text-[12px] font-bold">اكتشف كيف يعمل مسار</span>
            <ArrowDown className="h-5 w-5 animate-pulse transition-transform group-hover:translate-y-2" />
          </a>
        </motion.div>
      </div>
    </section>
  )
}

function PreviewCard({
  icon: Icon,
  title,
  description,
  completed,
  active,
  delay,
}: any) {
  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.9, y: 10 }}
      animate={{ opacity: 1, scale: 1, y: 0 }}
      transition={{ delay: delay, type: "spring", stiffness: 200, damping: 20 }}
      whileHover={{ y: -5, scale: 1.02 }}
      className={[
        "cursor-default rounded-xl border p-4 shadow-sm",
        active
          ? "border-primary/40 bg-primary/[0.05]"
          : "border-border/50 bg-background/50 hover:border-primary/30",
      ].join(" ")}
    >
      <div className="flex items-start gap-3">
        <div
          className={[
            "flex h-9 w-9 shrink-0 items-center justify-center rounded-lg shadow-inner",
            completed
              ? "bg-primary/10 text-primary"
              : active
                ? "bg-primary text-primary-foreground shadow-primary/40"
                : "bg-muted text-muted-foreground",
          ].join(" ")}
        >
          {completed ? (
            <Check className="h-4 w-4" />
          ) : (
            <Icon className="h-4 w-4" />
          )}
        </div>
        <div className="min-w-0">
          <p className="truncate text-sm font-black">{title}</p>
          <p className="mt-1 truncate text-[11px] font-medium text-muted-foreground">
            {description}
          </p>
        </div>
      </div>
    </motion.div>
  )
}
