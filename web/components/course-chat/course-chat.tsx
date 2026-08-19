"use client"

import { useBreadcrumbTrailing } from "@/components/breadcrumb-context"
import {
  MessageBubble,
  formatMuteRemaining,
} from "@/components/course-chat/message-bubble"
import { MuteDialog } from "@/components/course-chat/mute-dialog"
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardFooter } from "@/components/ui/card"
import {
  Empty,
  EmptyContent,
  EmptyHeader,
  EmptyMedia,
  EmptyTitle,
} from "@/components/ui/empty"
import { ChatSkeleton } from "@/components/course-chat/chat-skeleton"
import { Textarea } from "@/components/ui/textarea"
import { usePusherChannel } from "@/hooks/use-pusher"
import {
  chatDeleteMessage,
  chatEditMessage,
  chatGetCourseConversation,
  chatGetMessages,
  chatGetMutes,
  chatMarkAsRead,
  chatMuteUser,
  chatSendMessage,
  chatUnmute,
} from "@/lib/api/chat-client"
import type {
  ChatMessageResponse,
  ChatMuteUserRequest,
  ConversationResponse,
  CourseResponse,
  User,
} from "@/lib/api/types"
import { cn } from "@/lib/utils"
import {
  AlertTriangle,
  ArrowDown,
  Loader,
  MessageCircle,
  Send,
  VolumeX,
  X,
} from "lucide-react"
import { useCallback, useEffect, useMemo, useRef, useState } from "react"
import { toast } from "sonner"

const PAGE_SIZE = 30

interface ActiveMute {
  muteId: number | null
  mutedUntil: string
}

function isMutedNow(mute: ActiveMute | undefined) {
  if (!mute) return false
  return new Date(mute.mutedUntil).getTime() > Date.now()
}

function upsertMessage(
  list: ChatMessageResponse[],
  message: ChatMessageResponse
) {
  const index = list.findIndex((m) => m.id === message.id)
  if (index >= 0) {
    const next = [...list]
    next[index] = message
    return next
  }
  return [...list, message]
}

