"use client"

import type { Route } from "next"
import {
  Background,
  Controls,
  MiniMap,
  ReactFlow,
  useEdgesState,
  useNodesState,
  ConnectionLineType,
  MarkerType, // Required for v12 Arrows
  type Connection,
  type Edge,
  type NodeTypes,
} from "@xyflow/react"
import "@xyflow/react/dist/style.css"
import { useCallback, useEffect, useRef, useState } from "react"
import { toast } from "sonner"

import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import type { CourseResponse, RoadmapResponse } from "@/lib/api/types"
import { Check, Loader2, Plus, Save, Trash2, X } from "lucide-react"
import { useRouter } from "next/navigation"

import { CourseNode } from "./course-node"
import {
  createRoadmap,
  updateRoadmap,
  deleteRoadmap,
} from "@/lib/actions/roadmap"

const nodeTypes = { courseNode: CourseNode } satisfies NodeTypes
const EDGE_COLOR = "#3b82f6" // Solid blue color

interface RoadmapEditorProps {
  orgSlug: string
  roadmap: RoadmapResponse | null
  isNew: boolean
  availableCourses?: CourseResponse[]
}

export function RoadmapEditor({
  orgSlug,
  roadmap,
  isNew,
  availableCourses = [],
}: RoadmapEditorProps) {
  const router = useRouter()

  const [title, setTitle] = useState<string>(roadmap?.title || "")

  const [isSaving, setIsSaving] = useState(false)
  const [isDeleting, setIsDeleting] = useState(false)
  const [deleteOpen, setDeleteOpen] = useState(false)
  const [courseDialogOpen, setCourseDialogOpen] = useState(false)

  const edgeIdRef = useRef(0)

  const initializeNodesAndEdges = useCallback(() => {
    if (!roadmap?.items?.length) return { nodes: [], edges: [] }

    const items = [...roadmap.items].sort((a, b) => a.position - b.position)

    const nodes: CourseNode[] = items.map((item, index) => ({
      id: `course-${item.course.id}`,
      type: "courseNode",
      position: { x: index * 300 + 50, y: 150 },
      data: {
        course: item.course,
        position: item.position,
      },
    }))

    const edges: Edge[] = []
    for (let i = 0; i < items.length - 1; i++) {
      edges.push({
        id: `edge-${items[i].course.id}-${items[i + 1].course.id}`,
        source: `course-${items[i].course.id}`,
        target: `course-${items[i + 1].course.id}`,
        type: "smoothstep",
        animated: false, // Changed to solid line for clear direction
        style: { stroke: EDGE_COLOR, strokeWidth: 3 },
        markerEnd: {
          type: MarkerType.ArrowClosed,
          width: 20, // Explicitly defining arrow size for V12
          height: 20,
          color: EDGE_COLOR,
        },
      })
    }

    return { nodes, edges }
  }, [roadmap])

  const { nodes: initialNodes, edges: initialEdges } = initializeNodesAndEdges()
  const [nodes, setNodes, onNodesChange] = useNodesState(initialNodes)
  const [edges, setEdges, onEdgesChange] = useEdgesState(initialEdges)

  const removeNode = (nodeId: string) => {
    setNodes((nds) => nds.filter((node) => node.id !== nodeId))
    setEdges((eds) =>
      eds.filter((edge) => edge.source !== nodeId && edge.target !== nodeId)
    )
  }

  useEffect(() => {
    const handleRemoveNode = (event: Event) => {
      const customEvent = event as CustomEvent<{ nodeId: string }>
      removeNode(customEvent.detail.nodeId)
    }

    window.addEventListener("remove-node", handleRemoveNode)
    return () => {
      window.removeEventListener("remove-node", handleRemoveNode)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  const onConnect = useCallback(
    (connection: Connection) => {
      if (connection.source === connection.target) {
        toast.error("لا يمكن ربط الدورة بنفسها")
        return
      }

      // PREVENT BRANCHING (Ensures a clean A -> B -> C sequence)
      const sourceHasEdge = edges.some((e) => e.source === connection.source)
      if (sourceHasEdge) {
        toast.error(
          "هذه الدورة لها مسار تالي بالفعل. يرجى حذف الرابط القديم أولاً."
        )
        return
      }

      const targetHasEdge = edges.some((e) => e.target === connection.target)
      if (targetHasEdge) {
        toast.error("هذه الدورة مرتبطة بمسار سابق بالفعل.")
        return
      }

      // PREVENT CYCLES (Blocks the Last node from connecting back to the First node)
      const createsCycle = (sourceId: string, targetId: string) => {
        let current = targetId
        const visited = new Set<string>()
        while (current) {
          if (current === sourceId) return true
          visited.add(current)
          const nextEdge = edges.find((e) => e.source === current)
          if (nextEdge && !visited.has(nextEdge.target)) {
            current = nextEdge.target
          } else {
            break
          }
        }
        return false
      }

      if (createsCycle(connection.source, connection.target)) {
        toast.error("خطأ: لا يمكن ربط المسار بشكل دائري (من النهاية للبداية)")
        return
      }

      const newEdge: Edge = {
        id: `edge-${connection.source}-${connection.target}-${Date.now()}`,
        source: connection.source,
        target: connection.target,
        type: "smoothstep",
        animated: false,
        style: { stroke: EDGE_COLOR, strokeWidth: 3 },
        markerEnd: {
          type: MarkerType.ArrowClosed,
          width: 20,
          height: 20,
          color: EDGE_COLOR,
        },
      }

      setEdges((eds) => [...eds, newEdge])
    },
    [edges, setEdges]
  )

  const addCourseNode = (course: CourseResponse) => {
    const courseIdFormatted = `course-${course.id}`
    if (nodes.some((n) => n.id === courseIdFormatted)) {
      toast.error("هذه الدورة موجودة بالفعل في المسار")
      return
    }

    const maxX = nodes.reduce(
      (max, node) => Math.max(max, node.position.x),
      -250
    )
    const newPositionX = maxX + 300

    const newNode: CourseNode = {
      id: courseIdFormatted,
      type: "courseNode",
      position: { x: newPositionX, y: 150 },
      data: { course, position: nodes.length },
    }

    if (nodes.length > 0) {
      const lastNode = nodes[nodes.length - 1]
      const edgeExists = edges.some(
        (e) => e.source === lastNode.id && e.target === newNode.id
      )

      if (!edgeExists) {
        edgeIdRef.current += 1
        const newEdge: Edge = {
          id: `edge-${lastNode.id}-${newNode.id}-${edgeIdRef.current}`,
          source: lastNode.id,
          target: newNode.id,
          type: "smoothstep",
          animated: false,
          style: { stroke: EDGE_COLOR, strokeWidth: 3 },
          markerEnd: {
            type: MarkerType.ArrowClosed,
            width: 20,
            height: 20,
            color: EDGE_COLOR,
          },
        }
        setEdges((eds) => [...eds, newEdge])
      }
    }

    setNodes((nds) => [...nds, newNode])
    setCourseDialogOpen(false)
  }

  const generateOrderedCourseSequence = (): number[] => {
    if (edges.length === 0) {
      return nodes
        .sort((a, b) => a.position.x - b.position.x)
        .map((n) => parseInt(n.id.replace("course-", ""), 10))
    }

    const inEdges = new Set(edges.map((e) => e.target))
    const startNode = nodes.find((n) => !inEdges.has(n.id))

    const sequentiallyOrderedIds: number[] = []
    const markedVisualIds = new Set<string>()
    let currentRootIndex: CourseNode | undefined = startNode || nodes[0]

    while (currentRootIndex && !markedVisualIds.has(currentRootIndex.id)) {
      markedVisualIds.add(currentRootIndex.id)
      sequentiallyOrderedIds.push(
        parseInt(currentRootIndex.id.replace("course-", ""), 10)
      )

      const nextConnect = edges.find((e) => e.source === currentRootIndex!.id)

      if (nextConnect) {
        currentRootIndex = nodes.find((n) => n.id === nextConnect.target)
      } else {
        break
      }
    }

    nodes
      .filter((n) => !markedVisualIds.has(n.id))
      .sort((a, b) => a.position.x - b.position.x)
      .forEach((looseLinkNode) => {
        sequentiallyOrderedIds.push(
          parseInt(looseLinkNode.id.replace("course-", ""), 10)
        )
      })

    return sequentiallyOrderedIds
  }

  const handleSaveRoadmap = async () => {
    if (!title.trim()) {
      toast.error("يرجى إدخال اسم المسار التعليمي")
      return
    }

    setIsSaving(true)
    try {
      const parsedSequenceArrayIdPayload = generateOrderedCourseSequence()
      const uniqueCourseIds = Array.from(new Set(parsedSequenceArrayIdPayload))

      if (uniqueCourseIds.some((id) => isNaN(id))) {
        throw new Error("Invalid course IDs detected")
      }

      const result = isNew
        ? await createRoadmap(orgSlug, title, uniqueCourseIds)
        : await updateRoadmap(orgSlug, roadmap!.id, title, uniqueCourseIds)

      if (result?.error) {
        throw new Error(result.error)
      }

      toast.success(
        isNew ? "تم إنشاء المسار التعليمي" : "تم حفظ المسار التعليمي"
      )
      router.push(`/${orgSlug}/roadmaps` as Route)
      router.refresh()
    } catch (error) {
      console.error("Full save error:", error)
      toast.error(
        error instanceof Error
          ? error.message
          : "حدث خطأ أثناء حفظ المسار. تأكد من الباك إند."
      )
    } finally {
      setIsSaving(false)
    }
  }

  // ... (handleProceedDelete function remains the same)
  const handleProceedDelete = async () => {
    if (!roadmap?.id || isNew) return
    setIsDeleting(true)
    try {
      const response = await deleteRoadmap(orgSlug, roadmap.id)
      if (response?.error) throw new Error(response.error)
      toast.success("تم حذف المسار التعليمي")
      router.push(`/${orgSlug}/roadmaps` as Route)
      router.refresh()
    } catch {
      toast.error("حدث خطأ أثناء حذف المسار")
    } finally {
      setIsDeleting(false)
      setDeleteOpen(false)
    }
  }

  const usedCourseIds = nodes.map((node) => node.data.course.id)
  const availableCoursesToAdd = availableCourses.filter(
    (course) => !usedCourseIds.includes(course.id)
  )

  return (
    <div className="flex h-full min-h-[600px] flex-col space-y-4">
      {/* Toolbar */}
      <div className="flex flex-col gap-4 rounded-lg border bg-card p-4 md:flex-row md:items-center md:justify-between">
        {/* ADDED: Roadmap Title Naming Input */}
        <div className="flex flex-1 items-center gap-4" dir="rtl">
          <h2 className="shrink-0 text-lg font-semibold">
            {isNew ? "مسار جديد:" : `تعديل المسار #${roadmap?.id}:`}
          </h2>
          <Input
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            placeholder="أدخل اسم المسار التعليمي هنا..."
            className="max-w-xs border-primary focus-visible:ring-primary"
          />
        </div>

        <div className="flex items-center gap-2" dir="rtl">
          <Button
            variant="outline"
            size="sm"
            onClick={() => setCourseDialogOpen(true)}
            disabled={availableCoursesToAdd.length === 0}
          >
            <Plus className="ml-2 h-4 w-4" />
            إضافة دورة
          </Button>

          {!isNew && (
            <Button
              variant="destructive"
              size="sm"
              onClick={() => setDeleteOpen(true)}
              disabled={isDeleting}
            >
              <Trash2 className="ml-2 h-4 w-4" />
              حذف
            </Button>
          )}

          <Button
            size="sm"
            onClick={handleSaveRoadmap}
            disabled={isSaving || nodes.length === 0}
          >
            {isSaving ? (
              <Loader2 className="ml-2 h-4 w-4 animate-spin" />
            ) : (
              <Save className="ml-2 h-4 w-4" />
            )}
            حفظ
          </Button>

          <Button variant="ghost" size="sm" onClick={() => router.back()}>
            <X className="ml-2 h-4 w-4" />
            إلغاء
          </Button>
        </div>
      </div>

      {/* React Flow Canvas */}
      <div
        className="flex-1 overflow-hidden rounded-lg border bg-card"
        dir="ltr"
      >
        {nodes.length === 0 ? (
          <div className="flex h-full items-center justify-center">
            <div className="text-center" dir="rtl">
              <p className="text-lg text-muted-foreground">
                اسحب الدورات إلى هنا لبناء المسار التعليمي
              </p>
              <Button
                className="mt-4"
                onClick={() => setCourseDialogOpen(true)}
              >
                <Plus className="ml-2 h-4 w-4" />
                إضافة دورة
              </Button>
            </div>
          </div>
        ) : (
          <ReactFlow
            nodes={nodes}
            edges={edges}
            onNodesChange={onNodesChange}
            onEdgesChange={onEdgesChange}
            onConnect={onConnect}
            nodeTypes={nodeTypes}
            fitView
            fitViewOptions={{ padding: 0.2 }}
            attributionPosition="bottom-left"
            className="bg-background"
            connectionLineType={ConnectionLineType.SmoothStep}
            defaultEdgeOptions={{
              type: "smoothstep",
              animated: false,
              style: { stroke: EDGE_COLOR, strokeWidth: 3 },
              markerEnd: {
                type: MarkerType.ArrowClosed,
                width: 20,
                height: 20,
                color: EDGE_COLOR,
              },
            }}
          >
            <Background color="hsl(var(--muted-foreground) / 0.5)" gap={16} />
            <Controls className="!border-border !bg-card !fill-foreground" />
            <MiniMap
              nodeColor="hsl(var(--primary))"
              maskColor="hsl(var(--background) / 0.8)"
              className="!border-border !bg-card"
            />
          </ReactFlow>
        )}
      </div>

      {/* Add Course Dialog */}
      <Dialog open={courseDialogOpen} onOpenChange={setCourseDialogOpen}>
        {/* ... (Dialog content remains identical) ... */}
        <DialogContent dir="rtl">
          <DialogHeader>
            <DialogTitle>إضافة دورة إلى المسار</DialogTitle>
            <DialogDescription>
              اختر دورة لإضافتها إلى المسار التعليمي
            </DialogDescription>
          </DialogHeader>
          <div className="max-h-64 space-y-2 overflow-y-auto">
            {availableCoursesToAdd.map((course) => (
              <button
                key={course.id}
                className="group flex w-full items-center justify-between rounded-lg border p-3 text-right transition-colors hover:bg-accent"
                onClick={() => addCourseNode(course)}
              >
                <div>
                  <p className="font-medium">{course.title}</p>
                </div>
                <Check className="h-4 w-4 text-primary opacity-0 transition-opacity group-hover:opacity-100" />
              </button>
            ))}
          </div>
        </DialogContent>
      </Dialog>

      {/* Delete Confirmation Dialog */}
      <Dialog open={deleteOpen} onOpenChange={setDeleteOpen}>
        {/* ... (Delete Dialog content remains identical) ... */}
      </Dialog>
    </div>
  )
}
