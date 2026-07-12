"use client"

import { useEffect, useState } from "react"

type BreakpointMode = "min" | "max"

/**
 * Hook to detect whether the current viewport matches a given breakpoint rule.
 * Example:
 *   useIsBreakpoint("max", 768)   // true when width < 768
 *   useIsBreakpoint("min", 1024)  // true when width >= 1024
 */
export function useIsBreakpoint(
  mode: BreakpointMode = "max",
  breakpoint = 768
) {
  const query =
    mode === "min"
      ? `(min-width: ${breakpoint}px)`
      : `(max-width: ${breakpoint - 1}px)`

  const [matches, setMatches] = useState<boolean | undefined>(() => {
    if (typeof window !== "undefined") {
      return window.matchMedia(query).matches
    }
    return undefined
  })

  useEffect(() => {
    const mql = window.matchMedia(query)
    const onChange = (e: MediaQueryListEvent) => setMatches(e.matches)

    mql.addEventListener("change", onChange)
    return () => mql.removeEventListener("change", onChange)
  }, [query])

  return !!matches
}
