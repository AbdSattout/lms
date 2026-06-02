import "server-only"

type ApiMethod = (...args: never[]) => Promise<unknown>

type ApiMethods = Partial<
  Record<"get" | "post" | "patch" | "delete" | "put" | "options" | "head", ApiMethod>
>

export type ApiRoute<T extends ApiMethods> = T &
  (T["get"] extends ApiMethod
    ? (...args: Parameters<T["get"]>) => ReturnType<T["get"]>
    : unknown)

export type ApiTree = {
  [key: string]: ApiRoute<ApiMethods> | ApiTree
}

export function defineApiRoute<T extends ApiMethods>(methods: T) {
  return (
    methods.get ? Object.assign(methods.get, methods) : methods
  ) as ApiRoute<T>
}
