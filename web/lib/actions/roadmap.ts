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

export async function publishRoadmap(orgSlug: string, roadmapId: number) {
  try {
    await api.dashboard.roadmap.byId.publish(orgSlug, roadmapId)

    revalidatePath(`/${orgSlug}/roadmaps`)

    return { success: true }
  } catch (error) {
    console.error("Error publishing roadmap:", error)

    if (error instanceof Error) {
      return { error: error.message }
    }

    return { error: "Failed to publish roadmap" }
  }
}

export async function moveRoadmapToDraft(orgSlug: string, roadmapId: number) {
  try {
    await api.dashboard.roadmap.byId.draft(orgSlug, roadmapId)

    revalidatePath(`/${orgSlug}/roadmaps`)

    return { success: true }
  } catch (error) {
    console.error("Error moving roadmap to draft:", error)

    if (error instanceof Error) {
      return { error: error.message }
    }

    return { error: "Failed to move roadmap to draft" }
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
