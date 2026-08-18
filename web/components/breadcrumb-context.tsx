"use client"

import {
  createContext,
  useContext,
  useEffect,
  useState,
  type ReactNode,
} from "react"

export interface BreadcrumbItem {
  label: string
  href?: string
}

interface BreadcrumbContextType {
  trail: BreadcrumbItem[]
  setTrail: (items: BreadcrumbItem[]) => void
  trailing: ReactNode
  setTrailing: (node: ReactNode) => void
}

export const BreadcrumbContext = createContext<BreadcrumbContextType>({
  trail: [],
  setTrail: () => {},
  trailing: null,
  setTrailing: () => {},
})

export function BreadcrumbProvider({ children }: { children: ReactNode }) {
  const [trail, setTrailState] = useState<BreadcrumbItem[]>([])
  const [trailing, setTrailing] = useState<ReactNode>(null)

  function setTrail(items: BreadcrumbItem[]) {
    setTrailState((prev) => {
      if (
        prev.length === items.length &&
        prev.every(
          (item, i) =>
            item.label === items[i].label && item.href === items[i].href
        )
      ) {
        return prev
      }
      return items
    })
  }

  return (
    <BreadcrumbContext.Provider
      value={{ trail, setTrail, trailing, setTrailing }}
    >
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

export function useBreadcrumbTrailing(node: ReactNode) {
  const { setTrailing } = useContext(BreadcrumbContext)

  useEffect(() => {
    setTrailing(node)
    return () => setTrailing(null)
  }, [node, setTrailing])
}
