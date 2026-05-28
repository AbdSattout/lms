import "server-only"

type ApiMethod = (...args: never[]) => Promise<unknown>

type ApiMethods = {
  get: ApiMethod
} & Partial<Record<"post" | "patch" | "delete", ApiMethod>>

export type ApiRoute<T extends ApiMethods> = T & {
  (...args: Parameters<T["get"]>): ReturnType<T["get"]>
}

export type ApiTree = {
  [key: string]: ApiRoute<ApiMethods> | ApiTree
}

export function defineApiRoute<T extends ApiMethods>(methods: T): ApiRoute<T> {
  return Object.assign(
    (...args: Parameters<T["get"]>) => methods.get(...args),
    methods
  ) as ApiRoute<T>
}
