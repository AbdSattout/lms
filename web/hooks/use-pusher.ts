"use client"

import type Pusher from "pusher-js"
import { useCallback, useEffect, useRef, useState } from "react"

import { chatPusherAuth } from "@/lib/api/chat-client"

type EventHandler = (data: unknown) => void

/**
 * Subscribes to a Pusher channel (e.g. `private-conversation-123`).
 *
 * The channel is authorized through the backend `/chat/pusher/auth`
 * endpoint using the caller's backend JWT.
 *
 * Returns a stable `subscribe(event, handler)` function that registers a
 * handler and returns a cleanup function. `connected` reflects the current
 * Pusher connection state.
 */
export function usePusherChannel(channelName: string | null) {
  const pusherRef = useRef<Pusher | null>(null)
  const listenersRef = useRef<Map<string, Set<EventHandler>>>(new Map())
  const [connected, setConnected] = useState(false)

  useEffect(() => {
    if (!channelName) {
      setConnected(false)
      return
    }

    let disposed = false
    let pusher: Pusher | null = null

    void (async () => {
      const PusherModule = (await import("pusher-js")).default
      if (disposed) return

      const key = process.env.NEXT_PUBLIC_PUSHER_KEY
      const cluster = process.env.NEXT_PUBLIC_PUSHER_CLUSTER
      if (!key || !cluster) return

      pusher = new PusherModule(key, {
        cluster,
        enableStats: false,
        channelAuthorization: {
          customHandler: (params, callback) => {
            void chatPusherAuth(params.socketId, params.channelName).then(
              (result) => {
                if (result.data?.auth) {
                  callback(null, { auth: result.data.auth })
                } else {
                  callback(
                    new Error(result.error ?? "Pusher authorization failed"),
                    null
                  )
                }
              }
            )
          },
        },
      })

      pusher.connection.bind("connected", () => {
        if (!disposed) setConnected(true)
      })
      pusher.connection.bind("disconnected", () => {
        if (!disposed) setConnected(false)
      })

      const channel = pusher.subscribe(channelName)
      pusherRef.current = pusher

      channel.bind_global((event: string, data: unknown) => {
        listenersRef.current.get(event)?.forEach((handler) => handler(data))
      })

      if (!disposed) setConnected(pusher.connection.state === "connected")
    })()

    return () => {
      disposed = true
      const pusher = pusherRef.current
      pusherRef.current = null
      if (pusher) {
        pusher.unsubscribe(channelName)
        pusher.disconnect()
      }
      setConnected(false)
    }
  }, [channelName])

  const subscribe = useCallback((event: string, handler: EventHandler) => {
    let set = listenersRef.current.get(event)
    if (!set) {
      set = new Set()
      listenersRef.current.set(event, set)
    }
    set.add(handler)
    return () => {
      set.delete(handler)
    }
  }, [])

  return { connected, subscribe }
}
