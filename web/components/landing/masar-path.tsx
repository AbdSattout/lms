import { cn } from "@/lib/utils"

interface MasarPathProps {
  className?: string
}

export function MasarPath({ className }: MasarPathProps) {
  return (
    <div
      aria-hidden="true"
      className={cn(
        "pointer-events-none absolute top-16 bottom-0 left-1/2 z-0 hidden w-44 -translate-x-1/2 lg:block",
        className
      )}
    >
      <svg
        viewBox="0 0 176 2600"
        fill="none"
        className="h-full w-full overflow-visible"
        preserveAspectRatio="none"
      >
        <path
          d="
            M88 0
            C88 160 38 220 38 380
            C38 540 138 610 138 770
            C138 930 38 1000 38 1160
            C38 1320 138 1390 138 1550
            C138 1710 38 1780 38 1940
            C38 2100 88 2200 88 2600
          "
          className="stroke-primary/10"
          strokeWidth="10"
          strokeLinecap="round"
        />

        <path
          d="
            M88 0
            C88 160 38 220 38 380
            C38 540 138 610 138 770
            C138 930 38 1000 38 1160
            C38 1320 138 1390 138 1550
            C138 1710 38 1780 38 1940
            C38 2100 88 2200 88 2600
          "
          className="stroke-primary/25"
          strokeWidth="2"
          strokeLinecap="round"
        />

        <path
          d="
            M88 0
            C88 160 38 220 38 380
            C38 540 138 610 138 770
            C138 930 38 1000 38 1160
            C38 1320 138 1390 138 1550
            C138 1710 38 1780 38 1940
            C38 2100 88 2200 88 2600
          "
          className="stroke-primary/70"
          strokeWidth="2"
          strokeDasharray="2 15"
          strokeLinecap="round"
        />
      </svg>
    </div>
  )
}
