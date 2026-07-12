"use client"

import { useBreadcrumb, type BreadcrumbItem } from "./breadcrumb-context"

export function BreadcrumbTrail({ items }: { items: BreadcrumbItem[] }) {
  useBreadcrumb(items)
  return null
}
