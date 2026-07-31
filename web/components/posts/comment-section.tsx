"use client"

import { CommentItem } from "@/components/posts/comment-item"
import type { CommentResponse } from "@/lib/api/types"
import { useMemo } from "react"

interface CommentSectionProps {
  comments: CommentResponse[]
  onReply: (commentId: number, authorName: string) => void
  onCommentDeleted: (commentId: number) => void
}

interface CommentNode extends CommentResponse {
  replies: CommentNode[]
}

export function CommentSection({
  comments,
  onReply,
  onCommentDeleted,
}: CommentSectionProps) {
  const commentTree = useMemo(() => {
    const map = new Map<number, CommentNode>()
    const roots: CommentNode[] = []

    for (const comment of comments) {
      map.set(comment.id, { ...comment, replies: [] })
    }

    for (const comment of comments) {
      const node = map.get(comment.id)!
      if (comment.parentCommentId && map.has(comment.parentCommentId)) {
        const parent = map.get(comment.parentCommentId)!
        parent.replies.push(node)
      } else {
        roots.push(node)
      }
    }

    return roots
  }, [comments])

  if (comments.length === 0) {
    return (
      <div className="py-8 text-center text-muted-foreground">
        <p>لا توجد تعليقات بعد. كن أول من يعلق!</p>
      </div>
    )
  }

  return (
    <div className="flex flex-col gap-2">
      <h3 className="mb-2 text-lg font-semibold">
        التعليقات ({comments.length})
      </h3>
      {commentTree.map((node) => (
        <CommentNodeRenderer
          key={node.id}
          node={node}
          onReply={onReply}
          onCommentDeleted={onCommentDeleted}
          depth={0}
        />
      ))}
    </div>
  )
}

function CommentNodeRenderer({
  node,
  onReply,
  onCommentDeleted,
  depth,
}: {
  node: CommentNode
  onReply: (commentId: number, authorName: string) => void
  onCommentDeleted: (commentId: number) => void
  depth: number
}) {
  return (
    <div className={depth > 0 ? "border-r-2 border-muted pr-4" : ""}>
      <CommentItem
        comment={node}
        onReply={onReply}
        onCommentDeleted={onCommentDeleted}
      />
      {node.replies.length > 0 && (
        <div className="mt-2 flex flex-col gap-2">
          {node.replies.map((reply) => (
            <CommentNodeRenderer
              key={reply.id}
              node={reply}
              onReply={onReply}
              onCommentDeleted={onCommentDeleted}
              depth={depth + 1}
            />
          ))}
        </div>
      )}
    </div>
  )
}
