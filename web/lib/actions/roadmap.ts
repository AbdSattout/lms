// lib/actions/roadmap.ts
"use server"

import { api } from "@/lib/api"
import { revalidatePath } from "next/cache"
export async function createRoadmap(
  orgSlug: string,
  name: string,
  description: string,
  courseIds: number[]
) {
  try {
    await api.dashboard.roadmap.create.post(orgSlug, {
      name,
      description,
      courseIds,
    })
    revalidatePath(`/${orgSlug}/roadmaps`)
    return { success: true }
  } catch (error) {
    if (error instanceof Error) {
      return { error: error.message }
    }
    return { error: "Failed to create roadmap" }
  }
}

export async function updateRoadmap(
  orgSlug: string,
  roadmapId: number,
  name: string,
  description: string,
  courseIds: number[]
) {
  try {
    await api.dashboard.roadmap.byId.patch(orgSlug, roadmapId, {
      name,
      description,

      courseIds,
    })
    revalidatePath(`/${orgSlug}/roadmaps`)
    return { success: true }
  } catch (error) {
    console.error("Error updating roadmap:", error)
    if (error instanceof Error) {
      return { error: error.message }
    }
    return { error: "Failed to update roadmap" }
  }
}

export async function deleteRoadmap(orgSlug: string, roadmapId: number) {
  try {
    await api.dashboard.roadmap.byId.delete(orgSlug, roadmapId)
    revalidatePath(`/${orgSlug}/roadmaps`)
    return { success: true }
  } catch {
    return { error: "Failed to delete roadmap" }
  }
}
