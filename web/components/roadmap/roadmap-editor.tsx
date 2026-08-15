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
  MarkerType,
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
  deleteRoadmap,
  updateRoadmap,
} from "@/lib/actions/roadmap"

const nodeTypes = { courseNode: CourseNode } satisfies NodeTypes
const EDGE_COLOR = "#3b82f6"

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

  const [name, setName] = useState<string>(roadmap?.name || "")
  const [description, setDescription] = useState<string>(
    roadmap?.description || ""
  )

  const [isSaving, setIsSaving] = useState(false)
  const [isDeleting, setIsDeleting] = useState(false)
  const [deleteOpen, setDeleteOpen] = useState(false)
  const [courseDialogOpen, setCourseDialogOpen] = useState(false)

  const edgeIdRef = useRef(0)

  const getOrderedNodeIds = useCallback(
    (currentNodes: CourseNode[], currentEdges: Edge[]) => {
      if (currentEdges.length === 0) {
        return [...currentNodes]
          .sort((a, b) => a.position.x - b.position.x)
          .map((n) => n.id)
      }

      const inEdges = new Set(currentEdges.map((e) => e.target))
      const startNode = currentNodes.find((n) => !inEdges.has(n.id))
      const orderedIds: string[] = []
      const markedVisualIds = new Set<string>()
      let currentRoot: CourseNode | undefined = startNode || currentNodes[0]

      while (currentRoot && !markedVisualIds.has(currentRoot.id)) {
        markedVisualIds.add(currentRoot.id)
        orderedIds.push(currentRoot.id)
        const nextEdge = currentEdges.find((e) => e.source === currentRoot?.id)
        if (nextEdge) {
          currentRoot = currentNodes.find((n) => n.id === nextEdge.target)
        } else {
          break
        }
      }

      currentNodes
        .filter((n) => !markedVisualIds.has(n.id))
        .sort((a, b) => a.position.x - b.position.x)
        .forEach((n) => orderedIds.push(n.id))

      return orderedIds
    },
    []
  )

  const initializeNodesAndEdges = useCallback(() => {
    if (!roadmap?.items?.length) return { nodes: [], edges: [] }

    const items = [...roadmap.items].sort((a, b) => a.position - b.position)

    const nodes: CourseNode[] = items.map((item, index) => ({
      id: `course-${item.course.id}`,
      type: "courseNode",
      position: { x: index * 320 + 50, y: index * 120 + 100 },
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
        animated: false,
        style: { stroke: EDGE_COLOR, strokeWidth: 3 },
        markerEnd: {
          type: MarkerType.ArrowClosed,
          width: 20,
          height: 20,
          color: EDGE_COLOR,
        },
      })
    }
    return { nodes, edges }
  }, [roadmap])

  const [nodes, setNodes, onNodesChange] = useNodesState(
    initializeNodesAndEdges().nodes
  )
  const [edges, setEdges, onEdgesChange] = useEdgesState(
    initializeNodesAndEdges().edges
  )
  useEffect(() => {
    if (nodes.length === 0) return

    const orderedIds = getOrderedNodeIds(nodes as CourseNode[], edges)
    const stepMap = new Map<string, number>()
    orderedIds.forEach((id, index) => stepMap.set(id, index))

    setNodes((currentNodes) => {
      let isChanged = false
      const updatedNodes = currentNodes.map((node) => {
        const expectedPosition = stepMap.get(node.id) ?? 0
        if (node.data.position !== expectedPosition) {
          isChanged = true
          return { ...node, data: { ...node.data, position: expectedPosition } }
        }
        return node
      })
      return isChanged ? updatedNodes : currentNodes
    })
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [edges, nodes.length, nodes.map((n) => n.id).join(",")])

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
    return () => window.removeEventListener("remove-node", handleRemoveNode)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  const handleDeleteRoadmap = async () => {
    if (!roadmap) return
    setIsDeleting(true)
    try {
      const result = await deleteRoadmap(orgSlug, roadmap.id)
      if (result?.error) throw new Error(result.error)

      toast.success("تم حذف المسار بنجاح")
      router.push(`/${orgSlug}/roadmaps` as Route)
      router.refresh()
    } catch (error) {
      toast.error("حدث خطأ أثناء حذف المسار")
    } finally {
      setIsDeleting(false)
      setDeleteOpen(false)
    }
  }

  const onConnect = useCallback(
    (connection: Connection) => {
      if (connection.source === connection.target) {
        toast.error("لا يمكن ربط الدورة بنفسها")
        return
      }

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
        toast.error("خطأ: لا يمكن ربط المسار بشكل دائري")
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
    const maxYOffset =
      nodes.length > 0 ? Math.max(...nodes.map((n) => n.position.y)) + 120 : 100

    const newNode: CourseNode = {
      id: courseIdFormatted,
      type: "courseNode",
      position: { x: maxX + 320, y: maxYOffset },
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

  const handleSaveRoadmap = async () => {
    if (!name.trim()) {
      toast.error("يرجى إدخال اسم المسار التعليمي")
      return
    }
    setIsSaving(true)
    try {
      const orderedNodeIds = getOrderedNodeIds(nodes as CourseNode[], edges)
      const uniqueCourseIds = orderedNodeIds.map((id) =>
        parseInt(id.replace("course-", ""), 10)
      )

      if (uniqueCourseIds.some((id) => isNaN(id))) {
        throw new Error("Invalid course IDs detected")
      }

      const result = isNew
        ? await createRoadmap(orgSlug, name, description, uniqueCourseIds)
        : await updateRoadmap(
            orgSlug,
            roadmap!.id,
            name,
            description,
            uniqueCourseIds
          )

      if (result?.error) throw new Error(result.error)

      toast.success(
        isNew ? "تم إنشاء المسار التعليمي" : "تم حفظ المسار التعليمي"
      )
      router.push(`/${orgSlug}/roadmaps` as Route)
      router.refresh()
    } catch (error) {
      toast.error(
        error instanceof Error ? error.message : "حدث خطأ أثناء حفظ المسار."
      )
    } finally {
      setIsSaving(false)
    }
  }

  const usedCourseIds = nodes.map((node) => node.data.course.id)
  const availableCoursesToAdd = availableCourses.filter(
    (c) => !usedCourseIds.includes(c.id)
  )

  return (
    <div className="flex h-full min-h-[600px] flex-col space-y-4">
      <style
        dangerouslySetInnerHTML={{
          __html: `
        .rf-fix .react-flow__controls button, 
        .rf-fix .react-flow__minimap {
          background-color: hsl(var(--card)) !important;
          border-color: hsl(var(--border)) !important;
          color: hsl(var(--foreground)) !important;
        }
        .rf-fix .react-flow__controls button:hover {
          background-color: hsl(var(--accent)) !important;
        }
        .rf-fix .react-flow__controls path,
        .rf-fix .react-flow__minimap mask {
          fill: hsl(var(--foreground)) !important;
        }
      `,
        }}
      />

      <div className="flex flex-col gap-4 rounded-lg border bg-card p-4 md:flex-row md:items-center md:justify-between">
        <div className="flex flex-1 items-center gap-4" dir="rtl">
          <h2 className="shrink-0 text-sm font-semibold">
            {isNew ? "اسم جديد:" : "تعديل الاسم:"}
          </h2>
          <Input
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="أدخل اسم المسار التعليمي هنا..."
            className="max-w-xs border-primary focus-visible:ring-primary"
          />
        </div>
        <div className="flex flex-1 items-center gap-4" dir="rtl">
          <h2 className="shrink-0 text-sm font-semibold">
            {isNew ? "وصف جديد:" : "تعديل الوصف:"}
          </h2>
          <Input
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            placeholder="أدخل وصف المسار التعليمي هنا..."
            className="max-w-xs border-primary focus-visible:ring-primary"
          />
        </div>

        <div className="flex flex-wrap items-center gap-2" dir="rtl">
          <Button
            variant="outline"
            size="sm"
            onClick={() => setCourseDialogOpen(true)}
            disabled={availableCoursesToAdd.length === 0}
          >
            <Plus className="ml-2 h-4 w-4" /> إضافة دورة
          </Button>
          {!isNew && (
            <Button
              variant="destructive"
              size="sm"
              onClick={() => setDeleteOpen(true)}
              disabled={isDeleting}
            >
              <Trash2 className="ml-2 h-4 w-4" /> حذف
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
            )}{" "}
            حفظ
          </Button>
          <Button variant="ghost" size="sm" onClick={() => router.back()}>
            <X className="ml-2 h-4 w-4" /> إلغاء
          </Button>
        </div>
      </div>

      <div
        className="relative flex-1 overflow-hidden rounded-lg border bg-card"
        dir="ltr"
      >
        {nodes.length === 0 ? (
          <div className="flex h-full items-center justify-center">
            <div className="text-center" dir="rtl">
              <p className="mb-4 text-lg text-muted-foreground">
                لا توجد دورات في هذا المسار بعد. انقر على إضافة دورة للبدء ⚡
              </p>
              <Button
                onClick={() => setCourseDialogOpen(true)}
                disabled={availableCoursesToAdd.length === 0}
              >
                <Plus className="ml-2 h-4 w-4" /> إضافة دورة
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
            className="rf-fix bg-background"
            proOptions={{ hideAttribution: true }}
            connectionLineType={ConnectionLineType.SmoothStep}
          >
            <Background color="hsl(var(--muted-foreground) / 0.5)" gap={16} />
            <Controls
              className="!overflow-hidden !rounded-md !border !border-border shadow-sm"
              showInteractive={false}
            />
            <MiniMap
              nodeColor="hsl(var(--primary))"
              maskColor="hsl(var(--background)/0.5)"
              className="!rounded-md !border !border-border"
            />
          </ReactFlow>
        )}
      </div>

      <Dialog open={courseDialogOpen} onOpenChange={setCourseDialogOpen}>
        <DialogContent dir="rtl">
          <DialogHeader>
            <DialogTitle>إضافة دورة إلى المسار</DialogTitle>
          </DialogHeader>
          <div className="mt-2 max-h-64 space-y-2 overflow-y-auto">
            {availableCoursesToAdd.map((course) => (
              <button
                key={course.id}
                onClick={() => addCourseNode(course)}
                className="group flex w-full items-center justify-between rounded-lg border p-3 hover:bg-accent"
              >
                <p className="font-medium">{course.title}</p>
                <Check className="h-4 w-4 opacity-0 transition-opacity group-hover:opacity-100" />
              </button>
            ))}
          </div>
        </DialogContent>
      </Dialog>

      <Dialog open={deleteOpen} onOpenChange={setDeleteOpen}>
        <DialogContent dir="rtl">
          <DialogHeader>
            <DialogTitle className="text-right">تأكيد الحذف</DialogTitle>
            <DialogDescription className="text-right">
              إلغاء ورمي المسار بشكل نهائي؟ لن يمكن إسترجاعه.
            </DialogDescription>
          </DialogHeader>
          <div className="mt-4 flex justify-end gap-2">
            <Button
              variant="ghost"
              onClick={() => setDeleteOpen(false)}
              disabled={isDeleting}
            >
              إلغاء
            </Button>
            <Button
              variant="destructive"
              onClick={handleDeleteRoadmap}
              disabled={isDeleting}
            >
              حذف نهائي
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  )
}
