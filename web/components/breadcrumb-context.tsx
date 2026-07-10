"use client"

import { createContext, useContext, useEffect, useState, type ReactNode } from "react"

export interface BreadcrumbItem {
  label: string
  href?: string
}

interface BreadcrumbContextType {
  trail: BreadcrumbItem[]
  setTrail: (items: BreadcrumbItem[]) => void
}

export const BreadcrumbContext = createContext<BreadcrumbContextType>({
  trail: [],
  setTrail: () => {},
})

export function BreadcrumbProvider({ children }: { children: ReactNode }) {
  const [trail, setTrailState] = useState<BreadcrumbItem[]>([])

  function setTrail(items: BreadcrumbItem[]) {
    setTrailState((prev) => {
      if (
        prev.length === items.length &&
        prev.every(
          (item, i) =>
            item.label === items[i].label && item.href === items[i].href,
        )
      ) {
        return prev
      }
      return items
    })
  }

  return (
    <BreadcrumbContext.Provider value={{ trail, setTrail }}>
      {children}
    </BreadcrumbContext.Provider>
  )
}

export function useBreadcrumb(trail: BreadcrumbItem[]) {
  const { setTrail } = useContext(BreadcrumbContext)

  useEffect(() => {
    setTrail(trail)
    return () => setTrail([])
  }, [trail, setTrail])
}