export function CourseChat({
  course,
  currentUser,
  canMute,
  canDelete,
}: {
  course: CourseResponse
  currentUser: User
  canMute: boolean
  canDelete: boolean
}) {
  const [conversation, setConversation] = useState<ConversationResponse | null>(
    null
  )
  const [messages, setMessages] = useState<ChatMessageResponse[]>([])
  const [page, setPage] = useState(0)
  const [hasMore, setHasMore] = useState(false)
  const [loadingInitial, setLoadingInitial] = useState(true)
  const [loadingMore, setLoadingMore] = useState(false)
  const [loadError, setLoadError] = useState<string | null>(null)

  const [draft, setDraft] = useState("")
  const [editing, setEditing] = useState<ChatMessageResponse | null>(null)
  const [sending, setSending] = useState(false)

  const [mutes, setMutes] = useState<Record<number, ActiveMute>>({})
  const [muteTarget, setMuteTarget] = useState<ChatMessageResponse | null>(null)
  const [deleteTarget, setDeleteTarget] = useState<ChatMessageResponse | null>(
    null
  )

  const [showScrollButton, setShowScrollButton] = useState(false)

  const scrollRef = useRef<HTMLDivElement>(null)
  const atBottomRef = useRef(true)
  const messagesLengthRef = useRef(0)
  const textareaRef = useRef<HTMLTextAreaElement>(null)

  const channelName = conversation
    ? `private-conversation-${conversation.id}`
    : null
  const { connected, subscribe } = usePusherChannel(channelName)

  const currentUserMute = mutes[currentUser.id]
  const iAmMuted = isMutedNow(currentUserMute)

  const connectionStatus = useMemo(
    () => (
      <span
        className="flex items-center gap-1.5 text-xs text-muted-foreground"
        title={connected ? "متصل" : "جارٍ الاتصال"}
      >
        <span
          className={cn(
            "size-2 rounded-full",
            connected ? "bg-emerald-500" : "bg-muted-foreground/40"
          )}
        />
        {connected ? "متصل" : "جارٍ الاتصال..."}
      </span>
    ),
    [connected]
  )
  useBreadcrumbTrailing(connectionStatus)

  async function loadConversation() {
    setLoadingInitial(true)
    setLoadError(null)
    const res = await chatGetCourseConversation(course.id)
    if (res.error || !res.data) {
      setLoadError(res.error ?? "تعذر تحميل المحادثة")
      setLoadingInitial(false)
      return
    }
    setConversation(res.data)
    const messagesRes = await chatGetMessages(res.data.id, 0, PAGE_SIZE)
    if (messagesRes.error || !messagesRes.data) {
      setLoadError(messagesRes.error ?? "تعذر تحميل الرسائل")
      setLoadingInitial(false)
      return
    }
    const content = messagesRes.data.content ?? []
    setMessages([...content].reverse())
    setHasMore(!messagesRes.data.last)
    setPage(0)
    setLoadingInitial(false)
    if (content.length > 0) {
      void chatMarkAsRead(res.data.id, content[0].id)
    }
    void loadMutes(res.data.id)
  }

  async function loadMutes(conversationId: number) {
    const res = await chatGetMutes(conversationId)
    if (res.error || !res.data) return
    const next: Record<number, ActiveMute> = {}
    for (const mute of res.data) {
      next[mute.userId] = { muteId: mute.id, mutedUntil: mute.mutedUntil }
    }
    setMutes(next)
  }

  useEffect(() => {
    void loadConversation()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [course.id])

  useEffect(() => {
    if (!conversation) return
    const unsubscribers = [
      subscribe("message.created", (data) => {
        const message = data as ChatMessageResponse
        setMessages((prev) => upsertMessage(prev, message))
        if (message.senderId !== currentUser.id) {
          void chatMarkAsRead(conversation.id, message.id)
        }
      }),
      subscribe("message.updated", (data) => {
        const message = data as ChatMessageResponse
        setMessages((prev) => upsertMessage(prev, message))
      }),
      subscribe("message.deleted", (data) => {
        const { messageId } = data as { messageId: number }
        setMessages((prev) =>
          prev.map((m) =>
            m.id === messageId
              ? { ...m, deletedAt: new Date().toISOString(), content: null }
              : m
          )
        )
      }),
      subscribe("member.muted", (data) => {
        const { userId, mutedUntil } = data as {
          userId: number
          mutedUntil: string
        }
        setMutes((prev) => ({
          ...prev,
          [userId]: { muteId: null, mutedUntil },
        }))
      }),
      subscribe("member.unmuted", (data) => {
        const { userId } = data as { userId: number }
        setMutes((prev) => {
          const next = { ...prev }
          delete next[userId]
          return next
        })
      }),
    ]
    return () => unsubscribers.forEach((unsubscribe) => unsubscribe())
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [conversation?.id])

  // Auto-scroll to the bottom when new messages arrive, unless the user
  // scrolled up.
  useEffect(() => {
    const el = scrollRef.current
    if (!el) return
    const newLength = messages.length
    const isInitial = messagesLengthRef.current === 0 && newLength > 0
    const appended = newLength > messagesLengthRef.current
    messagesLengthRef.current = newLength

    if (appended && atBottomRef.current) {
      requestAnimationFrame(() => {
        el.scrollTop = el.scrollHeight
      })
    }
    if (isInitial) {
      requestAnimationFrame(() => {
        el.scrollTop = el.scrollHeight
      })
    }
  }, [messages.length])

  async function loadMore() {
    if (!conversation || loadingMore || !hasMore) return
    setLoadingMore(true)
    const nextPage = page + 1
    const res = await chatGetMessages(conversation.id, nextPage, PAGE_SIZE)
    if (res.data) {
      const older = [...(res.data.content ?? [])].reverse()
      const el = scrollRef.current
      const prevHeight = el?.scrollHeight ?? 0
      setMessages((prev) => [...older, ...prev])
      setHasMore(!res.data.last)
      setPage(nextPage)
      requestAnimationFrame(() => {
        const node = scrollRef.current
        if (node) node.scrollTop = node.scrollHeight - prevHeight
      })
    } else if (res.error) {
      toast.error(res.error)
    }
    setLoadingMore(false)
  }

  function handleScroll() {
    const el = scrollRef.current
    if (!el) return
    const distanceFromBottom = el.scrollHeight - el.scrollTop - el.clientHeight
    atBottomRef.current = distanceFromBottom < 100
    setShowScrollButton(distanceFromBottom > 100)
    if (el.scrollTop < 60 && hasMore && !loadingMore) {
      void loadMore()
    }
  }

  const handleSend = useCallback(
    async (content: string) => {
      if (!conversation || !content.trim() || sending || iAmMuted) return
      const text = content.trim()
      setSending(true)

      try {
        if (editing) {
          const res = await chatEditMessage(conversation.id, editing.id, text)
          if (res.data) {
            setMessages((prev) => upsertMessage(prev, res.data!))
            setDraft("")
            setEditing(null)
          } else {
            toast.error(res.error ?? "تعذر تعديل الرسالة")
          }
          return
        }

        const res = await chatSendMessage(conversation.id, text)
        if (res.data) {
          setDraft("")
          setMessages((prev) => upsertMessage(prev, res.data!))
        } else if (res.mutedUntil) {
          setMutes((prev) => ({
            ...prev,
            [currentUser.id]: { muteId: null, mutedUntil: res.mutedUntil! },
          }))
          toast.error("لقد تم كتمك في هذه الدورة")
        } else {
          toast.error(res.error ?? "تعذر إرسال الرسالة")
        }
      } finally {
        setSending(false)
      }
    },
    [conversation, editing, sending, iAmMuted, currentUser.id]
  )

  useEffect(() => {
    if (!sending) textareaRef.current?.focus()
  }, [sending])

  async function handleDelete() {
    if (!conversation || !deleteTarget) return
    const target = deleteTarget
    setDeleteTarget(null)
    const res = await chatDeleteMessage(conversation.id, target.id)
    if (res.error) {
      toast.error(res.error ?? "تعذر حذف الرسالة")
      return
    }
    setMessages((prev) =>
      prev.map((m) =>
        m.id === target.id
          ? { ...m, deletedAt: new Date().toISOString(), content: null }
          : m
      )
    )
    toast.success("تم حذف الرسالة")
  }

  async function handleMute(durationMinutes: number, reason: string) {
    if (!conversation || !muteTarget) return
    const request: ChatMuteUserRequest = {
      userId: muteTarget.senderId,
      courseId: course.id,
      conversationId: conversation.id,
      durationMinutes,
      reason: reason || undefined,
    }
    const res = await chatMuteUser(request)
    if (res.data) {
      setMutes((prev) => ({
        ...prev,
        [muteTarget.senderId]: {
          muteId: res.data!.id,
          mutedUntil: res.data!.mutedUntil,
        },
      }))
      toast.success("تم كتم المستخدم")
    } else {
      toast.error(res.error ?? "تعذر كتم المستخدم")
    }
  }

  async function handleUnmute(target: ChatMessageResponse) {
    const mute = mutes[target.senderId]
    if (!mute?.muteId) {
      toast.error("لا يمكن رفع الكتم لهذا المستخدم")
      return
    }
    const res = await chatUnmute(mute.muteId)
    if (res.error) {
      toast.error(res.error ?? "تعذر رفع الكتم")
      return
    }
    setMutes((prev) => {
      const next = { ...prev }
      delete next[target.senderId]
      return next
    })
    toast.success("تم رفع الكتم")
  }

  if (loadingInitial) return <ChatSkeleton />

  return (
    <Card className="absolute inset-0 flex h-[calc(100dvh-var(--spacing)*20)] flex-col gap-0 overflow-hidden py-0 md:h-[calc(100dvh-var(--spacing)*28)]">
      <CardContent
        ref={scrollRef}
        onScroll={handleScroll}
        className="flex min-h-0 flex-1 flex-col gap-3 overflow-y-auto px-4 py-4"
      >
        {loadError ? (
          <Empty>
            <EmptyHeader>
              <EmptyMedia variant="icon">
                <AlertTriangle />
              </EmptyMedia>
              <EmptyTitle>تعذر تحميل المحادثة</EmptyTitle>
            </EmptyHeader>
            <EmptyContent>{loadError}</EmptyContent>
            <Button onClick={() => void loadConversation()}>
              إعادة المحاولة
            </Button>
          </Empty>
        ) : (
          <>
            {hasMore && (
              <div className="flex justify-center py-1">
                <Button
                  variant="ghost"
                  size="sm"
                  disabled={loadingMore}
                  onClick={() => void loadMore()}
                >
                  {loadingMore ? (
                    <Loader className="size-4 animate-spin" />
                  ) : (
                    "تحميل المزيد"
                  )}
                </Button>
              </div>
            )}

            {messages.length === 0 ? (
              <Empty>
                <EmptyHeader>
                  <EmptyMedia variant="icon">
                    <MessageCircle />
                  </EmptyMedia>
                  <EmptyTitle>لا توجد رسائل بعد</EmptyTitle>
                </EmptyHeader>
                <EmptyContent>ابدأ المحادثة وأرسل أول رسالة الآن</EmptyContent>
              </Empty>
            ) : (
              messages.map((message) => {
                const isSent = message.senderId === currentUser.id
                const mute = mutes[message.senderId]
                const muted = isMutedNow(mute)
                return (
                  <MessageBubble
                    key={message.id}
                    message={message}
                    isSent={isSent}
                    muted={muted}
                    canMute={canMute}
                    canDelete={canDelete}
                    onEdit={() => {
                      if (isSent && !message.deletedAt) {
                        setEditing(message)
                        setDraft(message.content ?? "")
                      }
                    }}
                    onDelete={() => {
                      if (!message.deletedAt && (isSent || canDelete)) {
                        setDeleteTarget(message)
                      }
                    }}
                    onMute={() => setMuteTarget(message)}
                    onUnmute={() => void handleUnmute(message)}
                  />
                )
              })
            )}
          </>
        )}
      </CardContent>

      <CardFooter className="px-4 py-3">
        <form
          onSubmit={(e) => {
            e.preventDefault()
            void handleSend(draft)
          }}
          className="relative grid w-full gap-1"
        >
          {iAmMuted && currentUserMute && (
            <div className="flex w-full items-center gap-2 rounded-2xl bg-destructive/10 px-3 py-2 text-sm text-destructive">
              <VolumeX className="size-4 shrink-0" />
              <span>
                تم كتمك حتى {formatMuteRemaining(currentUserMute.mutedUntil)}
              </span>
            </div>
          )}
          {editing && (
            <div className="flex w-full items-center gap-2 rounded-2xl bg-primary/10 px-3 py-2 text-sm">
              <span className="min-w-0 flex-1 truncate text-muted-foreground">
                تعديل الرسالة: {editing.content}
              </span>
              <Button
                variant="ghost"
                size="icon-xs"
                type="button"
                onClick={() => {
                  setEditing(null)
                  setDraft("")
                }}
              >
                <X className="size-3.5" />
                <span className="sr-only">إلغاء التعديل</span>
              </Button>
            </div>
          )}
          <Textarea
            ref={textareaRef}
            value={draft}
            onChange={(e) => setDraft(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Enter" && !e.shiftKey) {
                e.preventDefault()
                void handleSend(draft)
              }
            }}
            placeholder="اكتب رسالتك..."
            disabled={loadingInitial || iAmMuted || sending}
            aria-disabled={sending}
            className="max-h-40 min-h-12 flex-1 resize-none rounded-4xl pe-10!"
            autoFocus
          />
          <Button
            type="submit"
            size="icon"
            disabled={!draft.trim() || loadingInitial || sending || iAmMuted}
            aria-label="إرسال"
            className="absolute end-2 top-[calc(100%-0.5rem)] size-8 -translate-y-full rounded-full"
          >
            {sending ? (
              <Loader className="size-3.5 animate-spin" />
            ) : (
              <Send className="size-3.5" />
            )}
          </Button>
          {showScrollButton && (
            <Button
              type="button"
              variant="secondary"
              size="icon"
              onClick={() =>
                scrollRef.current?.scrollTo({
                  top: scrollRef.current.scrollHeight,
                  behavior: "smooth",
                })
              }
              className="absolute bottom-[calc(100%+1.5rem)] left-1/2 -translate-x-1/2 rounded-full shadow-md"
              aria-label="الانتقال إلى الأسفل"
            >
              <ArrowDown />
            </Button>
          )}
        </form>
      </CardFooter>

      <MuteDialog
        open={!!muteTarget}
        onOpenChange={(open) => {
          if (!open) setMuteTarget(null)
        }}
        userName={muteTarget?.senderName ?? ""}
        onConfirm={handleMute}
      />

      <AlertDialog
        open={!!deleteTarget}
        onOpenChange={(open) => {
          if (!open) setDeleteTarget(null)
        }}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>حذف الرسالة</AlertDialogTitle>
            <AlertDialogDescription>
              هل أنت متأكد من حذف هذه الرسالة؟ لا يمكن التراجع عن هذا الإجراء.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>إلغاء</AlertDialogCancel>
            <AlertDialogAction onClick={() => void handleDelete()}>
              حذف
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </Card>
  )
}
