import "server-only"

type ApiMethod = (...args: never[]) => Promise<unknown>

type ApiMethods = Partial<
  Record<"get" | "post" | "patch" | "delete", ApiMethod>
>

export type ApiRoute<T extends ApiMethods> = T &
  (T["get"] extends ApiMethod
    ? (...args: Parameters<T["get"]>) => ReturnType<T["get"]>
    : unknown)

export type ApiTree = {
  [key: string]: ApiRoute<ApiMethods> | ApiTree
}

export function defineApiRoute<T extends ApiMethods>(methods: T): ApiRoute<T> {
  if (!methods.get) return methods as ApiRoute<T>
  return Object.assign(
    (...args: Parameters<NonNullable<T["get"]>>) => methods.get!(...args),
    methods
  ) as ApiRoute<T>
}
